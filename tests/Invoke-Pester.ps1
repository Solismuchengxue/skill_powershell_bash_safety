#requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$TestPath,

    [Parameter(Mandatory)]
    [int]$ExpectedCount
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module -Name Pester -ErrorAction Stop
$resolvedTest = (Resolve-Path -LiteralPath $TestPath -ErrorAction Stop).Path
$result = Invoke-Pester -Script $resolvedTest -PassThru -Strict

Write-Output "Pester: expected_count=$ExpectedCount actual_count=$($result.TotalCount) failure_count=$($result.FailedCount)"
if ($ExpectedCount -le 0 -or $result.TotalCount -ne $ExpectedCount -or $result.FailedCount -ne 0) {
    exit 1
}

exit 0
