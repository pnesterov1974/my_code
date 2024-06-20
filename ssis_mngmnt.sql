-- Common info
SELECT * FROM [SSISDB].[catalog].[catalog_properties];

-- Folders -> Projects -> Packages
SELECT [folder_id], [name], [description], [created_by_name], [created_time] FROM [catalog].[folders];
SELECT [project_id], [folder_id], [name], [deployed_by_name], [last_deployed_time], [created_time], [validation_status] FROM [catalog].[projects];
SELECT [package_id], [project_id], [name], [description], [entry_point], [validation_status] FROM [catalog].[packages];

-- Packages -> Executions -> Executables
SELECT [execution_id], [folder_name], [project_name], [package_name], [reference_id], [reference_type], [environment_name], [operation_type], [object_type], [object_id], [status], [start_time], [end_time], [process_id] FROM [catalog].[executions];
SELECT [executable_id], [execution_id], [executable_name], [package_name], [package_path] FROM [catalog].[executables];
SELECT [statistics_id], [execution_id], [executable_id], [execution_path], [start_time], [end_time], [execution_duration], [execution_result],[execution_value]
FROM [catalog].[executable_statistics];

-- Enviroments
SELECT * FROM [SSISDB].[catalog].[environment_references];
SELECT * FROM [SSISDB].[catalog].[environment_variables];
SELECT * FROM [SSISDB].[catalog].[environments];

-- Execution Parameters
SELECT * FROM [SSISDB].[catalog].[execution_parameter_values];


*/