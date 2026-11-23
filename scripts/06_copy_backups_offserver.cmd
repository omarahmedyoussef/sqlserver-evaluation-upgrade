@echo off
REM 06 - Copy backups OFF the server.
REM A backup on the same disk/VM as the data is not a real backup:
REM if the storage or host fails, the data, the backup and the snapshot go together.
REM Use a share with restricted (IT-only) permissions - backups contain all your data.

robocopy C:\PreUpgrade "\\<fileserver>\<restricted-share>\PreUpgrade_%DATE:~-4%" /E /R:2 /W:5
REM Check the summary table: FAILED must be 0.
