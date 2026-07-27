# OpenCode + Oh My OpenCode Nix 配置指南

本文档详细介绍如何在 Nix/NixOS 环境中配置和使用 OpenCode AI 编程助手及其增强插件 Oh My OpenCode。

## 📋 概述

| 项目 | 说明 | Nix 支持状态 |
|------|------|-------------|
| **OpenCode** | 开源 AI 编程助手，支持终端 TUI 和桌面应用 | ✅ nixpkgs 可用 |
| **Oh My OpenCode** | OpenCode 的增强插件，提供多 Agent 协作工作流 | ⚠️ 需通过 npm/bun 安装 |

---

## 🔧 Nix 支持详情

### OpenCode

- **nixpkgs**: `opencode` 包在 nixpkgs unstable 中可用
- **运行方式**: `nix run nixpkgs#opencode`
- **第三方 Flake**: `github:numtide/llm-agents.nix` 也提供 opencode 包
- **Home Manager**: ⚠️ 无原生模块，通过 `home.packages` 安装

### Oh My OpenCode

- **Nix 包**: ❌ 无原生 Nix 包
- **安装方式**: 通过 npm (`npx`) 或 bun (`bunx`) 安装
- **安装命令**: `bunx oh-my-opencode install`
- **配置管理**: ✅ 可以通过 Nix 管理配置文件

---

## 📦 安装配置

### 自动配置（已包含在 dotfiles）

```bash
cd ~/dotfiles/nix
home-manager switch --flake .#leoyzen
```

这会自动安装：
- `opencode` 主程序
- `bun` 和 `nodejs`（oh-my-opencode 的依赖）
- 所有配置文件（opencode.jsonc, oh-my-opencode.jsonc 等）
- Shell 补全支持

### 手动安装 oh-my-opencode

```bash
# 初次使用需要安装 oh-my-opencode 插件
install-oh-my-opencode

# 或者手动安装
bunx oh-my-opencode install
# 或
npx oh-my-opencode install
```

---

## 🗂️ 配置文件结构

```
~/.config/opencode/
├── opencode.jsonc          # 主配置文件（模型、MCP、Agent）
├── oh-my-opencode.jsonc    # oh-my-opencode 配置
├── antigravity.json        # Antigravity 认证配置
├── rootcloud-models.json   # 自定义模型配置
├── command/                # 自定义命令
└── skill/                  # 技能文件
```

### 配置管理策略

```nix
# nix/home-manager/modules/ai-tools.nix

# OpenCode 主配置（从 dotfiles 仓库引用）
xdg.configFile."opencode/opencode.jsonc".source = 
  ../../../../opencode/opencode.jsonc;

# oh-my-opencode 配置
xdg.configFile."opencode/oh-my-opencode.jsonc".source = 
  ../../../../opencode/oh-my-opencode.jsonc;
```

---

## ⚙️ 核心配置说明

### OpenCode 主配置 (opencode.jsonc)

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  
  // 启用的插件
  "plugin": [
    "oh-my-opencode",
    "opencode-antigravity-auth@beta",
    "@tarquinen/opencode-dcp@latest"
  ],
  
  // 默认模型
  "model": "wolf-ai/ack-dev",
  
  // MCP 服务器配置
  "mcp": {
    "mcp-router": {
      "type": "local",
      "command": ["npx", "-y", "@mcp_router/cli@latest", "connect"],
      "environment": {
        "MCPR_TOKEN": "{env:MCPR_TOKEN}"
      }
    }
  },
  
  // 启用的 Provider
  "enabled_providers": ["wolf-ai", "antigravity"],
  
  // 工具权限
  "tools": {
    "write": true,
    "bash": true,
    "read": true,
    "edit": true
  },
  
  // Agent 配置
  "agent": {
    "build": {
      "mode": "primary",
      "model": "wolf-ai/glm-4.7"
    },
    "plan": {
      "mode": "primary",
      "model": "google/antigravity-gemini-3.1-pro"
    }
  }
}
```

### Oh My OpenCode 配置 (oh-my-opencode.jsonc)

```jsonc
{
  "$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json",
  
  // Agent 覆盖配置
  "agentOverrides": {
    "hephaestus": {
      "model": "wolf-ai/ack-dev"
    }
  },
  
  // Agent 定义
  "agents": {
    "sisyphus": {
      "model": "wolf-ai/ack-dev"
    },
    "metis": {
      "model": "antigravity-claude-opus-4-6-thinking",
      "variant": "max"
    },
    "momus": {
      "model": "google/antigravity-gemini-3-flash",
      "variant": "max"
    }
  },
  
  // 任务分类
  "categories": {
    "quick": {
      "model": "wolf-ai/ack-dev"
    },
    "deep": {
      "model": "wolf-ai/ack-dev"
    }
  },
  
  // Tmux 集成
  "tmux": {
    "enabled": true,
    "layout": "even-vertical"
  }
}
```

---

## 🚀 使用方法

### 基本命令

```bash
# 启动 OpenCode
opencode

# 使用特定 skill
opencode --skill <skill-name>

# 使用缩写（已配置）
oc                    # 等同于 opencode
ocs <skill-name>      # 等同于 opencode --skill
```

### Agent 模式

Oh My OpenCode 提供多种 Agent 模式：

| Agent | 用途 | 默认模型 |
|-------|------|----------|
| **sisyphus** | 默认日常开发 | wolf-ai/ack-dev |
| **sisyphus-junior** | 轻量级任务 | wolf-ai/ack-dev |
| **metis** | 深度推理 | Claude Opus 4.6 Thinking |
| **momus** | 快速响应 | Gemini 3 Flash |
| **prometheus** | 代码审查 | wolf-ai/ack-dev |
| **atlas** | 架构规划 | wolf-ai/ack-dev |
| **oracle** | 问题诊断 | wolf-ai/ack-dev |
| **librarian** | 文档管理 | wolf-ai/ack-dev |

### 常用操作

```bash
# 启动默认 Agent
opencode

# 运行特定任务
opencode "分析当前目录代码结构"

# 使用特定类别
opencode --category deep "进行深度代码审查"

# Tmux 模式下运行后台任务
opencode --port  # 启动服务器模式
```

---

## 🔐 环境变量配置

某些功能需要设置环境变量（建议放在 `~/.config/fish/config.fish` 或 `~/.bashrc`）：

```bash
# MCP 路由器令牌（可选）
export MCPR_TOKEN="your-mcp-router-token"

# Context7 API 密钥（可选）
export CONTEXT7_API_KEY="your-context7-api-key"

# Antigravity 认证（如果使用）
export ANTIGRAVITY_API_KEY="your-antigravity-key"
```

**注意**: 不要将敏感密钥提交到 Git 仓库，使用本地配置文件：

```nix
# ~/.config/home-manager/local.nix（不在版本控制中）
{
  home.sessionVariables = {
    MCPR_TOKEN = "your-token";
  };
}
```

---

## 🐛 故障排除

### OpenCode 找不到命令

```bash
# 确保 opencode 在 PATH 中
which opencode

# 如果未找到，重新应用 Home Manager 配置
home-manager switch --flake .#leoyzen
```

### oh-my-opencode 未生效

```bash
# 检查是否已安装
ls ~/.local/share/opencode/plugins/

# 重新安装
install-oh-my-opencode

# 或
bunx oh-my-opencode install

# 重启 opencode
```

### MCP 服务器连接失败

- 检查 `MCPR_TOKEN` 环境变量是否设置
- 检查网络连接
- 查看 opencode 日志获取详细错误

### LSP 支持（Marksman）

```bash
# 确保 marksman 已安装
which marksman

# 手动安装（如果通过 Nix 未成功）
nix run nixpkgs#marksman
```

---

## 📝 配置更新流程

1. **修改配置文件**（在 `dotfiles/opencode/` 目录）

2. **应用配置**：
   ```bash
   cd ~/dotfiles/nix
   home-manager switch --flake .#leoyzen
   ```

3. **重启 opencode** 以加载新配置

---

## 🔄 与其他 AI 工具对比

| 特性 | OpenCode | Claude Code | Aider |
|------|----------|-------------|-------|
| **开源** | ✅ 完全开源 | ❌ 闭源 | ✅ 开源 |
| **Nix 支持** | ✅ nixpkgs | ❌ 无 | ⚠️ 需手动安装 |
| **多模型** | ✅ 支持 | ❌ Claude  only | ✅ 支持 |
| **Oh My** | ✅ 插件增强 | ❌ 无 | ❌ 无 |
| **本地模型** | ✅ 支持 | ❌ 不支持 | ✅ 支持 |

---

## 📚 相关资源

- [OpenCode 官网](https://opencode.ai/)
- [OpenCode GitHub](https://github.com/sst/opencode)
- [Oh My OpenCode 文档](https://github.com/code-yeongyu/oh-my-opencode)
- [Oh My OpenCode 配置参考](https://github.com/code-yeongyu/oh-my-opencode/blob/dev/docs/reference/configuration.md)
- [Nix LLM Agents](https://github.com/numtide/llm-agents.nix)

---

## ⚠️ 已知限制

1. **oh-my-opencode 非纯 Nix**
   - 需要通过 npm/bun 安装
   - 安装后会写入 `~/.local/share/opencode/`

2. **Node 依赖**
   - MCP Router 和某些插件依赖 Node.js
   - 已自动安装 `nodejs` 和 `bun`

3. **API 密钥管理**
   - 敏感信息需要通过环境变量或本地配置管理
   - 不要提交到 Git 仓库

4. **Tmux 集成**
   - 需要先在终端启动 tmux
   - 然后运行 `opencode --port`

---

## 💡 高级用法

### 自定义 Skill

在 `dotfiles/opencode/skill/` 目录添加自定义 skill，会自动同步到 `~/.config/opencode/skill/`。

### 多机器同步

由于配置通过 Nix 管理，在不同机器上使用相同的配置：

```bash
# 机器 A
home-manager switch --flake .#leoyzen

# 机器 B
home-manager switch --flake .#leoyzen
```

### 与 VS Code/Cursor 共存

OpenCode 可以与 VS Code、Cursor 等编辑器共存：

```bash
# 使用 OpenCode 进行批量重构
opencode "重构整个项目的错误处理"

# 使用 VS Code 进行精细编辑
code .
```

---

如有问题或需要更多帮助，请查看 [OpenCode Discord 社区](https://discord.gg/opencode) 或提交 GitHub Issue。