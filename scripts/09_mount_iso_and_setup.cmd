@echo off
REM 09 - Mount the SQL Server ISO when right-click > Mount is missing
REM (happens when WinRAR / 7-Zip owns the .iso file association).

powershell "Mount-DiskImage -ImagePath 'C:\ISO\<your-sql-server>.iso' -PassThru | Get-Volume | Select DriveLetter, FileSystemLabel"

REM Then run <DriveLetter>:\setup.exe
REM   Maintenance > Edition Upgrade > Specify a free edition > pick the edition
REM   Stop at "Edition Upgrade Rules": Failed must be 0 before continuing.

REM When finished:
REM powershell "Dismount-DiskImage -ImagePath 'C:\ISO\<your-sql-server>.iso'"
