/*
  01 - How many days are left on SQL Server Evaluation Edition?
  Evaluation runs for 180 days from install. After that the service will not start.
*/
SELECT SERVERPROPERTY('Edition')        AS Edition,
       SERVERPROPERTY('ProductVersion') AS ProductVersion;

SELECT create_date                                              AS InstallDate,
       DATEADD(DAY, 180, create_date)                           AS ExpiryDate,
       DATEDIFF(DAY, GETDATE(), DATEADD(DAY, 180, create_date)) AS DaysLeft
FROM sys.server_principals
WHERE name = N'NT AUTHORITY\SYSTEM';

-- Database sizes (to estimate backup space and time)
SELECT d.name,
       d.state_desc,
       CAST(SUM(mf.size) * 8.0 / 1024 / 1024 AS DECIMAL(10,2)) AS SizeGB
FROM sys.databases d
JOIN sys.master_files mf ON mf.database_id = d.database_id
WHERE d.name <> 'tempdb'
GROUP BY d.name, d.state_desc
ORDER BY SizeGB DESC;
