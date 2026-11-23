/*
  03 - Full backup of ALL databases, including master, msdb and model.
  - msdb holds your SQL Agent jobs, so its backup is your jobs backup.
  - COPY_ONLY: does not break your existing backup chain.
  - CHECKSUM:  validates pages while backing up.
*/
DECLARE @path NVARCHAR(400) = N'C:\PreUpgrade\';   -- change me
DECLARE @name SYSNAME, @sql NVARCHAR(MAX);

DECLARE db_cur CURSOR FOR
    SELECT name FROM sys.databases
    WHERE name <> 'tempdb' AND state_desc = 'ONLINE';

OPEN db_cur;
FETCH NEXT FROM db_cur INTO @name;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'BACKUP DATABASE ' + QUOTENAME(@name) +
               N' TO DISK = N''' + @path + @name + N'_PreUpgrade.bak''' +
               N' WITH COPY_ONLY, CHECKSUM, COMPRESSION, INIT, STATS = 10;';
    PRINT @sql;
    EXEC (@sql);
    FETCH NEXT FROM db_cur INTO @name;
END
CLOSE db_cur; DEALLOCATE db_cur;

-- Confirm every database got a backup in the last hour (no NULLs allowed)
SELECT d.name,
       b.backup_finish_date,
       CAST(b.compressed_backup_size / 1024 / 1024 AS DECIMAL(10,1)) AS SizeMB,
       m.physical_device_name
FROM sys.databases d
LEFT JOIN msdb.dbo.backupset b
       ON b.database_name = d.name
      AND b.backup_finish_date > DATEADD(HOUR, -1, GETDATE())
LEFT JOIN msdb.dbo.backupmediafamily m ON m.media_set_id = b.media_set_id
WHERE d.name <> 'tempdb'
ORDER BY d.name;
