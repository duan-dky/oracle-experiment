create table jobs_temp as select * from jobs where 1=2;--������jobs��ṹһ����jobs_temp��

insert into jobs_temp select * from jobs where jobs.max_salary>10000; --������ʴ���10000�����ݲ��뵽jobs_temp��

SELECT * FROM jobs_temp;--��ѯjobs_temp�е�����

drop table jobs_temp;--ɾ��jobs_temp��

select deptno,round(avg(sal),2) ƽ������ from emp group by deptno having avg(sal)>2000;--��emp����ƽ�����ʴ���2000�Ĳ�����Ϣ

grant select on emp to hr; --��Ȩ��ѯ 

select * from scott.emp --�л���hr���

revoke select on emp from hr;-- �ջز�ѯselect���Ȩ��

-- ��emp���в�������
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
      dbms_output.put_line('����ʧ�ܣ��ñ�ŵ�Ա���Ѿ����ڣ�');
END;

--������һ����¼���� dept_type�� ʹ�ø����͵ı���var_dept �洢 dept ¼���е�һ����¼��DEPTNO=20��
--������ͼ��ʾ���������һ��%ROWTYPE ���͵ı��� rowVar_dept��ʹ�øô������洢 dept���е�һ����¼��DEPTNO=40��
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
  dbms_output.put_line('���ű��'||var_dept.var_no||'�Ĳ���������'||var_dept.var_name||'�������ص���'||var_dept.var_loc);
  dbms_output.put_line('���ű��'||rowVar_dept.DEPTNO||'�Ĳ���������'||rowVar_dept.DNAME||'�������ص���'||rowVar_dept.LOC);
end;
