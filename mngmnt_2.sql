-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 1. Look for I/O requests taking longer than 15 seconds in the five most recent SQL Server Error Logs (Query 24)
CREATE TABLE #IOWarningResults(LogDate datetime, ProcessInfo sysname, LogText nvarchar(1000));

	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 0, 1, N'taking longer than 15 seconds';

	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 1, 1, N'taking longer than 15 seconds';

	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 2, 1, N'taking longer than 15 seconds';

	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 3, 1, N'taking longer than 15 seconds';

	INSERT INTO #IOWarningResults 
	EXEC xp_readerrorlog 4, 1, N'taking longer than 15 seconds';

SELECT [LogDate], [ProcessInfo], [LogText]
FROM #IOWarningResults
ORDER BY [LogDate] DESC;

DROP TABLE #IOWarningResults;
-- Finding 15 second I/O warnings in the SQL Server Error Log is useful evidence of
-- poor I/O performance (which might have many different causes)
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 2. Drive level latency information
SELECT [Drive],
	CASE 
		WHEN [num_of_reads] = 0 THEN 0 
		ELSE ([io_stall_read_ms] / [num_of_reads]) 
	END AS [Read Latency],
	CASE 
		WHEN [io_stall_write_ms] = 0 THEN 0 
		ELSE ([io_stall_write_ms] / [num_of_writes]) 
	END AS [Write Latency],
	CASE 
		WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0) THEN 0 
		ELSE ([io_stall] / ([num_of_reads] + [num_of_writes])) 
	END AS [Overall Latency],
	CASE 
		WHEN [num_of_reads] = 0 THEN 0 
		ELSE ([num_of_bytes_read] / [num_of_reads]) 
	END AS [Avg Bytes/Read],
	CASE 
		WHEN [io_stall_write_ms] = 0 THEN 0 
		ELSE ([num_of_bytes_written] / [num_of_writes]) 
	END AS [Avg Bytes/Write],
	CASE 
		WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0) THEN 0 
		ELSE (([num_of_bytes_read] + [num_of_bytes_written]) / ([num_of_reads] + [num_of_writes])) 
	END AS [Avg Bytes/Transfer]
FROM (SELECT LEFT(UPPER(mf.[physical_name]), 2) AS [Drive], 
             SUM([num_of_reads]) AS [num_of_reads],
	         SUM([io_stall_read_ms]) AS [io_stall_read_ms], 
	         SUM([num_of_writes]) AS [num_of_writes],
	         SUM([io_stall_write_ms]) AS [io_stall_write_ms], 
	         SUM([num_of_bytes_read]) AS [num_of_bytes_read],
	         SUM([num_of_bytes_written]) AS [num_of_bytes_written], 
	         SUM([io_stall]) AS [io_stall]
      FROM sys.[dm_io_virtual_file_stats](NULL, NULL) vfs
      INNER JOIN sys.[master_files] mf WITH (NOLOCK)
      ON vfs.[database_id] = mf.[database_id] AND vfs.[file_id] = mf.[file_id]
      GROUP BY LEFT(UPPER(mf.[physical_name]), 2)
      ) tab
ORDER BY [Overall Latency] OPTION (RECOMPILE);

-- Shows you the drive-level latency for reads and writes, in milliseconds
-- Latency above 20-25ms is usually a problem

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 3. Calculates average stalls per read, per write, and per total input/output for each database file  (Query 26) (IO Stalls by File)
SELECT DB_NAME(fs.[database_id]) AS [Database Name], 
       CAST(fs.[io_stall_read_ms]/(1.0 + fs.[num_of_reads]) AS NUMERIC(10,1)) AS [avg_read_stall_ms],
       CAST(fs.[io_stall_write_ms]/(1.0 + fs.[num_of_writes]) AS NUMERIC(10,1)) AS [avg_write_stall_ms],
       CAST((fs.[io_stall_read_ms] + fs.[io_stall_write_ms])/(1.0 + fs.[num_of_reads] + fs.[num_of_writes]) AS NUMERIC(10,1)) AS [avg_io_stall_ms],
       CONVERT(DECIMAL(18,2), mf.[size]/128.0) AS [File Size (MB)], 
       mf.[physical_name], 
       mf.[type_desc], 
       fs.[io_stall_read_ms], 
       fs.[num_of_reads], 
       fs.[io_stall_write_ms], 
       fs.[num_of_writes], 
       fs.[io_stall_read_ms] + fs.[io_stall_write_ms] AS [io_stalls], 
       fs.[num_of_reads] + fs.[num_of_writes] AS [total_io],
       [io_stall_queued_read_ms] AS [Resource Governor Total Read IO Latency (ms)], 
       [io_stall_queued_write_ms] AS [Resource Governor Total Write IO Latency (ms)] 
FROM sys.[dm_io_virtual_file_stats](null,null) fs
INNER JOIN sys.[master_files] mf WITH (NOLOCK) ON (fs.[database_id] = mf.[database_id]) AND (fs.[file_id] = mf.[file_id])
ORDER BY [avg_io_stall_ms] DESC OPTION (RECOMPILE);
-- Helps determine which database files on the entire instance have the most I/O bottlenecks
-- This can help you decide whether certain LUNs are overloaded and whether you might
-- want to move some files to a different location or perhaps improve your I/O performance

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 4. Recovery model, log reuse wait description, log file size, log usage size and compatibility level for all databases on instance
SELECT db.[name] AS [Database Name],
       db.[recovery_model_desc] AS [Recovery Model], 
       db.[state_desc], 
       db.[log_reuse_wait_desc] AS [Log Reuse Wait Description], 
       CONVERT(DECIMAL(18,2), ls.[cntr_value]/1024.0) AS [Log Size (MB)], 
       CONVERT(DECIMAL(18,2), lu.[cntr_value]/1024.0) AS [Log Used (MB)],
       CAST(CAST(lu.[cntr_value] AS FLOAT) / CAST(ls.[cntr_value] AS FLOAT)AS DECIMAL(18,2)) * 100 AS [Log Used %], 
       db.[compatibility_level] AS [DB Compatibility Level], 
       db.[page_verify_option_desc] AS [Page Verify Option], 
       db.[is_auto_create_stats_on], 
       db.[is_auto_update_stats_on], 
       db.[is_auto_update_stats_async_on], 
       db.[is_parameterization_forced], 
       db.[snapshot_isolation_state_desc], 
       db.[is_read_committed_snapshot_on], 
       db.[is_auto_close_on], 
       db.[is_auto_shrink_on], 
       db.[target_recovery_time_in_seconds], 
       db.[is_cdc_enabled], 
       db.[is_memory_optimized_elevate_to_snapshot_on], 
       db.[delayed_durability_desc], 
       db.[is_auto_create_stats_incremental_on]      
FROM sys.databases db WITH (NOLOCK)
INNER JOIN sys.dm_os_performance_counters lu WITH (NOLOCK) ON db.name = lu.instance_name
INNER JOIN sys.dm_os_performance_counters ls WITH (NOLOCK) ON db.name = ls.instance_name
WHERE lu.counter_name LIKE N'Log File(s) Used Size (KB)%' 
      AND ls.counter_name LIKE N'Log File(s) Size (KB)%'
      AND ls.cntr_value > 0 
ORDER BY db.[name] OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 5. Missing Indexes for all databases by Index Advantage  (Query 28) (Missing Indexes All Databases)
SELECT CONVERT(decimal(18,2), [user_seeks] * [avg_total_user_cost] * ([avg_user_impact] * 0.01)) AS [index_advantage], 
       migs.[last_user_seek], 
       mid.[statement] AS [Database.Schema.Table],
       mid.[equality_columns], 
       mid.[inequality_columns], 
       mid.[included_columns],
       migs.[unique_compiles], 
       migs.[user_seeks], 
       migs.[avg_total_user_cost], 
       migs.[avg_user_impact]
FROM sys.[dm_db_missing_index_group_stats] migs WITH (NOLOCK)
INNER JOIN sys.[dm_db_missing_index_groups] mig WITH (NOLOCK) ON migs.[group_handle] = mig.[index_group_handle]
INNER JOIN sys.[dm_db_missing_index_details] mid WITH (NOLOCK) ON mig.[index_handle] = mid.[index_handle]
ORDER BY [index_advantage] DESC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Get VLF Counts for all databases on the instance (Query 29) (VLF Counts)
-- (adapted from Michelle Ufford) 
CREATE TABLE #VLFInfo (RecoveryUnitID int, FileID  int,
					   FileSize bigint, StartOffset bigint,
					   FSeqNo      bigint, [Status]    bigint,
					   Parity      bigint, CreateLSN   numeric(38));
	 
CREATE TABLE #VLFCountResults(DatabaseName sysname, VLFCount int);
	 
EXEC sp_MSforeachdb N'Use [?]; 

				INSERT INTO #VLFInfo 
				EXEC sp_executesql N''DBCC LOGINFO([?])''; 
	 
				INSERT INTO #VLFCountResults 
				SELECT DB_NAME(), COUNT(*) 
				FROM #VLFInfo; 

				TRUNCATE TABLE #VLFInfo;'
	 
SELECT DatabaseName, VLFCount  
FROM #VLFCountResults
ORDER BY VLFCount DESC;
	 
DROP TABLE #VLFInfo;
DROP TABLE #VLFCountResults;

-- High VLF counts can affect write performance 
-- and they can make database restores and recovery take much longer
-- Try to keep your VLF counts under 200 in most cases

-- ///////////////////////////////////////////////////////////////////////////////
-- Get CPU utilization by database (Query 30) (CPU Usage by Database)
WITH DB_CPU_Stats
AS (
    SELECT [DatabaseID], DB_Name([DatabaseID]) AS [Database Name], 
           SUM([total_worker_time]) AS [CPU_Time_Ms]
    FROM sys.[dm_exec_query_stats] AS qs
    CROSS APPLY (SELECT CONVERT(int, [value]) AS [DatabaseID] 
                 FROM sys.[dm_exec_plan_attributes](qs.[plan_handle])
                 WHERE attribute = N'dbid'
                ) F_DB
    GROUP BY DatabaseID
)
SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Time_Ms] DESC) AS [CPU Rank],
       [Database Name], 
       [CPU_Time_Ms] AS [CPU Time (ms)], 
       CAST([CPU_Time_Ms] * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPU Percent]
FROM DB_CPU_Stats
WHERE [DatabaseID] <> 32767 -- ResourceDB
ORDER BY [CPU Rank] OPTION (RECOMPILE);

-- //////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Get I/O utilization by database (Query 31) (IO Usage By Database)
WITH Aggregate_IO_Statistics
AS
(SELECT DB_NAME(database_id) AS [Database Name],
CAST(SUM(num_of_bytes_read + num_of_bytes_written)/1048576 AS DECIMAL(12, 2)) AS io_in_mb
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS [DM_IO_STATS]
GROUP BY database_id)
SELECT ROW_NUMBER() OVER(ORDER BY io_in_mb DESC) AS [I/O Rank], [Database Name], io_in_mb AS [Total I/O (MB)],
       CAST(io_in_mb/ SUM(io_in_mb) OVER() * 100.0 AS DECIMAL(5,2)) AS [I/O Percent]
FROM Aggregate_IO_Statistics
ORDER BY [I/O Rank] OPTION (RECOMPILE);

-- //////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Get total buffer usage by database for current instance  (Query 32) (Total Buffer Usage by Database)
WITH AggregateBufferPoolUsage
AS
(SELECT DB_NAME(database_id) AS [Database Name],
CAST(COUNT(*) * 8/1024.0 AS DECIMAL (10,2))  AS [CachedSize]
FROM sys.dm_os_buffer_descriptors WITH (NOLOCK)
WHERE database_id <> 32767 -- ResourceDB
GROUP BY DB_NAME(database_id))
SELECT ROW_NUMBER() OVER(ORDER BY CachedSize DESC) AS [Buffer Pool Rank], [Database Name], CachedSize AS [Cached Size (MB)],
       CAST(CachedSize / SUM(CachedSize) OVER() * 100.0 AS DECIMAL(5,2)) AS [Buffer Pool Percent]
FROM AggregateBufferPoolUsage
ORDER BY [Buffer Pool Rank] OPTION (RECOMPILE);

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Clear Wait Stats with this command
-- DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);

-- Isolate top waits for server instance since last restart or wait statistics clear  (Query 33) (Top Waits)
WITH [Waits] 
AS (SELECT wait_type, wait_time_ms/ 1000.0 AS [WaitS],
          (wait_time_ms - signal_wait_time_ms) / 1000.0 AS [ResourceS],
           signal_wait_time_ms / 1000.0 AS [SignalS],
           waiting_tasks_count AS [WaitCount],
           100.0 *  wait_time_ms / SUM (wait_time_ms) OVER() AS [Percentage],
           ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS [RowNum]
    FROM sys.dm_os_wait_stats WITH (NOLOCK)
    WHERE [wait_type] NOT IN (
        N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR', N'BROKER_TASK_STOP',
		N'BROKER_TO_FLUSH', N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
        N'CHKPT', N'CLR_AUTO_EVENT', N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
        N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE', N'DBMIRROR_WORKER_QUEUE',
		N'DBMIRRORING_CMD', N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC', N'FSAGENT', N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
        N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', N'HADR_LOGCAPTURE_WAIT', 
		N'HADR_NOTIFICATION_DEQUEUE', N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
        N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP', N'LOGMGR_QUEUE', N'ONDEMAND_TASK_QUEUE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED', N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP', N'REQUEST_FOR_DEADLOCK_SEARCH',
		N'RESOURCE_QUEUE', N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP',
		N'SLEEP_DCOMSTARTUP', N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP', N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT', N'SP_SERVER_DIAGNOSTICS_SLEEP',
		N'SQLTRACE_BUFFER_FLUSH', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', N'SQLTRACE_WAIT_ENTRIES',
		N'WAIT_FOR_RESULTS', N'WAITFOR', N'WAITFOR_TASKSHUTDOWN', N'WAIT_XTP_HOST_WAIT',
		N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', N'WAIT_XTP_CKPT_CLOSE', N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT')
    AND waiting_tasks_count > 0)
SELECT
    MAX (W1.wait_type) AS [WaitType],
    CAST (MAX (W1.WaitS) AS DECIMAL (16,2)) AS [Wait_Sec],
    CAST (MAX (W1.ResourceS) AS DECIMAL (16,2)) AS [Resource_Sec],
    CAST (MAX (W1.SignalS) AS DECIMAL (16,2)) AS [Signal_Sec],
    MAX (W1.WaitCount) AS [Wait Count],
    CAST (MAX (W1.Percentage) AS DECIMAL (5,2)) AS [Wait Percentage],
    CAST ((MAX (W1.WaitS) / MAX (W1.WaitCount)) AS DECIMAL (16,4)) AS [AvgWait_Sec],
    CAST ((MAX (W1.ResourceS) / MAX (W1.WaitCount)) AS DECIMAL (16,4)) AS [AvgRes_Sec],
    CAST ((MAX (W1.SignalS) / MAX (W1.WaitCount)) AS DECIMAL (16,4)) AS [AvgSig_Sec]
FROM Waits AS W1
INNER JOIN Waits AS W2
ON W2.RowNum <= W1.RowNum
GROUP BY W1.RowNum
HAVING SUM (W2.Percentage) - MAX (W1.Percentage) < 99 -- percentage threshold
OPTION (RECOMPILE);

-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Signal Waits for instance  (Query 34) (Signal Waits)
SELECT CAST(100.0 * SUM(signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [% Signal (CPU) Waits],
CAST(100.0 * SUM(wait_time_ms - signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) AS [% Resource Waits]
FROM sys.dm_os_wait_stats WITH (NOLOCK)
WHERE wait_type NOT IN (
        N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR', N'BROKER_TASK_STOP',
		N'BROKER_TO_FLUSH', N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
        N'CHKPT', N'CLR_AUTO_EVENT', N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
        N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE', N'DBMIRROR_WORKER_QUEUE',
		N'DBMIRRORING_CMD', N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC', N'FSAGENT', N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
        N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', N'HADR_LOGCAPTURE_WAIT', 
		N'HADR_NOTIFICATION_DEQUEUE', N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
        N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP', N'LOGMGR_QUEUE', N'ONDEMAND_TASK_QUEUE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED', N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP', N'REQUEST_FOR_DEADLOCK_SEARCH',
		N'RESOURCE_QUEUE', N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP',
		N'SLEEP_DCOMSTARTUP', N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP', N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT', N'SP_SERVER_DIAGNOSTICS_SLEEP',
		N'SQLTRACE_BUFFER_FLUSH', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', N'SQLTRACE_WAIT_ENTRIES',
		N'WAIT_FOR_RESULTS', N'WAITFOR', N'WAITFOR_TASKSHUTDOWN', N'WAIT_XTP_HOST_WAIT',
		N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', N'WAIT_XTP_CKPT_CLOSE', N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT') OPTION (RECOMPILE);
       
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
--  Get logins that are connected and how many sessions they have (Query 35) (Connection Counts)
SELECT login_name, [program_name], COUNT(session_id) AS [session_count] 
FROM sys.dm_exec_sessions WITH (NOLOCK)
GROUP BY login_name, [program_name]
ORDER BY COUNT(session_id) DESC OPTION (RECOMPILE);

-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Get a count of SQL connections by IP address (Query 36) (Connection Counts by IP Address)
SELECT ec.client_net_address, es.[program_name], es.[host_name], es.login_name, 
COUNT(ec.session_id) AS [connection count] 
FROM sys.dm_exec_sessions AS es WITH (NOLOCK) 
INNER JOIN sys.dm_exec_connections AS ec WITH (NOLOCK) 
ON es.session_id = ec.session_id 
GROUP BY ec.client_net_address, es.[program_name], es.[host_name], es.login_name  
ORDER BY ec.client_net_address, es.[program_name] OPTION (RECOMPILE);

-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Get Average Task Counts (run multiple times)  (Query 37) (Avg Task Counts)
SELECT AVG(current_tasks_count) AS [Avg Task Count], 
AVG(runnable_tasks_count) AS [Avg Runnable Task Count],
AVG(pending_disk_io_count) AS [Avg Pending DiskIO Count]
FROM sys.dm_os_schedulers WITH (NOLOCK)
WHERE scheduler_id < 255 OPTION (RECOMPILE);

-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Get CPU Utilization History for last 256 minutes (in one minute intervals)  (Query 38) (CPU Utilization History)
-- This version works with SQL Server 2014
DECLARE @ts_now bigint = (SELECT cpu_ticks/(cpu_ticks/ms_ticks) FROM sys.dm_os_sys_info WITH (NOLOCK)); 

SELECT TOP(256) SQLProcessUtilization AS [SQL Server Process CPU Utilization], 
               SystemIdle AS [System Idle Process], 
               100 - SystemIdle - SQLProcessUtilization AS [Other Process CPU Utilization], 
               DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [Event Time] 
FROM (SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') 
			AS [SystemIdle], 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') 
			AS [SQLProcessUtilization], [timestamp] 
	  FROM (SELECT [timestamp], CONVERT(xml, record) AS [record] 
			FROM sys.dm_os_ring_buffers WITH (NOLOCK)
			WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
			AND record LIKE N'%<SystemHealth>%') AS x) AS y 
ORDER BY record_id DESC OPTION (RECOMPILE);

-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Get top total worker time queries for entire instance (Query 39) (Top Worker Time Queries)
SELECT TOP(50) DB_NAME(t.[dbid]) AS [Database Name], t.[text] AS [Query Text],  
qs.total_worker_time AS [Total Worker Time], qs.min_worker_time AS [Min Worker Time],
qs.total_worker_time/qs.execution_count AS [Avg Worker Time], 
qs.max_worker_time AS [Max Worker Time], qs.execution_count AS [Execution Count], 
qs.total_elapsed_time/qs.execution_count AS [Avg Elapsed Time], 
qs.total_logical_reads/qs.execution_count AS [Avg Logical Reads], 
qs.total_physical_reads/qs.execution_count AS [Avg Physical Reads], 
qp.query_plan AS [Query Plan], qs.creation_time AS [Creation Time]
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t 
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp 
ORDER BY qs.total_worker_time DESC OPTION (RECOMPILE);

-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Good basic information about OS memory amounts and state  (Query 40) (System Memory)
SELECT total_physical_memory_kb/1024 AS [Physical Memory (MB)], 
       available_physical_memory_kb/1024 AS [Available Memory (MB)], 
       total_page_file_kb/1024 AS [Total Page File (MB)], 
	   available_page_file_kb/1024 AS [Available Page File (MB)], 
	   system_cache_kb/1024 AS [System Cache (MB)],
       system_memory_state_desc AS [System Memory State]
FROM sys.dm_os_sys_memory WITH (NOLOCK) OPTION (RECOMPILE);

-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- SQL Server Process Address space info  (Query 41) (Process Memory)
-- (shows whether locked pages is enabled, among other things)
SELECT physical_memory_in_use_kb/1024 AS [SQL Server Memory Usage (MB)],
       large_page_allocations_kb, locked_page_allocations_kb, page_fault_count, 
	   memory_utilization_percentage, available_commit_limit_kb, 
	   process_physical_memory_low, process_virtual_memory_low
FROM sys.dm_os_process_memory WITH (NOLOCK) OPTION (RECOMPILE);

-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Page Life Expectancy (PLE) value for each NUMA node in current instance  (Query 42) (PLE by NUMA Node)
SELECT @@SERVERNAME AS [Server Name], [object_name], instance_name, cntr_value AS [Page Life Expectancy]
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE [object_name] LIKE N'%Buffer Node%' -- Handles named instances
AND counter_name = N'Page life expectancy' OPTION (RECOMPILE);

-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Memory Grants Pending value for current instance  (Query 43) (Memory Grants Pending)
SELECT @@SERVERNAME AS [Server Name], [object_name], cntr_value AS [Memory Grants Pending]                                                                                                       
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE [object_name] LIKE N'%Memory Manager%' -- Handles named instances
AND counter_name = N'Memory Grants Pending' OPTION (RECOMPILE);

-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Memory Clerk Usage for instance  (Query 44) (Memory Clerk Usage)
-- Look for high value for CACHESTORE_SQLCP (Ad-hoc query plans)
SELECT TOP(10) [type] AS [Memory Clerk Type], 
       SUM(pages_kb)/1024 AS [Memory Usage (MB)] 
FROM sys.dm_os_memory_clerks WITH (NOLOCK)
GROUP BY [type]  
ORDER BY SUM(pages_kb) DESC OPTION (RECOMPILE);

-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- Find single-use, ad-hoc and prepared queries that are bloating the plan cache  (Query 44) (Ad hoc Queries)
SELECT TOP(50) [text] AS [QueryText], cp.cacheobjtype, cp.objtype, cp.size_in_bytes 
FROM sys.dm_exec_cached_plans AS cp WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(plan_handle) 
WHERE cp.cacheobjtype = N'Compiled Plan' 
AND cp.objtype IN (N'Adhoc', N'Prepared') 
AND cp.usecounts = 1
ORDER BY cp.size_in_bytes DESC OPTION (RECOMPILE);
