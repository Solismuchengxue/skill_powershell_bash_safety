# 项目蓝图

## 意图与受众

本项目维护一个独立、可移植、可验证的 `powershell-bash-safety` Codex Skill，帮助需要编写、审阅、打包或执行 PowerShell、SSH、Bash 与 POSIX sh 链路的任务，在进入高风险运行前发现解释器、参数、quoting、字节和跨平台边界错误。

本文件是项目意图的共享权威。用户入口由 [README](../README.md) 负责，设计与正式边界由 [DESIGN](../DESIGN.md) 及 [架构说明](architecture.md) 负责，项目维护规则由 [AGENTS](../AGENTS.md) 负责。

## 成功结果

- Canonical package 在 `skills/powershell-bash-safety/` 保持自包含、可发现，并通过 OpenAI Skill 结构验证。
- PowerShell 与 Bash/POSIX sh 检查使用身份明确的 interpreter 和成熟 parser，空集合、计数、字节或 dialect 不确定时 fail closed。
- Fast、Milestone 与 Target 保持条件式分层；本地 parser PASS 不冒充 lint、目标环境或 runtime PASS。
- 项目级测试与文档能证明 adapter 合同、消费者授权边界和 source/deployment 区分，同时不把项目内部引用带入 portable package。

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

- Blueprint 只维护项目意图、范围、成功结果和长期约束，不复制用法、架构、当前行动、失败记录或测试明细。
- README 是用户入口；DESIGN 是简洁设计入口；`docs/architecture.md` 是详细架构权威；`AGENTS.md` 是维护与授权规则。
- `TODO.md` 和 `DEVLOG.md` 是 ignored 本地维护记录，不进入 Git checkpoint。
- Swift Cycle 只维护本项目内部工程循环；其 adoption 不授权 Git 后续动作、安装、发布、部署、凭据或真实目标运行。

## 第一里程碑出口

首次采用里程碑在以下条件同时满足时关闭：建立本意图权威；完成 `minimal` 职责映射与 AGENTS 持久绑定；在 `main` 建立可复现的本地初始检查点；相关 Markdown、Skill package 与现有离线测试通过；ignored 本地记录未进入 index；未授权外部层保持未变更或未验证。

## 更新触发

目标用户、核心价值、成功结果、范围、非目标、关键约束、source/deployment 边界或项目授权模型发生实质变化时更新本文件。普通实现、单次测试结果、短期待办和失败排障分别更新其对应权威，不在这里累积。
