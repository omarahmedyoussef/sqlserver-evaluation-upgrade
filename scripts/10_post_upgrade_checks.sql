/*
  10 - Post-upgrade verification.
*/
-- New edition (version should be unchanged for an edition-only upgrade)
SELECT SERVERPROPERTY('Edition')        AS Edition,
       SERVERPROPERTY('ProductVersion') AS ProductVersion;

-- All databases ONLINE
SELECT name, state_desc FROM sys.databases ORDER BY name;

-- Services running
SELECT servicename, status_desc FROM sys.dm_server_services;

-- Same number of jobs as before
SELECT COUNT(*) AS JobsCount FROM msdb.dbo.sysjobs;
