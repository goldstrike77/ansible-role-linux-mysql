![](https://img.shields.io/badge/Ansible-mysql-green.svg?logo=angular&style=for-the-badge)

>__Please note that the original design goal of this role was more concerned with the initial installation and bootstrapping environment, which currently does not involve performing continuous maintenance, and therefore are only suitable for testing and development purposes,  should not be used in production environments.__

>__请注意，此角色的最初设计目标更关注初始安装和引导环境，目前不涉及执行持续维护，因此仅适用于测试和开发目的，不应在生产环境中使用。__
___

<p><img src="https://raw.githubusercontent.com/goldstrike77/goldstrike77.github.io/master/img/logo/logo_mysql.png" align="right" /></p>

__Table of Contents__

- [Overview](#overview)
- [Task Specifications](#Task-Specifications)
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
MySQL is an open-source relational database management system (RDBMS). A relational database organizes data into one or more data tables in which data types may be related to each other; these relations help structure the data. SQL is a language programmers use to create, modify and extract data from the relational database, as well as control user access to the database. In addition to relational databases and SQL, an RDBMS like MySQL works with an operating system to implement a relational database in a computer's storage system, manages users, allows for network access and facilitates testing database integrity and creation of backups.

Percona Server for MySQL is a free, fully compatible, enhanced and open-source drop-in replacement for any MySQL database. It provides superior performance, scalability and instrumentation. Percona Server for MySQL is trusted by thousands of enterprises to provide better performance and concurrency for their most demanding workloads and delivers greater value to MySQL server users with optimized performance, greater performance scalability and availability, enhanced backups and increased visibility.

Orchestrator is a MySQL topology manager and a failover solution, runs as a service and provides command line access, HTTP API and Web interface. used in production on many large MySQL installments. It allows for detecting, querying and refactoring complex replication topologies, and provides reliable failure detection and intelligent recovery and promotion.

<p><img src="https://raw.githubusercontent.com/goldstrike77/docs/master/MySQL/orchestrator.png" /></p>

## Task Specifications
- Installation type
  - Standalone.
  - Replication with orchestrator management.
- Configuration
  - Buffer Pool Size, Connections, Character set and other general parameters.
  - Networking and Firewall.
  - Resource limiting.
  - Cluster member relationship.
  - Customized database.
  - Privilege management.
  - SQL Mode.
- Backup
  - Scheduled full and incremental backups.
  - Compressed backups.
  - Cloud storage backups.
- Monitoring
  - Status.
  - Variables.
  - Databases.
  - Table.
  - Query.
  - Replication.
- Analyzing
  - Query execution logging.
  - Grouped by fingerprint and reported in descending order of query.
- Security Safeguard Benchmark
  - Transparent Data Encryption (TDE) protects your critical data by enabling data-at-rest encryption in the database. It protects the privacy of your information, prevents data breaches and helps meet regulatory requirements.
  - Supports secure (encrypted) connections between clients and the server using the Transport Layer Security (TLS) protocol.
  - Encrypt/decrypt local or streaming backup in order to add another layer of protection to the backups.
  - File system permissions protected when potential vulnerability exists.
  - Authentication management makes IT infrastructures more secure by leveraging existing security rules and processes.
  - Ensure the test database is not installed.
  - Auditing provides monitoring and logging of connection and query activity that was performed on the MySQL server. Information will be transferred to the SIEM subsection like Graylog or ELK stack.
- Failover
  - Supports the automatic failover of the master, and the replication tree can be fixed when servers in the tree fail either manually.

>__The mysqld service must be disabled and can only be started manually if orchestrator replication management is used. see https://github.com/github/orchestrator/issues/891.__

>__There are some files that record MySQL account password for replication, xtrabackup and prometheus in /tmp folder at the first master node, Burn after reading!__

## Requirements
### Operating systems
This Ansible role installs Percona Server for MySQL on Linux operating system, including establishing a filesystem structure and server configuration with some common operational features, Will works on the following operating systems:

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
* `mysql_ssl`: A boolean value, whether Encrypting client and cluster communications.
* `mysql_storage_engine`: Preferred storage engine, InnoDB or MyISAM
* `mysql_innodb_buffer_pool_size`: The size in MB of the buffer pool.
* `mysql_max_connections`: The maximum permitted number of simultaneous client connections.
* `mysql_system_type`: Define instance parameters.

##### Cluster parameters
* `mysql_cluster_name`: Cluster name of servers that implements distribution performance.
* `mysql_cluster_mode`: Defines type of cluster type: standalone / replication.
* `mysql_cluster_mgmt`: MySQL high availability and replication management tool.

##### Role dependencies
* `mysql_orchestrator_dept`: A boolean value, whether Orchestrator use the same environment.

##### Orchestrator parameters
* `mysql_orchestrator_ui_user`: Management console authentication user.
* `mysql_orchestrator_ui_pass`: Management console authentication password.
* `mysql_orchestrator_ui_ssl`: A boolean value, whether Encrypting client communications.
* `mysql_orchestrator_port_ui`: Orchestrator Web UI listen port.
* `mysql_orchestrator_port_agent`: Orchestrator Agent listen port.
* `mysql_orchestrator_port_raft`: Orchestrator Raft listen port.
* `mysql_orchestrator_mysql_user`: MySQL topology control account name.
* `mysql_orchestrator_mysql_pass`: MySQL topology control account password.

##### Backup parameters
* `mysql_backupset_arg.life`: Lifetime of the latest full backup in seconds.
* `mysql_backupset_arg.keep`: The number of full backups (and its incrementals) to keep.
* `mysql_backupset_arg.encryptkey`: BackupSet encryption key, Generate by [openssl rand -base64 24].
* `mysql_backupset_arg.cloud_rsync`: Whether rsync for cloud storage.
* `mysql_backupset_arg.cloud_drive`: Specify the cloud storage providers.
* `mysql_backupset_arg.cloud_bwlimit`: Controls the bandwidth limit.
* `mysql_backupset_arg.cloud_event`: Define transfer events.
* `mysql_backupset_arg.cloud_config`: Specify the cloud storage configuration.

##### Listen port
* `mysql_port_mysqld`: MySQL instance listen port.
* `mysql_port_exporter`: Prometheus MySQL Exporter listen port.

##### Server System Variables
* `mysql_arg.binlog_cache_size`: Size of the cache to hold changes to the binary log during a transaction.
* `mysql_arg.binlog_format`: The binary logging format.
* `mysql_arg.binlog_stmt_cache_size`: Size of the cache for the binary log to hold nontransactional statements issued during a transaction.
* `mysql_arg.character_set`: Server's default character set.
* `mysql_arg.connect_timeout`: Server waits for a connect packet in seconds.
* `mysql_arg.data_encryption`: A boolean value, whether enabled the MySQL Data at Rest Encryption.
* `mysql_arg.default_time_zone`: Default server time zone.
* `mysql_arg.expire_logs_days`: The number of days for automatic binary log file removal.
* `mysql_arg.enforce_gtid_consistency`: Enforces GTID consistency by allowing execution of only statements that can be safely logged using a GTID.
* `mysql_arg.gtid_mode`: Controls whether GTID based logging is enabled and what type of transactions the logs can contain.
* `mysql_arg.lower_case_table_names`: Affects how the server handles identifier case sensitivity.
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

##### Service Mesh
* `environments`: Define the service environment.
* `tags`: Define the service custom label.
* `exporter_is_install`: Whether to install prometheus exporter.
* `consul_public_register`: Whether register a exporter service with public consul client.
* `consul_public_exporter_token`: Public Consul client ACL token.
* `consul_public_http_prot`: The consul Hypertext Transfer Protocol.
* `consul_public_clients`: List of public consul clients.
* `consul_public_http_port`: The consul HTTP API port.

### Other parameters
There are some variables in vars/main.yml:

* `mysql_kernel_parameters`: Operating system variables.
* `mysql_conf_scripts`: Specify the MySQL configure and script files.
* `mysqld_exporter_collector`: Prometheus mysqld exporter collector flags.
* `mysql_sql_mode`: Specify value the global SQL mode.
* `mysql_audit_log_commands`: Filtering command for audit process.

## Dependencies
- Ansible versions >= 2.8
- Python >= 2.7.5
- [Orchestrator](https://github.com/goldstrike77/ansible-role-linux-orchestrator)

## Example

### Hosts inventory file
See tests/inventory for an example.

    [MySQL]
    node01 ansible_host='192.168.1.10'
    node02 ansible_host='192.168.1.11'
    node03 ansible_host='192.168.1.12'

    [MySQL:vars]
    mysql_version='57'
    mysql_cluster_name='cluster01'
    mysql_cluster_mode='replication'

### Vars in role configuration
Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```yaml
- hosts: all
  roles:
     - role: ansible-role-linux-mysql
       mysql_version: '57'
```

### Combination of group vars and playbook
You can also use the group_vars or the host_vars files for setting the variables needed for this role. File you should change: group_vars/all or host_vars/`group_name`.

```yaml
mysql_releases: 'Percona'
mysql_version: '57'
mysql_path: '/data'
mysql_user: 'mysql'
mysql_mailto: 'somebody@example.com'
mysql_sa_pass: 'changeme'
mysql_ssl: false
mysql_storage_engine: 'InnoDB'
mysql_innodb_buffer_pool_size: '1024'
mysql_max_connections: '100'
mysql_system_type: 'autopilot'
mysql_cluster_name: 'cluster01'
mysql_cluster_mode: 'standalone'
mysql_cluster_mgmt: ''
mysql_orchestrator_dept: false
mysql_orchestrator_ui_user: 'admin'
mysql_orchestrator_ui_pass: 'changeme'
mysql_orchestrator_ui_ssl: false
mysql_orchestrator_port_ui: '3002'
mysql_orchestrator_port_agent: '3003'
mysql_orchestrator_port_raft: '10008'
mysql_orchestrator_mysql_user: 'orchestrator'
mysql_orchestrator_mysql_pass: 'changeme'
mysql_backupset_arg:
  life: '604800'
  keep: '2'
  encryptkey: 'Un9FA+CgxM5Yr/MpwTh5s6NXSQE0brp8'
  cloud_rsync: true
  cloud_drive: 'azureblob'
  cloud_bwlimit: '10M'
  cloud_event: 'sync'
  cloud_config:
    account: 'blobuser'
    key: 'base64encodedkey=='
    endpoint: 'blob.core.chinacloudapi.cn'
mysql_port_mysqld: '3306'
mysql_port_exporter: '9104'
mysql_arg:
  binlog_cache_size: '1048576'
  binlog_format: 'ROW'
  binlog_stmt_cache_size: '1048576'
  character_set: 'utf8mb4'
  connect_timeout: '30'
  data_encryption: false
  default_time_zone: '+8:00'
  expire_logs_days: '15'
  enforce_gtid_consistency: 'on'
  gtid_mode: 'on'
  lower_case_table_names: '0'
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
environments: 'Development'
tags:
  subscription: 'default'
  owner: 'nobody'
  department: 'Infrastructure'
  organization: 'The Company'
  region: 'IDC01'
exporter_is_install: false
consul_public_register: false
consul_public_exporter_token: '00000000-0000-0000-0000-000000000000'
consul_public_http_prot: 'https'
consul_public_http_port: '8500'
consul_public_clients:
  - '127.0.0.1'
```

## License
![](https://img.shields.io/badge/MIT-purple.svg?style=for-the-badge)

## Author Information
Please send your suggestions to make this role better.

## Contributors
Special thanks to the [Connext Information Technology](http://www.connext.com.cn) for their contributions to this role.
