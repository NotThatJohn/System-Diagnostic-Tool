
# ===========================================
# System Diagnostic & Health Check Tool
# Author: Jonathan Bell
# Version: 1.0
# ===========================================

Write-Host "Starting System Diagnostic Tool..." -ForegroundColor Cyan

# -----------------------------
# System Information
# -----------------------------
$systemInfo = [PSCustomObject]@{
    ComputerName = $env:COMPUTERNAME
    OSVersion    = (Get-CimInstance Win32_OperatingSystem).Caption
    OSBuild      = (Get-CimInstance Win32_OperatingSystem).BuildNumber
    Uptime       = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
}

# Display system info
Write-Host "`n=== SYSTEM INFORMATION ===" -ForegroundColor Green
$systemInfo | Format-List

# -----------------------------
# CPU Usage
# -----------------------------
$cpuUsage = Get-CimInstance Win32_Processor | Select-Object -Property Name, LoadPercentage

Write-Host "`n=== CPU USAGE ===" -ForegroundColor Green
$cpuUsage | Format-Table -AutoSize

# -----------------------------
# Memory Usage
# -----------------------------
$memory = Get-CimInstance Win32_OperatingSystem | Select-Object @{Name='TotalGB';Expression={[math]::Round($_.TotalVisibleMemorySize/1MB,2)}}, @{Name='FreeGB';Expression={[math]::Round($_.FreePhysicalMemory/1MB,2)}}

Write-Host "`n=== MEMORY USAGE (GB) ===" -ForegroundColor Green
$memory | Format-Table -AutoSize

# -----------------------------
# Disk Usage
# -----------------------------
$disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | Select-Object DeviceID, @{Name='SizeGB';Expression={[math]::Round($_.Size/1GB,2)}}, @{Name='FreeGB';Expression={[math]::Round($_.FreeSpace/1GB,2)}}

Write-Host "`n=== DISK USAGE ===" -ForegroundColor Green
$disks | Format-Table -AutoSize

# -----------------------------
# Network Information
# -----------------------------
$networkAdapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object Name, MacAddress, Status

Write-Host "`n=== NETWORK ADAPTERS ===" -ForegroundColor Green
$networkAdapters | Format-Table -AutoSize

# -----------------------------
# Export to HTML
# -----------------------------
$reportPath = "C:\Users\20jon\OneDrive\Desktop\System-Diagnostic-Report.html"

$reportContent = @"
<html>
<head><title>System Diagnostic Report</title></head>
<body>
<h2>System Information</h2>
<pre>$($systemInfo | Format-List | Out-String)</pre>

<h2>CPU Usage</h2>
<pre>$($cpuUsage | Format-Table | Out-String)</pre>

<h2>Memory Usage</h2>
<pre>$($memory | Format-Table | Out-String)</pre>

<h2>Disk Usage</h2>
<pre>$($disks | Format-Table | Out-String)</pre>

<h2>Network Adapters</h2>
<pre>$($networkAdapters | Format-Table | Out-String)</pre>

</body>
</html>
"@

$reportContent | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "`nHTML report saved to $reportPath" -ForegroundColor Cyan
