@echo off
REM 05 - Back up the SSRS encryption key (SSRS 2017-2022, instance name SSRS).
REM Without this key, a restored ReportServer database cannot decrypt
REM data source credentials and subscriptions.
REM The password must meet Windows complexity rules. Store it somewhere safe,
REM NOT next to the .snk file.
REM Note: the .snk file is small (tens of bytes) - that is normal.

"C:\Program Files\Microsoft SQL Server Reporting Services\Shared Tools\rskeymgmt.exe" -e -f C:\PreUpgrade\SSRS_Key.snk -p "<StrongPasswordHere>" -i SSRS
