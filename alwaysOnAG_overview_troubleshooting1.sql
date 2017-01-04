
-- POWERSHELL Check_cluster_votes
-- Get-ClusterNode | ft name, dynamicweight, nodeweight, state -AutoSize


-- To monitor availability database
select * from sys.availability_databases_cluster

select * from sys.dm_hadr_auto_page_repair

select * from sys.dm_hadr_database_replica_states

select * from sys.dm_hadr_database_replica_cluster_states

select * from sys.databases


-- To monitor availability replicas

select * from sys.availability_read_only_routing_lists

SELECT * FROM sys.dm_hadr_cluster_members

select * from sys.availability_replicas

select * from sys.dm_hadr_availability_replica_cluster_nodes

select * from sys.dm_hadr_availability_replica_cluster_states

select * from sys.dm_hadr_availability_replica_states

select * from sys.fn_hadr_backup_is_preferred_replica()




-- To monitor the availability groups 

select * from sys.availability_groups_cluster

select * from sys.availability_groups

select * from sys.dm_hadr_availability_group_states

-- To monitor the availability group listeners

select * from sys.availability_group_listener_ip_addresses

select * from sys.availability_group_listeners

select * from sys.dm_tcp_listener_states



-- other queries

select * from sys.availability_databases_cluster
select * from sys.availability_group_listener_ip_addresses
select * from sys.availability_group_listeners
select * from sys.availability_groups
select * from sys.availability_groups_cluster
select * from sys.availability_read_only_routing_lists
select * from sys.availability_replicas
select * from sys.dm_hadr_availability_group_states
select * from sys.dm_hadr_availability_replica_cluster_nodes
select * from sys.dm_hadr_availability_replica_cluster_states
select * from sys.dm_hadr_availability_replica_states
select * from sys.dm_hadr_cluster
select * from sys.dm_hadr_cluster_members
select * from sys.dm_hadr_cluster_networks
select * from sys.dm_hadr_database_replica_cluster_states
select * from sys.dm_io_cluster_shared_drives
select * from sys.dm_io_cluster_valid_path_names
select * from sys.dm_os_cluster_nodes
select * from sys.dm_os_cluster_properties

---



SELECT 
	ar.replica_server_name, 
	adc.database_name, 
	ag.name AS ag_name, 
	drs.is_local, 
	drs.is_primary_replica, 
	drs.synchronization_state_desc, 
	drs.database_state_desc,
	drs.is_commit_participant, 
	drs.synchronization_health_desc, 
	drs.recovery_lsn, 
	drs.truncation_lsn, 
	drs.last_sent_lsn, 
	drs.last_sent_time, 
	drs.last_received_lsn, 
	drs.last_received_time, 
	drs.last_hardened_lsn, 
	drs.last_hardened_time, 
	drs.last_redone_lsn, 
	drs.last_redone_time, 
	drs.log_send_queue_size, 
	drs.log_send_rate, 
	drs.redo_queue_size, 
	drs.redo_rate, 
	drs.filestream_send_rate, 
	drs.end_of_log_lsn, 
	drs.last_commit_lsn, 
	drs.last_commit_time
FROM sys.dm_hadr_database_replica_states AS drs
INNER JOIN sys.availability_databases_cluster AS adc 
	ON drs.group_id = adc.group_id AND 
	drs.group_database_id = adc.group_database_id
INNER JOIN sys.availability_groups AS ag
	ON ag.group_id = drs.group_id
INNER JOIN sys.availability_replicas AS ar 
	ON drs.group_id = ar.group_id AND 
	drs.replica_id = ar.replica_id
ORDER BY 
	ag.name, 
	ar.replica_server_name, 
	adc.database_name;
	
	
	
	select dc.database_name
, d.synchronization_health_desc
, d.synchronization_state_desc
, d.database_state_desc from  sys.dm_hadr_database_replica_states d 
join sys.availability_databases_cluster dc
on d.group_database_id=dc.group_database_id 
WHERE d.is_local=1