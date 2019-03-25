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
  * [Minimal Configuration](#minimal-configuration)
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

## Requirements
### Operating systems
This role will work on the following operating systems:

  * CentOS 7

### MySQL versions

The following list of supported the MySQL releases:

* Percona Server for MySQL 5.7

## Role variables
### Minimal configuration

In order to get the MySQL running, you'll have to define the following properties before executing the role:

* mysql_version

The `mysql_version` should contain the MySQL releases version.

### Main parameters #
There are some variables in defaults/main.yml which can (Or needs to) be overridden:
---
#### General parameters
* `mysql_path`: Specify the MySQL data directory.
* `mysql_selinux`: SELinux mysqld policy.
* `mysql_user`: System user name for running mysqld services.
* `mysql_mailto`: MySQL report mail recipient.
* `db_sa_pass`: MySQL root account password.
* `environments`: Define the object environment.
* `consul_is_register`: a boolean value, whether register a client service with consul.
* `consul_clients`: Consul client addresses list.
* `consul_http_port`: Consul client listen port.
* `consul_exporter_token`: Consul client ACL token.

#### Backup parameters
* `mysql_backupset_arg.life`: Lifetime of the latest full backup in seconds.
* `mysql_backupset_arg.keep`: The number of full backups (and its incrementals) to keep.
* `mysql_backupset_arg.encryptkey`: BackupSet encryption key.

#### Listen port
* `mysql_port_arg.mysqld`: MySQL instance listen port.
* `mysql_port_arg.mysql_exporter_port`: Prometheus MySQL Exporter listen port.

# Server System Variables #
* `mysql_arg.binlog_cache_size`: Size of the cache to hold changes to the binary log during a transaction.
* `mysql_arg.character_set`: Server's default character set.
* `mysql_arg.connect_timeout`: Server waits for a connect packet in seconds.
* `mysql_arg.interactive_timeout`: Server waits for activity on an interactive connection in seconds.
* `mysql_arg.join_buffer_size`: Size of the buffer that is used for index scans.
* `mysql_arg.log_queries_not_using_indexes`: Logs whether queries that do not use indexes.
* `mysql_arg.long_query_time`: Logs query that executes longer than in seconds.
* `mysql_arg.max_allowed_packet`: The maximum size of one packet.
* `mysql_arg.max_heap_table_size`: The maximum size to which user-created MEMORY tables are permitted to grow.
* `mysql_arg.open_files_limit`: The number of files that the operating system permits MySQL to open.
* `mysql_arg.open_nproc_limit`: The number of processes launched by systemd.
* `mysql_arg.query_cache_size`: Query cache size.
* `mysql_arg.query_cache_type`: Query cache type.
* `mysql_arg.read_rnd_buffer_size`: Size of the buffer that is used for reading rows in sorted order.
* `mysql_arg.storage_engine`: Preferred storage engine, InnoDB or MyISAM.
* `mysql_arg.table_definition_cache`: The number of table definitions that can be stored in the definition cache.
* `mysql_arg.table_open_cache`: The number of open tables for all threads.
* `mysql_arg.table_open_cache_instances`: The number of open tables cache instances. 
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

    mysql_path: '/data'
    mysql_selinux: 'false'
    mysql_user: 'mysql'
    mysql_mailto: 'somebody@example.com'
    db_sa_pass: 'password'
    mysql_backupset_arg:
      life: '604800'
      keep: '2'
      encryptkey: 'Un9FA+CgxM5Yr/MpwTh5s6NXSQE0brp8'
    mysql_port_arg:
      mysqld: '3306'
      mysql_exporter_port: '9104'
    mysql_arg:
      binlog_cache_size: '1M'
      character_set: 'utf8'
      connect_timeout: '10'
      interactive_timeout: '3600'
      join_buffer_size: '1M'
      log_queries_not_using_indexes: '1'
      long_query_time: '1'
      max_allowed_packet: '32M'
      max_heap_table_size: '32M'
      open_files_limit: '131072'
      open_nproc_limit: '131072'
      query_cache_size: '0'
      query_cache_type: '0'
      read_rnd_buffer_size: '1M'
      storage_engine: 'InnoDB'
      table_definition_cache: '4096'
      table_open_cache: '4096'
      table_open_cache_instances: '64' 
      tmp_table_size: '32M'
      wait_timeout: '3600'

## License

MIT

## Author Information
Please send your suggestions to make this role better.

## Contributors
Special thanks to the [Connext Information Technology](http://www.connext.com.cn) for their contributions to this role.
