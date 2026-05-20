param( # Line command params
    [int]$targetPid,   # PID of the process to monitor
    [string]$outfile   # output file where memory values will be saved
)
# Write header line to the output file
"mem_kb" | Out-File $outfile -Encoding ascii
# Loop while the target process is still running
while (Get-Process -Id $targetPid -ErrorAction SilentlyContinue) {
    $p = Get-Process -Id $targetPid # Get the process object
    # WorkingSet64 is in bytes, convert to KB
    $memKB = [math]::Round($p.WorkingSet64 / 1KB)
    # Append the memory value to the output file
    "$memKB" | Out-File $outfile -Append -Encoding ascii
    Start-Sleep -Milliseconds 10 # Wait 10 milliseconds before next sample
}
