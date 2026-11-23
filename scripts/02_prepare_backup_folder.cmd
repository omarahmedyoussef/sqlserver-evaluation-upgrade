@echo off
REM 02 - Create the backup folder and give the SQL Server service account write access.
REM Run in an elevated (Administrator) command prompt.
REM "Operating system error 5 (Access is denied)" during BACKUP means the
REM SQL Server SERVICE ACCOUNT can't write to the folder - not your Windows user.

REM Check the drive is a real disk (not a mounted CD-ROM) and has free space:
powershell "Get-Volume | Where-Object DriveLetter | Select DriveLetter, DriveType, @{n='FreeGB';e={[math]::Round($_.SizeRemaining/1GB,1)}} | Format-Table -AutoSize"

set BACKUP_DIR=C:\PreUpgrade
REM Default instance service account. Check yours with:
REM   SELECT servicename, service_account FROM sys.dm_server_services;
set SQL_SVC=NT Service\MSSQLSERVER

mkdir "%BACKUP_DIR%"
icacls "%BACKUP_DIR%" /grant "%SQL_SVC%":(OI)(CI)M
