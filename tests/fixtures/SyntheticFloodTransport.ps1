#requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$syntheticLine = [Console]::In.ReadLine()
if ($null -eq $syntheticLine) {
    exit 91
}
$syntheticLine = $null
[Console]::Out.Write(('X' * 4096))
exit 0
