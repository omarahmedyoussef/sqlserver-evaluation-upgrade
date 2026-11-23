/*
  11 - Re-enable jobs, run one manually, then check job history.
*/
USE msdb;

DECLARE @job SYSNAME;
DECLARE c CURSOR FOR SELECT name FROM dbo.sysjobs WHERE enabled = 0;
-- If some jobs were disabled BEFORE you started, filter them out here.
OPEN c; FETCH NEXT FROM c INTO @job;
WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC dbo.sp_update_job @job_name = @job, @enabled = 1;
    PRINT 'Enabled: ' + @job;
    FETCH NEXT FROM c INTO @job;
END
CLOSE c; DEALLOCATE c;

-- Run one job manually as a smoke test
-- EXEC msdb.dbo.sp_start_job @job_name = N'<YourJobName>';

-- Is it still running? (stop_execution_date NULL = running)
SELECT j.name, ja.start_execution_date, ja.stop_execution_date
FROM msdb.dbo.sysjobactivity ja
JOIN msdb.dbo.sysjobs j ON j.job_id = ja.job_id
WHERE ja.session_id = (SELECT MAX(session_id) FROM msdb.dbo.syssessions)
  AND ja.start_execution_date IS NOT NULL
ORDER BY ja.start_execution_date DESC;

-- Next day: every job outcome since the upgrade (expect no 'Failed')
DECLARE @since DATETIME = DATEADD(DAY, -1, GETDATE());   -- set to your upgrade time
SELECT j.name,
       CASE h.run_status WHEN 1 THEN 'Succeeded' WHEN 0 THEN 'Failed' ELSE 'Other' END AS Status,
       COUNT(*) AS Runs,
       MAX(msdb.dbo.agent_datetime(h.run_date, h.run_time)) AS LastRun
FROM msdb.dbo.sysjobhistory h
JOIN msdb.dbo.sysjobs j ON j.job_id = h.job_id
WHERE h.step_id = 0
  AND msdb.dbo.agent_datetime(h.run_date, h.run_time) >= @since
GROUP BY j.name, h.run_status
ORDER BY j.name, Status;
