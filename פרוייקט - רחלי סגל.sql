
--רחלי סגל שבבים ב 


use master 
--יצירת בסיס נתונים חדש 
create database project_racheli_segal
use project_racheli_segal 
--יצירת טבלת משתמשים
create table tbl_users (
--מזהה משתמש
--מפתח ראשי
userId int primary key identity(1,1), 
--שם משתמש
userName nvarchar(50) unique,
--סיסמה
userPassword nvarchar(50) not null,
--מזהה משתמש מנהל
--מפתח זר לטבלה עצמה
bosId int foreign key references tbl_users(userId)
)

select *
from tbl_users
--יצירת טבלת משימות
create table tbl_task(
--מזהה משימה
--מפתח ראשי
taskId int  primary key identity(1,1), 
--תאריך יצירת המשימה
taskDate date,
--תוכן המשימה
taskContent nvarchar(100),
--מזהה משתמש יוצר המשימה
--מפתח זר לטבלת משתמשים
creatorId int foreign key references tbl_users(userId),
--מזהה משתמש מבצע המשימה
--מפתח זר לטבלת משתמשים
performingId int foreign key references tbl_users(userId),
--סטאטוס המשימה
--מפתח זר לטבלת סטאטוס
statusId int foreign key references tbl_statuses(statusId),
--תאריך שינוי סטאטוס
statusDateChange date,
--מזהה משימת אב
--מפתח זר לטבלה עצמה
taskFather int foreign key references tbl_task(taskId)
)

select *
from tbl_task

--יצירת טבלת סטאטוסים
create table tbl_statuses(
--מזהה סטאטוס
--מפתח ראשי
statusId int primary key identity(1,1),
--שם סטאטוס
statusName nvarchar(20)
)
select *
from tbl_statuses


--יצירת טבלת ארכיון 
create table tbl_archives (
archivId int primary key identity(1,1), 
archivdate date,
archivcontact nvarchar(300)
)


--הוספת נתונים לטבלת משתמשים
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

--מעדכן את המנהל של מאיר שיהיה דוד אפילו שהוא נכנס אחריו
update tbl_users 
set bosId = (select userId
from tbl_users 
where userName = 'david')
where userName = 'meir b'

select*
from tbl_users

--הוספת נתונים לטבלת משימות
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

--הוספת נתונים לטבלת משימות
--1
--ממתין לטיפול
insert into tbl_statuses
values ('awaiting treatment')
--2
--בטיפול
insert into tbl_statuses
values ('in treatment')
--3
--בוצע
insert into tbl_statuses
values ('done')
--4
--בוטל
insert into tbl_statuses
values ('cancelled')

--חלק ב'
-- 1.
--פונקציה לזיהוי משתמש
go
create function ifExistsUser (@userName nvarchar(20), @passWord nvarchar(20))
returns int 
begin 
--אם אין שם כזה
if @userName not in(select userName
					from tbl_users)
	return 0
--אם זו לא הסיסמה שלו
if @passWord not in(select userPassword
					from tbl_users
					where @userName = userName)
	return -1 
--אם זה טוב מחזיר את המזהה שלו
return (select userId
		from tbl_users
		where @userName = userName and userPassword = @passWord)
end

--בדיקה
select dbo.ifExistsUser('מנהל', '12#6#5')

--2.
--פונקציה לשליפת שמות ומזהי עובדים כפופים
go
alter function takeUserChaild2 (@userId int ) returns table
return 
--מכין טבלה זמנית שבה יש את כל העובדים שכפופים לעובד שהתקבל
with childUserCTE 
as 
(
--מוציא את פרטי העובד
	select userId, userName
	from tbl_users
	where @userId = userId 
  union all 
  --ומצרף אליו את כל הכפופים אליו ושולח כל פעם לבדוק את הכפופים אליהם כמו ברקורסיה
	select u.userId, u.userName
	from tbl_users as u join childUserCTE on u.bosId =  childUserCTE.userId
)
--מחזיר את הטבלה המושלמת עם כל העובדים הכפופים והמנהל שלהם
select *
from childUserCTE

--בדיקה
select*
from[dbo].[takeUserChaild2](1)

--3.
--פונקציה לשליפת משימה וכל תתי המשימות שלה
create function takeTaskChaild3 (@taskId int) returns table 
return 
--מכין טבלה זמנית שבה יש את כל המשימות שהן הילדים של המשימה
with childTaskCTE
as
(
--מוציא את הפרטים של המשימה
	select taskId, taskContent
	from tbl_task
	where @taskId = taskId
   union all
--יחד עם הפרטים של המשימות שהן ילדים שלה ושולח כל פעם לטבלה מחדש כמו רקורסיה
	select t.taskId, t.taskContent
	from tbl_task as t join childTaskCTE on t.taskFather = childTaskCTE.taskId
)
--מחזיר את הטבלה המושלמת עם כל הילדיםs
select *
from childTaskCTE

--בדיקה
select*
from dbo.takeTaskChaild3(4)

--4.
--פונקציה לשליפת אבות משימה
alter function takeTaskFather4(@taskId int)returns table
return 
--מכין טבלה זמנית שבה יש את כל האבות של משימה
with fatherTaskCTE
as 
(
--מוציא את הפרטים של המשימה
	select taskId, taskContent, taskFather
	from tbl_task
	where @taskId = taskId
   union all
--יחד עם הפרטים של המשימה שהיא אבא שלה ושולח כל פעם לטבלה מחדש כמו רקורסיה
	select t.taskId, t.taskContent, t.taskFather
	from tbl_task as t join fatherTaskCTE on t.taskId = fatherTaskCTE.taskFather
)
--מחזיר את הטבלה המושלמת עם כל האבות
select taskId, taskContent
from fatherTaskCTE

--בדיקה
select *
from dbo.takeTaskFather4(5)


--5.
--פורצדורת שינוי סטטוס למשימה
create proc changeStatuts5 @taskId int, @statusId int 
as
--מאתחל משתנה בתאריך של היום כדי שלא ישתנה כל פעם
declare
@today date = GETDATE()
--משנה את הסטאטוס של המשימה שהתקבלה לסטאטוס שהתקבל
update tbl_task
set statusId = @statusId
where @taskId = taskId
--השינוי משנה  את תאריך שינוי הסטאטוס לתאריך הנוכחי של
update tbl_task 
set statusDateChange = @today
where @taskId = taskId 
go

--בדיקה
select*
from tbl_task
exec changeStatuts5 1,3
select*
from tbl_task

select* 
from tbl_task
--חזרה למצב ההתחלתי
exec changeStatuts5 1,2

update tbl_task 
set statusDateChange = '2024-03-11'
where taskId = 1

--6.
--לשאול את המורה 
--טריגר עדכון סטטוס למשימה
alter trigger taskStatusUpdate6 
on tbl_task 
after update 
as 
begin
--מגדיר משתנה במזהה של משימת האב
declare @father int 
set @father = (select taskFather
			   from inserted)
			   --בודק אם העדכון האחרון היה ל 3
	if (select statusId
		from inserted) = 3
		--בודק אם כל תתי המשימות של המשימת אב שמצאנו קודם הן 3 
		--מוריד מהבדיקה את משימת האב עצמה
		if 3 = all (select i.statusId
			from dbo.takeTaskChaild3(@father) as ttc join tbl_task as i on ttc.taskId = i.taskId
			where i.taskId not like @father)
			begin
			--שולחת לפרוצדורה שמשנה את התאריך את והסטטוס
				exec changeStatuts5 @father, 3
			end
end

--בדיקה
select*
from tbl_task

exec changeStatuts5 4,3

select*
from tbl_task

--חזרה למצב ההתחלתי
exec changeStatuts5 4,2

update tbl_task 
set statusDateChange = '2024-03-10'
where taskId = 4

--7. 
--פרוצדורת הוספה לטבלת משימות
go
alter proc AdditionToTaskTable_7 @taskDate date, @taskContent nvarchar(100),
								  @creatorId int, @performingId int, @taskFather int
as 
--אם מבצע המשימה לא נמצא בין העובדים שתחת יוצר המשימה תיזרק שגיאה
	if @performingId not in (
			select userId
			from[dbo].[takeUserChaild2](@creatorId)
			)
			--זריקת שגיאה 5001 זו השגיאה הבאה אחרי השגיאות הנתונות מתחילה
			throw 50001, 'שגיאה. לא ניתן ליצור משימה עבור שאינו כפוף ליוצר המשימה ', 1
	--מאתחל משתנה בתאריך של היום כדי שלא ישתנה כל פעם
	declare @today date =  GETDATE()
	--אם הנתונים טובים מכניס את הנתונים ויוצר משימה חדשהi
	insert into tbl_task 
	values (@taskDate, @taskContent, @creatorId, @performingId, 1, @today, @taskFather ) 
go
--בדיקה
select * 
from tbl_task
--עבד טוב
exec AdditionToTaskTable_7 '2024-03-28', 'bake a cake', 4, 3, 6
--זרק שגיאה
exec AdditionToTaskTable_7 '2024-03-28', 'bake a cake', 4, 1, 6

select * 
from tbl_task

--8.
--פרוצדורת הוספת משימות כללית
go
create proc AddingGeneralTasks_8 @bossId int, @taskContent nvarchar(100)
as
--טרנזקציה שבודקת באופן כללי שאין שגיאות
begin tran
	begin try
		begin
		--הגדרת משתנים ששומרים את התאריך (כדי שלא ישתנה כל פעם) ואת מזהה המשתמש
		declare @today date
		declare @userId int
		--מי הטבלה עליה עובר הקורסור
		declare
		cursorOfAddingGeneralTasks cursor
		for
		select userId
		from tbl_users
		where @bossId = bosId
		--מתחיל את המעבר על הטבלה
		open
		cursorOfAddingGeneralTasks
		fetch next from cursorOfAddingGeneralTasks into @userId
		while @@FETCH_STATUS = 0 --אחזור- אם הסטאטוס שחוזר עדיין שווה 0 ממשיך לעבור
			begin
				set @today = GETDATE()--שומר את התאריך של היום
				--שולח לפרוצדורה 7 שהיא מוסיפה משימות את המשתנים שהמשתמש הכניס ובסטאטוס
				--הוא מחכה לטיפול בכל מקרה כי רק עכשיו הגדירו את המשימה
				exec AdditionToTaskTable_7 @today, @taskContent, @bossId, @userId,null
				--מגדיר את השורה הבאה בטבלה
	fetch next from cursorOfAddingGeneralTasks into @userId
end
	end
	commit
end try
begin catch
	--אם יש בעיה סוגר את המעבר ואת המשתנים ויוצא
	close cursorOfAddingGeneralTasks
	deallocate cursorOfAddingGeneralTasks
	rollback;
end catch
--בכל מקרה בסוף סוגר את המשתנים
close cursorOfAddingGeneralTasks
deallocate cursorOfAddingGeneralTasks
go

select *
from tbl_task
exec AddingGeneralTasks_8 4, 'להגיש דוח שעות עבודה'
select *
from tbl_task

delete from tbl_task where taskContent = 'להגיש דוח שעות עבודה'


--9.
--טריגר למחיקת משימות ישנות 
alter trigger DeletingOldTasks_9 
on tbl_task 
after insert 
as
begin
	declare @taskContent nvarchar(100),@performingId nvarchar(25) ,@taskId int
	declare @today date = GETDATE()
	--מביא את שם המשתמש
	declare	@userId int = (select performingId
						   from inserted);
	--מכין טבלה חדשה ששומרת את כל
	with tableCTE
	as
	(
		--טבלה
		--עם עמודה שנותנת מספר לכל משימה לפי המשתמשים אם הסטאטוס הוא 3
		--המשימה הושלמה
		select *,ROW_NUMBER() over(partition by performingId order by
		statusDateChange desc)as orderByDate
		from tbl_task
		where statusId = 3
	)
	--מכניס למשתנים את מה שהם במקרה שהמספר שסוכם אותם גדול מ 3 סימן שכבר נשארו
	--3 ולכן זה מיותר וכן אם זה של המשתמש הזה
	select @taskId = taskId, @taskContent = taskContent, @performingId = performingId
	from tableCTE
	where orderByDate > 3 and performingId = @userId;
	--מוחק את המשימות שנכנסו למשתנה
	delete tbl_task
	where taskId = @taskId
	--מכניס למשתנה את התוכן של המשימה כמחרוזת
	declare @all nvarchar(300) = ' taskContent:' + @taskContent + ' performingId: ' +@performingId
	--מכניס לארכיון את התאריך והתוכן
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
--ויו המציג סיכום משימות לפי סטטוסים

alter proc DisplayingSummaryOfTasksByStatus_10
as
--דינאמי-sqlמגדיר משתנה לתוכו יכנס ה
declare @allstatuses nvarchar(max) = '';
with allstatus
as
(
	--מוציא את כל השמות של הסטאטוס
	select
	distinct statusName
	from tbl_statuses
)
--משרשר לתוך המשתנה את כולם
select @allstatuses += '[' + statusName +'], '
from allstatus
--מוריד את החלק אחרון הגרש
set @allstatuses=left(@allstatuses,len(@allstatuses)1)
print @allstatuses
exec
('select sn.*
from
('+
--מביא לו לפי מה למייןשם
--משתמש והשמות של הסטטוסים השונים
'
select statusName, userName
from tbl_statuses as s join tbl_task as t on s.statusId = t.statusId
right join tbl_users as u on t.performingId = u.userId
)as statusNames
pivot
('+
--סוכם את כמות הפעמים מכל סטטוס
'
count(statusname)'+
--לוקח מהדינאמי איזה רשומות יהיו בראש שעליהם תהיה הטבלה
'
for statusName in (' + @allstatuses + ')
)as SN')
go

--בדיקה
exec DisplayingSummaryOfTasksByStatus_10

--11.
--פונקציית שליפת משימות למשתמש
alter function RetrievingTasksToTheUser_11 (@userName nvarchar(25), @userPassword nvarchar(25))returns @tbl table
																		(taskDate date, taskContent nvarchar(100), 
																		creatorId int, statusDateChange date, 
																		taskFather int, statusMode varchar(15))
begin 
	--שולחת לפונקציה 1 לבדוק אם הסיסמה ושם המשתמש נכונים
	--אם לא, מחזיר ערכים פיקטיביים
	if (select dbo.ifExistsUser(@userName, @userPassword)) <= 0
	begin 
		insert into @tbl 
		values(GETDATE(), 'no content', 0, GETDATE(), 0,'no statusMode')
		return
	end
	--מכניס לטבלה את כל המשימות שהמבצע שלהם הוא מי שהוכנס 
	--עובר ובודק לכל אפשרות ומכניס סימן מתאים
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

--בדיקה
select *
from dbo.RetrievingTasksToTheUser_11('yossi', '123456')
