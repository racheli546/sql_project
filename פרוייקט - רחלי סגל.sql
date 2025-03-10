
--���� ��� ����� � 


use master 
--����� ���� ������ ��� 
create database project_racheli_segal
use project_racheli_segal 
--����� ���� �������
create table tbl_users (
--���� �����
--���� ����
userId int primary key identity(1,1), 
--�� �����
userName nvarchar(50) unique,
--�����
userPassword nvarchar(50) not null,
--���� ����� ����
--���� �� ����� ����
bosId int foreign key references tbl_users(userId)
)

select *
from tbl_users
--����� ���� ������
create table tbl_task(
--���� �����
--���� ����
taskId int  primary key identity(1,1), 
--����� ����� ������
taskDate date,
--���� ������
taskContent nvarchar(100),
--���� ����� ���� ������
--���� �� ����� �������
creatorId int foreign key references tbl_users(userId),
--���� ����� ���� ������
--���� �� ����� �������
performingId int foreign key references tbl_users(userId),
--������ ������
--���� �� ����� ������
statusId int foreign key references tbl_statuses(statusId),
--����� ����� ������
statusDateChange date,
--���� ����� ��
--���� �� ����� ����
taskFather int foreign key references tbl_task(taskId)
)

select *
from tbl_task

--����� ���� ��������
create table tbl_statuses(
--���� ������
--���� ����
statusId int primary key identity(1,1),
--�� ������
statusName nvarchar(20)
)
select *
from tbl_statuses


--����� ���� ������ 
create table tbl_archives (
archivId int primary key identity(1,1), 
archivdate date,
archivcontact nvarchar(300)
)


--����� ������ ����� �������
insert into tbl_users 
values('boss', '12#6#5', null)

insert into tbl_users 
values('yossi', '123456', (select userId
from tbl_users 
where userName = 'boss'))

insert into tbl_users 
values('meir b', 'Aa22', (select userId
from tbl_users 
where userName = 'david'))

insert into tbl_users 
values('david', 'david', (select userId
from tbl_users 
where userName = 'yossi'))

--����� �� ����� �� ���� ����� ��� ����� ���� ���� �����
update tbl_users 
set bosId = (select userId
from tbl_users 
where userName = 'david')
where userName = 'meir b'

select*
from tbl_users

--����� ������ ����� ������
--1
insert into tbl_task 
values ('2024-03-01', 'call the employees who left', 1, 2, 2, '2024-03-11', null )
--2
insert into tbl_task 
values ('2024-03-02', 'call Yossi', 1, 2, 3, '2024-03-10', 1 )
--3
insert into tbl_task 
values ('2024-03-02', 'call Dani', 2, 2, 3, '2024-03-11', 1 )
--4
insert into tbl_task 
values ('2024-03-02', 'call Miriam', 1, 2, 2, '2024-03-10', 1 )
--5
insert into tbl_task 
values ('2024-03-09', 'get Miriams phone number', 2, 4, 3, '2024-03-09', 4 )
--6
insert into tbl_task 
values ('2024-03-20', 'organize a purim party', 2, 4, 2, '2024-03-26', null )
--7
insert into tbl_task 
values ('2024-03-20', 'take care of the refreshments', 4, 4, 2, '2024-03-26', 6 )
--8
insert into tbl_task 
values ('2024-03-20', 'print orders', 4, 3, 1, '2024-03-25', 6 )
--9
insert into tbl_task 
values ('2024-03-22', 'order catering', 4, 3, 1, '2024-03-26', 7 )

--����� ������ ����� ������
--1
--����� ������
insert into tbl_statuses
values ('awaiting treatment')
--2
--������
insert into tbl_statuses
values ('in treatment')
--3
--����
insert into tbl_statuses
values ('done')
--4
--����
insert into tbl_statuses
values ('cancelled')

--��� �'
-- 1.
--������� ������ �����
go
create function ifExistsUser (@userName nvarchar(20), @passWord nvarchar(20))
returns int 
begin 
--�� ��� �� ���
if @userName not in(select userName
					from tbl_users)
	return 0
--�� �� �� ������ ���
if @passWord not in(select userPassword
					from tbl_users
					where @userName = userName)
	return -1 
--�� �� ��� ����� �� ����� ���
return (select userId
		from tbl_users
		where @userName = userName and userPassword = @passWord)
end

--�����
select dbo.ifExistsUser('����', '12#6#5')

--2.
--������� ������ ���� ����� ������ ������
go
alter function takeUserChaild2 (@userId int ) returns table
return 
--���� ���� ����� ��� �� �� �� ������� ������� ����� ������
with childUserCTE 
as 
(
--����� �� ���� �����
	select userId, userName
	from tbl_users
	where @userId = userId 
  union all 
  --����� ���� �� �� ������� ���� ����� �� ��� ����� �� ������� ����� ��� ��������
	select u.userId, u.userName
	from tbl_users as u join childUserCTE on u.bosId =  childUserCTE.userId
)
--����� �� ����� ������� �� �� ������� ������� ������ ����
select *
from childUserCTE

--�����
select*
from[dbo].[takeUserChaild2](1)

--3.
--������� ������ ����� ��� ��� ������� ���
create function takeTaskChaild3 (@taskId int) returns table 
return 
--���� ���� ����� ��� �� �� �� ������� ��� ������ �� ������
with childTaskCTE
as
(
--����� �� ������ �� ������
	select taskId, taskContent
	from tbl_task
	where @taskId = taskId
   union all
--��� �� ������ �� ������� ��� ����� ��� ����� �� ��� ����� ���� ��� �������
	select t.taskId, t.taskContent
	from tbl_task as t join childTaskCTE on t.taskFather = childTaskCTE.taskId
)
--����� �� ����� ������� �� �� ������s
select *
from childTaskCTE

--�����
select*
from dbo.takeTaskChaild3(4)

--4.
--������� ������ ���� �����
alter function takeTaskFather4(@taskId int)returns table
return 
--���� ���� ����� ��� �� �� �� ����� �� �����
with fatherTaskCTE
as 
(
--����� �� ������ �� ������
	select taskId, taskContent, taskFather
	from tbl_task
	where @taskId = taskId
   union all
--��� �� ������ �� ������ ���� ��� ��� ����� �� ��� ����� ���� ��� �������
	select t.taskId, t.taskContent, t.taskFather
	from tbl_task as t join fatherTaskCTE on t.taskId = fatherTaskCTE.taskFather
)
--����� �� ����� ������� �� �� �����
select taskId, taskContent
from fatherTaskCTE

--�����
select *
from dbo.takeTaskFather4(5)


--5.
--�������� ����� ����� ������
create proc changeStatuts5 @taskId int, @statusId int 
as
--����� ����� ������ �� ���� ��� ��� ����� �� ���
declare
@today date = GETDATE()
--���� �� ������� �� ������ ������� ������� ������
update tbl_task
set statusId = @statusId
where @taskId = taskId
--������ ����  �� ����� ����� ������� ������ ������ ��
update tbl_task 
set statusDateChange = @today
where @taskId = taskId 
go

--�����
select*
from tbl_task
exec changeStatuts5 1,3
select*
from tbl_task

select* 
from tbl_task
--���� ���� �������
exec changeStatuts5 1,2

update tbl_task 
set statusDateChange = '2024-03-11'
where taskId = 1

--6.
--����� �� ����� 
--����� ����� ����� ������
alter trigger taskStatusUpdate6 
on tbl_task 
after update 
as 
begin
--����� ����� ����� �� ����� ���
declare @father int 
set @father = (select taskFather
			   from inserted)
			   --���� �� ������ ������ ��� � 3
	if (select statusId
		from inserted) = 3
		--���� �� �� ��� ������� �� ������ �� ������ ���� �� 3 
		--����� ������� �� ����� ��� ����
		if 3 = all (select i.statusId
			from dbo.takeTaskChaild3(@father) as ttc join tbl_task as i on ttc.taskId = i.taskId
			where i.taskId not like @father)
			begin
			--����� ��������� ����� �� ������ �� �������
				exec changeStatuts5 @father, 3
			end
end

--�����
select*
from tbl_task

exec changeStatuts5 4,3

select*
from tbl_task

--���� ���� �������
exec changeStatuts5 4,2

update tbl_task 
set statusDateChange = '2024-03-10'
where taskId = 4

--7. 
--�������� ����� ����� ������
go
alter proc AdditionToTaskTable_7 @taskDate date, @taskContent nvarchar(100),
								  @creatorId int, @performingId int, @taskFather int
as 
--�� ���� ������ �� ���� ��� ������� ���� ���� ������ ����� �����
	if @performingId not in (
			select userId
			from[dbo].[takeUserChaild2](@creatorId)
			)
			--����� ����� 5001 �� ������ ���� ���� ������� ������� ������
			throw 50001, '�����. �� ���� ����� ����� ���� ����� ���� ����� ������ ', 1
	--����� ����� ������ �� ���� ��� ��� ����� �� ���
	declare @today date =  GETDATE()
	--�� ������� ����� ����� �� ������� ����� ����� ����i
	insert into tbl_task 
	values (@taskDate, @taskContent, @creatorId, @performingId, 1, @today, @taskFather ) 
go
--�����
select * 
from tbl_task
--��� ���
exec AdditionToTaskTable_7 '2024-03-28', 'bake a cake', 4, 3, 6
--��� �����
exec AdditionToTaskTable_7 '2024-03-28', 'bake a cake', 4, 1, 6

select * 
from tbl_task

--8.
--�������� ����� ������ �����
go
create proc AddingGeneralTasks_8 @bossId int, @taskContent nvarchar(100)
as
--�������� ������ ����� ���� ���� ������
begin tran
	begin try
		begin
		--����� ������ ������� �� ������ (��� ��� ����� �� ���) ��� ���� ������
		declare @today date
		declare @userId int
		--�� ����� ���� ���� �������
		declare
		cursorOfAddingGeneralTasks cursor
		for
		select userId
		from tbl_users
		where @bossId = bosId
		--����� �� ����� �� �����
		open
		cursorOfAddingGeneralTasks
		fetch next from cursorOfAddingGeneralTasks into @userId
		while @@FETCH_STATUS = 0 --�����- �� ������� ����� ����� ���� 0 ����� �����
			begin
				set @today = GETDATE()--���� �� ������ �� ����
				--���� ��������� 7 ���� ������ ������ �� ������� ������� ����� ��������
				--��� ���� ������ ��� ���� �� �� ����� ������ �� ������
				exec AdditionToTaskTable_7 @today, @taskContent, @bossId, @userId,null
				--����� �� ����� ���� �����
	fetch next from cursorOfAddingGeneralTasks into @userId
end
	end
	commit
end try
begin catch
	--�� �� ���� ���� �� ����� ��� ������� �����
	close cursorOfAddingGeneralTasks
	deallocate cursorOfAddingGeneralTasks
	rollback;
end catch
--��� ���� ���� ���� �� �������
close cursorOfAddingGeneralTasks
deallocate cursorOfAddingGeneralTasks
go

select *
from tbl_task
exec AddingGeneralTasks_8 4, '����� ��� ���� �����'
select *
from tbl_task

delete from tbl_task where taskContent = '����� ��� ���� �����'


--9.
--����� ������ ������ ����� 
alter trigger DeletingOldTasks_9 
on tbl_task 
after insert 
as
begin
	declare @taskContent nvarchar(100),@performingId nvarchar(25) ,@taskId int
	declare @today date = GETDATE()
	--���� �� �� ������
	declare	@userId int = (select performingId
						   from inserted);
	--���� ���� ���� ������ �� ��
	with tableCTE
	as
	(
		--����
		--�� ����� ������ ���� ��� ����� ��� �������� �� ������� ��� 3
		--������ ������
		select *,ROW_NUMBER() over(partition by performingId order by
		statusDateChange desc)as orderByDate
		from tbl_task
		where statusId = 3
	)
	--����� ������� �� �� ��� ����� ������ ����� ���� ���� � 3 ���� ���� �����
	--3 ���� �� ����� ��� �� �� �� ������ ���
	select @taskId = taskId, @taskContent = taskContent, @performingId = performingId
	from tableCTE
	where orderByDate > 3 and performingId = @userId;
	--���� �� ������� ������ ������
	delete tbl_task
	where taskId = @taskId
	--����� ������ �� ����� �� ������ �������
	declare @all nvarchar(300) = ' taskContent:' + @taskContent + ' performingId: ' +@performingId
	--����� ������� �� ������ ������
	insert
	into tbl_archives
	values(@today,@all)
end
	select * 
	from tbl_task 
	where performingId = 2
    exec AdditionToTaskTable_7 '2024-04-03', 'Tidy up the office', 2, 2, null
	select * 
	from tbl_task
	where performingId = 2

	exec changeStatuts5 19736, 3

--10.
--��� ����� ����� ������ ��� �������

alter proc DisplayingSummaryOfTasksByStatus_10
as
--������-sql����� ����� ����� ���� �
declare @allstatuses nvarchar(max) = '';
with allstatus
as
(
	--����� �� �� ����� �� �������
	select
	distinct statusName
	from tbl_statuses
)
--����� ���� ������ �� ����
select @allstatuses += '[' + statusName +'], '
from allstatus
--����� �� ���� ����� ����
set @allstatuses=left(@allstatuses,len(@allstatuses)1)
print @allstatuses
exec
('select sn.*
from
('+
--���� �� ��� �� �������
--����� ������ �� �������� ������
'
select statusName, userName
from tbl_statuses as s join tbl_task as t on s.statusId = t.statusId
right join tbl_users as u on t.performingId = u.userId
)as statusNames
pivot
('+
--���� �� ���� ������ ��� �����
'
count(statusname)'+
--���� �������� ���� ������ ���� ���� ������ ���� �����
'
for statusName in (' + @allstatuses + ')
)as SN')
go

--�����
exec DisplayingSummaryOfTasksByStatus_10

--11.
--�������� ����� ������ ������
alter function RetrievingTasksToTheUser_11 (@userName nvarchar(25), @userPassword nvarchar(25))returns @tbl table
																		(taskDate date, taskContent nvarchar(100), 
																		creatorId int, statusDateChange date, 
																		taskFather int, statusMode varchar(15))
begin 
	--����� �������� 1 ����� �� ������ ��� ������ ������
	--�� ��, ����� ����� ���������
	if (select dbo.ifExistsUser(@userName, @userPassword)) <= 0
	begin 
		insert into @tbl 
		values(GETDATE(), 'no content', 0, GETDATE(), 0,'no statusMode')
		return
	end
	--����� ����� �� �� ������� ������ ���� ��� �� ������ 
	--���� ����� ��� ������ ������ ���� �����
	insert into @tbl 
	select t.taskDate, t.taskContent, t.creatorId, t.statusDateChange, t.taskFather, 
		case when statusId = 3 then 'v'
			 when statusId = 4 then 'x'
			 when (statusId = 1 or statusId = 2) and dateDiff(mm, taskDate, getdate()) > 1 then '!'
			 when (statusId = 1 or statusId = 2) and dateDiff(mm, taskDate, getdate()) > 3 then '!!!'
			 else '?'
			  end statusMode
				from tbl_users as u join tbl_task as t on u.userId = t.performingId
				where @userName = u.userName and @userPassword = u.userPassword
	
	return
end

--�����
select *
from dbo.RetrievingTasksToTheUser_11('yossi', '123456')
