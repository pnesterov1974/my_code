-- 1 Show the latest executed packages filtered by Project and Package Name TODO: Folder

DECLARE @ProjectNamePattern NVARCHAR(100) = '%Compensation%'-- Filter data by project name (use % for no filter)
DECLARE @PackageNamePattern NVARCHAR(100) = '%Plan_Daily_Compensation_Buf_Update_Step_0_Ex%'-- Filter data by package name (use % for no filter)
DECLARE @ExecutionIdFilter BIGINT = NULL-- Filter data by execution id (use NULL for no filter)
-- Show last 15 executions
SELECT TOP 15
	e.[execution_id], 
	e.[project_name],
	e.[package_name],
	e.[project_lsn],
	e.[status], 
	[status_desc] = CASE e.[status] 
						WHEN 1 THEN 'Created'
						WHEN 2 THEN 'Running'
						WHEN 3 THEN 'Cancelled'
						WHEN 4 THEN 'Failed'
						WHEN 5 THEN 'Pending'
						WHEN 6 THEN 'Ended Unexpectedly'
						WHEN 7 THEN 'Succeeded'
						WHEN 8 THEN 'Stopping'
						WHEN 9 THEN 'Completed'
					END,
	e.[start_time],
	e.[end_time],
	[elapsed_time_min] = DATEDIFF(mi, e.[start_time], e.[end_time])
FROM SSISDB.catalog.[executions] e 
WHERE e.[project_name] LIKE @ProjectNamePattern
      --AND e.[package_name] LIKE @PackageNamePattern
	  --AND e.[execution_id] = ISNULL(@executionIdFilter, e.execution_id)
ORDER BY e.[execution_id] DESC
OPTION (RECOMPILE);

-- Get detailed information for the first package in the list
DECLARE @ExecutionId BIGINT, @PackageName NVARCHAR(1000); 
SELECT TOP 1 @ExecutionId = e.[execution_id], @PackageName = e.[package_name] 
FROM SSISDB.catalog.[executions] e
WHERE e.[project_name] LIKE @projectNamePattern
      --AND e.[package_name] LIKE @packageNamePattern
      --AND e.[execution_id] = ISNULL(@executionIdFilter, e.[execution_id])
ORDER BY e.[execution_id] DESC
OPTION (RECOMPILE);

-- Show successfull execution history
SELECT TOP 15
	e.[execution_id], 
	e.[project_name],
	e.[package_name],
	e.[project_lsn],
	e.[status], 
	[status_desc] = CASE e.[status] 
						WHEN 1 THEN 'Created'
						WHEN 2 THEN 'Running'
						WHEN 3 THEN 'Cancelled'
						WHEN 4 THEN 'Failed'
						WHEN 5 THEN 'Pending'
						WHEN 6 THEN 'Ended Unexpectedly'
						WHEN 7 THEN 'Succeeded'
						WHEN 8 THEN 'Stopping'
						WHEN 9 THEN 'Completed'
					END,
	e.[start_time],
	e.[end_time],
	[elapsed_time_min] = DATEDIFF(mi, e.[start_time], e.[end_time])
FROM SSISDB.catalog.[executions] e 
WHERE e.[status] IN (2,7)
      AND e.[package_name] = @packageName
ORDER BY e.[execution_id] DESC
OPTION (RECOMPILE);

-- Show error messages
SELECT * 
FROM SSISDB.catalog.[event_messages] em 
WHERE (em.[operation_id] = @executionId) --AND (em.event_name = 'OnError')
ORDER BY em.[event_message_id] DESC
OPTION (RECOMPILE);

-- Show warnings for memory allocations (example for warnings)
SELECT * 
FROM SSISDB.catalog.[event_messages] em 
WHERE (em.[operation_id] = @executionId)
      AND (em.[event_name] = 'OnInformation') 
      --AND ([message] LIKE '%memory allocation%') 
ORDER BY em.event_message_id DESC
OPTION (RECOMPILE);

-- 2. Show execution historical data. Also show Dataflow destination informations
DECLARE @SourceNameFilter AS nvarchar(max) = '%%';

IF (OBJECT_ID('tempdb..#t') IS NOT NULL) DROP TABLE #t;

WITH [PRE] AS (
	SELECT * FROM SSISDB.catalog.[event_messages] em 
	WHERE em.[event_name] IN ('OnPreExecute')
),
[POST] AS (
	SELECT * FROM SSISDB.catalog.[event_messages] em 
	WHERE em.[event_name] IN ('OnPostExecute')
)
SELECT
	b.[operation_id],
	[from_event_message_id] = b.[event_message_id],
	[to_event_message_id] = e.[event_message_id],
	b.[package_path],
	b.[message_source_name],
	[pre_message_time] = b.[message_time],
	[post_message_time] = e.[message_time],
	[elapsed_time_min] = DATEDIFF(mi, b.[message_time], COALESCE(e.[message_time], SYSDATETIMEOFFSET()))
INTO #t
FROM [PRE] b
LEFT JOIN [POST] e ON (b.[operation_id] = e.[operation_id]) AND (b.[package_name] = e.[package_name]) AND (b.[message_source_id] = e.[message_source_id])
INNER JOIN 	SSISDB.catalog.[executions] e2 ON b.[operation_id] = e2.[execution_id]
WHERE b.[package_path] = '\Package'
      AND b.[message_source_name] LIKE @SourceNameFilter
      AND e2.[status] IN (2,7);

SELECT * FROM #t ORDER BY operation_id DESC;

-- Show DataFlow Destination Informations
WITH [cte] AS (
	SELECT *,
		[token_destination_name_start] = CHARINDEX(': "', [message]) + 3,
		[token_destination_name_end] = CHARINDEX('" wrote', [message]),
		[token_rows_start] = LEN([message]) - CHARINDEX('e', REVERSE([message]), 1) + 3,
		[token_rows_end] = LEN([message]) - CHARINDEX('r', REVERSE([message]), 1)
	FROM [catalog].[event_messages] em
)
SELECT TOP 100
	c.[operation_id],
	[event_message_id],
	[package_name],
	c.[message_source_name],
	[message_time],
	--destination_name = SUBSTRING([message], token_destination_name_start,  token_destination_name_end - token_destination_name_start),
	[loaded_rows] = SUBSTRING([message], [token_rows_start], [token_rows_end] - [token_rows_start]),
	[message]
FROM [cte] as c 
INNER JOIN #t t ON (c.[operation_id] = t.[operation_id]) AND (c.[event_message_id] BETWEEN t.[from_event_message_id] AND t.[to_event_message_id])
WHERE ([subcomponent_name] = 'SSIS.Pipeline') 
      AND ([message] like '%rows.%')
ORDER BY c.[operation_id] DESC, [message_time] DESC;


-- 3. Show the Information/Warning/Error messages found in the log for a specific execution. 
-- The first resultset is the log, the second one shows the performance
DECLARE @ExecutionIdFilter BIGINT = NULL;-- Filter data by execution id (use NULL for no filter)
DECLARE @ShowOnlyChildPackages BIT = 0;-- Show only Child Packages or everyhing
DECLARE @MessageSourceName NVARCHAR(MAX) = '%';-- Show only message from a specific Message Source

-- Log Info
SELECT * FROM SSISDB.catalog.[event_messages] em 
WHERE ((em.[operation_id] = @ExecutionIdFilter) OR @ExecutionIdFilter IS NULL) 
      AND (em.[event_name] IN ('OnInformation', 'OnError', 'OnWarning'))
      AND ([package_path] LIKE CASE WHEN @ShowOnlyChildPackages = 1 THEN '\Package' ELSE '%' END)
      AND (em.[message_source_name] LIKE @messageSourceName)
ORDER BY em.[event_message_id];

-- Performance Breakdown
IF (OBJECT_ID('tempdb..#t') IS NOT NULL) DROP TABLE #t;

WITH [PRE] AS (
	SELECT * FROM SSISDB.catalog.[event_messages] em 
	WHERE em.[event_name] IN ('OnPreExecute')
	AND ((em.[operation_id] = @executionIdFilter) OR @executionIdFilter IS NULL)
	AND (em.[message_source_name] LIKE @messageSourceName)
), 
[POST] AS (
	SELECT * FROM SSISDB.catalog.[event_messages] em 
	WHERE em.[event_name] IN ('OnPostExecute')
	AND ((em.[operation_id] = @executionIdFilter) OR @executionIdFilter IS NULL)
	AND (em.[message_source_name] like @messageSourceName)
)
SELECT
	b.[operation_id],
	[from_event_message_id] = b.[event_message_id],
	[to_event_message_id] = e.[event_message_id],
	b.[package_path],
	b.[execution_path],
	b.[message_source_name],
	[pre_message_time] = b.[message_time],
	[post_message_time] = e.[message_time],
	[elapsed_time_min] = DATEDIFF(mi, b.[message_time], COALESCE(e.[message_time], SYSDATETIMEOFFSET()))
INTO #t
FROM [PRE] b
LEFT JOIN [POST] e ON (b.[operation_id] = e.[operation_id]) AND (b.[package_name] = e.[package_name]) AND (b.[message_source_id] = e.[message_source_id]) AND (b.[execution_path] = e.[execution_path])
INNER JOIN SSISDB.catalog.[executions] e2 ON b.[operation_id] = e2.[execution_id]
WHERE e2.[status] IN (2,7)
OPTION (RECOMPILE);

SELECT * FROM #t 
WHERE package_path LIKE CASE WHEN @ShowOnlyChildPackages = 1 THEN '\Package' ELSE '%' END
ORDER BY #t.[pre_message_time] DESC;


-- 4. Show the parameters values used for a specific execution. The first resultset shows the values set via "parameters", the second via the "set" option
DECLARE @ExecutionIdFilter BIGINT = 9841801;

SELECT * FROM SSISDB.catalog.[execution_parameter_values] WHERE [execution_id] = @executionIdFilter and [value_set] = 1;

SELECT * FROM SSISDB.catalog.[execution_property_override_values] WHERE [execution_id] = @executionIdFilter;