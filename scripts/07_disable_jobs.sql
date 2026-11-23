/*
  07 - Disable all enabled SQL Agent jobs before the snapshot / upgrade,
  so no ETL runs mid-change. Save the list: you'll re-enable exactly these.
*/
USE msdb;

SELECT name, enabled FROM dbo.sysjobs ORDER BY name;   -- record the "before" state

DECLARE @job SYSNAME;
DECLARE c CURSOR FOR SELECT name FROM dbo.sysjobs WHERE enabled = 1;
OPEN c; FETCH NEXT FROM c INTO @job;
WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC dbo.sp_update_job @job_name = @job, @enabled = 0;
    PRINT 'Disabled: ' + @job;
    FETCH NEXT FROM c INTO @job;
END
CLOSE c; DEALLOCATE c;

SELECT name, enabled FROM dbo.sysjobs ORDER BY name;
