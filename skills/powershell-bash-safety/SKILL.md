---
name: powershell-bash-safety
description: Use when writing, reviewing, packaging, or running PowerShell, SSH, Bash, or POSIX sh chains where parameter sets, quoting, interpreters, line endings, transferred artifacts, or exit codes can make a script fail across platforms.
---

# PowerShell 与 Bash 安全执行

## 三级模式

Gate 是条件式层级，不是每次全部执行，也不是拆成多张用户审批卡。选择满足当前风险的最小模式，并只检查本次受影响范围。

### 日常快速模式（默认）

- PowerShell 使用固定 PowerShell 7 与官方 AST Parser；Bash/sh 使用身份明确的本地 interpreter 执行 `-n`。
- 同一个薄适配器顺手完成 UTF-8、LF、BOM、NUL、样本数、dialect 和 interpreter identity 检查；不执行目标脚本。
- 用户只接收一次 PASS/FAIL 摘要。

### 里程碑模式

- 仍只检查相关范围。PowerShell 增加已可用的 PSScriptAnalyzer；仅有相关逻辑测试时运行 Pester。
- Bash/sh 增加已可用的 ShellCheck；shfmt 只是可选格式工具，不是默认硬门。
- 工具缺失写 `NOT_RUN`/`NOT_VERIFIED`，验证过程不自动安装。

### 目标环境模式

- 只在部署、发布、真实运行前，或明确要求 Linux/FNOS/container 兼容性时，用目标 WSL distribution、container 或主机的真实 interpreter 复核。
- Git Bash PASS 只证明 Windows 本地兼容层解析通过，不能冒充目标 Linux 证据。
- WSL、Docker、远程主机、部署和真实运行分别受 action-time 授权；本 Skill 不自动扩大权限。

## 选择与边界

- Windows PowerShell 固定使用 `C:\Program Files\PowerShell\7\pwsh.exe`；缺失时读取 [Windows 一次性引导](references/windows-bootstrap.md)并停止，不回退到 `powershell.exe`。
- PowerShell 使用 [Test-PowerShellSyntax.ps1](scripts/Test-PowerShellSyntax.ps1)，Shell 使用 [Test-ShellSyntax.ps1](scripts/Test-ShellSyntax.ps1)。两者都只是官方/成熟 parser 的安全编排器，不自研分析算法。
- parser、lint、target compatibility 与 runtime 是不同结论。前一层 PASS 不替代后一层；真实变更、安装、凭据、服务中断和生产执行均需独立授权。

命令、输入输出、dialect/backend 与工具状态见 [中文操作参考](references/zh-CN.md)。
