##################################################################################
#
# Name: get-windowsblueprint.ps1
#
# Author: James McNabb, Eric Wold, Dylan Chamberlain, Nicholas Fair, William Wier
# Date: 8/1/2023
#
# Comments: Creates a system blueprint for the sytems provided in 
# c:\scripts\powershell\Servers-to-Scan.txt (one per line) and creates are report
# for each server in C:\scripts\powershell\blueprints\ 
# Named: {srv}-wnidowsblueprint-YYYYMMDD.txt
#                        
# Usage: .\get-windowsblueprint.ps1          
#           
# Report Sections:
# 1. Host Name
# 2. System Information (IP, DNS Gateway)
# 3. Hardware Information
# 4. Host File
# 5. User Information
# 6. Groups Information
# 7. Installed Software
# 8. Services and Statuses
# 9. Open Ports
# 10. Scheduled Tasks
# 11. Firewall Setup
# 12. Webserver Information
# 13. SSL Information
# 14. File Shares
# 15. Printer Information
#
##################################################################################

# Clear Screen
cls

#---------------------------
# Functions
#---------------------------

Function logstamp {
    # creates a logstamp - format: YearMonthDayHour
    # get date for the logstamp function
    $now=get-Date
    $yr=$now.Year.ToString()
    $mo=$now.Month.ToString()
    $dy=$now.Day.ToString()
    $hr=$now.Hour.ToString()
    $mi=$now.Minute.ToString()
    $sc=$now.Second.ToString()

    # pad date
    if ($mo.length -lt 2) {$mo="0" + $mo}
    if ($dy.length -lt 2) {$dy="0" + $dy}
#    if ($hr.length -lt 2) {$hr="0" + $hr}
#    if ($mi.length -lt 2) {$mi="0" + $mi}
#    if ($sc.length -lt 2) {$sc="0" + $sc}
    
    write-output $yr$mo$dy
#     $hr$mi$sc
}

#---------------------------
# Main
#---------------------------

#Path to Server List
#$srv = "TFSZapTest01"
$srvList = (Get-Content c:\scripts\powershell\Servers-to-Scan.txt)

foreach($srv in $srvList) 
{ 

# Create Log file name and path
# get date stamp for log by calling logstamp function
$logDate = logstamp
# logfile name
$logfilename = $srv + "-WindowsBluePrint"
# logfile extension
$logExt = ".txt"
# logfile path
$logPath = "C:\scripts\powershell\blueprints\"
# create myOutFile
$myOutFile = $logPath + $logFilename + "-" + $logDate + $logExt

# Create Logfile and path if necessary
If (Test-Path $logPath)
            {
              # File exists
              Write-Output ("Output folder exists")     
            }Else
            {
              # Create Log Folder if it does not exist
              New-Item -path $logPath -type directory
            }

If (Test-Path $myOutFile)
            {
              # Create Log file 
              New-Item -path $myOutFile -type file -force
            }   

# Get Time Stamp
$myDate = get-Date
            
# Write Header
# -----------------

    Write-Output " " | Out-File $myOutFile -Append -width 120
    Write-Output " ------------------------------------------------------------------------------------------" | Out-File $myOutFile -Append -width 120
    Write-Output " __          ___           _                     ____  _                       _       _   " | Out-File $myOutFile -Append -width 120
    Write-Output " \ \        / (_)         | |                   |  _ \| |                     (_)     | |  " | Out-File $myOutFile -Append -width 120
    Write-Output "  \ \  /\  / / _ _ __   __| | _____      _____  | |_) | |_   _  ___ _ __  _ __ _ _ __ | |_ " | Out-File $myOutFile -Append -width 120
    Write-Output "   \ \/  \/ / | | '_ \ / _` |/ _ \ \ /\ / / __|  |  _ <| | | | |/ _ \ '_ \| '__| | '_ \| __|" | Out-File $myOutFile -Append -width 120
    Write-Output "    \  /\  /  | | | | | (_| | (_) \ V  V /\__ \ | |_) | | |_| |  __/ |_) | |  | | | | | |_ " | Out-File $myOutFile -Append -width 120
    Write-Output "     \/  \/   |_|_| |_|\__,_|\___/ \_/\_/ |___/ |____/|_|\__,_|\___| .__/|_|  |_|_| |_|\__|" | Out-File $myOutFile -Append -width 120
    Write-Output "                                                                   | |                     " | Out-File $myOutFile -Append -width 120
    Write-Output "                                                                   |_|                     " | Out-File $myOutFile -Append -width 120
    Write-Output " ------------------------------------------------------------------------------------------" | Out-File $myOutFile -Append -width 120
    Write-Output " $("WindowsBlueprint for ")$($srv)" | Out-File $myOutFile -Append -width 120
    Write-Output " $("Date: ")$($myDate)" | Out-File -width 120 $myOutFile -Append
    Write-Output " ------------------------------------------------------------------------------------------" | Out-File $myOutFile -Append -width 120
    Write-Output " " | Out-File $myOutFile -Append -width 120

# Table of Contents
Write-Output "Table of Contents:" | Out-File $myOutFile -Append -width 120
Write-Output "# 1. Host Name" | Out-File $myOutFile -Append -width 120
Write-Output " 2. System Information (IP, DNS Gateway)" | Out-File $myOutFile -Append -width 120
Write-Output " 3. Hardware Information" | Out-File $myOutFile -Append -width 120
Write-Output " 4. Host File" | Out-File $myOutFile -Append -width 120
Write-Output " 5. User Information" | Out-File $myOutFile -Append -width 120
Write-Output " 6. Groups Information" | Out-File $myOutFile -Append -width 120
Write-Output " 7. Installed Software" | Out-File $myOutFile -Append -width 120
Write-Output " 8. Services and Statuses" | Out-File $myOutFile -Append -width 120
Write-Output " 9. Open Ports" | Out-File $myOutFile -Append -width 120
Write-Output " 10. Scheduled Tasks" | Out-File $myOutFile -Append -width 120
Write-Output " 11. Firewall Setup" | Out-File $myOutFile -Append -width 120
Write-Output " 12. Webserver Information" | Out-File $myOutFile -Append -width 120
Write-Output " 13. SSL Information" | Out-File $myOutFile -Append -width 120
Write-Output " 14. File Shares" | Out-File $myOutFile -Append -width 120
Write-Output " 15. Printer Information" | Out-File $myOutFile -Append -width 120
Write-Output " " | Out-File $myOutFile -Append -width 120

# 1. Host Name
# ----------------------
# Use WMI to get remote host name

$myHostName = Get-WmiObject -class Win32_ComputerSystem -computername $srv 
$myHostNameOnly = $myHostName.name
# Output host name to file
Write-Output "--- 1. Host Name  --- " | Out-File $myOutFile -Append -width 120
Write-Output "Host: $myHostNameOnly" | Out-File $myOutFile -Append -width 120

# 2. System Information (IP, DNS Gateway)
# ----------------------
# Comment Goes here

# 3. Hardware Information
# ----------------------
# Comment Goes here

# 4. Host File
# ----------------------
# Comment Goes here


# 5. User Information
# ----------------------
# Comment Goes here

# 6. Groups Information
# ----------------------
# Comment Goes here

# 7. Installed Software
# ----------------------
# Comment Goes here

# 8. Services and Statuses
# ----------------------
# Comment Goes here

# 9. Open Ports
# ----------------------
# Comment Goes here

# 10. Scheduled Tasks
# ----------------------
# Comment Goes here

# 11. Firewall Setup
# ----------------------
# Comment Goes here

# 12. Webserver Information
# ----------------------
# Comment Goes here

# 13. SSL Information
# ----------------------
# Comment Goes here

# 14. File Shares
# ----------------------
# Comment Goes here

# 15. Printer Information
# ----------------------
# Comment Goes here

 
}