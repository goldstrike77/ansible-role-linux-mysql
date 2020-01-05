![](https://img.shields.io/badge/Ansible-mysql-green.svg?logo=angular&style=for-the-badge)

>__Please note that the original design goal of this role was more concerned with the initial installation and bootstrapping environment, which currently does not involve performing continuous maintenance, and therefore are only suitable for testing and development purposes,  should not be used in production environments.__

>__请注意，此角色的最初设计目标更关注初始安装和引导环境，目前不涉及执行连续维护，因此仅适用于测试和开发目的，不应在生产环境中使用。__
___

<p><img src="https://raw.githubusercontent.com/goldstrike77/goldstrike77.github.io/master/img/logo/logo_mysql.png" align="right" /></p>

__Table of Contents__

- [Overview](#overview)
- [Requirements](#requirements)
  * [Operating systems](#operating-systems)
  * [MySQL Versions](#MySQL-versions)
- [ Role variables](#Role-variables)
  * [Main Configuration](#Main-parameters)
  * [Other Configuration](#Other-parameters)
- [Dependencies](#dependencies)
- [Example Playbook](#example-playbook)
  * [Hosts inventory file](#Hosts-inventory-file)
  * [Vars in role configuration](#vars-in-role-configuration)
  * [Combination of group vars and playbook](#combination-of-group-vars-and-playbook)
- [License](#license)
- [Author Information](#author-information)
- [Contributors](#Contributors)

## Overview
This Ansible role installs Percona Server for MySQL on linux operating system, including establishing a filesystem structure and server configuration with some common operational features.

>__<span style="color:red">The mysqld service must be disabled and can only be started manually if orchestrator replication management is used. see https://github.com/github/orchestrator/issues/891.</span>__

## Requirements
### Operating systems
This role will work on the following operating systems:

  * CentOS 7

### MySQL versions

The following list of supported the MySQL releases:

* MySQL Community Server 5.7
* Percona Server for MySQL 5.7

## Role variables
### Main parameters #
There are some variables in defaults/main.yml which can (Or needs to) be overridden:
##### General parameters
* `mysql_releases`: Define MySQL distribution.
* `mysql_version`: Specify the MySQL version.
* `mysql_path`: Specify the MySQL data directory.
* `mysql_user`: System user name for running mysqld services.
* `mysql_mailto`: MySQL report mail recipient.
* `mysql_sa_pass`: MySQL root account password.
* `mysql_storage_engine`: Preferred storage engine, InnoDB or MyISAM
* `mysql_innodb_buffer_pool_size`: The size in MB of the buffer pool.
* `mysql_max_connections`: The maximum permitted number of simultaneous client connections.
* `mysql_system_type`: Define instance parameters.

##### Cluster parameters
* `mysql_cluster_name`: Cluster name of servers that implements distribution performance.
* `mysql_cluster_mode`: Defines type of cluster type: standalone / replication.
* `mysql_cluster_mgmt`: High availability and replication management tool.
* `mysql_cluster_mgmt_user`: Management console authentication user.
* `mysql_cluster_mgmt_pass`: Management console authentication password.

##### Service Mesh
* `environments`: Define the service environment.
* `tags`: Define the service custom label.
* `exporter_is_install`: Whether to install prometheus exporter.
* `consul_public_register`: false Whether register a exporter service with public consul client.
* `consul_public_exporter_token`: Public Consul client ACL token.
* `consul_public_clients`: List of public consul clients.
* `consul_public_http_port`: The consul HTTP API port.

##### Backup parameters
* `mysql_backupset_arg.life`: Lifetime of the latest full backup in seconds.
* `mysql_backupset_arg.keep`: The number of full backups (and its incrementals) to keep.
* `mysql_backupset_arg.encryptkey`: BackupSet encryption key, Generate by [openssl rand -base64 24].

##### Listen port
* `mysql_port_mysqld`: MySQL instance listen port.
* `mysql_port_exporter`: Prometheus MySQL Exporter listen port.
* `mysql_port_orchestrator_web`: Orchestrator Web UI listen port.
* `mysql_port_orchestrator_raft`: Orchestrator Raft listen port.

##### Server System Variables
* `mysql_arg.binlog_cache_size`: Size of the cache to hold changes to the binary log during a transaction.
* `mysql_arg.binlog_format`: The binary logging format.
* `mysql_arg.binlog_stmt_cache_size`: Size of the cache for the binary log to hold nontransactional statements issued during a transaction.
* `mysql_arg.character_set`: Server's default character set.
* `mysql_arg.connect_timeout`: Server waits for a connect packet in seconds.
* `mysql_arg.expire_logs_days`: The number of days for automatic binary log file removal.
* `mysql_arg.enforce_gtid_consistency`: Enforces GTID consistency by allowing execution of only statements that can be safely logged using a GTID.
* `mysql_arg.gtid_mode`: Controls whether GTID based logging is enabled and what type of transactions the logs can contain.
* `mysql_arg.innodb_buffer_pool_instances`: The number of regions that the InnoDB buffer pool is divided into.
* `mysql_arg.innodb_flush_log_at_trx_commit`: Controls the balance between strict ACID compliance for commit operations and higher performance.
* `mysql_arg.innodb_log_buffer_size`: Size in MB of the buffer that InnoDB uses to write to the log files on disk.
* `mysql_arg.innodb_log_file_size`: The size in MB of each log file in a log group.
* `mysql_arg.innodb_max_dirty_pages_pct`: A target for flushing activity.
* `mysql_arg.innodb_max_undo_log_size`: The size in MB of undo tablespaces.
* `mysql_arg.innodb_page_cleaners`: The number of page cleaner threads that flush dirty pages from buffer pool instances.
* `mysql_arg.innodb_purge_threads`: The number of background threads devoted to the InnoDB purge operation.
* `mysql_arg.innodb_read_io_threads`: The number of I/O threads for read operations in InnoDB.
* `mysql_arg.innodb_write_io_threads`: The number of I/O threads for write operations in InnoDB.
* `mysql_arg.interactive_timeout`: Server waits for activity on an interactive connection in seconds.
* `mysql_arg.join_buffer_size`: Size of the buffer that is used for index scans.
* `mysql_arg.key_buffer_size`: Size of the buffer used for MyISAM tables index blocks in MB.
* `mysql_arg.log_queries_not_using_indexes`: Logs whether queries that do not use indexes.
* `mysql_arg.long_query_time`: Logs query that executes longer than in seconds.
* `mysql_arg.max_allowed_packet`: The maximum size of one packet.
* `mysql_arg.max_connect_errors`: Limits the maximum number of interrupted without a successful connection.
* `mysql_arg.max_heap_table_size`: The maximum size to which user-created MEMORY tables are permitted to grow.
* `mysql_arg.max_prepared_stmt_count`: Limits the total number of prepared statements in the server.
* `mysql_arg.open_files_limit`: The number of files that the operating system permits MySQL to open.
* `mysql_arg.open_nproc_limit`: The number of processes launched by systemd.
* `mysql_arg.performance_schema_max_table_instances`: The maximum number of instrumented table objects.
* `mysql_arg.query_cache_size`: Query cache size.
* `mysql_arg.query_cache_type`: Query cache type.
* `mysql_arg.read_rnd_buffer_size`: Size of the buffer that is used for reading rows in sorted order.
* `mysql_arg.slave_net_timeout`: The number of seconds to wait for more data from the master before the slave.
* `mysql_arg.sync_binlog`: Controls how often the MySQL server synchronizes the binary log to disk.
* `mysql_arg.table_definition_cache`: The number of table definitions that can be stored in the definition cache.
* `mysql_arg.table_open_cache`: The number of open tables for all threads.
* `mysql_arg.table_open_cache_instances`: The number of open tables cache instances.
* `mysql_arg.thread_cache_size`: How many threads the server should cache for reuse.
* `mysql_arg.thread_handling`: The thread-handling model used by the server for connection threads. 
* `mysql_arg.thread_pool_max_threads`: The maximum number of threads in the thread pool.
* `mysql_arg.thread_pool_oversubscribe`: How many worker threads in a thread group can remain active at the same time once a thread group is oversubscribed due to stalls.
* `mysql_arg.tmp_table_size`: The maximum size of internal in-memory temporary tables.
* `mysql_arg.wait_timeout`: Server waits for activity on a noninteractive connection in seconds.

### Other parameters
There are some variables in vars/main.yml:

* `mysql_kernel_parameters`: Operating system variables.
* `mysql_conf_scripts`: Specify the MySQL configure and script files.
* `mysqld_exporter_collector`: Prometheus mysqld exporter collector flags.
* `mysql_sql_mode`: Specify value the global SQL mode.
* `mysql_audit_log_commands`: Filtering command for audit process.

## Dependencies
There are no dependencies on other roles.

## Example

### Hosts inventory file
See tests/inventory for an example.

    node01 ansible_host='192.168.1.10' mysql_version='57'

### Vars in role configuration
Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: all
      roles:
         - role: ansible-role-linux-mysql
           mysql_version: '57'

### Combination of group vars and playbook
You can also use the group_vars or the host_vars files for setting the variables needed for this role. File you should change: group_vars/all or host_vars/`group_name`

    mysql_releases: 'Percona'
    mysql_version: '57'
    mysql_path: '/data'
    mysql_user: 'mysql'
    mysql_mailto: 'somebody@example.com'
    mysql_sa_pass: 'changeme'
    mysql_storage_engine: 'InnoDB'
    mysql_innodb_buffer_pool_size: '1024'
    mysql_max_connections: '100'
    mysql_system_type: 'autopilot'
    mysql_cluster_name: 'cluster01'
    mysql_cluster_mode: 'standalone'
    mysql_cluster_mgmt: 'orchestrator'
    mysql_cluster_mgmt_user: 'admin'
    mysql_cluster_mgmt_pass: 'changeme'
    mysql_backupset_arg:
      life: '604800'
      keep: '2'
      encryptkey: 'Un9FA+CgxM5Yr/MpwTh5s6NXSQE0brp8'
    mysql_port_mysqld: '3306'
    mysql_port_exporter: '9104'
    mysql_port_orchestrator_web: '3002'
    mysql_port_orchestrator_raft: '10008'
    mysql_arg:
      binlog_cache_size: '1048576'
      binlog_format: 'ROW'
      binlog_stmt_cache_size: '1048576'
      character_set: 'utf8mb4'
      connect_timeout: '30'
      expire_logs_days: '15'
      enforce_gtid_consistency: 'on'
      gtid_mode: 'on'
      innodb_buffer_pool_instances: '8'
      innodb_flush_log_at_trx_commit: '2'
      innodb_log_buffer_size: '16'
      innodb_log_file_size: '1024'
      innodb_max_dirty_pages_pct: '85'
      innodb_max_undo_log_size: '1024'
      innodb_page_cleaners: '4'
      innodb_purge_threads: '4'
      innodb_read_io_threads: '4'
      innodb_write_io_threads: '4'
      interactive_timeout: '3600'
      join_buffer_size: '1M'
      key_buffer_size: '32'
      log_queries_not_using_indexes: '1'
      long_query_time: '1'
      max_allowed_packet: '32M'
      max_connect_errors: '100'
      max_heap_table_size: '32M'
      max_prepared_stmt_count: '262144'
      open_files_limit: '131072'
      open_nproc_limit: '131072'
      performance_schema_max_table_instances: '512'
      query_cache_size: '0'
      query_cache_type: '0'
      read_rnd_buffer_size: '1M'
      slave_net_timeout: '10'
      sync_binlog: '1000'
      table_definition_cache: '4096'
      table_open_cache: '4096'
      table_open_cache_instances: '64'
      thread_cache_size: '50'
      thread_handling: 'pool-of-threads'
      thread_pool_max_threads: '1000'
      thread_pool_oversubscribe: '10'
      tmp_table_size: '32M'
      wait_timeout: '3600'
    environments: 'SIT'
    tags:
      subscription: 'default'
      owner: 'nobody'
      department: 'Infrastructure'
      organization: 'The Company'
      region: 'IDC01'
    exporter_is_install: false
    consul_public_register: false
    consul_public_exporter_token: '00000000-0000-0000-0000-000000000000'
    consul_public_clients: 'localhost'
    consul_public_http_port: '8500'

## License
![](https://img.shields.io/badge/MIT-purple.svg?style=for-the-badge)

## Author Information
Please send your suggestions to make this role better.

## Contributors
Special thanks to the [Connext Information Technology](http://www.connext.com.cn) for their contributions to this role.
