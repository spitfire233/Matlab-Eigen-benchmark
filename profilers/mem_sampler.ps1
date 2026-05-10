param(
    [int]$targetPid,
    [string]$outfile
)

"mem_kb" | Out-File $outfile -Encoding ascii

while (Get-Process -Id $pid -ErrorAction SilentlyContinue) {

    $p = Get-Process -Id $targetPid

    # WorkingSet64 = bytes
    $memKB = [math]::Round($p.WorkingSet64 / 1KB)

    "$memKB" | Out-File $outfile -Append -Encoding ascii

    Start-Sleep -Milliseconds 50
}
