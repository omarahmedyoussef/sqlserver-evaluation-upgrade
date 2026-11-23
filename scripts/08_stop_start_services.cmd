@echo off
REM 08 - Stop services for a consistent VM snapshot, then start them again.
REM Default instance names; adjust for named instances.

if /I "%1"=="stop" (
    net stop SQLServerReportingServices
    net stop SQLSERVERAGENT
    net stop MSSQLSERVER
    echo Services stopped. Take the VM snapshot now and wait for it to COMPLETE.
    goto :eof
)

if /I "%1"=="start" (
    net start MSSQLSERVER
    net start SQLSERVERAGENT
    net start SQLServerReportingServices
    goto :eof
)

echo Usage: 08_stop_start_services.cmd stop ^| start
