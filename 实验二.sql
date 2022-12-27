create table jobs_temp as select * from jobs where 1=2;--创建和jobs表结构一样的jobs_temp表

insert into jobs_temp select * from jobs where jobs.max_salary>10000; --将最大工资大于10000的数据插入到jobs_temp中

SELECT * FROM jobs_temp;--查询jobs_temp中的数据

drop table jobs_temp;--删除jobs_temp表

select deptno,round(avg(sal),2) 平均工资 from emp group by deptno having avg(sal)>2000;--求emp表中平均工资大于2000的部门信息

grant select on emp to hr; --授权查询 

select * from scott.emp --切换到hr查表

revoke select on emp from hr;-- 收回查询select表的权限

-- 向emp表中插入数据
DECLARE
  v_empno EMP.EMPNO%TYPE := 1000;
  v_ename EMP.ENAME%TYPE := 'STEVE';
  v_job EMP.JOB%TYPE := 'CLERK';
  v_mgr EMP.MGR%TYPE := '7782';
  v_hiredate EMP.HIREDATE%TYPE := to_date('2020-1-1', 'YYYY-MM-DD');
  v_sal EMP.SAL%TYPE := 8000;
  v_comm EMP.COMM%Type;
  v_deptno EMP.DEPTNO%TYPE := 10;
BEGIN
  INSERT INTO EMP(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) 
  VALUES (v_empno, v_ename, v_job, v_mgr, v_hiredate, v_sal, v_comm, v_deptno);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      dbms_output.put_line('插入失败！该编号的员工已经存在！');
END;

--声明型一个记录类型 dept_type， 使用该类型的变量var_dept 存储 dept 录表中的一条记录（DEPTNO=20）
--并按下图所示输出，声明一个%ROWTYPE 类型的变量 rowVar_dept，使用该储变量存储 dept表中的一条记录（DEPTNO=40）
declare
type dept_type is record
(
  var_no   NUMBER,
  var_name VARCHAR2(14),
  var_loc VARCHAR2(13)
);
var_dept dept_type;
rowVar_dept dept%ROWTYPE;
begin
  select DEPTNO,DNAME,LOC into var_dept from dept where DEPTNO=20;
  select * into rowVar_dept from dept where DEPTNO=40;
  dbms_output.put_line('部门编号'||var_dept.var_no||'的部门名称是'||var_dept.var_name||'、工作地点在'||var_dept.var_loc);
  dbms_output.put_line('部门编号'||rowVar_dept.DEPTNO||'的部门名称是'||rowVar_dept.DNAME||'、工作地点在'||rowVar_dept.LOC);
end;
