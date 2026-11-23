/*
  04 - Prove the backup files are restorable (reads them without restoring).
  Expect "The backup set on file 1 is valid." for every database.
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
    SET @sql = N'RESTORE VERIFYONLY FROM DISK = N''' + @path + @name +
               N'_PreUpgrade.bak'' WITH CHECKSUM;';
    PRINT '--- ' + @name;
    EXEC (@sql);
    FETCH NEXT FROM db_cur INTO @name;
END
CLOSE db_cur; DEALLOCATE db_cur;
