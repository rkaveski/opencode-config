import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const boolTrueValues = new Set(["1", "true", "yes", "on"]);

const mcpNameSourcebot = "sourcebot";
const mcpNameSourcebotSecondary = "sourcebot-secondary";
const mcpNameContext7 = "context7";
const mcpNameAtlassian = "atlassian";
const mcpNameFigma = "figma";
const mcpNameChromeDevtools = "chrome-devtools";
const mcpNameWorkspaceDocs = "workspace_docs";

const pluginNameTrueMem = "true-mem";
const instructionPathSourcebotFirst = "./instructions/sourcebot-first.md";

const localCommandType = "local";
const remoteCommandType = "remote";
const sourcebotDefaultUrl = "http://localhost:3000/api/mcp";
const sourcebotSecondaryDefaultUrl = "http://localhost:3001/api/mcp";
const browserUrlArgument = "--browser-url=";
const noUsageStatisticsArgument = "--no-usage-statistics";

const defaultConfigHome = path.join(process.env.HOME ?? "", ".config");
const configHome = process.env.XDG_CONFIG_HOME || defaultConfigHome;
const installDir = process.env.OPENCODE_INSTALL_DIR || path.join(configHome, "opencode");
const binDir = path.join(installDir, "bin");
const outputFilePath = process.argv[2] || path.join(installDir, "opencode.json");
const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(scriptDirectory, "..");
const templatePath = path.join(repoRoot, "templates", "opencode.json.template");

const readBool = (name, fallback = false) => {
  const rawValue = process.env[name];
  if (rawValue == null || rawValue === "") {
    return fallback;
  }

  return boolTrueValues.has(rawValue.toLowerCase());
};

const ensureParentDir = (filePath) => {
  mkdirSync(path.dirname(filePath), { recursive: true });
};

const buildLocalCommand = (fileName) => [path.join(binDir, fileName)];

const config = JSON.parse(readFileSync(templatePath, "utf8"));
const hasSourcebotEnabled = readBool("ENABLE_SOURCEBOT", false) || readBool("ENABLE_SOURCEBOT_SECONDARY", false);

config.model = process.env.OPENCODE_DEFAULT_MODEL || config.model;
config.plugin = readBool("ENABLE_TRUE_MEM", true) ? [pluginNameTrueMem] : [];
config.instructions = config.instructions.filter((instructionPath) => instructionPath !== instructionPathSourcebotFirst);

if (hasSourcebotEnabled) {
  config.instructions.unshift(instructionPathSourcebotFirst);
}

config.mcp = {
  [mcpNameAtlassian]: {
    type: remoteCommandType,
    url: "https://mcp.atlassian.com/v1/mcp",
    oauth: {},
  },
  [mcpNameFigma]: {
    type: remoteCommandType,
    url: "https://mcp.figma.com/mcp",
    enabled: readBool("ENABLE_FIGMA", false),
  },
};

if (readBool("ENABLE_SOURCEBOT", false)) {
  config.mcp[mcpNameSourcebot] = {
    type: remoteCommandType,
    url: process.env.SOURCEBOT_MCP_URL || sourcebotDefaultUrl,
    enabled: true,
    oauth: false,
  };
}

if (readBool("ENABLE_SOURCEBOT_SECONDARY", false)) {
  config.mcp[mcpNameSourcebotSecondary] = {
    type: remoteCommandType,
    url: process.env.SOURCEBOT_SECONDARY_MCP_URL || sourcebotSecondaryDefaultUrl,
    enabled: true,
    oauth: false,
  };
}

if (readBool("ENABLE_CONTEXT7", false)) {
  config.mcp[mcpNameContext7] = {
    type: localCommandType,
    timeout: 120000,
    command: buildLocalCommand("run-context7-mcp.sh"),
    enabled: true,
  };
}

if (readBool("ENABLE_CHROME_DEVTOOLS", false)) {
  const browserUrl = process.env.CHROME_DEVTOOLS_BROWSER_URL || "http://127.0.0.1:9222";
  config.mcp[mcpNameChromeDevtools] = {
    type: localCommandType,
    timeout: 120000,
    command: ["npx", "-y", "chrome-devtools-mcp@latest", `${browserUrlArgument}${browserUrl}`, noUsageStatisticsArgument],
    enabled: true,
  };
}

if (readBool("ENABLE_WORKSPACE_DOCS", false)) {
  config.mcp[mcpNameWorkspaceDocs] = {
    type: localCommandType,
    timeout: 600000,
    command: buildLocalCommand("run-workspace-docs-mcp.sh"),
    enabled: true,
    environment: {
      WORKSPACE_DOCS_ENABLE_IMAGE_OCR: process.env.WORKSPACE_DOCS_ENABLE_IMAGE_OCR || "false",
    },
  };
}

config.agent.build.model = process.env.OPENCODE_BUILD_MODEL || config.agent.build.model;
config.agent.build.variant = process.env.OPENCODE_BUILD_VARIANT || config.agent.build.variant;
config.agent.plan.model = process.env.OPENCODE_PLAN_MODEL || config.agent.plan.model;
config.agent.plan.variant = process.env.OPENCODE_PLAN_VARIANT || config.agent.plan.variant;
config.provider["github-copilot"].options.timeout =
  Number(process.env.OPENCODE_PROVIDER_TIMEOUT_MS || config.provider["github-copilot"].options.timeout);

ensureParentDir(outputFilePath);
writeFileSync(outputFilePath, `${JSON.stringify(config, null, 2)}\n`);
