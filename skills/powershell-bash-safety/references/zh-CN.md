# PowerShell 与 Shell 高效验证参考

本文件只记录两个薄适配器的命令合同。PowerShell/PSScriptAnalyzer/Pester/ShellCheck/shfmt/WSL 的第三方手册不复制到 package。

## 1. 模式选择

| 模式 | 默认范围 | PowerShell | Bash/sh | 证据边界 |
| --- | --- | --- | --- | --- |
| `Fast` | 本次受影响文件 | 官方 AST | 已识别本地 backend 的 `-n` | 本地 parser compatibility |
| `Milestone` | 相关模块/里程碑 | AST + 可用 PSScriptAnalyzer；相关时 Pester | `-n` + 可用 ShellCheck | parser + 可选 lint |
| `Target` | 明确目标环境 | 由目标任务另行绑定 | WSL/目标 container/主机真实 interpreter | 指定目标 compatibility |

Gate 是内部条件式层级。Fast 不是“少做安全检查”，而是把必要的 bytes、count、dialect 和 identity 合并到一次 adapter 运行；Milestone 与 Target 只在风险触发时升级。

## 2. PowerShell adapter

`scripts/Test-PowerShellSyntax.ps1` 只收集 `.ps1/.psm1/.psd1`，验证 UTF-8 无 BOM、LF、无 NUL、样本数和固定 PowerShell 7 identity，再调用官方 `System.Management.Automation.Language.Parser.ParseFile`。它不执行目标脚本，也不依赖用户级 `.codex\tools` 副本。

```powershell
$adapter = Join-Path $SkillRoot 'scripts\Test-PowerShellSyntax.ps1'
& 'C:\Program Files\PowerShell\7\pwsh.exe' -NoLogo -NoProfile `
    -ExecutionPolicy Bypass -File $adapter `
    -LiteralPath $ChangedFile -Mode Fast
$adapterExit = $LASTEXITCODE
```

目录或多根 path list 必须提供正数 `ExpectedCount`；多根使用 `-LiteralPathList`，每行一个 literal path。`-OutputFormat Json` 提供与 Text 相同的结构化字段。

`Milestone` 才探测 PSScriptAnalyzer。已存在则通过 `ScriptDefinition` 静态检查；缺失为 `NOT_RUN/TOOL_UNAVAILABLE`，Fast 为 `NOT_RUN/MODE_FAST`。Pester 只在相关 adapter/逻辑有测试时由项目 runner 调用，不替代 AST。

## 3. Shell adapter

`scripts/Test-ShellSyntax.ps1` 收集 `.bash/.sh` 与有 shell shebang 的无扩展名文件，验证 UTF-8 无 BOM、LF、无 NUL、样本数，再按文件调用 `bash -n` 或 `sh -n`。它不会执行目标脚本。

本地 Fast：

```powershell
$adapter = Join-Path $SkillRoot 'scripts\Test-ShellSyntax.ps1'
& 'C:\Program Files\PowerShell\7\pwsh.exe' -NoLogo -NoProfile `
    -ExecutionPolicy Bypass -File $adapter `
    -LiteralPath $ChangedShellFile `
    -Dialect Auto -Backend Auto -Mode Fast
$adapterExit = $LASTEXITCODE
```

关键选择：

- `Dialect Auto` 只接受明确的 `bash`/`sh` shebang，或把 `.bash` 唯一判为 Bash；无 shebang 的 `.sh` 保持歧义并 fail closed。
- `Backend Auto` 只选择从实际 `git.exe` root 证明且唯一的 Git Bash；不取 PATH 中第一个 `bash.exe`。
- Git Bash 使用同一 root 的 `cygpath.exe` 转换 Windows/MSYS path domain，并报告 bash/sh 绝对路径与版本。
- System32/WindowsApps `bash.exe` 是 WSL launcher，不是 shell interpreter；MSYS2 不是 Git Bash，Auto 发现时要求 `Backend Explicit`。
- `Backend WSL` 只允许 `Mode Target`，并要求显式 `WslDistribution`；调用会启动目标环境，因此仍需 action-time 授权。
- `Backend Explicit` 需要绝对 `InterpreterPath` 和显式 Bash/Sh dialect。

`Milestone` 才探测 ShellCheck。缺失为 `NOT_RUN/TOOL_UNAVAILABLE`；issues 与 parser errors 使已启用里程碑 gate FAIL。shfmt 不自动运行，也不是默认 gate。

## 4. 统一输出

两个 adapter 的 Text 是默认人类摘要，Json 用于机器消费。共同字段包括：

- `discovered/validated/skipped`；
- `encoding_errors/parse_errors`；
- mode、result、exit code、expected count；
- 实际 interpreter/backend identity 和可选 lint status。

exit `0` 表示当前已启用 gate 通过；exit `1` 表示 parser 或已启用 lint 发现问题；exit `2` 表示输入、字节、count、identity、读取或工具执行前置失败。空集合不能 PASS。

PowerShell adapter 报告 `psscriptanalyzer_status/reason`；Shell adapter额外报告 `backend/evidence_scope/dialects/interpreters/shellcheck_status/reason`。Fast 的 Git Bash 结果必须保留 `WINDOWS_LOCAL_COMPAT`，不能重标为目标 Linux PASS。

## 5. 与运行层的边界

Parser 与 lint 不证明 parameter binding、archive bytes、transport、container entrypoint、remote identity 或 runtime health。只有实际任务触发这些风险时才增加对应检查；WSL/Docker/远程连接、安装、部署、rollback、凭据和服务中断仍分别请求执行时授权。

## 6. 一次性 sudo 遮蔽输入

只在具体 action 已获授权、用户明确选择 GUI 输入且 Windows interactive desktop 可用时调用。先从固定 PowerShell 7 启动 STA session；密码只在随后出现的 WPF 窗口中输入两次，不在 terminal、chat 或 history 中输入：

```powershell
& 'C:\Program Files\PowerShell\7\pwsh.exe' -NoLogo -NoProfile -Sta
```

在该 STA session 中，用同一组 non-secret action parameters 先生成 digest，取得该 digest 对应的 action-time authorization 后再执行：

```powershell
$modulePath = Join-Path $SkillRoot 'scripts\Invoke-MaskedSudoOverSsh.psm1'
Import-Module -Name $modulePath -Force

$action = @{
    AuthorizationId = 'approved-action-001'
    HostName = 'server.example'
    UserName = 'operator'
    Port = 22
    TargetCommand = '/usr/bin/id'
    TargetArgument = @('-u')
    KnownHostsFile = Join-Path $env:USERPROFILE '.ssh\known_hosts'
    MaxOutputBytes = 1048576
}
$digest = New-SolisSudoActionDigest @action
# 在获得该 digest 对应的 action-time authorization 后：
$result = Invoke-SolisMaskedSudoOverSsh @action -ExpectedActionDigest $digest
```

`TargetCommand` 必须是 absolute POSIX path；target 不得需要 inherited stdin。`MaxOutputBytes` 默认 `1048576`、范围 `1..16777216`，是 action digest 的一部分，并分别限制 sudo/target stdout/stderr；Windows transport 也使用有界并发读取。任何输出超限都返回 `ErrorLayer=OutputLimit`、`FailureCode=OUTPUT_LIMIT_EXCEEDED`。module 在 GUI 前后两次校验 action identity，并固定 `BatchMode=yes`、`StrictHostKeyChecking=yes`、`RequestTTY=no`、`PasswordAuthentication=no`。SSH/sudo/target 结果只保存在返回对象的 `Ssh`、`Sudo`、`Target` 三层中；调用方若另行持久化结果，必须先按目标项目的数据与日志规则脱敏。

GUI cancel、两次输入不一致、空值、MTA、non-Windows、session 0、WPF 不可用、helper/SSH/known_hosts/identity 前置失败、digest 漂移、输出超限或 protocol 不完整均直接失败。没有 console、PTY、DPAPI、SecretStore 或 plaintext file fallback，也没有自动 retry。
