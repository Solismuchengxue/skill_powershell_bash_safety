# PowerShell 与 Bash 安全执行

`powershell-bash-safety` 是一个 Codex Skill，用于减少 PowerShell、SSH、Bash、POSIX sh、archive、文件传输与 container 启动链中的跨平台执行错误。

它把源码解析、参数绑定、制品字节、远端解释器和真实运行拆成独立 gate，帮助在进入高风险运行前发现 parameter set、quoting、EOL、shebang、checksum、entrypoint 和 exit code 问题。

项目为什么存在、成功结果、范围与非目标见 [项目蓝图](docs/blueprint.md)。

## 使用方式

在适用任务中使用：

```text
$powershell-bash-safety
```

典型场景包括：

- PowerShell 调用 SSH、SCP、Docker、WSL 或 Linux shell；
- Windows 上生成的脚本或 archive 上传后在 Linux 失败；
- `bash` 与 `/bin/sh` dialect 混用；
- native command 的 argv、`$LASTEXITCODE` 或多层 quoting 不可靠；
- Compose、wrapper 与 image entrypoint 的主进程 owner 不唯一。

## 项目结构

- `skills/powershell-bash-safety/`：权威 Skill package。
- `skills/powershell-bash-safety/scripts/Test-PowerShellSyntax.ps1`：官方 PowerShell AST Parser 的安全薄适配器，提供精确收集、计数、ReparsePoint、Text/Json 与稳定退出码。
- `skills/powershell-bash-safety/scripts/Test-ShellSyntax.ps1`：Bash/sh parser 的 backend-aware 薄适配器，提供 dialect、identity、path-domain、Text/Json 与条件式 ShellCheck。
- `skills/powershell-bash-safety/references/windows-bootstrap.md`：缺少固定 PowerShell 7 入口时按需读取的一次性引导边界。
- `tests/Test-PowerShellSyntax.Tests.ps1`：使用 Pester 和系统临时目录 fixtures 的离线行为验证。
- `tests/Test-ShellSyntax.Tests.ps1`：覆盖 Bash/sh dialect、backend、identity、工具缺失和输出合同的 Pester fixtures。
- `tests/Test-ConsumerDepth.Tests.ps1`：离线验证消费者角色、授权深度、Target gate 与 portable package 引用边界。
- `tests/Invoke-Pester.ps1`：断言 Pester expected/actual/failure count 的项目级 runner。
- `docs/blueprint.md`：项目意图、成功结果、范围、长期约束与更新触发的共享权威。
- `docs/consumer-forward-test-plan.md`：可提交的项目级测试证据；包含代表性 task reference，但不进入 portable Skill package。
- `DESIGN.md`：设计与 authority 边界。
- `docs/architecture.md`：多层执行模型和验证顺序。
- `DEVLOG.md`：本地踩坑与维护证据，Git ignored。
- `TODO.md`：本地当前行动，Git ignored。

## 当前限制

- Skill 只提供防错与验证方法，不授予远程写入、部署、服务中断、凭据读取或生产执行权限。
- parser PASS 不等于 package、transport 或 runtime PASS。
- 用户级已安装副本是独立 mirror；源码变化不会自动安装。
- PSScriptAnalyzer 是可选增强；不可用时明确 `NOT_RUN`，不由 syntax adapter 安装。Pester 与编辑器实时诊断都不替代官方 AST gate。
- Windows 正常流程固定调用 `C:\Program Files\PowerShell\7\pwsh.exe`；PowerShell 7、Starship、Pastel Powerline、NFM、Profile、PATH 与终端设置均是独立 action-time milestone，本源码候选不执行这些变更。
- 默认 Fast 只验证受影响文件；Milestone 条件增加 lint/tests；Target 仅在发布、部署或明确目标兼容性需求时进入。Git Bash PASS 不是 Linux/FNOS/container PASS。
- 消费者角色不会自动扩大验证深度：实施者默认 Fast、按相关变化进入 Milestone；只读审查者不继承 fixture、Target 或运维执行权限。
