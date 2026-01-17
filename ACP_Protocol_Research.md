# Agent Client Protocol (ACP) 深度调研

> **免责声明**: ACP（Agent Client Protocol）与 IBM 的 Agent Communication Protocol 是两个不同的协议。本文档仅讨论 Agent Client Protocol（由 Zed Industries 主导）。

## 目录

- [核心概念](#核心概念)
- [架构与通信模型](#架构与通信模型)
- [生命周期](#生命周期)
- [工具系统详解](#工具系统详解)
- [用户交互工具传递](#用户交互工具传递)
- [MCP 集成](#mcp-集成)
  - [客户端提供 MCP 服务器详解](#客户端提供-mcp-服务器详解)
- [创建 MCP 服务器](#创建-mcp-服务器)
  - [MCP 服务器开发概览](#mcp-服务器开发概览)
  - [Python MCP 服务器实现](#python-mcp-服务器实现)
  - [TypeScript MCP 服务器实现](#typescript-mcp-服务器实现)
  - [MCP 服务器最佳实践](#mcp-服务器最佳实践)
- [自定义工具实现](#自定义工具实现)
- [扩展机制](#扩展机制)
- [实现参考](#实现参考)

---

## 核心概念

### 什么是 ACP？

**Agent Client Protocol (ACP)** 是一个标准化通信协议，用于代码编辑器/IDE 与 AI 编码代理之间的通信。它的目标是解决以下问题：

- **集成开销**：每个新代理-编辑器组合都需要自定义集成
- **兼容性有限**：代理只能在部分可用编辑器中工作
- **厂商锁定**：选择某个代理意味着接受其可用的接口

ACP 类似于 LSP（Language Server Protocol），它提供了一个标准化的协议，使得实现 ACP 的代理可以与任何兼容的编辑器协同工作。

### 设计理念

ACP 假设用户主要在编辑器中工作，并希望使用代理来协助完成特定任务。该协议适用于本地和远程场景：

- **本地代理**：作为编辑器的子进程运行，通过 stdio 上的 JSON-RPC 通信
- **远程代理**：可以在云端或独立基础设施上托管，通过 HTTP 或 WebSocket 通信

### 协议特点

- 基于 **JSON-RPC 2.0** 规范
- 两种消息类型：
  - **Methods（方法）**：请求-响应对，期望结果或错误
  - **Notifications（通知）**：单向消息，不需要响应
- 默认格式使用 Markdown，允许灵活的富文本表示

---

## 架构与通信模型

### 角色定义

#### Agent（代理）

代理是使用生成式 AI 自主修改代码的程序。它们通常作为客户端的子进程运行。

**Agent 基准方法**：
- `initialize` - 协商版本并交换能力
- `authenticate` - 认证（如需要）
- `session/new` - 创建新会话
- `session/prompt` - 发送用户提示

**Agent 可选方法**：
- `session/load` - 加载现有会话（需要 `loadSession` 能力）
- `session/set_mode` - 切换代理操作模式

**Agent 通知**：
- `session/cancel` - 取消正在进行的操作（无响应预期）

#### Client（客户端）

客户端提供用户与代理之间的接口。它们通常是代码编辑器（IDE、文本编辑器），也可以是其他用于与代理交互的 UI。客户端管理环境、处理用户交互并控制对资源的访问。

**Client 基准方法**：
- `session/request_permission` - 请求工具调用的用户授权

**Client 可选方法**：
- `fs/read_text_file` - 读取文件内容（需要 `fs.readTextFile` 能力）
- `fs/write_text_file` - 写入文件内容（需要 `fs.writeTextFile` 能力）
- `terminal/*` - 终端操作（需要 `terminal` 能力）

**Client 通知**：
- `session/update` - 发送会话更新以通知客户端更改

### 消息流程

典型的流程遵循以下模式：

```
1. 初始化阶段
   - Client → Agent: initialize 建立连接
   - Client → Agent: authenticate（如果代理需要）

2. 会话设置（二选一）
   - Client → Agent: session/new 创建新会话
   - Client → Agent: session/load 恢复现有会话（如果支持）

3. 提示轮次
   - Client → Agent: session/prompt 发送用户消息
   - Agent → Client: session/update 通知进度更新
   - Agent → Client: 文件操作或权限请求（如需要）
   - Client → Agent: session/cancel 中断处理（如需要）
   - 轮次结束，代理发送带有停止原因的 session/prompt 响应
```

---

## 生命周期

### 初始化

初始化是建立 ACP 连接的第一步。

**Client → Agent: initialize 请求**

```json
{
  "jsonrpc": "2.0",
  "id": 0,
  "method": "initialize",
  "params": {
    "protocolVersion": 1,
    "clientCapabilities": {
      "fs": {
        "readTextFile": true,
        "writeTextFile": true
      },
      "terminal": false
    },
    "clientInfo": {
      "name": "Zed",
      "version": "0.170.0"
    }
  }
}
```

**Agent → Client: initialize 响应**

```json
{
  "jsonrpc": "2.0",
  "id": 0,
  "result": {
    "protocolVersion": 1,
    "agentCapabilities": {
      "loadSession": true,
      "mcpCapabilities": {
        "http": true,
        "sse": false
      },
      "promptCapabilities": {
        "audio": false,
        "embeddedContext": false,
        "image": false
      },
      "sessionCapabilities": {}
    },
    "agentInfo": {
      "name": "Gemini CLI",
      "version": "1.2.3"
    },
    "authMethods": []
  }
}
```

### 会话设置

**创建新会话**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "session/new",
  "params": {
    "cwd": "/home/user/project",
    "mcpServers": [
      {
        "name": "filesystem",
        "command": "/path/to/mcp-server",
        "args": ["--stdio"],
        "env": []
      }
    ]
  }
}
```

**Agent 响应**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "sessionId": "sess_abc123def456",
    "modes": {
      "currentModeId": "ask",
      "availableModes": [
        {
          "id": "ask",
          "name": "Ask",
          "description": "请求权限后进行任何更改"
        },
        {
          "id": "code",
          "name": "Code",
          "description": "使用完整工具访问权限编写和修改代码"
        }
      ]
    }
  }
}
```

### 提示轮次（Prompt Turn）

提示轮次代表客户端和代理之间的完整交互周期，从用户消息开始，直到代理完成其响应。

**步骤 1：用户消息**

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "session/prompt",
  "params": {
    "sessionId": "sess_abc123def456",
    "prompt": [
      {
        "type": "text",
        "text": "Can you analyze this code for potential issues?"
      },
      {
        "type": "resource",
        "resource": {
          "uri": "file:///home/user/project/main.py",
          "mimeType": "text/x-python",
          "text": "def process_data(items):\n    for item in items:\n        print(item)"
        }
      }
    ]
  }
}
```

**步骤 2-6：代理处理和报告输出**

代理通过 `session/update` 通知报告输出，包括计划、消息块、工具调用等。

---

## 工具系统详解

### 工具调用类型

工具调用代表语言模型请求代理在提示轮次期间执行的操作。当 LLM 确定需要与外部系统交互（如读取文件、运行代码或获取数据）时，它会生成工具调用，代理代表其执行。

#### 工具种类（ToolKind）

| Kind | 描述 | 图标建议 |
|------|------|----------|
| `read` | 读取文件或数据 | 文档图标 |
| `edit` | 修改文件或内容 | 编辑图标 |
| `delete` | 删除文件或数据 | 删除图标 |
| `move` | 移动或重命名文件 | 移动图标 |
| `search` | 搜索信息 | 搜索图标 |
| `execute` | 运行命令或代码 | 终端图标 |
| `think` | 内部推理或规划 | 大脑图标 |
| `fetch` | 检索外部数据 | 下载图标 |
| `other` | 其他工具类型 | 默认图标 |

#### 工具调用状态（ToolCallStatus）

| Status | 描述 |
|--------|------|
| `pending` | 工具调用尚未开始运行（输入正在流式传输或等待批准） |
| `in_progress` | 工具调用当前正在运行 |
| `completed` | 工具调用成功完成 |
| `failed` | 工具调用失败并返回错误 |

### 创建工具调用

当语言模型请求工具调用时，代理**应该**向客户端报告：

```json
{
  "jsonrpc": "2.0",
  "method": "session/update",
  "params": {
    "sessionId": "sess_abc123def456",
    "update": {
      "sessionUpdate": "tool_call",
      "toolCallId": "call_001",
      "title": "读取配置文件",
      "kind": "read",
      "status": "pending",
      "rawInput": {
        "path": "/home/user/project/config.json"
      }
    }
  }
}
```

**字段说明**：

- `toolCallId`：会话中此工具调用的唯一标识符
- `title`：描述工具正在执行的可读标题
- `kind`：工具类别
- `status`：当前执行状态
- `content`：工具调用产生的内容
- `locations`：受此工具调用影响的文件位置
- `rawInput`：发送到工具的原始输入参数
- `rawOutput`：工具返回的原始输出

### 更新工具调用

工具执行时，代理发送更新以报告进度和结果：

```json
{
  "jsonrpc": "2.0",
  "method": "session/update",
  "params": {
    "sessionId": "sess_abc123def456",
    "update": {
      "sessionUpdate": "tool_call_update",
      "toolCallId": "call_001",
      "status": "in_progress",
      "content": [
        {
          "type": "content",
          "content": {
            "type": "text",
            "text": "找到 3 个配置文件..."
          }
        }
      ]
    }
  }
}
```

更新中除 `toolCallId` 外的所有字段都是可选的。只需包含正在更改的字段。

### 工具调用内容类型

#### 1. 常规内容

标准内容块，如文本、图像或资源：

```json
{
  "type": "content",
  "content": {
    "type": "text",
    "text": "分析完成。发现 3 个问题。"
  }
}
```

#### 2. 差异（Diffs）

文件修改以差异形式显示：

```json
{
  "type": "diff",
  "path": "/home/user/project/src/config.json",
  "oldText": "{\n  \"debug\": false\n}",
  "newText": "{\n  \"debug\": true\n}"
}
```

#### 3. 终端

命令执行的活动终端输出：

```json
{
  "type": "terminal",
  "terminalId": "term_xyz789"
}
```

当终端嵌入在工具调用中时，客户端会在生成时实时显示输出，并在终端释放后继续显示输出。

### 跟随代理（Following the Agent）

工具调用可以报告它们正在使用的文件位置，使客户端能够实现"跟随"功能，实时跟踪代理正在访问或修改哪些文件：

```json
{
  "path": "/home/user/project/src/main.py",
  "line": 42
}
```

---

## 用户交互工具传递

### 权限请求

代理**可以**在执行工具调用之前通过调用 `session/request_permission` 方法请求用户权限：

```json
{
  "jsonrpc": "2.0",
  "id": 5,
  "method": "session/request_permission",
  "params": {
    "sessionId": "sess_abc123def456",
    "toolCall": {
      "toolCallId": "call_001",
      "title": "准备实施",
      "kind": "switch_mode",
      "status": "pending",
      "content": [
        {
          "type": "text",
          "text": "## 实施计划..."
        }
      ]
    },
    "options": [
      {
        "optionId": "allow-once",
        "name": "允许一次",
        "kind": "allow_once"
      },
      {
        "optionId": "allow-always",
        "name": "始终允许",
        "kind": "allow_always"
      },
      {
        "optionId": "reject-once",
        "name": "拒绝",
        "kind": "reject_once"
      },
      {
        "optionId": "reject-always",
        "name": "始终拒绝",
        "kind": "reject_always"
      }
    ]
  }
}
```

#### 权限选项类型（PermissionOptionKind）

| Kind | 描述 |
|------|------|
| `allow_once` | 仅这次允许此操作 |
| `allow_always` | 允许此操作并记住选择 |
| `reject_once` | 仅这次拒绝此操作 |
| `reject_always` | 拒绝此操作并记住选择 |

#### 客户端响应

客户端使用用户的决定响应：

```json
{
  "jsonrpc": "2.0",
  "id": 5,
  "result": {
    "outcome": {
      "outcome": "selected",
      "optionId": "allow-once"
    }
  }
}
```

客户端**可以**根据用户设置自动允许或拒绝权限请求。如果当前的提示轮次被取消，客户端**必须**响应 `"cancelled"` 结果：

```json
{
  "jsonrpc": "2.0",
  "id": 5,
  "result": {
    "outcome": {
      "outcome": "cancelled"
    }
  }
}
```

### 会话模式（Session Modes）

代理可以提供它们可以操作的模式集。模式通常影响使用的系统提示、工具可用性以及它们是否在运行前请求权限。

#### 初始状态

在会话设置期间，代理**可以**返回它可以操作的模式列表和当前活动模式：

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "sessionId": "sess_abc123def456",
    "modes": {
      "currentModeId": "ask",
      "availableModes": [
        {
          "id": "ask",
          "name": "Ask",
          "description": "请求权限后进行任何更改"
        },
        {
          "id": "architect",
          "name": "Architect",
          "description": "设计和规划软件系统而不实施"
        },
        {
          "id": "code",
          "name": "Code",
          "description": "使用完整工具访问权限编写和修改代码"
        }
      ]
    }
  }
}
```

#### 设置当前模式

**从客户端设置**

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "session/set_mode",
  "params": {
    "sessionId": "sess_abc123def456",
    "modeId": "code"
  }
}
```

**从代理设置**

代理可以通过发送 `current_mode_update` 会话通知来更改其自己的模式并通知客户端：

```json
{
  "jsonrpc": "2.0",
  "method": "session/update",
  "params": {
    "sessionId": "sess_abc123def456",
    "update": {
      "sessionUpdate": "current_mode_update",
      "modeId": "code"
    }
  }
}
```

#### 退出计划模式

代理可能从特殊"退出模式"工具中切换模式的常见情况是在计划/架构师模式期间提供给语言模型的工具。当语言模型确定准备好开始实施解决方案时，可以调用此工具。这个"切换模式"工具通常会请求权限运行，就像任何其他工具一样。

### 斜杠命令（Slash Commands）

代理可以宣传一组用户可以调用的斜杠命令。这些命令提供对特定代理功能和工作流的快速访问。

#### 宣传命令

创建会话后，代理**可以**通过 `available_commands_update` 会话通知发送可用命令列表：

```json
{
  "jsonrpc": "2.0",
  "method": "session/update",
  "params": {
    "sessionId": "sess_abc123def456",
    "update": {
      "sessionUpdate": "available_commands_update",
      "availableCommands": [
        {
          "name": "web",
          "description": "搜索网络信息",
          "input": {
            "unstructured": {
              "hint": "要搜索的查询"
            }
          }
        },
        {
          "name": "test",
          "description": "为当前项目运行测试"
        },
        {
          "name": "plan",
          "description": "创建详细的实施计划",
          "input": {
            "unstructured": {
              "hint": "要规划的内容描述"
            }
          }
        }
      ]
    }
  }
}
```

#### 运行命令

命令作为提示请求中的常规用户消息包含：

```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "session/prompt",
  "params": {
    "sessionId": "sess_abc123def456",
    "prompt": [
      {
        "type": "text",
        "text": "/web agent client protocol"
      }
    ]
  }
}
```

代理识别命令前缀并相应地处理它。命令可以与任何其他用户消息内容类型（图像、音频等）一起包含在同一提示数组中。

#### 动态更新

代理可以在会话期间的任何时间通过发送另一个 `available_commands_update` 通知来更新可用命令列表。这允许基于上下文添加命令，在不再相关时删除，或使用更新的描述进行修改。

---

## MCP 集成

### 什么是 MCP？

**Model Context Protocol (MCP)** 是一个标准化接口，用于 LLM 代理与外部工具、数据源和服务进行交互。MCP 提供：

- 一致的工具定义格式
- 标准的请求/响应模式
- 工具发现机制
- 错误处理约定

### ACP 与 MCP 的关系

ACP 使用 MCP 作为代理访问外部工具和数据源的标准方式。创建会话时，客户端**可以**包含代理应该连接的 MCP 服务器连接详情。

### MCP 服务器传输类型

#### 1. Stdio 传输（必需）

所有代理**必须**支持通过 stdio（标准输入/输出）连接到 MCP 服务器。这是默认的传输机制。

```json
{
  "name": "filesystem",
  "command": "/path/to/mcp-server",
  "args": ["--stdio"],
  "env": [
    {
      "name": "API_KEY",
      "value": "secret123"
    }
  ]
}
```

#### 2. HTTP 传输（可选）

当代理支持 `mcpCapabilities.http` 时，客户端可以指定使用 HTTP 传输的 MCP 服务器配置：

```json
{
  "type": "http",
  "name": "api-server",
  "url": "https://api.example.com/mcp",
  "headers": [
    {
      "name": "Authorization",
      "value": "Bearer token123"
    },
    {
      "name": "Content-Type",
      "value": "application/json"
    }
  ]
}
```

#### 3. SSE 传输（可选，已弃用）

当代理支持 `mcpCapabilities.sse` 时，客户端可以指定使用 SSE 传输的 MCP 服务器配置。

> **注意**：此传输方式已被 MCP 规范弃用。

### 检查传输支持

在使用 HTTP 或 SSE 传输之前，客户端**必须**在初始化期间验证代理的能力：

```json
{
  "jsonrpc": "2.0",
  "id": 0,
  "result": {
    "protocolVersion": 1,
    "agentCapabilities": {
      "mcpCapabilities": {
        "http": true,
        "sse": true
      }
    }
  }
}
```

### MCP 工具在 ACP 中的使用

当语言模型请求调用 MCP 工具时：

1. **代理识别 MCP 工具调用**
2. **报告工具调用状态**：通过 `session/update` 通知
3. **调用 MCP 服务器**：代理通过配置的传输与 MCP 服务器通信
4. **更新工具调用状态**：使用 MCP 返回的结果更新工具调用状态
5. **发送结果给 LLM**：将 MCP 工具结果作为工具响应返回给语言模型

### 客户端提供 MCP 服务器

客户端**可以**使用此能力通过包含自己的 MCP 服务器将工具直接提供给底层语言模型。这使客户端能够向代理公开自定义工具而无需修改代理代码。

#### 完整工作流程

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │ 1. session/new with mcpServers
       ▼
┌─────────────┐
│   Agent     │
└──────┬──────┘
       │ 2. Connect to all listed MCP servers
       ▼
┌──────────────────────┐
│  MCP Server (Stdio) │
│  (provides custom   │
│   tools to Agent)    │
└──────┬───────────────┘
       │ 3. Discover tools from MCP
       ▼
┌─────────────┐
│   Agent     │
└──────┬──────┘
       │ 4. Make tools available to LLM
       ▼
┌─────────────┐
│     LLM     │ → calls tool
└──────┬──────┘
       │ 5. Execute via MCP
       ▼
┌──────────────────────┐
│  MCP Server (Stdio) │
│  (executes tool)      │
└──────┬───────────────┘
       │ 6. Return result
       ▼
┌─────────────┐
│   Agent     │
└──────┬──────┘
       │ 7. Report via ACP session/update
       ▼
┌─────────────┐
│   Client    │
└─────────────┘
```

#### MCP 服务器配置格式详解

**Stdio 传输接口**

```typescript
interface StdioMcpServer {
  name: string;           // MCP 服务器的可读标识符
  command: string;        // MCP 服务器可执行文件的绝对路径
  args: string[];         // 传递给服务器的命令行参数
  env: EnvVariable[];      // 启动服务器时设置的环境变量
}

interface EnvVariable {
  name: string;           // 环境变量名称
  value: string;          // 环境变量值
}
```

**HTTP 传输接口**

```typescript
interface HttpMcpServer {
  type: "http";           // 必须是 "http"
  name: string;            // 可读标识符
  url: string;             // MCP 服务器的 URL
  headers: HttpHeader[];    // 请求时包含的 HTTP 头
}

interface HttpHeader {
  name: string;           // HTTP 头名称
  value: string;          // HTTP 头值
}
```

#### 客户端实现示例

**TypeScript 客户端提供 MCP 服务器**

```typescript
import { ClientSideConnection, ndJsonStream } from '@agentclientprotocol/sdk';

async function createSessionWithMcpServers(
  clientConn: ClientSideConnection,
  cwd: string
) {
  // 1. 初始化并检查代理的 MCP 能力
  const initResult = await clientConn.initialize({
    protocolVersion: 1,
    clientCapabilities: {
      fs: {
        readTextFile: true,
        writeTextFile: true
      },
      terminal: false
    },
    clientInfo: {
      name: "MyCustomClient",
      version: "1.0.0"
    }
  });

  // 2. 验证支持的 MCP 传输
  const supportsHttp = initResult.agentCapabilities.mcpCapabilities?.http ?? false;
  const supportsSse = initResult.agentCapabilities.mcpCapabilities?.sse ?? false;

  console.log(`代理能力检查:`);
  console.log(`  - HTTP 传输: ${supportsHttp ? '支持' : '不支持'}`);
  console.log(`  - SSE 传输: ${supportsSse ? '支持' : '不支持'}`);

  // 3. 配置 MCP 服务器列表
  const mcpServers = [
    // 本地 MCP 服务器（stdio 传输）
    {
      name: "filesystem",
      command: "/usr/local/bin/filesystem-mcp",
      args: ["--stdio"],
      env: [
        {
          name: "HOME",
          value: process.env.HOME
        },
        {
          name: "PROJECT_ROOT",
          value: cwd
        }
      ]
    },
    // 自定义工具 MCP 服务器（stdio 传输）
    {
      name: "my-custom-tools",
      command: "/usr/local/bin/mcp-tools-server.py",
      args: ["--stdio", "--verbose"],
      env: [
        {
          name: "GITHUB_TOKEN",
          value: process.env.GITHUB_TOKEN || ""
        },
        {
          name: "K8S_TOKEN",
          value: process.env.K8S_TOKEN || ""
        }
      ]
    },
    // HTTP MCP 服务器（如果代理支持）
    ...(supportsHttp ? [
      {
        type: "http" as const,
        name: "api-tools",
        url: "https://api.mycompany.com/mcp",
        headers: [
          {
            name: "Authorization",
            value: `Bearer ${process.env.API_TOKEN}`
          },
          {
            name: "X-Custom-Header",
            value: "my-value"
          },
          {
            name: "Content-Type",
            value: "application/json"
          }
        ]
      }
    ] : [])
  ];

  console.log(`\n配置 ${mcpServers.length} 个 MCP 服务器:`);
  mcpServers.forEach(server => {
    if ('type' in server) {
      console.log(`  - ${server.name} (${server.type}): ${server.url}`);
    } else {
      console.log(`  - ${server.name} (stdio): ${server.command}`);
    }
  });

  // 4. 创建会话并提供 MCP 服务器
  const sessionResult = await clientConn.newSession({
    cwd,
    mcpServers  // ← 这里将 MCP 服务器配置给代理
  });

  console.log(`\n会话 ${sessionResult.sessionId} 已创建`);
  console.log('所有 MCP 服务器已提供给代理');

  return sessionResult;
}

// 使用示例
async function main() {
  const stream = ndJsonStream(process.stdout, process.stdin);
  const clientConn = new ClientSideConnection(stream);

  const cwd = process.cwd();
  const session = await createSessionWithMcpServers(clientConn, cwd);

  // 发送提示
  await clientConn.prompt({
    sessionId: session.sessionId,
    prompt: [
      {
        type: "text",
        text: "请列出可用的工具"
      }
    ]
  });
}

main().catch(console.error);
```

#### Python MCP 服务器完整示例

```python
#!/usr/bin/env python3
"""
自定义 MCP 服务器 - 暴露自定义工具给 ACP 客户端
安装: pip install mcp httpx
运行: python my_mcp_server.py --stdio
"""
import httpx
from typing import Any
from mcp import Server

# 创建 MCP 服务器
mcp = Server("my-custom-tools")

# ===== 工具定义 =====

@mcp.tool()
async def create_pr(
    repo_name: str,
    title: str,
    description: str,
    branch: str = "feature/new-feature",
    labels: list[str] | None = None
) -> str:
    """创建 Pull Request

    创建一个新的 Pull Request 到指定的 GitHub 代码仓库

    Args:
        repo_name: 仓库名称（格式: owner/repo）
        title: PR 标题
        description: PR 描述（支持 GitHub Flavored Markdown）
        branch: 源分支名称，默认 'feature/new-feature'
        labels: PR 标签列表（可选）

    Returns:
        PR 的 URL 和基本信息
    """
    try:
        async with httpx.AsyncClient(timeout=60.0) as client:
            # 构建 GitHub API 请求
            payload = {
                "title": title,
                "body": description,
                "head": branch,
                "base": "main"
            }
            if labels:
                payload["labels"] = labels

            response = await client.post(
                f"https://api.github.com/repos/{repo_name}/pulls",
                json=payload,
                headers={
                    "Authorization": f"Bearer {get_github_token()}",
                    "Accept": "application/vnd.github.v3+json",
                    "User-Agent": "MyMcpServer/1.0"
                }
            )
            response.raise_for_status()
            pr_data = response.json()

            return f"""✅ PR 创建成功！

**PR #{pr_data['number']}:** {title}
**URL:** {pr_data['html_url']}
**状态:** {pr_data['state']}
**作者:** {pr_data['user']['login']}
**分支:** {pr_data['head']['ref']} → {pr_data['base']['ref']}
"""

    except httpx.HTTPStatusError as e:
        return f"❌ 创建 PR 失败: HTTP {e.response.status_code} - {e.response.text}"
    except Exception as e:
        return f"❌ 创建 PR 失败: {str(e)}"

@mcp.tool()
async def run_tests(
    test_path: str = "tests/",
    verbose: bool = False,
    coverage: bool = True,
    timeout: int = 300
) -> dict[str, Any]:
    """运行测试套件

    在指定的路径中运行测试，支持自定义选项

    Args:
        test_path: 测试文件或目录的路径
        verbose: 是否显示详细的测试输出
        coverage: 是否生成代码覆盖率报告
        timeout: 测试超时时间（秒）

    Returns:
        包含测试结果的字典
    """
    import subprocess
    import json

    try:
        args = ["pytest", test_path]
        if verbose:
            args.append("-v")
        if coverage:
            args.extend(["--cov", "--cov-report=term"])

        process = subprocess.Popen(
            args,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=timeout
        )

        stdout, stderr = process.communicate()

        return {
            "exit_code": process.returncode,
            "stdout": stdout,
            "stderr": stderr,
            "success": process.returncode == 0,
            "command": " ".join(args)
        }
    except subprocess.TimeoutExpired:
        process.kill()
        return {
            "exit_code": -1,
            "stdout": "",
            "stderr": "测试超时",
            "success": False,
            "command": " ".join(args),
            "error": "timeout"
        }
    except Exception as e:
        return {
            "exit_code": -2,
            "stdout": "",
            "stderr": str(e),
            "success": False,
            "command": " ".join(args),
            "error": str(e)
        }

@mcp.tool()
async def deploy_service(
    service_name: str,
    environment: str = "staging",
    docker_tag: str = "latest",
    replicas: int = 3,
    rolling_update: bool = True
) -> str:
    """部署微服务到指定环境

    部署指定的 Docker 镜像到 Kubernetes 集群中的指定环境

    Args:
        service_name: 服务名称（例如: user-service）
        environment: 目标环境（staging, production）
        docker_tag: Docker 镜像标签
        replicas: Pod 副本数量
        rolling_update: 是否使用滚动更新策略

    Returns:
        部署状态和相关信息
    """
    try:
        async with httpx.AsyncClient(timeout=120.0) as client:
            deployment_config = {
                "service": service_name,
                "environment": environment,
                "image": f"{service_name}:{docker_tag}",
                "replicas": replicas,
                "strategy": {
                    "type": "rolling" if rolling_update else "recreate"
                }
            }

            response = await client.post(
                "https://k8s.internal/api/deploy",
                json=deployment_config,
                headers={
                    "Authorization": f"Bearer {get_k8s_token()}",
                    "Content-Type": "application/json"
                }
            )
            response.raise_for_status()
            deploy_data = response.json()

            return f"""✅ 部署请求已提交

**服务:** {service_name}
**环境:** {environment}
**镜像:** {service_name}:{docker_tag}
**副本数:** {replicas}
**更新策略:** {'滚动' if rolling_update else '重建'}
**部署 ID:** {deploy_data['deployment_id']}
**状态:** {deploy_data['status']}
"""

    except httpx.HTTPStatusError as e:
        return f"❌ 部署失败: HTTP {e.response.status_code}"
    except Exception as e:
        return f"❌ 部署失败: {str(e)}"

# ===== 资源定义 =====

@mcp.resource("env://config")
async def environment_config() -> str:
    """当前环境的配置信息"""
    config = {
        "environment": "development",
        "kubernetes_cluster": "dev-cluster-01",
        "database_url": "postgresql://dev-db.internal:5432/app",
        "redis_url": "redis://dev-redis.internal:6379",
        "api_base_url": "https://dev-api.example.com",
        "enabled_features": ["feature_flags", "beta_features"]
    }
    return json.dumps(config, indent=2)

@mcp.resource("docs://deployment-guide")
async def deployment_guide() -> str:
    """部署指南文档"""
    return """# 部署指南

## 前置条件
- 有效的 Kubernetes 访问令牌
- Docker 镜像已推送到镜像仓库
- 环境已预先创建

## 部署步骤
1. 使用 `deploy_service` 工具
2. 指定服务名称和目标环境
3. 等待部署完成
4. 验证服务健康状态

## 可用环境
- `staging`: 测试环境
- `production`: 生产环境

## 工具参考
- `deploy_service`: 部署服务
- `run_tests`: 运行测试套件
- `create_pr`: 创建 Pull Request
"""

@mcp.resource("tools://manifest")
async def tools_manifest() -> str:
    """工具清单"""
    manifest = {
        "name": "my-custom-tools",
        "version": "1.0.0",
        "description": "集成了 CI/CD、Git 和 Kubernetes 操作的自定义工具集",
        "tools": [
            {
                "name": "create_pr",
                "description": "创建 GitHub Pull Request",
                "category": "git"
            },
            {
                "name": "run_tests",
                "description": "运行测试并生成覆盖率报告",
                "category": "testing"
            },
            {
                "name": "deploy_service",
                "description": "部署服务到 Kubernetes",
                "category": "deployment"
            }
        ]
    }
    return json.dumps(manifest, indent=2)

# 辅助函数
def get_github_token() -> str:
    import os
    return os.environ.get("GITHUB_TOKEN", "")

def get_k8s_token() -> str:
    import os
    return os.environ.get("K8S_TOKEN", "")

# 启动服务器
if __name__ == "__main__":
    import sys
    mcp.run(transport="stdio")
```

#### 代理端自动发现和集成工具

```typescript
import { Agent, AgentSideConnection } from '@agentclientprotocol/sdk';
import { StdioMcpClient, HTTPMcpClient } from './mcp-clients';

class MyAgent implements Agent {
  private mcpClients = new Map<string, any>();
  private availableTools = new Map<string, any>();

  async newSession(req: NewSessionRequest): Promise<NewSessionResponse> {
    const sessionId = generateSessionId();

    // === 代理自动连接所有 MCP 服务器 ===
    console.log(`开始连接 ${req.mcpServers.length} 个 MCP 服务器...`);

    for (const mcpConfig of req.mcpServers) {
      console.log(`  连接 ${mcpConfig.name}...`);

      const mcpClient = await this.connectToMcpServer(mcpConfig);
      this.mcpClients.set(mcpConfig.name, mcpClient);

      // === 自动发现工具 ===
      try {
        const toolsList = await mcpClient.listTools();
        console.log(`    发现 ${toolsList.tools.length} 个工具:`);

        for (const tool of toolsList.tools) {
          this.availableTools.set(tool.name, tool);
          console.log(`      - ${tool.name}: ${tool.description}`);
        }
      } catch (error) {
        console.error(`    工具发现失败:`, error);
      }
    }

    console.log(`\n总计: ${this.availableTools.size} 个工具可用于 LLM`);

    return {
      sessionId,
      modes: {
        currentModeId: "code",
        availableModes: [
          {
            id: "code",
            name: "Code",
            description: "完整工具访问权限"
          }
        ]
      }
    };
  }

  async prompt(req: PromptRequest): Promise<PromptResponse> {
    // === 将工具提供给 LLM ===
    const toolsArray = Array.from(this.availableTools.values());
    console.log(`向 LLM 提供 ${toolsArray.length} 个工具`);

    const llmRequest = {
      messages: req.prompt,
      tools: toolsArray.map(tool => ({
        type: "function" as const,
        function: {
          name: tool.name,
          description: tool.description,
          parameters: tool.inputSchema
        }
      }))
    };

    const llmResponse = await callLLM(llmRequest);

    // === 处理工具调用 ===
    if (llmResponse.tool_calls && llmResponse.tool_calls.length > 0) {
      console.log(`LLM 请求 ${llmResponse.tool_calls.length} 个工具调用`);

      for (const toolCall of llmResponse.tool_calls) {
        const toolName = toolCall.function.name;

        // 通过 ACP 报告工具调用开始
        this.clientConnection.sessionUpdate({
          sessionId: req.sessionId,
          update: {
            sessionUpdate: 'tool_call',
            toolCallId: toolCall.id,
            title: `执行工具: ${toolName}`,
            kind: this.determineToolKind(toolName),
            status: 'in_progress'
          }
        });

        // === 查找负责的 MCP 客户端 ===
        const mcpClient = this.findMcpClientForTool(toolName);
        if (!mcpClient) {
          throw new Error(`No MCP client found for tool: ${toolName}`);
        }

        // === 通过 MCP 执行工具 ===
        console.log(`  通过 MCP 执行 ${toolName}...`);
        const mcpResult = await mcpClient.callTool({
          name: toolName,
          arguments: JSON.parse(toolCall.function.arguments)
        });

        console.log(`  工具执行完成`);
        console.log(`    结果:`, mcpResult);

        // 报告工具调用结果
        this.clientConnection.sessionUpdate({
          sessionId: req.sessionId,
          update: {
            sessionUpdate: 'tool_call_update',
            toolCallId: toolCall.id,
            status: 'completed',
            content: mcpResult.content || [{
              type: 'text' as const,
              text: JSON.stringify(mcpResult, null, 2)
            }],
            rawOutput: mcpResult
          }
        });

        // 将结果反馈给 LLM 继续对话...
      }
    }

    return { stopReason: 'end_turn' };
  }

  private async connectToMcpServer(config: any) {
    // 根据配置类型选择相应的 MCP 客户端
    if (config.type === 'http') {
      console.log(`    使用 HTTP 传输: ${config.url}`);
      return new HTTPMcpClient(config.url, config.headers);
    } else {
      console.log(`    使用 Stdio 传输: ${config.command}`);
      return new StdioMcpClient(config.command, config.args, config.env);
    }
  }

  private findMcpClientForTool(toolName: string): any {
    // 查找包含指定工具的 MCP 客户端
    for (const [mcpName, mcpClient] of this.mcpClients) {
      const tools = mcpClient.getAvailableTools();
      if (tools.some(tool => tool.name === toolName)) {
        return mcpClient;
      }
    }
    return null;
  }

  private determineToolKind(toolName: string): string {
    // 根据工具名称推断工具类型
    if (toolName.includes('read') || toolName.includes('fetch')) return 'read';
    if (toolName.includes('write') || toolName.includes('edit')) return 'edit';
    if (toolName.includes('deploy') || toolName.includes('run')) return 'execute';
    return 'other';
  }
}
```

#### 关键要点

1. **客户端主动提供**：客户端在创建/加载会话时，通过 `mcpServers` 参数主动提供 MCP 服务器列表

2. **代理自动连接**：代理**应该**连接到客户端指定的所有 MCP 服务器

3. **透明工具发现**：代理通过 MCP 协议自动发现和注册这些服务器暴露的工具

4. **无需修改代理代码**：客户端可以通过提供 MCP 服务器来暴露新工具，而无需修改代理本身的代码

5. **多种传输方式**：客户端可以混合使用 stdio、HTTP 等不同传输方式的 MCP 服务器，前提是代理支持相应的传输能力

6. **能力检查**：客户端应该使用 HTTP 或 SSE 传输前，先检查代理是否支持相应的 MCP 能力（`mcpCapabilities.http` 或 `mcpCapabilities.sse`）

7. **环境变量传递**：客户端可以通过 `env` 参数将敏感信息（如 API 密钥）传递给 MCP 服务器，而无需在工具调用参数中暴露

这种机制使得客户端能够灵活地向代理提供自定义工具，增强了代理的能力而无需修改代理代码。

---

## 创建 MCP 服务器

### MCP 服务器开发概览

创建 MCP 服务器是实现自定义工具的标准方式。MCP 服务器是独立的进程，通过 stdio 或 HTTP 暴露工具、资源和提示给代理。

### Python MCP 服务器实现

#### 基础模板

```python
#!/usr/bin/env python3
"""
MCP 服务器基础模板
安装: pip install mcp
运行: python mcp_server.py --stdio
"""
from mcp import Server

# 创建 MCP 服务器
mcp = Server("my-server")

@mcp.tool()
async def my_tool(param1: str, param2: int = 42) -> str:
    """工具描述（此处定义的文档会暴露给 LLM)

    Args:
        param1: 第一个参数的描述
        param2: 第二个参数的描述，默认值 42

    Returns:
        返回结果的描述
    """
    # 实现你的工具逻辑
    return f"处理结果: {param1}, {param2}"

# 启动服务器
if __name__ == "__main__":
    mcp.run(transport="stdio")
```

#### 完整示例：CI/CD 工具集

```python
#!/usr/bin/env python3
"""
MCP 服务器 - CI/CD 工具集
提供 GitHub、测试运行和部署相关的工具
安装: pip install mcp httpx
运行: python cicd_mcp_server.py --stdio
"""
import asyncio
import httpx
import json
import subprocess
from typing import Any, Optional
from mcp import Server

# 创建 MCP 服务器
mcp = Server("cicd-tools")

# ===== GitHub 工具 =====

@mcp.tool()
async def create_github_issue(
    repo: str,
    title: str,
    body: str,
    labels: list[str] | None = None,
    assignees: list[str] | None = None
) -> str:
    """在 GitHub 仓库中创建 Issue

    Args:
        repo: 仓库标识符（格式: owner/repo）
        title: Issue 标题
        body: Issue 内容（支持 Markdown）
        labels: 要添加的标签列表（可选）
        assignees: 要指派的用户列表（可选）

    Returns:
        创建的 Issue 信息
    """
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            payload = {
                "title": title,
                "body": body
            }
            if labels:
                payload["labels"] = labels
            if assignees:
                payload["assignees"] = assignees

            response = await client.post(
                f"https://api.github.com/repos/{repo}/issues",
                json=payload,
                headers={
                    "Authorization": f"Bearer {get_github_token()}",
                    "Accept": "application/vnd.github.v3+json"
                }
            )
            response.raise_for_status()

            issue_data = response.json()
            return f"""✅ Issue 创建成功

Issue #{issue_data['number']}: {title}
URL: {issue_data['html_url']}
状态: {issue_data['state']}
作者: {issue_data['user']['login']}
"""

    except httpx.HTTPStatusError as e:
        return f"❌ GitHub API 错误: {e.response.status_code} - {e.response.text}"
    except Exception as e:
        return f"❌ 创建 Issue 失败: {str(e)}"

@mcp.tool()
async def get_repo_issues(
    repo: str,
    state: str = "open",
    per_page: int = 10
) -> dict[str, Any]:
    """获取 GitHub 仓库的 Issue 列表

    Args:
        repo: 仓库标识符（格式: owner/repo）
        state: Issue 状态（open, closed, all）
        per_page: 每页返回的数量

    Returns:
        Issue 列表和分页信息
    """
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.get(
                f"https://api.github.com/repos/{repo}/issues",
                params={
                    "state": state,
                    "per_page": per_page
                },
                headers={
                    "Authorization": f"Bearer {get_github_token()}",
                    "Accept": "application/vnd.github.v3+json"
                }
            )
            response.raise_for_status()

            issues = response.json()

            return {
                "total_count": len(issues),
                "issues": [
                    {
                        "number": issue["number"],
                        "title": issue["title"],
                        "state": issue["state"],
                        "url": issue["html_url"],
                        "created_at": issue["created_at"]
                    }
                    for issue in issues
                ]
            }
    except Exception as e:
        return {
            "error": str(e),
            "total_count": 0,
            "issues": []
        }

# ===== 测试工具 =====

@mcp.tool()
async def run_unit_tests(
    test_path: str = "tests/",
    verbose: bool = False,
    coverage: bool = True,
    junit_xml: bool = False
) -> dict[str, Any]:
    """运行单元测试

    在指定的路径中运行单元测试，支持多种输出格式

    Args:
        test_path: 测试文件或目录的路径
        verbose: 是否显示详细的测试输出
        coverage: 是否生成代码覆盖率报告
        junit_xml: 是否生成 JUnit XML 格式的报告

    Returns:
        测试执行结果
    """
    try:
        args = ["python", "-m", "pytest", test_path]
        if verbose:
            args.append("-v")
        if coverage:
            args.extend(["--cov=.", "--cov-report=term"])
        if junit_xml:
            args.append("--junitxml=test-results.xml")

        process = asyncio.create_subprocess_exec(
            *args,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )

        stdout, stderr = await process.communicate()
        exit_code = await process.wait()

        return {
            "exit_code": exit_code,
            "stdout": stdout.decode('utf-8'),
            "stderr": stderr.decode('utf-8'),
            "success": exit_code == 0,
            "command": " ".join(args)
        }
    except Exception as e:
        return {
            "exit_code": -1,
            "stdout": "",
            "stderr": str(e),
            "success": False,
            "error": str(e)
        }

@mcp.tool()
async def lint_code(
    file_path: str,
    linter: str = "flake8",
    max_line_length: int = 100
) -> dict[str, Any]:
    """代码质量检查（Linting）

    对指定文件运行代码质量检查工具

    Args:
        file_path: 要检查的文件路径
        linter: 使用的 linter 工具（flake8, pylint）
        max_line_length: 最大行长度

    Returns:
        Lint 检查结果
    """
    try:
        args = []
        if linter == "flake8":
            args = ["flake8", f"--max-line-length={max_line_length}", file_path]
        elif linter == "pylint":
            args = ["pylint", file_path, "--max-line-length", str(max_line_length)]
        else:
            return {
                "success": False,
                "error": f"不支持的 linter: {linter}"
            }

        process = await asyncio.create_subprocess_exec(
            *args,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )

        stdout, stderr = await process.communicate()
        exit_code = await process.wait()

        return {
            "exit_code": exit_code,
            "output": stdout.decode('utf-8'),
            "errors": stderr.decode('utf-8'),
            "success": exit_code == 0
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }

# ===== 部署工具 =====

@mcp.tool()
async def deploy_to_environment(
    service_name: str,
    environment: str,
    version: str,
    rollout_timeout: int = 600,
    health_check: bool = True
) -> str:
    """部署服务到指定环境

    完整的部署流程，包括健康检查

    Args:
        service_name: 服务名称
        environment: 目标环境（staging, production）
        version: 要部署的版本号
        rollout_timeout: 滚动超时时间（秒）
        health_check: 是否执行健康检查

    Returns:
        部署结果和状态
    """
    try:
        # 模拟部署过程
        deploy_status = {
            "service_name": service_name,
            "environment": environment,
            "version": version,
            "status": "in_progress",
            "timestamp": asyncio.get_event_loop().time()
        }

        # 调用部署 API（示例）
        async with httpx.AsyncClient(timeout=rollout_timeout) as client:
            deploy_response = await client.post(
                "https://deploy.internal/api/v1/deploy",
                json=deploy_status,
                headers={
                    "Authorization": f"Bearer {get_deploy_token()}",
                    "Content-Type": "application/json"
                }
            )
            deploy_response.raise_for_status()
            deployment_id = deploy_response.json()["deployment_id"]

        # 健康检查
        if health_check:
            health_result = await perform_health_check(service_name, environment)
            deploy_status["health_check"] = health_result
        else:
            deploy_status["health_check"] = "skipped"

        deploy_status["status"] = "completed"
        deploy_status["deployment_id"] = deployment_id

        return f"""✅ 部署成功

服务: {service_name}
环境: {environment}
版本: {version}
部署 ID: {deployment_id}
健康检查: {deploy_status['health_check']}

预计访问: https://{environment}.internal/{service_name}
"""

    except Exception as e:
        return f"❌ 部署失败: {str(e)}"

async def perform_health_check(service: str, env: str) -> str:
    """执行 Health Check"""
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            url = f"https://{env}.internal/{service_name}/health"
            response = await client.get(url, timeout=10.0)
            if response.status_code == 200:
                return "healthy"
            else:
                return f"unhealthy (status: {response.status_code})"
    except:
        return "failed"

# ===== 资源定义 =====

@mcp.resource("env://deployment-config")
async def deployment_config() -> str:
    """部署环境配置"""
    config = {
        "environments": {
            "staging": {
                "url": "https://staging.internal",
                "region": "us-west-2",
                "cluster": "staging-cluster"
            },
            "production": {
                "url": "https://api.example.com",
                "region": "us-west-2",
                "cluster": "prod-cluster",
                "requires_approval": True
            }
        },
        "allowed_services": [
            "user-service",
            "order-service",
            "payment-service"
        ],
        "deployment_strategy": "blue-green"
    }
    return json.dumps(config, indent=2)

@mcp.resource("docs://cicd-guide")
async def cicd_guide() -> str:
    """CI/CD 流程指南"""
    return """# CI/CD 工具指南

## 可用工具

### GitHub 工具
- `create_github_issue`: 创建 GitHub Issue
- `get_repo_issues`: 获取 Issue 列表

### 测试工具
- `run_unit_tests`: 运行单元测试
- `lint_code`: 代码质量检查

### 部署工具
- `deploy_to_environment`: 部署服务到指定环境

## 使用流程

1. **开发阶段**：使用 `run_unit_tests` 和 `lint_code` 验证代码
2. **创建 Issue**：使用 `create_github_issue` 追踪任务
3. **部署到 Staging**：使用 `deploy_to_environment` 部署到测试环境
4. **验证后续**：使用 `get_repo_issues` 查看 Issue 状态
5. **生产部署**：使用 `deploy_to_environment` 部署到生产环境

## 环境要求

- GitHub Token: `GITHUB_TOKEN` 环境变量
- 部署 Token: `DEPLOY_TOKEN` 环境变量
- Python 3.10+
- 依赖: mcp, httpx

## 安全注意事项

- 所有部署到生产环境的操作需要人工审批
- 敏感信息（API 密钥）通过环境变量传递
- 部署前必须通过所有测试
"""

# ===== 辅助函数 =====

def get_github_token() -> str:
    import os
    token = os.environ.get("GITHUB_TOKEN")
    if not token:
        raise ValueError("GITHUB_TOKEN 环境变量未设置")
    return token

def get_deploy_token() -> str:
    import os
    token = os.environ.get("DEPLOY_TOKEN")
    if not token:
        raise ValueError("DEPLOY_TOKEN 环境变量未设置")
    return token

# 启动服务器
if __name__ == "__main__":
    mcp.run(transport="stdio")
```

### TypeScript MCP 服务器实现

#### 基础模板

```typescript
// mcp-server.ts
import { Server } from "@modelcontextprotocol/sdk";

// 创建 MCP 服务器
const server = new Server(
  {
    name: "my-server",
    version: "1.0.0"
  },
  {
    capabilities: {
      tools: {}
    }
  }
);

// 列出可用工具
server.setRequestHandler("tools/list", async () => {
  return {
    tools: [
      {
        name: "my_tool",
        description: "工具描述",
        inputSchema: {
          type: "object",
          properties: {
            param1: {
              type: "string",
              description: "第一个参数"
            },
            param2: {
              type: "number",
              description: "第二个参数",
              default: 42
            }
          },
          required: ["param1"]
        }
      }
    ]
  };
});

// 调用工具
server.setRequestHandler("tools/call", async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case "my_tool":
      return await myTool(args);
    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});

// 工具实现
async function myTool(args: any) {
  const { param1, param2 = 42 } = args;

  // 实现你的工具逻辑
  return {
    content: [
      {
        type: "text",
        text: `处理结果: ${param1}, ${param2}`
      }
    ]
  };
}

// 启动服务器
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch(console.error);
```

#### 完整示例：数据库管理工具

```typescript
// database-mcp-server.ts
import { Server } from "@modelcontextprotocol/sdk";
import { Pool } from 'pg';

// 数据库连接池
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'myapp',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'password'
});

// 创建 MCP 服务器
const server = new Server(
  {
    name: "database-tools",
    version: "1.0.0"
  },
  {
    capabilities: {
      tools: {},
      resources: {}
    }
  }
);

// ===== 工具定义 =====

server.setRequestHandler("tools/list", async () => {
  return {
    tools: [
      {
        name: "query_database",
        description: "执行 SELECT 查询（只读）",
        inputSchema: {
          type: "object",
          properties: {
            query: {
              type: "string",
              description: "SQL SELECT 查询语句"
            }
          },
          required: ["query"]
        }
      },
      {
        name: "insert_data",
        description: "向指定表插入数据",
        inputSchema: {
          type: "object",
          properties: {
            table: {
              type: "string",
              description: "目标表名"
            },
            data: {
              type: "object",
              description: "要插入的数据（JSON 对象）"
            }
          },
          required: ["table", "data"]
        }
      },
      {
        name: "update_data",
        description: "更新表中的数据",
        inputSchema: {
          type: "object",
          properties: {
            table: {
              type: "string",
              description: "目标表名"
            },
            where: {
              type: "object",
              description: "WHERE 条件（JSON 对象）"
            },
            data: {
              type: "object",
              description: "要更新的数据（JSON 对象）"
            }
          },
          required: ["table", "where", "data"]
        }
      },
      {
        name: "get_table_schema",
        description: "获取表的结构信息",
        inputSchema: {
          type: "object",
          properties: {
            table: {
              type: "string",
              description: "表名"
            }
          },
          required: ["table"]
        }
      }
    ]
  };
});

// 工具调用处理
server.setRequestHandler("tools/call", async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "query_database":
        return await queryDatabase(args);
      case "insert_data":
        return await insertData(args);
      case "update_data":
        return await updateData(args);
      case "get_table_schema":
        return await getTableSchema(args);
      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error: any) {
    return {
      content: [
        {
          type: "text",
          text: `错误: ${error.message || String(error)}`
        }
      ],
      isError: true
    };
  }
});

// ===== 工具实现 =====

async function queryDatabase(args: any) {
  const { query } = args;

  // 安全检查：只允许 SELECT 查询
  if (!query.trim().toUpperCase().startsWith("SELECT")) {
    throw new Error("只允许执行 SELECT 查询");
  }

  const client = await pool.connect();
  try {
    const result = await client.query(query);
    return {
      content: [
        {
          type: "text",
          text: `查询执行成功\n\n返回 ${result.rows.length} 行:\n\n${JSON.stringify(result.rows, null, 2)}`
        }
      ]
    };
  } finally {
    client.release();
  }
}

async function insertData(args: any) {
  const { table, data } = args;

  // 验证表名（防止 SQL 注入）
  const validTableNameRegex = /^[a-zA-Z_][a-zA-Z0-9_]*$/;
  if (!validTableNameRegex.test(table)) {
    throw new Error("无效的表名");
  }

  const columns = Object.keys(data).join(', ');
  const values = Object.values(data);
  const placeholders = values.map((_, i) => `$${i + 1}`).join(', ');

  const query = `INSERT INTO ${table} (${columns}) VALUES (${placeholders}) RETURNING *`;

  const client = await pool.connect();
  try {
    const result = await client.query(query, values);
    return {
      content: [
        {
          type: "text",
          text: `数据插入成功\n\n插入的行:\n${JSON.stringify(result.rows[0], null, 2)}`
        }
      ]
    };
  } finally {
    client.release();
  }
}

async function updateData(args: any) {
  const { table, where, data } = args;

  // 验证表名
  const validTableNameRegex = /^[a-zA-Z_][a-zA-Z0-9_]*$/;
  if (!validTableNameRegex.test(table)) {
    throw new Error("无效的表名");
  }

  const setClause = Object.keys(data)
    .map((key, i) => `${key} = $${i + 1}`)
    .join(', ');
  const whereClause = Object.keys(where)
    .map((key, i) => `${key} = $${Object.keys(data).length + i + 1}`)
    .join(' AND ');

  const values = [...Object.values(data), ...Object.values(where)];
  const query = `UPDATE ${table} SET ${setClause} WHERE ${whereClause} RETURNING *`;

  const client = await pool.connect();
  try {
    const result = await client.query(query, values);
    return {
      content: [
        {
          type: "text",
          text: `数据更新成功\n\n更新了 ${result.rowCount} 行\n\n更新后的行:\n${JSON.stringify(result.rows, null, 2)}`
        }
      ]
    };
  } finally {
    client.release();
  }
}

async function getTableSchema(args: any) {
  const { table } = args;

  const query = `
    SELECT
      column_name,
      data_type,
      is_nullable,
      column_default
    FROM information_schema.columns
    WHERE table_name = $1
    ORDER BY ordinal_position
  `;

  const client = await pool.connect();
  try {
    const result = await client.query(query, [table]);

    if (result.rows.length === 0) {
      throw new Error(`表 '${table}' 不存在`);
    }

    const schemaInfo = result.rows.map((row: any) => ({
      column: row.column_name,
      type: row.data_type,
      nullable: row.is_nullable === 'YES',
      default: row.column_default
    }));

    return {
      content: [
        {
          type: "text",
          text: `表结构: ${table}\n\n${JSON.stringify(schemaInfo, null, 2)}`
        }
      ]
    };
  } finally {
    client.release();
  }
}

// ===== 资源定义 =====

server.setRequestHandler("resources/list", async () => {
  return {
    resources: [
      {
        uri: "db://stats",
        name: "数据库统计信息",
        description: "数据库连接和表的统计信息",
        mimeType: "application/json"
      },
      {
        uri: "db://tables",
        name: "所有表列表",
        description: "数据库中所有用户表的列表",
        mimeType: "application/json"
      }
    ]
  };
});

server.setRequestHandler("resources/read", async (request) => {
  const { uri } = request.params;

  switch (uri) {
    case "db://stats":
      return await getDatabaseStats();
    case "db://tables":
      return await getTablesList();
    default:
      throw new Error(`Unknown resource: ${uri}`);
  }
});

async function getDatabaseStats() {
  const client = await pool.connect();
  try {
    const tableCount = await client.query("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public'");
    const connectionCount = await client.query("SELECT COUNT(*) FROM pg_stat_activity");

    return {
      contents: [
        {
          uri: "db://stats",
          mimeType: "application/json",
          text: JSON.stringify({
            tables: parseInt(tableCount.rows[0].count),
            active_connections: parseInt(connectionCount.rows[0].count)
          }, null, 2)
        }
      ]
    };
  } finally {
    client.release();
  }
}

async function getTablesList() {
  const client = await pool.connect();
  try {
    const result = await client.query(`
      SELECT table_name, table_size
      FROM (
        SELECT
          table_name,
          pg_total_relation_size(schemaname||'.'||tablename) as table_size
        FROM pg_tables
        WHERE schemaname = 'public'
      ) t
      ORDER BY table_size DESC
    `);

    const tables = result.rows.map((row: any) => ({
      name: row.table_name,
      size_bytes: parseInt(row.table_size),
      size_human: formatBytes(row.table_size)
    }));

    return {
      contents: [
        {
          uri: "db://tables",
          mimeType: "application/json",
          text: JSON.stringify(tables, null, 2)
        }
      ]
    };
  } finally {
    client.release();
  }
}

function formatBytes(bytes: number): string {
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  if (bytes === 0) return '0 Bytes';
  const i = Math.floor(Math.log(bytes) / Math.log(1024));
  return Math.round(bytes / Math.pow(1024, i) * 100) / 100 + ' ' + sizes[i];
}

// 启动服务器并处理关闭
async function main() {
  const transport = new StdioServerTransport();

  // 优雅关闭
  process.on('SIGINT', async () => {
    console.error('Closing MCP server...');
    await pool.end();
    process.exit(0);
  });

  await server.connect(transport);
  console.error('Database MCP server started');
}

main().catch((error) => {
  console.error('Failed to start MCP server:', error);
  process.exit(1);
});
```

### MCP 服务器最佳实践

#### 1. 错误处理

```python
@mcp.tool()
async def safe_tool(param: str) -> str:
    """带完整错误处理的工具"""
    try:
        # 业务逻辑
        result = await do_something(param)
        return f"成功: {result}"

    except httpx.TimeoutException:
        return "错误: 操作超时，请稍后重试"

    except httpx.HTTPStatusError as e:
        if e.response.status_code == 404:
            return "错误: 资源未找到"
        elif e.response.status_code >= 500:
            return "错误: 服务器错误，请稍后重试"
        else:
            return f"错误: HTTP {e.response.status_code}"

    except ValueError as e:
        return f"错误: 参数无效 - {str(e)}"

    except Exception as e:
        # 记录完整错误但不暴露给用户
        logger.error(f"Unexpected error in safe_tool: {e}", exc_info=True)
        return "错误: 处理请求时发生意外错误"
```

#### 2. 参数验证

```python
from pydantic import BaseModel, Field, validator

@mcp.tool()
async def validated_tool(user_id: str, age: int, email: str) -> str:
    """带参数验证的工具"""
    # 使用 Pydantic 进行类型验证
    class ToolInput(BaseModel):
        user_id: str = Field(..., min_length=1, description="用户 ID")
        age: int = Field(..., ge=0, le=150, description="年龄")
        email: str = Field(..., regex=r'^[^@]+@[^@]+\.[^@]+$', description="邮箱地址")

    try:
        args = ToolInput(user_id=user_id, age=age, email=email)
        # 继续处理...
        return "参数验证通过"
    except ValueError as e:
        return f"参数验证失败: {str(e)}"
```

#### 3. 异步操作

```python
@mcp.tool()
async def parallel_operations(task_ids: list[str]) -> str:
    """并行执行多个操作"""
    async with httpx.AsyncClient(timeout=None) as http_client:
        # 创建并发任务
        tasks = [
            fetch_task_status(http_client, task_id)
            for task_id in task_ids
        ]

        # 并行执行并等待所有完成
        results = await asyncio.gather(*tasks, return_exceptions=True)

        # 处理结果
        success_count = sum(1 for r in results if not isinstance(r, Exception))
        error_count = len(results) - success_count

        return f"""
        并行执行完成:
        - 总任务数: {len(task_ids)}
        - 成功: {success_count}
        - 失败: {error_count}
        """

async def fetch_task_status(client: httpx.AsyncClient, task_id: str):
    """获取单个任务状态"""
    response = await client.get(f"https://api.example.com/tasks/{task_id}")
    response.raise_for_status()
    return response.json()
```

#### 4. 资源缓存

```python
from functools import lru_cache
from datetime import datetime, timedelta

@mcp.resource("cached://expensive-data")
async def expensive_data() -> str:
    """带缓存的昂贵资源"""
    cache_key = "expensive_data_last_update"

    # 检查缓存是否过期
    if hasattr(expensive_data_with_cache, '_last_update'):
        if datetime.now() - expensive_data_with_cache._last_update < timedelta(minutes=5):
            return expensive_data_with_cache._cached_result

    # 生成新数据
    result = await generate_expensive_data()

    # 更新缓存
    expensive_data_with_cache._cached_result = result
    expensive_data_with_cache._last_update = datetime.now()

    return result
```

#### 5. 安全考虑

```python
import os
import secrets

@mcp.tool()
async def secure_operation(
    sensitive_data: str,
    verify_token: str | None = None
) -> str:
    """安全的操作处理"""
    # 1. 敏感信息处理
    sanitized_data = sanitize_input(sensitive_data)

    # 2. 令牌验证（如果提供）
    if verify_token:
        if not verify_security_token(verify_token):
            return "错误: 令牌验证失败"

    # 3. 日志脱敏
    logger.info(f"Processing secure operation (ID: {generate_operation_id()})")

    # 4. 执行操作
    result = await perform_operation(sanitized_data)

    return f"操作完成。结果已记录（ID: {generate_operation_id()})"
```

---

## 自定义工具实现

### 在 ACP 中实现自定义工具

虽然 ACP 本身不直接定义"自定义工具"的概念（工具调用由代理内部管理），但通过以下机制可以实现自定义工具功能：

#### 1. MCP 服务器集成（推荐）

实现自定义工具的最标准方式是创建 MCP 服务器：

**步骤**：

1. **创建 MCP 服务器**
   ```python
   # Python MCP 服务器示例
   from mcp import Server
   import httpx

   app = Server("my-tools")

   @app.tool()
   async def fetch_weather(city: str) -> str:
       """获取指定城市的天气信息"""
       async with httpx.AsyncClient() as client:
           response = await client.get(f"https://api.weather.com/{city}")
           return response.json()
   ```

2. **配置 ACP 代理连接**
   ```json
   {
     "name": "custom-tools",
     "command": "/path/to/mcp-server",
     "args": ["--stdio"],
     "env": []
   }
   ```

3. **代理自动发现工具**
   - 代理会自动连接到 MCP 服务器
   - 工具自动可用给语言模型
   - 工具调用通过 ACP 的工具调用机制报告

#### 2. 扩展方法（自定义方法）

ACP 允许通过以下方式添加自定义功能：

**自定义请求**

任何以下划线（`_`）开头的方法名称都保留用于自定义扩展：

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "_myorg/custom_tool",
  "params": {
    "sessionId": "sess_abc123def456",
    "action": "deploy",
    "target": "production"
  }
}
```

**自定义通知**

```json
{
  "jsonrpc": "2.0",
  "method": "_myorg/deployment_status",
  "params": {
    "deploymentId": "deploy_001",
    "status": "in_progress",
    "progress": 45
  }
}
```

#### 3. `_meta` 字段扩展

所有协议类型都包括一个 `_meta` 字段，实现可以使用它来附加自定义信息：

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "session/prompt",
  "params": {
    "sessionId": "sess_abc123def456",
    "prompt": [
      {
        "type": "text",
        "text": "Hello, world!"
      }
    ],
    "_meta": {
      "traceparent": "00-80e1afed08e019fc1110464cfa66635c-7a085853722dc6d2-01",
      "myorg.featureFlags": {
        "experimentalUI": true
      }
    }
  }
}
```

### TypeScript SDK 实现

使用 `@agentclientprotocol/sdk` 实现 ACP 代理：

```typescript
import {
  Agent,
  AgentSideConnection,
  type SessionUpdate,
  type ToolCallContent
} from '@agentclientprotocol/sdk';

class CustomAgent implements Agent {
  private sessions = new Map<string, Session>();

  constructor(private client: AgentSideConnection) {}

  async initialize(req: InitializeRequest): Promise<InitializeResponse> {
    return {
      protocolVersion: 1,
      agentCapabilities: {
        loadSession: false,
        mcpCapabilities: {
          http: true,
          sse: false
        },
        promptCapabilities: {
          audio: false,
          embeddedContext: false,
          image: false
        },
        sessionCapabilities: {}
      },
      agentInfo: {
        name: "My Custom Agent",
        version: "1.0.0"
      },
      authMethods: []
    };
  }

  async newSession(req: NewSessionRequest): Promise<NewSessionResponse> {
    const sessionId = generateSessionId();
    const session = new Session(req);
    this.sessions.set(sessionId, session);

    return {
      sessionId
    };
  }

  async prompt(req: PromptRequest): Promise<PromptResponse> {
    const session = this.sessions.get(req.sessionId);
    if (!session) throw new Error('Session not found');

    // 发送工具调用通知
    this.client.sessionUpdate({
      sessionId: req.sessionId,
      update: {
        sessionUpdate: 'tool_call',
        toolCallId: 'call_001',
        title: '执行自定义工具',
        kind: 'execute',
        status: 'in_progress'
      }
    });

    // 执行工具逻辑
    const result = await this.executeCustomTool();

    // 发送更新
    this.client.sessionUpdate({
      sessionId: req.sessionId,
      update: {
        sessionUpdate: 'tool_call_update',
        toolCallId: 'call_001',
        status: 'completed',
        content: [
          {
            type: 'content',
            content: {
              type: 'text',
              text: result
            }
          }
        ]
      }
    });

    return {
      stopReason: 'end_turn'
    };
  }

  private async executeCustomTool(): Promise<string> {
    // 自定义工具实现
    return '工具执行完成';
  }
}

// 创建代理连接
const stream = ndJsonStream(process.stdout, process.stdin);
new AgentSideConnection(
  (connection) => new CustomAgent(connection),
  stream
);
```

---

## 扩展机制

### `_meta` 字段

协议中的所有类型都包括一个类型为 `{ [key: string]: unknown }` 的 `_meta` 字段，实现可以使用它来附加自定义信息。这包括请求、响应、通知，甚至是内容块、工具调用、计划条目和能力对象等嵌套类型。

**保留字段**：

客户端可以将字段传播到代理以用于关联目的，例如 `requestId`。`_meta` 中的以下根级键**应该**为 W3C 追踪上下文保留，以保证与现有 MCP 实现和 OpenTelemetry 工具的互操作性：

- `traceparent`
- `tracestate`
- `baggage`

### 扩展方法

协议保留任何以下划线（`_`）开头的方法名称用于自定义扩展。这允许实现添加新功能而不会与未来协议版本冲突。

**实现规则**：

- **自定义请求**：必须包含 `id` 字段并期望响应
- **自定义通知**：省略 `id` 字段，是单向的
- **未知方法**：接收端必须用标准的"方法未找到"错误响应
- **忽略未知通知**：实现应该忽略无法识别的通知

### 宣传自定义能力

实现**应该**使用能力对象中的 `_meta` 字段来宣传对扩展及其方法的支持：

```json
{
  "jsonrpc": "2.0",
  "id": 0,
  "result": {
    "protocolVersion": 1,
    "agentCapabilities": {
      "loadSession": true,
      "_meta": {
        "myorg": {
          "workspace": true,
          "fileNotifications": true,
          "customTools": ["deploy", "monitor"]
        }
      }
    }
  }
}
```

这允许实现在初始化期间协商自定义功能，而不破坏与标准客户端和代理的兼容性。

---

## 实现参考

### 官方 SDK

- **TypeScript SDK**: `@agentclientprotocol/sdk` (npm)
  - [GitHub 仓库](https://github.com/agentclientprotocol/typescript-sdk)
  - [文档](https://agentclientprotocol.github.io/typescript-sdk)

- **Python SDK**: `agent-client-protocol` (PyPI)
  - [GitHub 仓库](https://github.com/agentclientprotocol/python-sdk)
  - [文档](https://agentclientprotocol.github.io/python-sdk)

### 生产级实现

#### 1. Gemini CLI (Google)

一个完整的、生产就绪的 ACP 代理实现：

```typescript
// 来源: https://github.com/google-gemini/gemini-cli
export class GeminiAgent implements Agent {
  constructor(
    private config: Config,
    private settings: LoadedSettings,
    private argv: CliArgs,
    private connection: AgentSideConnection,
  ) {}

  async initialize(req: InitializeRequest): Promise<InitializeResponse> {
    // 初始化逻辑
  }

  async prompt(req: PromptRequest): Promise<PromptResponse> {
    // 提示处理逻辑
  }
}

// 创建连接
const stream = acp.ndJsonStream(stdout, stdin);
new acp.AgentSideConnection(
  (connection) => new GeminiAgent(config, settings, argv, connection),
  stream,
);
```

#### 2. OpenCode Agent

```typescript
// 来源: https://github.com/anomalyco/opencode
export class Agent implements ACPAgent {
  constructor(
    connection: AgentSideConnection,
    fullConfig: ACPConfig
  ) {}

  async initialize(req: InitializeRequest): Promise<InitializeResponse> {
    // 实现
  }
}
```

#### 3. Cursor Agent ACP Adapter

一个将 Cursor Agent 桥接到 ACP 的适配器：

```typescript
// 来源: https://github.com/blowmage/cursor-agent-acp-npm
export class CursorAgentAdapter {
  private agentConnection?: AgentSideConnection;

  constructor(config: AdapterConfig, options: AdapterOptions = {}) {
    // 初始化
  }

  // 实现自定义工具注册和执行
  private registerTools(): void {
    // 工具注册逻辑
  }
}
```

### 社区资源

- **ACP 官方文档**: https://agentclientprotocol.com
- **Zed Industries**: https://zed.dev (ACP 主要贡献者)
- **JetBrains**: https://jetbrains.com (支持 ACP 的 IDE)

---

## 最佳实践

### 工具调用报告

1. **始终提供有意义的标题**：帮助用户理解代理正在做什么
2. **正确使用工具种类**：使客户端能够显示适当的图标
3. **及时更新状态**：提供实时的进度反馈
4. **报告相关位置**：实现"跟随"功能

### 权限请求

1. **仅在必要时请求权限**：避免不必要的用户交互
2. **提供清晰的选项**：使用适当的权限选项类型
3. **尊重用户选择**：记住 `allow_always` 和 `reject_always` 选择
4. **优雅处理取消**：确保取消操作时正确清理资源

### MCP 集成

1. **支持多种传输**：至少支持 stdio，鼓励支持 HTTP
2. **正确处理错误**：将 MCP 错误转换为适当的 ACP 错误响应
3. **缓存工具列表**：避免重复的 MCP 工具发现请求
4. **连接所有指定的服务器**：客户端可能通过 MCP 服务器提供自定义工具

### 扩展性

1. **使用下划线前缀**：为自定义方法和方法命名
2. **宣传自定义能力**：使用 `_meta` 字段让其他方了解可用的扩展
3. **忽略未知通知**：确保客户端的兼容性
4. **响应未知方法**：使用标准的"方法未找到"错误

---

## 总结

Agent Client Protocol (ACP) 是一个强大而灵活的协议，它标准化了 AI 编码代理与代码编辑器之间的通信。通过以下机制，它支持丰富的工具系统和用户交互：

1. **工具调用系统**：通过 `session/update` 通知报告工具执行状态、进度和结果
2. **权限请求**：通过 `session/request_permission` 方法实现用户确认交互
3. **会话模式**：支持不同的代理操作模式（Ask、Architect、Code 等）
4. **斜杠命令**：提供快速访问特定代理功能的机制
5. **MCP 集成**：使用 MCP 作为访问外部工具和数据源的标准方式
6. **扩展机制**：通过 `_meta` 字段和自定义方法实现自定义功能

通过理解这些机制，开发者可以构建强大、互操作且用户友好的 AI 编码代理和编辑器集成。

---

## 参考资料

- [ACP 官方文档](https://agentclientprotocol.com)
- [ACP TypeScript SDK](https://github.com/agentclientprotocol/typescript-sdk)
- [ACP Python SDK](https://github.com/agentclientprotocol/python-sdk)
- [Gemini CLI 实现](https://github.com/google-gemini/gemini-cli)
- [OpenCode 实现](https://github.com/anomalyco/opencode)
- [MCP 规范](https://modelcontextprotocol.io)
