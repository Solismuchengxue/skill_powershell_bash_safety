# 消费者前向测试计划

## 状态与范围

- 状态：项目本地 Milestone acceptance plan，不进入 portable Skill package。
- 目的：用代表性消费者证明同一 Skill 会按角色、任务风险和 action-time authorization 选择不同验证深度，而不是让所有消费者执行完整 gate chain。
- 本计划只读取当前 Skill source、adapter contract 和已有验证证据；不会唤醒消费者任务，也不会修改消费者项目、`AGENTS.md`、模型或任务状态。

## 代表性消费者映射

| 角色 | Consumer identifier | 默认深度 | Milestone | Target |
| --- | --- | --- | --- | --- |
| Runtime 实施者 | `runtime-implementer` | 受影响脚本使用 Fast | adapter 或相关逻辑变化时运行已可用 lint 与相关 Pester | 只有项目权威方对具体运行环境另行授权后 |
| Studio OS 实施者 | `studio-os-implementer` | 受影响脚本使用 Fast | adapter 或相关逻辑变化时运行已可用 lint 与相关 Pester | 不因调用 Skill 自动进入 WSL、FNOS、container 或远程运行；需要具体授权 |
| Studio OS 只读审查者 | `studio-os-read-only-reviewer` | 审阅源码、interpreter contract 和已有证据；可运行明确只读 parser | 仅在 lint 已存在且不产生项目写入时运行；当前 fixture-based Pester 不属于只读 reviewer 默认权限 | 不执行 WSL、FNOS、container、远程或运维脚本 |

## 前向场景

### C1 Runtime 实施者

- 输入：本次受影响的 PowerShell 或 Bash/sh 文件，以及权威 expected count。
- 预期：Fast 闭合 bytes、count、identity、dialect 与 parser；工具缺失不自动安装。
- 升级：adapter 或相关逻辑发生变化时进入 Milestone；只有具体目标环境已获项目权威方 action-time authorization 时进入 Target。
- 停止条件：目标 identity、授权或必要证据缺失时保持 `NOT_VERIFIED`。

### C2 Studio OS 实施者

- 输入与 Fast/Milestone 规则同 C1。
- 预期：调用 Skill 不产生 WSL、FNOS、container、SSH 或远程运行副作用。
- 升级：Target 必须绑定具体环境与独立授权；Git Bash `WINDOWS_LOCAL_COMPAT` 不得升级为目标 Linux PASS。

### C3 Studio OS 只读审查者

- 输入：源码、interpreter contract 与已有验证证据。
- 预期：仅运行已证明无项目写入的 parser；lint 只有在工具已存在且不产生项目写入时才可运行。
- 禁止：修改文件、安装工具、执行 fixture-based Pester、运维脚本或 Target backend。
- 结论：未运行的行为、lint 或 Target 检查保持 `NOT_VERIFIED`/`NOT_RUN`。

## Acceptance

1. PowerShell adapter 的公开 mode 只包含 Fast/Milestone；Shell adapter 包含 Fast/Milestone/Target，并对 WSL 要求 Target 与显式 distribution。
2. Runtime 与 Studio OS 实施者默认使用 Fast，相关逻辑变化才进入 Milestone，Target 需要具体环境的独立授权。
3. 只读审查者不继承实施权限；已存在且无项目写入的 parser/lint 与 fixture-based Pester、Target/运维执行分开。
4. portable package 与公开 tracked payload 不包含内部任务身份；消费者映射只使用通用 identifier。
5. MCP 消息审批、空回传和任务唤醒问题保持 `UNKNOWN`/外部边界，不声明为 Shell safety 已解决。
