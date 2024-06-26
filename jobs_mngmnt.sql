-- Job Level Setup and Configuration information which is also found in the SQL Server Agent Job Properties window in SSMS
SELECT 
    sJOB.[job_id] AS [JobID],
    sJOB.[name] AS [JobName],
    sDBP.[name] AS [JobOwner],
    sCAT.[name] AS [JobCategory],
    sJOB.[description] AS [JobDescription],
    CASE sJOB.[enabled]
        WHEN 1 THEN 'Yes'
        WHEN 0 THEN 'No'
    END AS [IsEnabled],
    sJOB.[date_created] AS [JobCreatedOn],
    sJOB.[date_modified] AS [JobLastModifiedOn],
    sSVR.[name] AS [OriginatingServerName],
    sJSTP.[step_id] AS [JobStartStepNo],
    sJSTP.[step_name] AS [JobStartStepName],
    CASE
        WHEN sSCH.[schedule_uid] IS NULL THEN 'No'
        ELSE 'Yes'
    END AS [IsScheduled],
    sSCH.[schedule_uid] AS [JobScheduleID],
    sSCH.[name] AS [JobScheduleName],
    CASE sJOB.[delete_level]
        WHEN 0 THEN 'Never'
        WHEN 1 THEN 'On Success'
        WHEN 2 THEN 'On Failure'
        WHEN 3 THEN 'On Completion'
    END AS [JobDeletionCriterion]
FROM msdb.dbo.[sysjobs] sJOB
LEFT JOIN msdb.sys.[servers] sSVR ON sJOB.[originating_server_id] = sSVR.[server_id]
LEFT JOIN msdb.dbo.[syscategories] sCAT ON sJOB.[category_id] = sCAT.[category_id]
LEFT JOIN msdb.dbo.[sysjobsteps] sJSTP ON sJOB.[job_id] = sJSTP.[job_id] AND sJOB.[start_step_id] = sJSTP.[step_id]
LEFT JOIN msdb.sys.[database_principals] sDBP ON sJOB.[owner_sid] = sDBP.[sid]
LEFT JOIN msdb.dbo.[sysjobschedules] AS sJOBSCH ON sJOB.[job_id] = sJOBSCH.[job_id]
LEFT JOIN msdb.dbo.[sysschedules] AS [sSCH] ON sJOBSCH.[schedule_id] = sSCH.[schedule_id]
ORDER BY [JobName]

-- details of last/latest execution of the SQL Server Agent Job and also the next time when the job is going to run (if it is scheduled)
SELECT 
    sJOB.[job_id] AS [JobID],
    sJOB.[name] AS [JobName],
    CASE 
        WHEN sJOBH.[run_date] IS NULL OR sJOBH.[run_time] IS NULL THEN NULL
        ELSE CAST(CAST(sJOBH.[run_date] AS CHAR(8)) + ' ' + 
                  STUFF(STUFF(RIGHT('000000' + CAST([sJOBH].[run_time] AS VARCHAR(6)),  6), 3, 0, ':'), 6, 0, ':') AS DATETIME
				 )
     END AS [LastRunDateTime],
     CASE sJOBH.[run_status]
        WHEN 0 THEN 'Failed'
        WHEN 1 THEN 'Succeeded'
        WHEN 2 THEN 'Retry'
        WHEN 3 THEN 'Canceled'
        WHEN 4 THEN 'Running' -- In Progress
     END AS [LastRunStatus],
     STUFF(STUFF(RIGHT('000000' + CAST([sJOBH].[run_duration] AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') AS [LastRunDuration (HH:MM:SS)],
     sJOBH.[message] AS [LastRunStatusMessage],
     CASE sJOBSCH.[NextRunDate]
          WHEN 0 THEN NULL
          ELSE CAST(CAST(sJOBSCH.[NextRunDate] AS CHAR(8)) + ' ' +
                    STUFF(STUFF(RIGHT('000000' + CAST([sJOBSCH].[NextRunTime] AS VARCHAR(6)),  6), 3, 0, ':'), 6, 0, ':') AS DATETIME
			        )
      END AS [NextRunDateTime]
FROM msdb.dbo.[sysjobs] sJOB
LEFT JOIN (SELECT [job_id],
                   MIN([next_run_date]) AS [NextRunDate],
                   MIN([next_run_time]) AS [NextRunTime]
           FROM msdb.dbo.[sysjobschedules]
           GROUP BY [job_id]
           ) sJOBSCH
     ON sJOB.[job_id] = [sJOBSCH].[job_id]
LEFT JOIN (SELECT [job_id],
                  [run_date],
                  [run_time],
                  [run_status],
                  [run_duration],
                  [message],
                  ROW_NUMBER() OVER (PARTITION BY [job_id] ORDER BY [run_date] DESC, [run_time] DESC) AS [RowNumber]
           FROM [msdb].[dbo].[sysjobhistory]
           WHERE [step_id] = 0
          ) sJOBH
        ON (sJOB.[job_id] = sJOBH.[job_id]) AND (sJOBH.[RowNumber] = 1)
ORDER BY [JobName];

-- Job Step level Setup and Configuration information
SELECT
    sJOB.[job_id] AS [JobID],
    sJOB.[name] AS [JobName],
    sJSTP.[step_uid] AS [StepID],
    sJSTP.[step_id] AS [StepNo],
    sJSTP.[step_name] AS [StepName],
    CASE sJSTP.[subsystem]
        WHEN 'ActiveScripting' THEN 'ActiveX Script'
        WHEN 'CmdExec' THEN 'Operating system (CmdExec)'
        WHEN 'PowerShell' THEN 'PowerShell'
        WHEN 'Distribution' THEN 'Replication Distributor'
        WHEN 'Merge' THEN 'Replication Merge'
        WHEN 'QueueReader' THEN 'Replication Queue Reader'
        WHEN 'Snapshot' THEN 'Replication Snapshot'
        WHEN 'LogReader' THEN 'Replication Transaction-Log Reader'
        WHEN 'ANALYSISCOMMAND' THEN 'SQL Server Analysis Services Command'
        WHEN 'ANALYSISQUERY' THEN 'SQL Server Analysis Services Query'
        WHEN 'SSIS' THEN 'SQL Server Integration Services Package'
        WHEN 'TSQL' THEN 'Transact-SQL script (T-SQL)'
        ELSE sJSTP.[subsystem]
      END AS [StepType],
      sPROX.[name] AS [RunAs],
      sJSTP.[database_name] AS [Database],
      sJSTP.[command] AS [ExecutableCommand],
      CASE sJSTP.[on_success_action]
        WHEN 1 THEN 'Quit the job reporting success'
        WHEN 2 THEN 'Quit the job reporting failure'
        WHEN 3 THEN 'Go to the next step'
        WHEN 4 THEN 'Go to Step: ' 
                    + QUOTENAME(CAST(sJSTP.[on_success_step_id] AS VARCHAR(3))) 
                    + ' ' 
                    + sOSSTP.[step_name]
      END AS [OnSuccessAction],
      sJSTP.[retry_attempts] AS [RetryAttempts],
      sJSTP.[retry_interval] AS [RetryInterval (Minutes)],
      CASE sJSTP.[on_fail_action]
        WHEN 1 THEN 'Quit the job reporting success'
        WHEN 2 THEN 'Quit the job reporting failure'
        WHEN 3 THEN 'Go to the next step'
        WHEN 4 THEN 'Go to Step: ' 
                    + QUOTENAME(CAST([sJSTP].[on_fail_step_id] AS VARCHAR(3))) 
                    + ' ' 
                    + sOFSTP.[step_name]
      END AS [OnFailureAction]
FROM msdb.dbo.[sysjobsteps] sJSTP
INNER JOIN msdb.dbo.[sysjobs] sJOB ON sJSTP.[job_id] = sJOB.[job_id]
LEFT JOIN msdb.dbo.[sysjobsteps] sOSSTP ON (sJSTP.[job_id] = sOSSTP.[job_id]) AND (sJSTP.[on_success_step_id] = sOSSTP.[step_id])
LEFT JOIN msdb.dbo.[sysjobsteps] AS [sOFSTP] ON (sJSTP.[job_id] = sOFSTP.[job_id]) AND (sJSTP.[on_fail_step_id] = sOFSTP.[step_id])
LEFT JOIN msdb.dbo.[sysproxies] AS [sPROX] ON sJSTP.[proxy_id] = sPROX.[proxy_id]
ORDER BY [JobName], [StepNo];

-- details of last/latest execution of the job step
SELECT
    sJOB.[job_id] AS [JobID],
    sJOB.[name] AS [JobName],
    sJSTP.[step_uid] AS [StepID],
    sJSTP.[step_id] AS [StepNo],
    sJSTP.[step_name] AS [StepName],
    CASE sJSTP.[last_run_outcome]
        WHEN 0 THEN 'Failed'
        WHEN 1 THEN 'Succeeded'
        WHEN 2 THEN 'Retry'
        WHEN 3 THEN 'Canceled'
        WHEN 5 THEN 'Unknown'
      END AS [LastRunStatus],
    STUFF(STUFF(RIGHT('000000' + CAST(sJSTP.[last_run_duration] AS VARCHAR(6)),  6), 3, 0, ':'), 6, 0, ':') AS [LastRunDuration (HH:MM:SS)],
    sJSTP.[last_run_retries] AS [LastRunRetryAttempts],
    CASE sJSTP.[last_run_date]
        WHEN 0 THEN NULL
        ELSE CAST(CAST(sJSTP.[last_run_date] AS CHAR(8)) + ' ' + 
		          STUFF(STUFF(RIGHT('000000' + CAST(sJSTP.[last_run_time] AS VARCHAR(6)),  6), 3, 0, ':'), 6, 0, ':') AS DATETIME)
    END AS [LastRunDateTime]
FROM msdb.dbo.[sysjobsteps] AS sJSTP
INNER JOIN msdb.dbo.[sysjobs] AS sJOB ON sJSTP.[job_id] = sJOB.[job_id]
ORDER BY [JobName], [StepNo];

-- list of schedules created/available in SQL Server and the details (Occurrence, Recurrence, Frequency, etc.) of each of the schedules.
SELECT [schedule_uid] AS [ScheduleID],
       [name] AS [ScheduleName],
       CASE [enabled]
          WHEN 1 THEN 'Yes'
          WHEN 0 THEN 'No'
       END AS [IsEnabled],
       CASE 
          WHEN [freq_type] = 64 THEN 'Start automatically when SQL Server Agent starts'
          WHEN [freq_type] = 128 THEN 'Start whenever the CPUs become idle'
          WHEN [freq_type] IN (4,8,16,32) THEN 'Recurring'
          WHEN [freq_type] = 1 THEN 'One Time'
       END [ScheduleType],
       CASE [freq_type]
          WHEN 1 THEN 'One Time'
          WHEN 4 THEN 'Daily'
          WHEN 8 THEN 'Weekly'
          WHEN 16 THEN 'Monthly'
          WHEN 32 THEN 'Monthly - Relative to Frequency Interval'
          WHEN 64 THEN 'Start automatically when SQL Server Agent starts'
          WHEN 128 THEN 'Start whenever the CPUs become idle'
       END [Occurrence],
       CASE [freq_type]
          WHEN 4 THEN 'Occurs every ' + CAST([freq_interval] AS VARCHAR(3)) + ' day(s)'
          WHEN 8 THEN 'Occurs every ' + CAST([freq_recurrence_factor] AS VARCHAR(3)) 
                       + ' week(s) on '
                       + CASE WHEN [freq_interval] & 1 = 1 THEN 'Sunday' ELSE '' END
                       + CASE WHEN [freq_interval] & 2 = 2 THEN ', Monday' ELSE '' END
                       + CASE WHEN [freq_interval] & 4 = 4 THEN ', Tuesday' ELSE '' END
                       + CASE WHEN [freq_interval] & 8 = 8 THEN ', Wednesday' ELSE '' END
                       + CASE WHEN [freq_interval] & 16 = 16 THEN ', Thursday' ELSE '' END
                       + CASE WHEN [freq_interval] & 32 = 32 THEN ', Friday' ELSE '' END
                       + CASE WHEN [freq_interval] & 64 = 64 THEN ', Saturday' ELSE '' END
          WHEN 16 THEN 'Occurs on Day ' + CAST([freq_interval] AS VARCHAR(3)) 
                       + ' of every '
                       + CAST([freq_recurrence_factor] AS VARCHAR(3)) + ' month(s)'
          WHEN 32 THEN 'Occurs on '
                       + CASE [freq_relative_interval]
                             WHEN 1 THEN 'First'
                             WHEN 2 THEN 'Second'
                             WHEN 4 THEN 'Third'
                             WHEN 8 THEN 'Fourth'
                             WHEN 16 THEN 'Last'
                         END
                       + ' ' 
                       + CASE [freq_interval]
                             WHEN 1 THEN 'Sunday'
                             WHEN 2 THEN 'Monday'
                             WHEN 3 THEN 'Tuesday'
                             WHEN 4 THEN 'Wednesday'
                             WHEN 5 THEN 'Thursday'
                             WHEN 6 THEN 'Friday'
                             WHEN 7 THEN 'Saturday'
                             WHEN 8 THEN 'Day'
                             WHEN 9 THEN 'Weekday'
                             WHEN 10 THEN 'Weekend day'
                         END
                        + ' of every ' + CAST([freq_recurrence_factor] AS VARCHAR(3)) 
                        + ' month(s)'
          END AS [Recurrence],
      CASE [freq_subday_type]
          WHEN 1 THEN 'Occurs once at ' 
                    + STUFF(STUFF(RIGHT('000000' + CAST([active_start_time] AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
          WHEN 2 THEN 'Occurs every ' 
                    + CAST([freq_subday_interval] AS VARCHAR(3)) + ' Second(s) between ' 
                    + STUFF(STUFF(RIGHT('000000' + CAST([active_start_time] AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
                    + ' & ' 
                    + STUFF(STUFF(RIGHT('000000' + CAST([active_end_time] AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
          WHEN 4 THEN 'Occurs every ' 
                    + CAST([freq_subday_interval] AS VARCHAR(3)) + ' Minute(s) between ' 
                    + STUFF(STUFF(RIGHT('000000' + CAST([active_start_time] AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
                    + ' & ' 
                    + STUFF(STUFF(RIGHT('000000' + CAST([active_end_time] AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
          WHEN 8 THEN 'Occurs every ' 
                    + CAST([freq_subday_interval] AS VARCHAR(3)) + ' Hour(s) between ' 
                    + STUFF(STUFF(RIGHT('000000' + CAST([active_start_time] AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
                    + ' & ' 
                    + STUFF(STUFF(RIGHT('000000' + CAST([active_end_time] AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
      END AS [Frequency],
      STUFF(STUFF(CAST([active_start_date] AS VARCHAR(8)), 5, 0, '-'), 8, 0, '-') AS [ScheduleUsageStartDate],
      STUFF(STUFF(CAST([active_end_date] AS VARCHAR(8)), 5, 0, '-'), 8, 0, '-') AS [ScheduleUsageEndDate],
      [date_created] AS [ScheduleCreatedOn],
      [date_modified] AS [ScheduleLastModifiedOn]
FROM msdb.dbo.[sysschedules]
ORDER BY [ScheduleName];