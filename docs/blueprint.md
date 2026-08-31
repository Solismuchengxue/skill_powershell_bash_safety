# 项目蓝图

## 意图与受众

本项目维护一个独立、可移植、可验证的 `powershell-bash-safety` Codex Skill，帮助需要编写、审阅、打包或执行 PowerShell、SSH、Bash 与 POSIX sh 链路的任务，在进入高风险运行前发现解释器、参数、quoting、字节和跨平台边界错误。

本文件是项目意图的共享权威。用户入口由 [README](../README.md) 负责，设计与正式边界由 [DESIGN](../DESIGN.md) 及 [架构说明](architecture.md) 负责，项目维护规则由 [AGENTS](../AGENTS.md) 负责。

## 成功结果

| 可观察结果 | 验证入口 |
| --- | --- |
| Canonical package 自包含、可发现，并符合 OpenAI Skill 结构 | `skills/powershell-bash-safety/` 与 package validator |
| PowerShell 与 Bash/POSIX sh 使用身份明确的 interpreter 和成熟 parser；不确定输入 fail closed | Package 内 syntax adapters 及项目级 adapter tests |
| Fast、Milestone、Target 保持条件式分层，本地 parser PASS 不冒充后续层证据 | [架构说明](architecture.md)与离线合同测试 |
| 项目级证据能验证 adapter 和消费者授权边界，同时不污染 portable package | [消费者前向测试计划](consumer-forward-test-plan.md)与 package 边界测试 |

## 范围与非目标

范围包括 PowerShell、native argv、SSH、Bash、POSIX sh、archive、transport 与 container 启动链的防错方法，以及相应的离线 adapter、测试和项目文档。

非目标包括自动安装工具、修改用户或系统配置、覆盖 installed Skill mirror、连接或变更远程环境、读取凭据、部署、服务中断、真实消费者切换，以及替代组织级协调、验收或发布权威。

## 约束与 UNKNOWN

- Windows PowerShell 工作固定使用 `C:\Program Files\PowerShell\7\pwsh.exe`；固定入口缺失时停止，不回退到 Windows PowerShell 5.1。
- Canonical source、installed mirror、Git checkpoint、目标环境和 runtime 是不同 identity；授权与 PASS 不跨层传递。
- 可选 lint 工具缺失时保持 `NOT_RUN`，目标环境未实际验证时保持 `NOT_VERIFIED`。
- 真实 WSL、FNOS、container、SSH 或生产兼容性只在绑定具体目标并获得 action-time authorization 后验证；当前不能由 Git Bash 或离线测试推断。
- 项目级消费者测试证据可以进入本仓库，但其中的 task reference 不属于 portable Skill package。

## 关键边界

| 边界 | 权威位置 | 不证明或不授权 |
| --- | --- | --- |
| 项目意图与用户/设计事实分工 | 本文件、[README](../README.md)、[DESIGN](../DESIGN.md) | Blueprint 不复制用法、架构、当前行动、失败或测试明细 |
| Canonical source 与 installed mirror 分离 | [DESIGN](../DESIGN.md)与[架构说明](architecture.md) | Source PASS 不证明安装、部署或 active 使用 |
| Git checkpoint 与外部发布分离 | [AGENTS](../AGENTS.md) | 本地 commit 不授权 remote、push、tag 或 Release |
| 本地行动与共享权威分离 | `TODO.md`、`DEVLOG.md` 与 `.gitignore` | Ignored 记录不进入 Git checkpoint，也不替代共享事实 |
| Swift Cycle 只维护项目内部工程循环 | [AGENTS](../AGENTS.md) | Adoption 不授权删除、安装、凭据、Target 或真实运行 |

## 第一里程碑出口

首次采用里程碑在以下条件同时满足时关闭：建立本意图权威；完成 `minimal` 职责映射与 AGENTS 持久绑定；在 `main` 建立可复现的本地初始检查点；相关 Markdown、Skill package 与现有离线测试通过；ignored 本地记录未进入 index；未授权外部层保持未变更或未验证。

## 更新触发

目标用户、核心价值、成功结果、范围、非目标、关键约束、source/deployment 边界或项目授权模型发生实质变化时更新本文件。普通实现、单次测试结果、短期待办和失败排障分别更新其对应权威，不在这里累积。
