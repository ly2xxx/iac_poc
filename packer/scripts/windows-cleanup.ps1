# Windows cleanup script for templates
# Based on VirtualizationHowTo article best practices

Write-Host "Starting Windows cleanup process..."

# Clear Windows Update downloads
Get-ChildItem "C:\Windows\SoftwareDistribution\Download" -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

# Clear temp files
Get-ChildItem "C:\Windows\Temp" -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
Get-ChildItem "C:\Users\*\AppData\Local\Temp" -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

# Clear event logs
Get-WinEvent -ListLog * | Where-Object {$_.RecordCount -gt 0} | ForEach-Object {
    try {
        Clear-WinEvent -LogName $_.LogName -ErrorAction SilentlyContinue
    } catch {
        Write-Host "Could not clear log: $($_.LogName)"
    }
}

# Clear recycle bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# Run disk cleanup
Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait

# Defragment system drive
Optimize-Volume -DriveLetter C -Defrag

Write-Host "Windows cleanup complete"
