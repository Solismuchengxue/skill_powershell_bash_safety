#requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$RemainingArguments
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$inputStream = [Console]::OpenStandardInput()
$buffer = [Collections.Generic.List[byte]]::new()
while ($true) {
    $nextByte = $inputStream.ReadByte()
    if ($nextByte -lt 0) {
        exit 91
    }
    if ($nextByte -eq 10) {
        break
    }
    $buffer.Add([byte]$nextByte)
}

$lineEnding = 'lf'
if ($buffer.Count -gt 0 -and $buffer[$buffer.Count - 1] -eq 13) {
    $buffer.RemoveAt($buffer.Count - 1)
    $lineEnding = 'crlf'
}
$bytes = $buffer.ToArray()
try {
    $hash = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes)).ToLowerInvariant()
    $firstByte = if ($bytes.Length -gt 0) { $bytes[0].ToString('x2') } else { 'NA' }
    $lastByte = if ($bytes.Length -gt 0) { $bytes[$bytes.Length - 1].ToString('x2') } else { 'NA' }
    $diagnostic = "received_sha256=$hash;line_ending=$lineEnding;byte_count=$($bytes.Length);first=$firstByte;last=$lastByte"
    $targetOutput = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($diagnostic))
    Write-Output 'SOLIS_SUDO_V1 SUDO_STDOUT '
    Write-Output 'SOLIS_SUDO_V1 SUDO_STDERR '
    Write-Output "SOLIS_SUDO_V1 TARGET_STDOUT $targetOutput"
    Write-Output 'SOLIS_SUDO_V1 TARGET_STDERR '
    Write-Output 'SOLIS_SUDO_V1 RESULT sudo_exit=0 target_started=1 target_exit=0'
}
finally {
    [Array]::Clear($bytes, 0, $bytes.Length)
    $buffer.Clear()
}

exit 0
