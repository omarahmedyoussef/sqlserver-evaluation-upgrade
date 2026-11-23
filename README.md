# SQL Server Evaluation Edition Upgrade – Runbook & Scripts

A step-by-step runbook for moving a SQL Server instance (plus SSRS) off the **180-day Evaluation edition** before it expires, with no data loss and a tested rollback path.

Written from a real upgrade of a data warehouse on **SQL Server 2025 + SSRS 2022**, with SQL Agent ETL jobs running hourly.

## Why this matters

When Evaluation expires, the **SQL Server service won't start** (`Error 17051: SQL Server evaluation edition has expired`). At that point the normal in-place *Edition Upgrade* usually fails, and you're stuck installing a new instance and restoring databases under pressure.

Do it **before** it expires and the upgrade itself takes about five minutes. Most of the work is preparation.

## Choosing the target edition

| Edition | Cost | Licensed for production? |
|---|---|---|
| Enterprise / Standard | Paid (needs product key) | ✅ Yes |
| Enterprise Developer / Standard Developer (2025) | Free | ❌ Dev/test only |
| Express | Free | ✅ Yes, but 10 GB per database limit |

> Evaluation has all Enterprise features. On SQL Server 2025, pick **Enterprise Developer** if you want to keep the same feature set. **Standard Developer** behaves like Standard and may break features you were using.

## The runbook

| # | Step | Script |
|---|---|---|
| 1 | Check edition, days left, database sizes | `01_check_evaluation_days_left.sql` |
| 2 | Create backup folder, grant the **SQL service account** write access | `02_prepare_backup_folder.cmd` |
| 3 | Full `COPY_ONLY` backup of **all** DBs incl. `master`, `msdb`, `model` | `03_backup_all_databases.sql` |
| 4 | `RESTORE VERIFYONLY` every backup | `04_verify_backups.sql` |
| 5 | Script out Agent jobs (SSMS → Jobs → F7 → select all → Script Job as → CREATE To → File) | – |
| 6 | Back up the **SSRS encryption key** | `05_backup_ssrs_key.cmd` |
| 7 | Copy backups **off the server** to a restricted share | `06_copy_backups_offserver.cmd` |
| 8 | Disable Agent jobs | `07_disable_jobs.sql` |
| 9 | Stop services → **VM snapshot** → start services | `08_stop_start_services.cmd` |
| 10 | Mount ISO → `setup.exe` → Maintenance → **Edition Upgrade** | `09_mount_iso_and_setup.cmd` |
| 11 | Verify edition, DB states, services, job count | `10_post_upgrade_checks.sql` |
| 12 | Re-enable jobs, run one manually, check history the next day | `11_enable_jobs_and_test.sql` |
| 13 | Upgrade **SSRS** edition separately (see below) | – |
| 14 | After 2–3 stable days: delete the VM snapshot, dismount the ISO | – |

## Backup vs. snapshot: you need both

- **VM snapshot** = fast rollback point. Revert the whole VM in minutes if setup fails halfway. But it lives on the **same storage** as the VM and depends on the base disk, so it is **not a backup**.
- **Database backups** = your real safety net, *if* they're verified and **copied off the server**. A backup on the same disk as the data dies with that disk.

**Risks if you skip them:**
- Setup fails mid-way and the service won't start → no fast way back
- Storage or host failure during the change → data, backups and snapshot lost together
- Corrupt backup file discovered only when you need it → that's why `RESTORE VERIFYONLY` exists
- Lost `msdb` → every Agent job and schedule gone
- Lost SSRS key → reports open but can't connect to their data sources

## Gotchas we hit

- **`Operating system error 5 (Access is denied)` on BACKUP.** SQL Server writes the file as its **service account** (e.g. `NT Service\MSSQLSERVER`), not as you. Grant that account Modify on the folder.
- **The "D:" drive was a CD-ROM.** The Windows install ISO was still mounted: 0 bytes free, read-only. Check `DriveType` before choosing a backup location.
- **SSRS is a separate product with its own license.** Upgrading the Database Engine doesn't touch it. Check *Report Server Configuration Manager → Edition*.
- **SQL Server 2025 doesn't include SSRS.** Microsoft consolidated on-prem reporting into Power BI Report Server, so you need the standalone **SSRS 2022 installer** to change its edition.
- **Re-running the SSRS installer and clicking Next only patched it** (version changed, edition stayed Evaluation). You have to explicitly choose the edition.
- **No "Mount" on right-click.** WinRAR/7-Zip had taken over `.iso`. Use `Mount-DiskImage`.
- **The SSRS `.snk` key file is only ~52 bytes.** That's normal.
- **SSRS subscription jobs have GUID names.** Those Agent jobs are created by SSRS; don't delete them.

## SSRS edition upgrade

1. Download *Microsoft SQL Server 2022 Reporting Services* (`SQLServerReportingServices.exe`) from the Microsoft Download Center.
2. Run as Administrator → choose to upgrade the edition → pick the target edition → finish.
3. Verify in **Report Server Configuration Manager**: *Edition* must no longer say Evaluation.
4. Open the web portal (`http://localhost/Reports`) and run a report.

## Disclaimer

Test in your own environment and review Microsoft's licensing terms for your use case. Scripts are provided as-is.
