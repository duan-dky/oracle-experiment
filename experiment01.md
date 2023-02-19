# CDB和PDB的概念
- 在CDB中可以有多个PDB，包含一个root根（CDB$ROOT）容器、一个种子（PDB$SEED）容器和多个PDB容器。
- CDB$ROOT：根容器用来做所有容器的根，对每个PDB容器进行统一管理，sqlplus / as sysdba默认连接根容器，需要切换到其他的PDB容器才可以对单独的PDB容器操作。
- PDB$SEED：种子容器作为插入PDB容器的模板而存在，每个CDB容器都有一个种子容器，且不可对其中对象进行修改。
- 用户：CDB$ROOT中的普通用户可以通过权限分配来访问一个或多个指定的PDB容器，最大权限用户是sysdba。其中PDB容器也可单独创建普通用户来管理该数据库。
# CDB和PDB相关语句
Windows 命令行窗口（cmd）以DBA权限连接数据库：sqlplus / as sysdba
- 查看当前容器
```sql
select sys_context('USERENV','CON_NAME') from dual;  
show con_name
```   
*提示：Oracle启动时，默认连接CDB容器。*
- 查看PDB（CDB模式下）
```sql
show pdbs                           --查看所有pdb
select name, open_mode from v$pdbs;     --v$pdbs为PDB信息视图
select con_id, dbid, guid, name, open_mode from v$pdbs;
```
*提示：CDB启动时，PDB是自动启动到MOUNT状态，而不是OPEN，所以我们还需要手工打开。当然，也可以通过在CDB中配置触发器来自动打开PDB。*
- 切换和打开/关闭容器
```sql
alter session set container=pdborcl;           --切换到pdborcl
alter session set container=CDB$ROOT;       --切换到CDB容器

alter pluggable database pdborcl open/close;    --打开/关闭pdborcl
alter pluggable database all open/close;        --打开/关闭所有PDB
```
*提示：alter session set container仅切换当前容器，不改变容器的open_mode。
alter pluggable database xxx open/close，仅打开或关闭容器，不改变当前容器。*
- 如果要打开并切换，需要同时执行上述命令，或者在切换后执行startup：
```sql
alter session set container=pdborcl;
startup
```
*关闭当前容器可使用shutdown immediate。*  
*关闭CDB时，其所包含的PDB也会关闭，尝试自行验证。*  
- 创建或克隆前要指定文件映射的位置（需要CBD下sysdba权限）
```sql
alter system set db_create_file_dest='C:\app\oracle12c\oradata\orcl\pdbtest1';    --文件夹需存在
show parameter db_create_file_dest
```
- 创建PDB（需要CBD下sysdba权限）
```sql
create pluggable database pdbtest1 admin user pt1admin identified by admin;
alter pluggable database pdbtest1 open;    --将pdbtest1打开
```
*提示：还可通过DBCA进行向导式创建，标准版不支持创建多个PDB。*
- 克隆PDB（需要CBD下sysdba权限）
```sql
alter pluggable database pdborcl open;        --orcl必须打开才可以被克隆
create pluggable database pdbtest2 from pdborcl;
alter pluggable database pdbtest2 open;       --将pdbtest2打开
```
- 删除PDB（需要CBD下sysdba权限）
```sql
alter pluggable database pdbtest1 close;             --关闭之后才能删除
drop pluggable database pdbtest1 including datafiles;  --删除pdbtest1
```
- 创建一个触发器让PDB能够在CDB启动时打开，并验证效果。

# EM Express连接CDB和PDB
- 为容器配置EM Express监听端口
    - 打开并切换至容器（CDB或PDB）
    - 查看监听端口（CDB$Root默认为5500，0表示未配置）
    - 配置监听端口
    - 访问https://database-hostname:portnumber/em/进行验证
```sql
sqlplus / as sysdba
alter session set container= pdborcl/CDB$ROOT;       --切换容器
startup                                         --打开容器
select dbms_xdb_config.gethttpsport() from dual;       --查看监听关口
exec DBMS_XDB_CONFIG.SETHTTPSPORT(5501);  --配置监听端口
```
- 进行访问验证  
*提示：exec dbms_xdb_config.setglobalportenabled(TRUE);为CDB配置全局端口，使用全局端口的优点是不需要为每个PDB配置端口，可通过全局端口连接所有PDB。*
- 分别使用EM Express连接CDB和PDB  
*查看表空间数据文件只能在连接到PDB。*
- EM Express和SQL PLUS查看和修改Oracle参数
    - sys用户以sysdba身份登录EM Express，同时运行SQL Plus；
    - EM Express中，配置——初始化参数，有两个页签：“当前”是指当前实例使用的参数，在内存中保存；“SPfile”是指服务器参数文件中的参数。  

- SQL Plus查看参数示例
```sql
show parameters                       --查看所有内存参数
show parameter workarea_size_policy     --查看特定内存参数
show parameter spfile                  --查看spfile文件位置
create pfile from spfile;                 --spfile从创建pfile
create spfile from pfile;                 --pfile从创建spfile
```
*提示：spfile是二进制文件不可以直接编辑，生成的pfile是ASCII文本文件可直接编辑。startup启动次序spfile优先于pfile。查找文件的顺序是spfileSID.ora>spfile.ora>initSID.ora->init.ora（spfile优先于pfile）。从spfile启动数据库，在查看show parameter pfile和show parameter spfile 都能看到spfile参数文件的路径。使用pfile启动数据库，我们无论是查看show parameter pfile还是show parameter spfile 都无法看到pfile参数文件的路径。*  
- 不同参数的修改方式和生效条件不同：
    - 会话级别对某些参数进行更改：使用alter session命令，修改立即生效，并仅在当前会话有效。  
    *提示：会话是用户通过用户进程与Oracle实例建立的连接。例如，当用户启动SQLPlus 时必须提供有效的用户名和密码，之后Oracle为此用户建立一个会话。从用户开始连接到用户断开连接（或退出数据库应用程序）期间，会话一直持续。*
    - 系统级别对某些参数进行更改：使用alter system命令，它的影响不仅仅是某个会话，而是整个实例。分为立即生效immediate和延迟生效deferred，immediate表示当前会话立即生效，deferred表示下次会话生效。可使用scope指定修改范围，scope=spfile表示会在spfile中修改这个参数，在正在运行的实例的内存中不进行修改，那么只有数据库的实例重启以后，对这个参数的修改才会起作用；scope=memory表示在当前实例的内存中修改这个参数，而不在spfile中修改，这个参数的修改会影响到当前实例的运行，数据库重新启动以后失效。scope=both内存和spfile都修改。
- EM Express查看不同参数的修改方式和生效条件，查看动态和会话两列
    - 会话一列有对勾的，表示会话级别可修改。
    - 动态一列有对勾的，表示系统级别可修改，蓝色表示immediate，黄色表示deferred。
    - 两列均无对勾的，只能修改spfile，实例重启后生效。
- SQL Plus查看不同参数的修改方式和生效条件
```sql
select name,ISSES_MODIFIABLE,ISSYS_MODIFIABLE from
v$parameter where name in
(‘workarea_size_policy’,‘audit_file_dest’,‘sga_target’,‘sga_max_size’);
```
