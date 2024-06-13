-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 1.   SQL and OS Version information for current instance.
SELECT @@SERVERNAME AS [Server Name], @@VERSION AS [SQL Server and OS Version Info];

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 2. Get selected server properties.
SELECT SERVERPROPERTY('MachineName') AS [MachineName], 
       SERVERPROPERTY('ServerName') AS [ServerName],  
       SERVERPROPERTY('InstanceName') AS [Instance], 
       SERVERPROPERTY('IsClustered') AS [IsClustered], 
       SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS [ComputerNamePhysicalNetBIOS], 
       SERVERPROPERTY('Edition') AS [Edition], 
       SERVERPROPERTY('ProductLevel') AS [ProductLevel], 
       SERVERPROPERTY('ProductVersion') AS [ProductVersion], 
       SERVERPROPERTY('ProcessID') AS [ProcessID],
       SERVERPROPERTY('Collation') AS [Collation], 
       SERVERPROPERTY('IsFullTextInstalled') AS [IsFullTextInstalled], 
       SERVERPROPERTY('IsIntegratedSecurityOnly') AS [IsIntegratedSecurityOnly],
       SERVERPROPERTY('IsHadrEnabled') AS [IsHadrEnabled], 
       SERVERPROPERTY('HadrManagerStatus') AS [HadrManagerStatus],
       SERVERPROPERTY('IsXTPSupported') AS [IsXTPSupported];
	   
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 3. Get SQL Server Agent jobs and Category information.
SELECT sj.[name] AS [JobName], 
       sj.[description] AS [JobDescription], 
       SUSER_SNAME(sj.[owner_sid]) AS [JobOwner],
       sj.[date_created] AS [DateCreated], 
       sj.[enabled] AS [Enabled], 
       sj.[notify_email_operator_id] AS [NotifyEmailOperatorId], 
       sc.[name] AS [CategoryName]
FROM msdb.dbo.[sysjobs] sj WITH (NOLOCK)
INNER JOIN msdb.dbo.[syscategories] sc WITH (NOLOCK) ON sj.[category_id] = sc.[category_id]
ORDER BY sj.[name] OPTION (RECOMPILE);

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 4. Get SQL Server Agent Alert Information.
SELECT [name], [event_source], [message_id], [severity], [enabled], [has_notification], 
       [delay_between_responses], [occurrence_count], [last_occurrence_date], [last_occurrence_time]
FROM msdb.dbo.[sysalerts] WITH (NOLOCK)
ORDER BY [name] OPTION (RECOMPILE);

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 5. Returns a list of all global trace flags that are enabled.
DBCC TRACESTATUS (-1);

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 6. Windows information.
SELECT [windows_release], [windows_service_pack_level], [windows_sku], [os_language_version]
FROM sys.dm_os_windows_info WITH (NOLOCK) OPTION (RECOMPILE);

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 7. SQL Server Services information.
SELECT [servicename], [process_id], [startup_type_desc], [status_desc], [last_startup_time], [service_account],
       [is_clustered], [cluster_nodename], [filename]
FROM sys.dm_server_services WITH (NOLOCK) OPTION (RECOMPILE);

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 8. SQL Server NUMA Node information.
SELECT [node_id], [node_state_desc], [memory_node_id], [processor_group], [online_scheduler_count], 
       [active_worker_count], [avg_load_balance], [resource_monitor_state]
FROM sys.dm_os_nodes WITH (NOLOCK) 
WHERE [node_state_desc] <> N'ONLINE DAC' OPTION (RECOMPILE);

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 9. Hardware information (Cannot distinguish between HT and multi-core)
SELECT [cpu_count] AS [Logical CPU Count], 
       [scheduler_count] AS [SchedulerCount] , 
       [hyperthread_ratio] AS [Hyperthread Ratio],
       [cpu_count] / [hyperthread_ratio] AS [Physical CPU Count], 
       [physical_memory_kb] / 1024 AS [Physical Memory (MB)], 
       [committed_kb] / 1024 AS [Committed Memory (MB)],
       [committed_target_kb] / 1024 AS [Committed Target Memory (MB)],
       [max_workers_count] AS [Max Workers Count], 
       [affinity_type_desc] AS [Affinity Type], 
       [sqlserver_start_time] AS [SQL Server Start Time], 
       [virtual_machine_type_desc] AS [Virtual Machine Type]
FROM sys.dm_os_sys_info WITH (NOLOCK) OPTION (RECOMPILE);

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 10. Get System Manufacturer and model number from.
EXEC xp_readerrorlog 0, 1, "Manufacturer";

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 11. Get processor description from Windows Registry.
EXEC xp_instance_regread N'HKEY_LOCAL_MACHINE', N'HARDWARE\DESCRIPTION\System\CentralProcessor\0', N'ProcessorNameString';

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 12. Shows you where the SQL Server failover cluster diagnostic log is located and how it is configured
SELECT [is_enabled], [path], [max_size], [max_files]
FROM sys.dm_os_server_diagnostics_log_configurations WITH (NOLOCK) OPTION (RECOMPILE);

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 13. Get information about your OS cluster (if your database server is in a cluster)
SELECT [VerboseLogging], [SqlDumperDumpFlags], [SqlDumperDumpPath], [SqlDumperDumpTimeOut], 
       [FailureConditionLevel], [HealthCheckTimeout]
FROM sys.dm_os_cluster_properties WITH (NOLOCK) OPTION (RECOMPILE);

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 14. Get information about your cluster nodes and their status (if your database server is in a failover cluster)
SELECT [NodeName], [status_description], [is_current_owner]
FROM sys.dm_os_cluster_nodes WITH (NOLOCK) OPTION (RECOMPILE);

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 15. Get information about any AlwaysOn AG cluster this instance is a part of
SELECT [cluster_name], [quorum_type_desc], [quorum_state_desc]
FROM sys.dm_hadr_cluster WITH (NOLOCK) OPTION (RECOMPILE);

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 16. Get configuration values for instance
SELECT [name], [value], [value_in_use], [minimum], [maximum], [description], [is_dynamic], [is_advanced]
FROM sys.configurations WITH (NOLOCK)
ORDER BY [name] OPTION (RECOMPILE);

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 17; See if buffer pool extension (BPE) is enabled (BPE Enabled)
SELECT [path], 
       [state_description], 
	   [current_size_in_kb], 
       CAST([current_size_in_kb] / 1048576.0 AS DECIMAL(10, 2)) AS [Size (GB)]
FROM sys.dm_os_buffer_pool_extension_configuration WITH (NOLOCK) OPTION (RECOMPILE);

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 18. Look at buffer descriptors to see BPE usage by database (BPE Usage) 
SELECT DB_NAME([database_id]) AS [Database Name], 
       COUNT([page_id]) AS [Page Count],
       CAST(COUNT(*) / 128.0 AS DECIMAL(10, 2)) AS [Buffer size(MB)], 
       AVG([read_microsec]) AS [Avg Read Time (microseconds)]
FROM sys.dm_os_buffer_descriptors WITH (NOLOCK)
WHERE [database_id] <> 32767 
      AND [is_in_bpool_extension] = 1
GROUP BY DB_NAME([database_id]) 
ORDER BY [Buffer size(MB)] DESC OPTION (RECOMPILE);

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 19. Get information about TCP Listener for SQL Server  (Query 20) (TCP Listener States)
SELECT [listener_id], [ip_address], [is_ipv4], [port], [type_desc], [state_desc], [start_time]
FROM sys.dm_tcp_listener_states WITH (NOLOCK) 
ORDER BY [listener_id] OPTION (RECOMPILE);

--///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 20. Get information on location, time and size of any memory dumps from SQL Server
SELECT [filename], 
       [creation_time], 
	   [size_in_bytes] / 1048576.0 AS [Size (MB)]
FROM sys.dm_server_memory_dumps WITH (NOLOCK) 
ORDER BY [creation_time] DESC OPTION (RECOMPILE);

--///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 21, File names and paths for TempDB and all user databases in instance
SELECT DB_NAME([database_id]) AS [Database Name], 
       [file_id], 
	   [name], 
	   [physical_name], 
	   [type_desc], 
	   [state_desc], 
	   [is_percent_growth], 
	   [growth], 
       CONVERT(BIGINT, [growth] / 128.0) AS [Growth in MB], 
       CONVERT(BIGINT, [size] / 128.0) AS [Total Size in MB]
FROM sys.master_files WITH (NOLOCK)
WHERE ([database_id] > 4 AND [database_id] <> 32767)
      OR ([database_id] = 2)
ORDER BY DB_NAME([database_id]) OPTION (RECOMPILE);

--///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 22. Volume info for all LUNS that have database files on the current instance
SELECT DISTINCT vs.[volume_mount_point], 
                vs.[file_system_type], 
                vs.[logical_volume_name], 
                CONVERT(DECIMAL(18, 2), vs.[total_bytes] / 1073741824.0) AS [Total Size (GB)],
                CONVERT(DECIMAL(18, 2), vs.[available_bytes] / 1073741824.0) AS [Available Size (GB)],  
                CAST(CAST(vs.[available_bytes] AS FLOAT)/ CAST(vs.[total_bytes] AS FLOAT) AS DECIMAL(18,2)) * 100 AS [Space Free %] 
FROM sys.master_files f WITH (NOLOCK)
CROSS APPLY sys.dm_os_volume_stats(f.[database_id], f.[file_id]) vs OPTION (RECOMPILE);

--///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 23. Drive level latency information
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
FROM (SELECT LEFT(mf.[physical_name], 2) AS [Drive], 
             SUM([num_of_reads]) AS [num_of_reads],
	         SUM([io_stall_read_ms]) AS [io_stall_read_ms], 
			 SUM([num_of_writes]) AS [num_of_writes],
	         SUM([io_stall_write_ms]) AS [io_stall_write_ms], 
			 SUM([num_of_bytes_read]) AS [num_of_bytes_read],
	         SUM([num_of_bytes_written]) AS [num_of_bytes_written], 
			 SUM([io_stall]) AS [io_stall]
      FROM sys.dm_io_virtual_file_stats(NULL, NULL) vfs
      INNER JOIN sys.master_files mf WITH (NOLOCK) ON vfs.[database_id] = mf.[database_id] AND vfs.[file_id] = mf.[file_id]
      GROUP BY LEFT(mf.[physical_name], 2)
	  ) tab
ORDER BY [Overall Latency] OPTION (RECOMPILE); -- Latency above 20-25ms is usually a problem

--///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 24. Calculates average stalls per read, per write, and per total input/output for each database file
SELECT DB_NAME(fs.[database_id]) AS [Database Name], 
       CAST(fs.[io_stall_read_ms]/(1.0 + fs.[num_of_reads]) AS NUMERIC(10, 1)) AS [avg_read_stall_ms],
       CAST(fs.[io_stall_write_ms]/(1.0 + fs.[num_of_writes]) AS NUMERIC(10, 1)) AS [avg_write_stall_ms],
       CAST((fs.[io_stall_read_ms] + fs.[io_stall_write_ms])/(1.0 + fs.[num_of_reads] + fs.[num_of_writes]) AS NUMERIC(10, 1)) AS [avg_io_stall_ms],
       CONVERT(DECIMAL(18,2), mf.[size]/128.0) AS [File Size (MB)], 
	   mf.[physical_name], 
	   mf.[type_desc], 
	   fs.[io_stall_read_ms], 
	   fs.[num_of_reads],
	   fs.[io_stall_write_ms], 
	   fs.[num_of_writes], 
	   fs.[io_stall_read_ms] + fs.[io_stall_write_ms] AS [io_stalls], 
	   fs.[num_of_reads] + fs.[num_of_writes] AS [total_io]
FROM sys.dm_io_virtual_file_stats(null,null) fs
INNER JOIN sys.master_files mf WITH (NOLOCK) ON fs.[database_id] = mf.[database_id] AND fs.[file_id] = mf.[file_id]
ORDER BY [avg_io_stall_ms] DESC OPTION (RECOMPILE);

--///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 25. Recovery model, log reuse wait description, log file size, log usage size and compatibility level for all databases on instance
SELECT db.[name] AS [Database Name], 
       db.[recovery_model_desc] AS [Recovery Model], 
	   db.[state_desc], 
       db.[log_reuse_wait_desc] AS [Log Reuse Wait Description], 
       CONVERT(DECIMAL(18, 2), ls.[cntr_value]/1024.0) AS [Log Size (MB)], 
	   CONVERT(DECIMAL(18, 2), lu.[cntr_value]/1024.0) AS [Log Used (MB)],
       CAST(CAST(lu.[cntr_value] AS FLOAT) / CAST(ls.[cntr_value] AS FLOAT) AS DECIMAL(18, 2)) * 100 AS [Log Used %], 
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
INNER JOIN sys.dm_os_performance_counters lu WITH (NOLOCK) ON db.[name] = lu.[instance_name]
INNER JOIN sys.dm_os_performance_counters ls WITH (NOLOCK) ON db.[name] = ls.[instance_name]
WHERE (lu.[counter_name] LIKE N'Log File(s) Used Size (KB)%') 
		AND (ls.[counter_name] LIKE N'Log File(s) Size (KB)%')
		AND (ls.[cntr_value] > 0) 
OPTION (RECOMPILE);

--///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 26. Missing Indexes for all databases by Index Advantage
SELECT CONVERT(DECIMAL(18, 2), [user_seeks] * [avg_total_user_cost] * ([avg_user_impact] * 0.01)) AS [index_advantage], --///
       migs.[last_user_seek], 
	   mid.[statement] AS [Database.Schema.Table],
	   mid.[equality_columns], 
	   mid.[inequality_columns], 
	   mid.[included_columns],
	   migs.[unique_compiles], 
	   migs.[user_seeks], 
	   migs.[avg_total_user_cost], 
	   migs.[avg_user_impact]
FROM sys.dm_db_missing_index_group_stats migs WITH (NOLOCK)
INNER JOIN sys.dm_db_missing_index_groups mig WITH (NOLOCK) ON migs.[group_handle] = mig.[index_group_handle]
INNER JOIN sys.dm_db_missing_index_details mid WITH (NOLOCK) ON mig.[index_handle] = mid.[index_handle]
ORDER BY [index_advantage] DESC OPTION (RECOMPILE);

--///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 27. Get VLF Counts for all databases on the instance
CREATE TABLE #VLFInfo (RecoveryUnitID int, FileID  int,
					   FileSize    bigint, StartOffset bigint,
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
--///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 28. Get CPU utilization by database
WITH DB_CPU_Stats AS (
	SELECT [DatabaseID], 
			DB_Name([DatabaseID]) AS [Database Name], 
			SUM([total_worker_time]) AS [CPU_Time_Ms]
	 FROM sys.dm_exec_query_stats qs
	 CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID] 
				  FROM sys.[dm_exec_plan_attributes](qs.[plan_handle])
				  WHERE [attribute] = N'dbid'
				  ) F_DB
	 GROUP BY DatabaseID
)
SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Time_Ms] DESC) AS [CPU Rank],
       [Database Name], 
	   [CPU_Time_Ms] AS [CPU Time (ms)], 
       CAST([CPU_Time_Ms] * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPU Percent]
FROM DB_CPU_Stats
WHERE [DatabaseID] <> 32767 -- ResourceDB
ORDER BY [CPU Rank] OPTION (RECOMPILE); -- Helps determine which database is using the most CPU resources on the instance

--///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 29. Get I/O utilization by database
WITH [Aggregate_IO_Statistics] AS (
	SELECT DB_NAME([database_id]) AS [Database Name],
	       CAST(SUM([num_of_bytes_read] + [num_of_bytes_written]) / 1048576 AS DECIMAL(12, 2)) AS [io_in_mb]
	FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS [DM_IO_STATS]
	GROUP BY [database_id]
)
SELECT ROW_NUMBER() OVER(ORDER BY [io_in_mb] DESC) AS [I/O Rank], 
       [Database Name], 
	   [io_in_mb] AS [Total I/O (MB)],
       CAST([io_in_mb] / SUM([io_in_mb]) OVER() * 100.0 AS DECIMAL(5,2)) AS [I/O Percent]
FROM [Aggregate_IO_Statistics]
ORDER BY [I/O Rank] OPTION (RECOMPILE); -- Helps determine which database is using the most I/O resources on the instance

--///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 30. Get total buffer usage by database for current instance
WITH [AggregateBufferPoolUsage] AS (
	SELECT DB_NAME([database_id]) AS [Database Name],
	       CAST(COUNT(*) * 8/1024.0 AS DECIMAL (10,2)) AS [CachedSize]
	FROM sys.dm_os_buffer_descriptors WITH (NOLOCK)
	WHERE [database_id] > 4 -- system databases
		  AND [database_id] <> 32767 -- ResourceDB
	GROUP BY DB_NAME([database_id])
)
SELECT ROW_NUMBER() OVER(ORDER BY [CachedSize] DESC) AS [Buffer Pool Rank], 
       [Database Name], 
	   [CachedSize] AS [Cached Size (MB)],
       CAST([CachedSize] / SUM([CachedSize]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [Buffer Pool Percent]
FROM [AggregateBufferPoolUsage]
ORDER BY [Buffer Pool Rank] OPTION (RECOMPILE);
--/////////////////////////////////////////////////////////////////////////////////////////
-- 30
-- Clear Wait Stats 
DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);
-- Isolate top waits for server instance since last restart or statistics clear
WITH [Waits] AS (
	SELECT [wait_type], 
	       CAST([wait_time_ms] / 1000. AS DECIMAL(12, 2)) AS [wait_time_s],
	       CAST(100. * [wait_time_ms] / SUM([wait_time_ms]) OVER () AS DECIMAL(12, 2)) AS [pct],
	       ROW_NUMBER() OVER (ORDER BY [wait_time_ms] DESC) AS rn
	FROM sys.dm_os_wait_stats WITH (NOLOCK)
	WHERE [wait_type] NOT IN (
		N'CLR_SEMAPHORE', N'LAZYWRITER_SLEEP', N'RESOURCE_QUEUE',N'SLEEP_TASK',
        N'SLEEP_SYSTEMTASK', N'SQLTRACE_BUFFER_FLUSH', N'WAITFOR', N'LOGMGR_QUEUE',
        N'CHECKPOINT_QUEUE', N'REQUEST_FOR_DEADLOCK_SEARCH', N'XE_TIMER_EVENT',
        N'BROKER_TO_FLUSH', N'BROKER_TASK_STOP', N'CLR_MANUAL_EVENT', N'CLR_AUTO_EVENT',
		N'DISPATCHER_QUEUE_SEMAPHORE' ,N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'XE_DISPATCHER_WAIT',
        N'XE_DISPATCHER_JOIN', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', N'ONDEMAND_TASK_QUEUE',
	    N'BROKER_EVENTHANDLER', N'SLEEP_BPOOL_FLUSH', N'SLEEP_DBSTARTUP', N'DIRTY_PAGE_POLL',
		N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',N'SP_SERVER_DIAGNOSTICS_SLEEP',
		N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
		N'WAIT_XTP_HOST_WAIT', N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', N'WAIT_XTP_CKPT_CLOSE',
		N'PWAIT_ALL_COMPONENTS_INITIALIZED')
),
[Running_Waits] AS (
    SELECT [wait_type], [wait_time_s], [pct],
	SUM([pct]) OVER(ORDER BY pct DESC ROWS UNBOUNDED PRECEDING) AS [running_pct]
	FROM [Waits] W1
)
SELECT [wait_type], [wait_time_s], [pct], [running_pct]
FROM [Running_Waits]
WHERE [running_pct] - [pct] <= 99
ORDER BY [running_pct]
OPTION (RECOMPILE);
-- The SQL Server Wait Type Repository
-- http://blogs.msdn.com/b/psssql/archive/2009/11/03/the-sql-server-wait-type-repository.aspx
-- Wait statistics, or please tell me where it hurts
-- http://www.sqlskills.com/blogs/paul/wait-statistics-or-please-tell-me-where-it-hurts/
-- SQL Server 2005 Performance Tuning using the Waits and Queues
-- http://technet.microsoft.com/en-us/library/cc966413.aspx
-- sys.dm_os_wait_stats (Transact-SQL)
-- http://msdn.microsoft.com/en-us/library/ms179984(v=sql.120).aspx

--/////////////////////////////////////////////////////////////////////////////////////////
-- 31. Signal Waits for instance
SELECT CAST(100.0 * SUM([signal_wait_time_ms]) / SUM ([wait_time_ms]) AS NUMERIC(20, 2)) AS [% Signal (CPU) Waits],
       CAST(100.0 * SUM([wait_time_ms] - [signal_wait_time_ms]) / SUM ([wait_time_ms]) AS NUMERIC(20, 2)) AS [% Resource Waits]
FROM sys.dm_os_wait_stats WITH (NOLOCK) OPTION (RECOMPILE); -- Signal Waits above 15-20% is usually a sign of CPU pressure

--/////////////////////////////////////////////////////////////////////////////////////////
-- 32. Get logins that are connected and how many sessions they have
SELECT [login_name], 
       [program_name], 
	   COUNT([session_id]) AS [session_count] 
FROM sys.dm_exec_sessions WITH (NOLOCK)
GROUP BY [login_name], [program_name]
ORDER BY COUNT([session_id]) DESC OPTION (RECOMPILE);

--/////////////////////////////////////////////////////////////////////////////////////////
-- 33. Get a count of SQL connections by IP address (Query 35) (Connection Counts by IP Address)
SELECT ec.[client_net_address], 
       es.[program_name], 
	   es.[host_name], 
	   es.[login_name], 
	   COUNT(ec.[session_id]) AS [connection count] 
FROM sys.dm_exec_sessions es WITH (NOLOCK) 
INNER JOIN sys.dm_exec_connections ec WITH (NOLOCK) ON es.[session_id] = ec.[session_id] 
GROUP BY ec.[client_net_address], es.[program_name], es.[host_name], es.[login_name]  
ORDER BY ec.[client_net_address], es.[program_name] OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 34. Get Average Task Counts (run multiple times)
SELECT AVG([current_tasks_count]) AS [Avg Task Count], 
       AVG([runnable_tasks_count]) AS [Avg Runnable Task Count],
       AVG([pending_disk_io_count]) AS [Avg Pending DiskIO Count]
FROM sys.dm_os_schedulers WITH (NOLOCK)
WHERE [scheduler_id] < 255 OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 35. Get CPU Utilization History for last 256 minutes (in one minute intervals)
DECLARE @ts_now bigint = (SELECT [cpu_ticks] / ([cpu_ticks] / [ms_ticks]) FROM sys.dm_os_sys_info WITH (NOLOCK)); 

SELECT TOP(256) [SQLProcessUtilization] AS [SQL Server Process CPU Utilization], 
                [SystemIdle] AS [System Idle Process], 
                100 - [SystemIdle] - [SQLProcessUtilization] AS [Other Process CPU Utilization], 
                DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [Event Time] 
FROM (SELECT [record].value('(./Record/@id)[1]', 'int') AS [record_id], 
			 [record].value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS [SystemIdle], 
			 [record].value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS [SQLProcessUtilization],
			 [timestamp] 
	  FROM (SELECT [timestamp], 
	               CONVERT(xml, [record]) AS [record] 
			FROM sys.dm_os_ring_buffers WITH (NOLOCK)
			WHERE [ring_buffer_type] = N'RING_BUFFER_SCHEDULER_MONITOR' 
			      AND [record] LIKE N'%<SystemHealth>%'
		    ) x
	  ) y 
ORDER BY [record_id] DESC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 36. Good basic information about OS memory amounts and state
SELECT [total_physical_memory_kb] / 1024 AS [Physical Memory (MB)], 
       [available_physical_memory_kb] / 1024 AS [Available Memory (MB)], 
       [total_page_file_kb] / 1024 AS [Total Page File (MB)], 
	   [available_page_file_kb] / 1024 AS [Available Page File (MB)], 
	   [system_cache_kb] / 1024 AS [System Cache (MB)],
       [system_memory_state_desc] AS [System Memory State]
FROM sys.dm_os_sys_memory WITH (NOLOCK) OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 37. SQL Server Process Address space info (shows whether locked pages is enabled, among other things)
SELECT [physical_memory_in_use_kb] / 1024 AS [SQL Server Memory Usage (MB)],
       [large_page_allocations_kb], 
	   [locked_page_allocations_kb], 
	   [page_fault_count], 
	   [memory_utilization_percentage], 
	   [available_commit_limit_kb], 
	   [process_physical_memory_low], 
	   [process_virtual_memory_low]
FROM sys.dm_os_process_memory WITH (NOLOCK) OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 38. Page Life Expectancy (PLE) value for each NUMA node in current instance
SELECT @@SERVERNAME AS [Server Name], 
       [object_name], 
	   [instance_name], 
	   [cntr_value] AS [Page Life Expectancy]
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE [object_name] LIKE N'%Buffer Node%' -- Handles named instances
      AND [counter_name] = N'Page life expectancy' OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 39. Memory Grants Pending value for current instance
SELECT @@SERVERNAME AS [Server Name], 
       [object_name], 
	   [cntr_value] AS [Memory Grants Pending]                                                                                                       
FROM sys.dm_os_performance_counters WITH (NOLOCK)
WHERE [object_name] LIKE N'%Memory Manager%' -- Handles named instances
      AND [counter_name] = N'Memory Grants Pending' OPTION (RECOMPILE);
-- Memory Grants Pending above zero for a sustained period is a very strong indicator of memory pressure

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 40. Memory Clerk Usage for instance. Look for high value for CACHESTORE_SQLCP (Ad-hoc query plans)
SELECT TOP(10) [type] AS [Memory Clerk Type], 
       SUM([pages_kb]) / 1024 AS [Memory Usage (MB)] 
FROM sys.dm_os_memory_clerks WITH (NOLOCK)
GROUP BY [type]  
ORDER BY SUM([pages_kb]) DESC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 41. Find single-use, ad-hoc and prepared queries that are bloating the plan cache
SELECT TOP(50) est.[text] AS [QueryText], 
               cp.[cacheobjtype], 
			   cp.[objtype], 
			   cp.[size_in_bytes] 
FROM sys.dm_exec_cached_plans cp WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text([plan_handle]) est 
WHERE cp.[cacheobjtype] = N'Compiled Plan' 
      AND cp.[objtype] IN (N'Adhoc', N'Prepared') 
      AND cp.[usecounts] = 1
ORDER BY cp.[size_in_bytes] DESC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- Database specific queries *****************************************************************

-- **** Switch to a user database *****
USE fst;--YourDatabaseName;
GO

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 42. Individual File Sizes and space available for current database  (Query 44) (File Sizes and Space)
SELECT f.[name] AS [File Name] , 
       f.[physical_name] AS [Physical Name], 
       CAST((f.[size] / 128.0) AS DECIMAL(15, 2)) AS [Total Size in MB],
       CAST(f.[size] / 128.0 - CAST(FILEPROPERTY(f.[name], 'SpaceUsed') AS int) / 128.0 AS DECIMAL(15, 2)) AS [Available Space In MB], 
	   [file_id],
	   fg.[name] AS [Filegroup Name]
FROM sys.database_files f WITH (NOLOCK) 
LEFT JOIN sys.data_spaces fg WITH (NOLOCK) 
ON f.[data_space_id] = fg.[data_space_id] OPTION (RECOMPILE);


-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 43. I/O Statistics by file for the current database  (Query 45) (IO Stats By File)
SELECT DB_NAME(DB_ID()) AS [Database Name], 
       df.[name] AS [Logical Name],
	   vfs.[file_id], 
       df.[physical_name] AS [Physical Name], 
	   vfs.[num_of_reads], 
	   vfs.[num_of_writes], 
	   vfs.[io_stall_read_ms], 
	   vfs.[io_stall_write_ms],
       CAST(100. * vfs.[io_stall_read_ms]/(vfs.[io_stall_read_ms] + vfs.[io_stall_write_ms]) AS DECIMAL(10,1)) AS [IO Stall Reads Pct],
       CAST(100. * vfs.[io_stall_write_ms]/(vfs.[io_stall_write_ms] + vfs.[io_stall_read_ms]) AS DECIMAL(10,1)) AS [IO Stall Writes Pct],
       (vfs.[num_of_reads] + vfs.[num_of_writes]) AS [Writes + Reads], 
       CAST(vfs.[num_of_bytes_read]/1048576.0 AS DECIMAL(10, 2)) AS [MB Read], 
       CAST(vfs.[num_of_bytes_written]/1048576.0 AS DECIMAL(10, 2)) AS [MB Written],
       CAST(100. * vfs.[num_of_reads]/(vfs.[num_of_reads] + vfs.[num_of_writes]) AS DECIMAL(10, 1)) AS [# Reads Pct],
       CAST(100. * vfs.[num_of_writes]/(vfs.[num_of_reads] + vfs.[num_of_writes]) AS DECIMAL(10, 1)) AS [# Write Pct],
       CAST(100. * vfs.[num_of_bytes_read]/(vfs.[num_of_bytes_read] + vfs.[num_of_bytes_written]) AS DECIMAL(10, 1)) AS [Read Bytes Pct], 
       CAST(100. * vfs.[num_of_bytes_written]/(vfs.[num_of_bytes_read] + vfs.[num_of_bytes_written]) AS DECIMAL(10, 1)) AS [Written Bytes Pct]
FROM sys.dm_io_virtual_file_stats(DB_ID(), NULL) vfs
INNER JOIN sys.database_files df WITH (NOLOCK) ON vfs.[file_id]= df.[file_id]
OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 44. Top cached queries by Execution Count
SELECT TOP (100) qs.[execution_count], 
                 qs.[total_rows], 
				 qs.[last_rows], 
				 qs.[min_rows], 
				 qs.[max_rows],
                 qs.[last_elapsed_time], 
				 qs.[min_elapsed_time], 
				 qs.[max_elapsed_time], 
				 [total_worker_time], 
				 [total_logical_reads], 
                 SUBSTRING(qt.[TEXT], qs.[statement_start_offset] / 2 +1,
					(CASE WHEN qs.[statement_end_offset] = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.[TEXT])) * 2
	                      ELSE qs.[statement_end_offset] 
					 END - qs.[statement_start_offset]) / 2) AS [query_text] 
FROM sys.dm_exec_query_stats AS qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
ORDER BY qs.[execution_count] DESC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 45. Top Cached SPs By Execution Count
SELECT TOP(100) 
       p.[name] AS [SP Name], 
       qs.[execution_count],
       ISNULL(qs.[execution_count] / DATEDIFF(Minute, qs.[cached_time], GETDATE()), 0) AS [Calls/Minute],
       qs.[total_worker_time] / qs.[execution_count] AS [AvgWorkerTime], 
	   qs.[total_worker_time] AS [TotalWorkerTime],  
       qs.[total_elapsed_time], 
	   qs.[total_elapsed_time] / qs.[execution_count] AS [avg_elapsed_time],
       qs.cached_time
FROM sys.procedures p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats qs WITH (NOLOCK) ON p.[object_id] = qs.[object_id]
WHERE qs.[database_id] = DB_ID()
ORDER BY qs.[execution_count] DESC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 46. Top Cached SPs By Avg Elapsed Time
SELECT TOP(25) p.[name] AS [SP Name], 
               qs.[total_elapsed_time] / qs.[execution_count] AS [avg_elapsed_time], 
               qs.[total_elapsed_time], 
			   qs.[execution_count], 
			   ISNULL(qs.[execution_count]/DATEDIFF(Minute, qs.[cached_time], GETDATE()), 0) AS [Calls/Minute], 
			   qs.[total_worker_time]/qs.[execution_count] AS [AvgWorkerTime], 
               qs.[total_worker_time] AS [TotalWorkerTime], 
			   qs.[cached_time]
FROM sys.procedures p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats qs WITH (NOLOCK) ON p.[object_id] = qs.[object_id]
WHERE qs.[database_id] = DB_ID()
ORDER BY [avg_elapsed_time] DESC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 47. Top Cached SPs By Avg Elapsed Time with execution time variability
SELECT TOP(25) p.[name] AS [SP Name],
               qs.[execution_count], 
			   qs.[min_elapsed_time],
               qs.[total_elapsed_time] / qs.[execution_count] AS [avg_elapsed_time],
               qs.[max_elapsed_time], 
			   qs.[last_elapsed_time],  
			   qs.[cached_time]
FROM sys.procedures p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats qs WITH (NOLOCK) ON p.[object_id] = qs.[object_id]
WHERE qs.[database_id] = DB_ID()
ORDER BY [avg_elapsed_time] DESC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 48. Top Cached SPs By Total Worker time. Worker time relates to CPU cost.
SELECT TOP(25) p.[name] AS [SP Name], 
               qs.[total_worker_time] AS [TotalWorkerTime], 
               qs.[total_worker_time] / qs.[execution_count] AS [AvgWorkerTime], 
			   qs.[execution_count], 
               ISNULL(qs.[execution_count] / DATEDIFF(Minute, qs.[cached_time], GETDATE()), 0) AS [Calls/Minute],
               qs.[total_elapsed_time], 
			   qs.[total_elapsed_time] / qs.[execution_count] AS [avg_elapsed_time], 
			   qs.[cached_time]
FROM sys.procedures p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats qs WITH (NOLOCK) ON p.[object_id] = qs.[object_id]
WHERE qs.[database_id] = DB_ID()
ORDER BY qs.[total_worker_time] DESC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 49. Top Cached SPs By Total Logical Reads (SQL Server 2014). Logical reads relate to memory pressure.
SELECT TOP(25) p.[name] AS [SP Name], 
               qs.[total_logical_reads] AS [TotalLogicalReads], 
               qs.[total_logical_reads] / qs.[execution_count] AS [AvgLogicalReads],
			   qs.[execution_count], 
               ISNULL(qs.[execution_count] / DATEDIFF(Minute, qs.[cached_time], GETDATE()), 0) AS [Calls/Minute], 
               qs.[total_elapsed_time], 
			   qs.[total_elapsed_time] / qs.[execution_count] AS [avg_elapsed_time], 
			   qs.[cached_time]
FROM sys.procedures p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats qs WITH (NOLOCK) ON p.[object_id] = qs.[object_id]
WHERE qs.[database_id] = DB_ID()
ORDER BY qs.[total_logical_reads] DESC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 50. Top Cached SPs By Total Physical Reads (SQL Server 2014). Physical reads relate to disk I/O pressure
SELECT TOP(25) p.[name] AS [SP Name],
               s.[total_physical_reads] AS [TotalPhysicalReads], 
               qs.[total_physical_reads] / qs.[execution_count] AS [AvgPhysicalReads], 
			   qs.[execution_count], 
               qs.[total_logical_reads],
			   qs.[total_elapsed_time], 
			   qs.[total_elapsed_time] / qs.[execution_count] AS [avg_elapsed_time], 
			   qs.[cached_time] 
FROM sys.procedures p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats qs WITH (NOLOCK) ON p.[object_id] = qs.[object_id]
WHERE qs.[database_id] = DB_ID()
      AND qs.[total_physical_reads] > 0
ORDER BY qs.[total_physical_reads] DESC, qs.[total_logical_reads] DESC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 51. Top Cached SPs By Total Logical Writes (SQL Server 2014) Logical writes relate to both memory and disk I/O pressure 
SELECT TOP(25) p.[name] AS [SP Name], 
               qs.[total_logical_writes] AS [TotalLogicalWrites], 
               qs.[total_logical_writes] / qs.[execution_count] AS [AvgLogicalWrites], 
			   qs.[execution_count],
               ISNULL(qs.[execution_count] / DATEDIFF(Minute, qs.[cached_time], GETDATE()), 0) AS [Calls/Minute],
               qs.[total_elapsed_time], 
			   qs.[total_elapsed_time] / qs.[execution_count] AS [avg_elapsed_time], 
               qs.[cached_time]
FROM sys.procedures p WITH (NOLOCK)
INNER JOIN sys.dm_exec_procedure_stats qs WITH (NOLOCK) ON p.[object_id] = qs.[object_id]
WHERE qs.[database_id] = DB_ID()
      AND qs.[total_logical_writes] > 0
ORDER BY qs.[total_logical_writes] DESC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 52. Lists the top statements by average input/output usage for the current database
SELECT TOP(50) OBJECT_NAME(qt.[objectid], [dbid]) AS [SP Name],
               (qs.[total_logical_reads] + qs.[total_logical_writes]) / qs.[execution_count] AS [Avg IO],
			   qs.[execution_count] AS [Execution Count],
               SUBSTRING(qt.[text], qs.[statement_start_offset] / 2, 
					(CASE 
					   WHEN qs.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.[text])) * 2 
		               ELSE qs.statement_end_offset 
	                 END - qs.statement_start_offset) / 2) AS [Query Text]	
FROM sys.dm_exec_query_stats qs WITH (NOLOCK)
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
WHERE qt.[dbid] = DB_ID()
ORDER BY [Avg IO] DESC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 53. Possible Bad NC Indexes (writes > reads)
SELECT OBJECT_NAME(s.[object_id]) AS [Table Name], 
       i.[name] AS [Index Name], 
	   i.[index_id], 
       i.[is_disabled], 
	   i.[is_hypothetical], 
	   i.[has_filter], 
	   i.[fill_factor],
       [user_updates] AS [Total Writes], 
	   [user_seeks] + [user_scans] + [user_lookups] AS [Total Reads],
       [user_updates] - ([user_seeks] + [user_scans] + [user_lookups]) AS [Difference]
FROM sys.dm_db_index_usage_stats s WITH (NOLOCK)
INNER JOIN sys.indexes i WITH (NOLOCK) ON (s.[object_id] = i.[object_id]) AND (i.index_id = s.index_id)
WHERE (OBJECTPROPERTY(s.[object_id], 'IsUserTable') = 1)
      AND (s.database_id = DB_ID())
      AND (user_updates > (user_seeks + user_scans + user_lookups))
      AND (i.index_id > 1)
ORDER BY [Difference] DESC, [Total Writes] DESC, [Total Reads] ASC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 54. Missing Indexes for current database by Index Advantage
SELECT DISTINCT CONVERT(DECIMAL(18,2), user_seeks * avg_total_user_cost * (avg_user_impact * 0.01)) AS [index_advantage], 
       migs.[last_user_seek], 
	   mid.[statement] AS [Database.Schema.Table],
       mid.[equality_columns], 
	   mid.[inequality_columns], 
	   mid.[included_columns],
       migs.[unique_compiles], 
	   migs.[user_seeks], 
	   migs.[avg_total_user_cost], 
	   migs.[avg_user_impact],
       OBJECT_NAME(mid.[object_id]) AS [Table Name], 
	   p.[rows] AS [Table Rows]
FROM sys.dm_db_missing_index_group_stats migs WITH (NOLOCK)
INNER JOIN sys.dm_db_missing_index_groups mig WITH (NOLOCK) ON migs.[group_handle] = mig.[index_group_handle]
INNER JOIN sys.dm_db_missing_index_details mid WITH (NOLOCK) ON mig.[index_handle] = mid.[index_handle]
INNER JOIN sys.partitions p WITH (NOLOCK) ON p.[object_id] = mid.[object_id]
WHERE mid.[database_id] = DB_ID() 
ORDER BY [index_advantage] DESC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 55. Find missing index warnings for cached plans in the current database. Could take some time on a busy instance
SELECT TOP(25) OBJECT_NAME([objectid]) AS [ObjectName], 
               qp.[query_plan], 
			   cp.[objtype], 
			   cp.[usecounts]
FROM sys.dm_exec_cached_plans cp WITH (NOLOCK)
CROSS APPLY sys.dm_exec_query_plan(cp.[plan_handle]) qp
WHERE CAST(qp.[query_plan] AS NVARCHAR(MAX)) LIKE N'%MissingIndex%'
      AND [dbid] = DB_ID()
ORDER BY cp.[usecounts] DESC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 56. Breaks down buffers used by current database by object (table, index) in the buffer cache. Can take some time on a large database
SELECT OBJECT_NAME(p.[object_id]) AS [Object Name], 
       p.[index_id], 
       CAST(COUNT(*) / 128.0 AS DECIMAL(10, 2)) AS [Buffer size(MB)],  
       COUNT(*) AS [BufferCount], 
	   p.[Rows] AS [Row Count],
       p.[data_compression_desc] AS [Compression Type]
FROM sys.allocation_units a WITH (NOLOCK)
INNER JOIN sys.dm_os_buffer_descriptors b WITH (NOLOCK) ON a.[allocation_unit_id] = b.[allocation_unit_id]
INNER JOIN sys.partitions p WITH (NOLOCK) ON a.[container_id] = p.[hobt_id]
WHERE b.[database_id] = CONVERT(int, DB_ID())
      AND p.[object_id] > 100
GROUP BY p.[object_id], p.[index_id], p.[data_compression_desc], p.[Rows]
ORDER BY [BufferCount] DESC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 57. Get Table names, row counts, and compression status for clustered index or heap.
SELECT OBJECT_NAME([object_id]) AS [ObjectName], 
       SUM([Rows]) AS [RowCount], 
	   [data_compression_desc] AS [CompressionType]
FROM sys.partitions WITH (NOLOCK)
WHERE (index_id < 2) --ignore the partitions from the non-clustered index if any
      AND (OBJECT_NAME(object_id) NOT LIKE N'sys%')
      AND (OBJECT_NAME(object_id) NOT LIKE N'queue_%') 
      AND (OBJECT_NAME(object_id) NOT LIKE N'filestream_tombstone%') 
      AND (OBJECT_NAME(object_id) NOT LIKE N'fulltext%')
      AND (OBJECT_NAME(object_id) NOT LIKE N'ifts_comp_fragment%')
      AND (OBJECT_NAME(object_id) NOT LIKE N'filetable_updates%')
      AND (OBJECT_NAME(object_id) NOT LIKE N'xml_index_nodes%')
GROUP BY [object_id], [data_compression_desc]
ORDER BY SUM([Rows]) DESC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 58. Get some key table properties.
SELECT [name], [create_date], [lock_on_bulk_load], [is_replicated], [has_replication_filter], 
       [is_tracked_by_cdc], [lock_escalation_desc], [is_memory_optimized], [durability_desc]
FROM sys.tables WITH (NOLOCK) 
ORDER BY [name] OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 59. When were Statistics last updated on all indexes?
SELECT o.[name], 
       i.[name] AS [Index Name],
       STATS_DATE(i.[object_id], i.[index_id]) AS [Statistics Date], 
       s.[auto_created], 
	   s.[no_recompute], 
	   s.[user_created], 
	   st.[row_count], 
	   s.[is_incremental], 
	   st.[used_page_count]
FROM sys.objects o WITH (NOLOCK) 
INNER JOIN sys.indexes i WITH (NOLOCK) ON o.[object_id] = i.[object_id]
INNER JOIN sys.stats s WITH (NOLOCK) ON (i.[object_id] = s.[object_id]) AND (i.[index_id] = s.[stats_id])
INNER JOIN sys.dm_db_partition_stats st WITH (NOLOCK) ON (o.[object_id] = st.[object_id]) AND (i.[index_id] = st.[index_id])
WHERE o.[type] = 'U'
ORDER BY STATS_DATE(i.[object_id], i.[index_id]) ASC OPTION (RECOMPILE);  

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 60. Get fragmentation info for all indexes above a certain size in the current database. Could take some time on a very large database.
SELECT DB_NAME(ps.[database_id]) AS [Database Name], 
       OBJECT_NAME(ps.[OBJECT_ID]) AS [Object Name], 
       i.[name] AS [Index Name], 
	   ps.[index_id], 
	   ps.[index_type_desc], 
	   ps.[avg_fragmentation_in_percent], 
       ps.[fragment_count], 
	   ps.[page_count], 
	   i.[fill_factor], 
	   i.[has_filter], 
	   i.[filter_definition]
FROM sys.dm_db_index_physical_stats(DB_ID(),NULL, NULL, NULL , N'LIMITED') ps
INNER JOIN sys.indexes i WITH (NOLOCK) ON (ps.[object_id] = i.[object_id]) AND (ps.[index_id] = i.[index_id])
WHERE (ps.[database_id] = DB_ID())
      AND (ps.[page_count] > 2500)
ORDER BY ps.[avg_fragmentation_in_percent] DESC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
--- 70. Index Read/Write stats (all tables in current DB) ordered by Reads
SELECT OBJECT_NAME(s.[object_id]) AS [ObjectName], 
       i.[index_id], 
	   i.[name] AS [IndexName],
	   s.[user_seeks] + s.[user_scans] + s.[user_lookups] AS [Reads], 
	   s.[user_updates] AS [Writes],  
	   i.[type_desc] AS [IndexType], 
	   i.[fill_factor] AS [FillFactor], 
	   i.[has_filter], 
	   i.[filter_definition], 
	   s.[last_user_scan], 
	   s.[last_user_lookup], 
	   s.[last_user_seek]
FROM sys.dm_db_index_usage_stats s WITH (NOLOCK)
INNER JOIN sys.indexes i WITH (NOLOCK) ON s.[object_id] = i.[object_id]
WHERE OBJECTPROPERTY(s.[object_id], 'IsUserTable') = 1
      AND (i.[index_id] = s.[index_id])
      AND (s.[database_id] = DB_ID())
ORDER BY s.[user_seeks] + s.[user_scans] + s.[user_lookups] DESC OPTION (RECOMPILE); -- Order by reads

-- ////////////////////////////////////////////////////////////////////////////////////////////////
--- 80. Index Read/Write stats (all tables in current DB) ordered by Writes
SELECT OBJECT_NAME(s.[object_id]) AS [ObjectName], 
       i.[index_id], 
	   i.[name] AS [IndexName], 
	   s.[user_updates] AS [Writes], 
	   s.[user_seeks] + s.[user_scans] + s.[user_lookups] AS [Reads], 
	   i.[type_desc] AS [IndexType], 
	   i.[fill_factor] AS [FillFactor], 
	   i.[has_filter], 
	   i.[filter_definition],
	   s.[last_system_update], 
	   s.[last_user_update]
FROM sys.dm_db_index_usage_stats s WITH (NOLOCK) 
INNER JOIN sys.indexes AS i WITH (NOLOCK) ON s.[object_id] = i.[object_id]
WHERE (OBJECTPROPERTY(s.[object_id],'IsUserTable') = 1)
      AND (i.[index_id] = s.[index_id])
      AND (s.[database_id] = DB_ID())
ORDER BY s.[user_updates] DESC OPTION (RECOMPILE);						 -- Order by writes

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 81. Look at recent Full backups for the current database
SELECT TOP (30) bs.[machine_name], 
                bs.[server_name], 
				bs.[database_name] AS [Database Name], 
				bs.[recovery_model],
                CONVERT(BIGINT, bs.[backup_size] / 1048576 ) AS [Uncompressed Backup Size (MB)],
                CONVERT(BIGINT, bs.[compressed_backup_size] / 1048576 ) AS [Compressed Backup Size (MB)],
                CONVERT(NUMERIC (20, 2), (CONVERT(FLOAT, bs.[backup_size]) / CONVERT (FLOAT, bs.[compressed_backup_size]))) AS [Compression Ratio], 
                DATEDIFF(SECOND, bs.[backup_start_date], bs.[backup_finish_date]) AS [Backup Elapsed Time (sec)],
                bs.[backup_finish_date] AS [Backup Finish Date]
FROM msdb.dbo.[backupset] bs WITH (NOLOCK)
WHERE (DATEDIFF(SECOND, bs.[backup_start_date], bs.[backup_finish_date]) > 0) 
      AND (bs.[backup_size] > 0)
      AND (bs.[type] = 'D') -- Change to L if you want Log backups
      AND ([database_name] = DB_NAME(DB_ID()))
ORDER BY bs.[backup_finish_date] DESC OPTION (RECOMPILE);

-- ////////////////////////////////////////////////////////////////////////////////////////////////
-- 82. Get the average full backup size by month for the current database.
SELECT [database_name] AS [Database], 
       DATEPART(month, [backup_start_date]) AS [Month],
	   CAST(AVG([backup_size] / 1024 / 1024) AS DECIMAL(15, 2)) AS [Backup Size (MB)],
       CAST(AVG([compressed_backup_size] / 1024 / 1024) AS DECIMAL(15, 2)) AS [Compressed Backup Size (MB)],
       CAST(AVG([backup_size] / [compressed_backup_size]) AS DECIMAL(15, 2)) AS [Compression Ratio]
FROM msdb.dbo.[backupset] WITH (NOLOCK)
WHERE ([database_name] = DB_NAME(DB_ID()))
      AND ([type] = 'D')
      AND (backup_start_date >= DATEADD(MONTH, -12, GETDATE()))
GROUP BY [database_name], DATEPART(mm, [backup_start_date]) OPTION (RECOMPILE);