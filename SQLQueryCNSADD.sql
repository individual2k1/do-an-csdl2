--Created 06/17/2021
--Create DB
Create Database QLRPCNS
Go
Use QLRPCNS
Go

------------------------------Create Tables-------------------------------
--Table Admin -----------------------------Quản lý tài khoản ADMIN
Create table [Admin]
(
	AdmId int identity(1,1) primary key,
	Username varchar(100) not null,
	Pass varchar(100) not null,
	FullName nvarchar(100),
	Bod datetime,
	[Address] nvarchar(200),
	Phone nvarchar(20),
	Email nvarchar(100) not null
)
Go

--Table Customer -------------------------Quản lý tài khoản khách hàng
Create table Customer 
(
	CusId int identity(1,1) primary key,
	Username nvarchar(100) unique not null,
	[Password] nvarchar(100) not null,
	CreditCard int not null,
	FullName nvarchar(100) default '',
	Bod datetime,
	[Address] nvarchar(200) default '',
	Phone nvarchar(20),
	Email nvarchar(100) not null,
	Avata nvarchar(100),
	[Status] int default 1
)
Go

--Table Cinema ------------------------------- Các rạp chiếu chi nhánh của Cinestar
Create table Cinema
(
	CinId int identity(1,1) primary key,
	NameCi nvarchar(100) not null,
	[Address] nvarchar(200),
	Seats int default 0,
	Phone nvarchar(20),
	[Image] nvarchar(100),
	[Status] int
)
Go

--Table Country ------------------------Quốc gia sản xuất phim đó
Create table Country
(
	CouId int identity(1,1) primary key,
	NameCo nvarchar(100) not null,
	[Status] int
)
Go


--Table TypeFilm ---------------------Thể loại phim
Create table TypeFilm
(
	TypId int identity(1,1) primary key,
	NameT nvarchar(100) not null,
	[Status] int
)
Go


--Table Film -----------------Danh sách phim, all
Create table Film
(
	FilId int identity(1,1) primary key,
	TypId int CONSTRAINT FK_Film_TypId FOREIGN KEY(TypId) REFERENCES TypeFilm(TypId),
	CouId int CONSTRAINT FK_Film_CouId FOREIGN KEY(CouId) REFERENCES Country(CouId),
	NameF nvarchar(100) not null,
	Director nvarchar(100),
	Actor nvarchar(100),
	Duration int,
	[Description] ntext,
	[Detail] ntext,
	Picture varchar(100),
	PictureBig varchar(100),
	[Status] int
)
Go

--Table ShowTimes ----------------------Lịch chiếu phim
Create table ShowTimes
(
	ShoId int identity(1,1) primary key,
	FilId int CONSTRAINT FK_ShowTimes_FilId FOREIGN KEY(FilId) REFERENCES Film(FilId),
	CinId int CONSTRAINT FK_ShowTimes_CinId FOREIGN KEY(CinId) REFERENCES Cinema(CinId),
	--ShowTime datetime not null check(Datediff(D, ShowTime, GETDATE()) > 0),
	ShowTime datetime not null,
	[Time] time,
	[View] int default 0,
	Price float check(Price > 0) not null,
	[Status] int
)
Go



--Create Booking ----Bảng đặt vé
Create table Booking
(
	BooId int identity(1,1) primary key,
	CusId int CONSTRAINT FK_Booking_CusId FOREIGN KEY(CusId) REFERENCES Customer(CusId),
	ShoId int CONSTRAINT FK_Booking_ShoId FOREIGN KEY(ShoId) REFERENCES ShowTimes(ShoId),
	
	Quantity int check (Quantity > 0),
	Bilmoney float,
	DateBooking datetime default getdate(),
	[Status] varchar(100) default 'No'
)
Go

--Table Feedback ----------Cảm nhận của khách hàng hay gọi là bình luận
Create table Feedback -- Cảm nhận
(
	FeeId int identity(1,1) primary key,
	FilId int constraint FK_Feedback_FilId foreign key(FilId) references Film(FilId),
	Avata nvarchar(100),
	FullName nvarchar(100) not null,
	Comment nvarchar(500) not null,
	Created datetime default getdate(),-- ngày tạo cảm nhận
	[Status] int default 1
)
Go
--Table Seat
Create table Seat
(
	SeatId int identity(1,1) primary key,
	TySeat nvarchar (20),
	Seats varchar (5) not null,
	ShoId int CONSTRAINT FK_Seat_Showtime FOREIGN KEY(ShoId) REFERENCES ShowTimes(ShoId),
	[Status] nvarchar(30) 


)
ALTER TABLE Booking
  ADD SeatId int CONSTRAINT FK_Booking_SeatId FOREIGN KEY(SeatId) REFERENCES Seat(SeatId);
--------------------------------------------Create Procedure-------------------------------------------------------------------------
--Table Admin

if exists (select * from dbo.sysobjects where name = 'sp_Admin_GetByAll') -- Thủ tục lưu lại Toàn bộ bảng => Hiện thị toàn bộ bảng Thông tin ADM
	drop procedure [dbo].[sp_Admin_GetByAll]
Go 
CREATE PROCEDURE dbo.sp_Admin_GetByAll
AS
	SELECT * FROM [Admin]
Go

if exists (select * from dbo.sysobjects where name = 'sp_Admin_GetById')--Produce cho Id => Hiện thị Thông tin ADM bằng cách tìm ID ADM
	drop procedure [dbo].[sp_Admin_GetById]
Go 
CREATE PROCEDURE dbo.sp_Admin_GetById    
@AdmId	int
AS
SELECT * FROM [Admin] WHERE  AdmId= @AdmId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Admin_Update') --Update thông tin ADMIN
	drop procedure [dbo].[sp_Admin_Update]
Go 
CREATE PROCEDURE dbo.sp_Admin_Update
@AdmId	int,
@FullName	nvarchar(100),
@Bod	datetime,
@Address	nvarchar(200),
@Phone	nvarchar(20),
@Email	nvarchar(100)
AS
UPDATE [Admin] SET [FullName] = @FullName,[Bod] = @Bod,[Address] = @Address,[Phone] = @Phone,[Email] = @Email
WHERE  AdmId= @AdmId
Go

if exists (select * from sysobjects where name = 'sp_Admin_CheckLogin') --Check Đăng nhập
	drop procedure [sp_Admin_CheckLogin]
Go
CREATE PROCEDURE sp_Admin_CheckLogin
@Username varchar(50),
@Pass varchar(50)
AS
SELECT * FROM [Admin]
WHERE [Username]= @Username And [Pass]= @Pass
Go

if exists (select * from sysobjects where name = 'sp_Admin_ChangePass') -- Thay đổi mật khẩu
	drop procedure [sp_Admin_ChangePass]
Go 
CREATE PROCEDURE sp_Admin_ChangePass
@Username	varchar(50),
@Pass	varchar(50)
AS
UPDATE [Admin] SET [Pass]= @Pass
WHERE  Username= @Username
Go
-------------------------------------------------------------------------------------------------------------------------------
--Table Customer
if exists (select * from sysobjects where name = 'sp_Customer_CheckLogin') ----- Check Tài khoản đăng nhập của khách hàng
	drop procedure [sp_Customer_CheckLogin]
Go
CREATE PROCEDURE sp_Customer_CheckLogin
@Username nvarchar(50),
@Pass nvarchar(50)
AS
SELECT * FROM [Customer]
WHERE [Username]= @Username And [Password]= @Pass
Go

if exists (select * from sysobjects where name = 'sp_Customer_ChangePass') ---- Thay đổi pass khi khách hàng muốn thay đổi pass
	drop procedure [sp_Customer_ChangePass]
Go 
CREATE PROCEDURE sp_Customer_ChangePass
@Username	nvarchar(50),
@Pass	nvarchar(50)
AS
UPDATE [Customer] SET [Password]= @Pass
WHERE  Username= @Username
Go

if exists (select * from dbo.sysobjects where name = 'sp_Customer_GetByAll') ---Hiện thị toàn bộ thông tin khách hàng giúp admin kiểm soát
	drop procedure [dbo].[sp_Customer_GetByAll]
Go 
CREATE PROCEDURE dbo.sp_Customer_GetByAll
AS
	SELECT * FROM Customer
Go

if exists (select * from dbo.sysobjects where name = 'sp_Customer_GetById') ----Hiện Thông tin khách hàng theo id khách
	drop procedure [dbo].[sp_Customer_GetById]
Go 
CREATE PROCEDURE dbo.sp_Customer_GetById
@CusId	int
AS
SELECT * FROM [Customer] WHERE  CusId= @CusId
Go
 
if exists (select * from dbo.sysobjects where name = 'sp_Customer_GetByTop') ---Khách hàng thường xuyên của rạp phim, tính khách hàng thường xuyên xem phim
    drop procedure [dbo].[sp_Customer_GetByTop]                  
Go 
CREATE PROCEDURE dbo.sp_Customer_GetByTop
@Top nvarchar(10),
@Where nvarchar(500), 
@Order nvarchar(500)
AS
	Declare @SQL as nvarchar(500) 
Select @SQL = 'SELECT top (' + @Top + ') * FROM [Customer]'
if len(@Top) = 0
BEGIN
Select @SQL = 'SELECT * FROM [Customer]'
END
if len(@Where) >0
BEGIN
Select @SQL = @SQL + ' Where ' + @Where
END
if len(@Order) >0
BEGIN
Select @SQL = @SQL + ' Order by ' + @Order
END
EXEC (@SQL)
Go

if exists (select * from dbo.sysobjects where name = 'sp_Customer_Insert') -- Thêm tài khoản vào csdl
	drop procedure [dbo].[sp_Customer_Insert]
Go 
CREATE PROCEDURE dbo.sp_Customer_Insert
@Username	nvarchar(100),
@Password	nvarchar(100),
@CreditCard	int,
@FullName	nvarchar(100),
@Bod	datetime,
@Address	nvarchar(200),
@Phone	nvarchar(20),
@Email	nvarchar(100),
@Avata nvarchar(100),
@Status	int
AS
	If(@Username In (Select [Username] From [Customer])) ----------- Bẩy lỗi nếu thêm vào user trùng với user trong csdl
	Begin
		Raiserror ('This account is already exists', 16, 1)
		Return
	End
	If(@Email In (Select [Email] From [Customer])) ----------- Bẩy lỗi nếu thêm Email trùng với email trong csdl
	Begin
		Raiserror ('This email is already exists', 16, 1)
		Return
	End
INSERT INTO [Customer]([Username],[Password],[CreditCard],[FullName],[Bod],[Address],[Phone],[Email],Avata,[Status]) VALUES(@Username ,@Password ,@CreditCard ,@FullName ,@Bod ,@Address ,@Phone ,@Email ,@Avata,@Status )
Go

if exists (select * from dbo.sysobjects where name = 'sp_Customer_Update') ---Cập nhật thông tin khách hàng
	drop procedure [dbo].[sp_Customer_Update]
Go 
CREATE PROCEDURE dbo.sp_Customer_Update
@CusId	int,
@Username	nvarchar(100),
@CreditCard	int,
@FullName	nvarchar(100),
@Bod	datetime,
@Address	nvarchar(200),
@Phone	nvarchar(20),
@Email	nvarchar(100),
@Avata nvarchar(100),
@Status	int
AS
	If(@Email In (Select [Email] From [Customer] Where [CusId]<>@CusId)) --Bẩy lỗi nếu update vs tài khoản đã tồn tại
	Begin
		Raiserror ('Update error, this email is already exists', 16, 1)
		Return
	End
UPDATE [Customer] SET [Username] = @Username,[CreditCard] = @CreditCard,[FullName] = @FullName,[Bod] = @Bod,[Address] = @Address,[Phone] = @Phone,[Email] = @Email,Avata=@Avata,[Status] = @Status
WHERE  CusId= @CusId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Customer_Delete') --- Chức năng xóa tài khoản
	drop procedure [dbo].[sp_Customer_Delete]
Go 
CREATE PROCEDURE dbo.sp_Customer_Delete 
@CusId	int
AS
	If(@CusId In (Select CusId From [Booking]))
	Begin
		Raiserror ('Can not delete this employee', 16, 1) -------- bẩy lỗi khách hàng ko thể xóa vé đã đặt
		Return
	End
Delete FROM [Customer] WHERE  CusId= @CusId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Customer_Update_Status')
	drop procedure [dbo].[sp_Customer_Update_Status]
Go 
CREATE PROCEDURE dbo.sp_Customer_Update_Status --- Chức năng update trạng thái khách hàng, on hay off
(
	@CusId int,
	@Status int
)
AS
Update [Customer] SET [Status]=@Status where CusId=@CusId
Go
-------------------------------------------------------------------------------------------------------------
--Table Cinema
if exists (select * from dbo.sysobjects where name = 'sp_Cinema_GetByAll') ----Hiện thị bảng rạp phim
	drop procedure [dbo].[sp_Cinema_GetByAll]
Go 
CREATE PROCEDURE dbo.sp_Cinema_GetByAll
AS
	SELECT * FROM Cinema
Go

if exists (select * from dbo.sysobjects where name = 'sp_Cinema_GetById')
	drop procedure [dbo].[sp_Cinema_GetById]
Go 
CREATE PROCEDURE dbo.sp_Cinema_GetById ------------- Hiện thị rạp phim theo cách tìm ID rạp phim
@CinId	int
AS
SELECT * FROM [Cinema] WHERE  CinId= @CinId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Cinema_GetByTop') ---Top rạp được đặt vé nhiều 
	drop procedure [dbo].[sp_Cinema_GetByTop]
Go 
CREATE PROCEDURE dbo.sp_Cinema_GetByTop
@Top nvarchar(10),
@Where nvarchar(500), 
@Order nvarchar(500)
AS
	Declare @SQL as nvarchar(500) 
Select @SQL = 'SELECT top (' + @Top + ') * FROM [Cinema]'
if len(@Top) = 0
BEGIN
Select @SQL = 'SELECT * FROM [Cinema]'
END
if len(@Where) >0
BEGIN
Select @SQL = @SQL + ' Where ' + @Where
END
if len(@Order) >0
BEGIN
Select @SQL = @SQL + ' Order by ' + @Order
END
EXEC (@SQL)
Go

if exists (select * from dbo.sysobjects where name = 'sp_Cinema_Insert') ---Thêm rạp phim
	drop procedure [dbo].[sp_Cinema_Insert]
Go 
CREATE PROCEDURE dbo.sp_Cinema_Insert
@NameCi	nvarchar(100),
@Address	nvarchar(200),
@Seats	int,
@Phone	nvarchar(20),
@Image nvarchar(100),
@Status	int
AS
	If(@NameCi In (Select [NameCi] From [Cinema]))  --- bẩy lỗi nếu thêm rạp phim trùng
	Begin
		Raiserror ('This cinema is already exists', 16, 1)
		Return
	End
INSERT INTO [Cinema]([NameCi],[Address],[Seats],[Phone],[Image],[Status]) VALUES(@NameCi ,@Address ,@Seats ,@Phone,@Image ,@Status )
Go

if exists (select * from dbo.sysobjects where name = 'sp_Cinema_Update') ----Cập nhật rạp phim
	drop procedure [dbo].[sp_Cinema_Update]
Go 
CREATE PROCEDURE dbo.sp_Cinema_Update
@CinId	int,
@NameCi	nvarchar(100),
@Address	nvarchar(200),
@Seats	int,
@Phone	nvarchar(20),
@Image nvarchar(100),
@Status	int
AS
	If(@NameCi In (Select [NameCi] From [Cinema] Where [CinId]<>@CinId)) ---nếu tên rạp nằm trong bảng csdl rạp phìm thì =>
	Begin
		Raiserror ('Update error, this cinema is already exists', 16, 1) ---bẩy lỗi nếu cập nhật trùng
		Return
	End
UPDATE [Cinema] SET [NameCi] = @NameCi,[Address] = @Address,[Seats] = @Seats,[Phone] = @Phone,[Image]=@Image,[Status] = @Status
WHERE  CinId= @CinId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Cinema_Delete') --- xóa dữ liệu rạp
	drop procedure [dbo].[sp_Cinema_Delete]
Go 
CREATE PROCEDURE dbo.sp_Cinema_Delete
@CinId	int
AS
	If(@CinId In (Select CinId From [ShowTimes]))---- nếu rạp phim có trong lịch chiếu phim thì ko thể xóa => lỗi
	Begin
		Raiserror ('Can not delete this cinema', 16, 1)
		Return
	End
Delete FROM [Cinema] WHERE  CinId= @CinId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Cinema_Update_Status') ---Cập nhật trạng thái rạp
	drop procedure [dbo].[sp_Cinema_Update_Status]
Go 
CREATE PROCEDURE dbo.sp_Cinema_Update_Status
(
	@CinId int,
	@Status int
)
AS
Update [Cinema] SET [Status]=@Status where CinId=@CinId
Go
----------------------------------------------------------------------------------------------------------------------
--Table Country
if exists (select * from dbo.sysobjects where name = 'sp_Country_GetByAll')----- Hiện thị toàn bộ bảng Quốc gia
	drop procedure [dbo].[sp_Country_GetByAll]
Go 
CREATE PROCEDURE dbo.sp_Country_GetByAll
AS
	SELECT * FROM Country
Go

if exists (select * from dbo.sysobjects where name = 'sp_Country_GetById')----------- Hiện thị thông tin quốc gia theo, tìm theo id
	drop procedure [dbo].[sp_Country_GetById]
Go 
CREATE PROCEDURE dbo.sp_Country_GetById
@CouId	int
AS
SELECT * FROM [Country] WHERE  CouId= @CouId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Country_GetByTop') ---------- Lưu, tìm top phim quốc gia nào được xem nhiều nhất
	drop procedure [dbo].[sp_Country_GetByTop]
Go 
CREATE PROCEDURE dbo.sp_Country_GetByTop
@Top nvarchar(10),
@Where nvarchar(500), 
@Order nvarchar(500)
AS
	Declare @SQL as nvarchar(500) 
Select @SQL = 'SELECT top (' + @Top + ') * FROM [Country]'
if len(@Top) = 0
BEGIN
Select @SQL = 'SELECT * FROM [Country]'
END
if len(@Where) >0
BEGIN
Select @SQL = @SQL + ' Where ' + @Where
END
if len(@Order) >0
BEGIN
Select @SQL = @SQL + ' Order by ' + @Order
END
EXEC (@SQL)
Go

if exists (select * from dbo.sysobjects where name = 'sp_Country_Insert') ---------- Thêm quốc gia
	drop procedure [dbo].[sp_Country_Insert]
Go 
CREATE PROCEDURE dbo.sp_Country_Insert
@NameCo	nvarchar(100),
@Status	int
AS
	If(@NameCo In (Select [NameCo] From [Country]))
	Begin
		Raiserror ('This Country is already exists', 16, 1)
		Return
	End
INSERT INTO [Country]([NameCo],[Status]) VALUES(@NameCo ,@Status )
Go

if exists (select * from dbo.sysobjects where name = 'sp_Country_Update') --------------- Cập nhật quốc gia
	drop procedure [dbo].[sp_Country_Update]
Go 
CREATE PROCEDURE dbo.sp_Country_Update
@CouId	int,
@NameCo	nvarchar(100),
@Status	int
AS
	If(@NameCo In (Select [NameCo] From [Country] Where [CouId]<>@CouId))
	Begin
		Raiserror ('Update error, this Country is already exists', 16, 1)
		Return
	End
UPDATE [Country] SET [NameCo] = @NameCo,[Status] = @Status
WHERE  CouId= @CouId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Country_Delete') -----xóa dữ liệu csdl
	drop procedure [dbo].[sp_Country_Delete]
Go 
CREATE PROCEDURE dbo.sp_Country_Delete
@CouId	int
AS
	If(@CouId In (Select CouId From [Film])) ----------------nếu id quốc gia nằm trong bảng film thì ko được xóa < vi phạm dữ liệu>
	Begin
		Raiserror ('Can not delete this Country', 16, 1) -----<bẩy>
		Return
	End
Delete FROM [Country] WHERE  CouId= @CouId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Country_Update_Status') ---------------Uptade trạng thái on off
	drop procedure [dbo].[sp_Country_Update_Status]
Go 
CREATE PROCEDURE dbo.sp_Country_Update_Status
(
	@CouId int,
	@Status int
)
AS
Update [Country] SET [Status]=@Status where CouId=@CouId
Go
-----------------------------------------------------------------------------------------------------------------
--Table TypeFilm
if exists (select * from dbo.sysobjects where name = 'sp_TypeFilm_GetByAll') -----------hiện toàn bộ bảng film
	drop procedure [dbo].[sp_TypeFilm_GetByAll]
Go 
CREATE PROCEDURE dbo.sp_TypeFilm_GetByAll
AS
	SELECT * FROM TypeFilm
Go

if exists (select * from dbo.sysobjects where name = 'sp_TypeFilm_GetById')---------Hiện thị thể loại, tìm bằng id
	drop procedure [dbo].[sp_TypeFilm_GetById]
Go 
CREATE PROCEDURE dbo.sp_TypeFilm_GetById
@TypId	int
AS
SELECT * FROM [TypeFilm] WHERE  TypId= @TypId
Go

if exists (select * from dbo.sysobjects where name = 'sp_TypeFilm_GetByTop')--------xếp hạng thể loại
	drop procedure [dbo].[sp_TypeFilm_GetByTop]
Go 
CREATE PROCEDURE dbo.sp_TypeFilm_GetByTop
@Top nvarchar(10),
@Where nvarchar(500), 
@Order nvarchar(500)
AS
	Declare @SQL as nvarchar(500) 
Select @SQL = 'SELECT top (' + @Top + ') * FROM [TypeFilm]'
if len(@Top) = 0
BEGIN
Select @SQL = 'SELECT * FROM [TypeFilm]'
END
if len(@Where) >0
BEGIN
Select @SQL = @SQL + ' Where ' + @Where
END
if len(@Order) >0
BEGIN
Select @SQL = @SQL + ' Order by ' + @Order
END
EXEC (@SQL)
Go

if exists (select * from dbo.sysobjects where name = 'sp_TypeFilm_Insert') -----------Thêm
	drop procedure [dbo].[sp_TypeFilm_Insert]
Go 
CREATE PROCEDURE dbo.sp_TypeFilm_Insert
@NameT	nvarchar(100),
@Status	int
AS
	If(@NameT In (Select [NameT] From [TypeFilm]))
	Begin
		Raiserror ('This Type Film is already exists', 16, 1)
		Return
	End
INSERT INTO [TypeFilm]([NameT],[Status]) VALUES(@NameT ,@Status )
Go

if exists (select * from dbo.sysobjects where name = 'sp_TypeFilm_Update') -----------update
	drop procedure [dbo].[sp_TypeFilm_Update]
Go 
CREATE PROCEDURE dbo.sp_TypeFilm_Update
@TypId	int,
@NameT	nvarchar(100),
@Status	int
AS
	If(@NameT In (Select [NameT] From [TypeFilm] Where TypId<>@TypId)) ------------nếu tên thể loại update = tên thể loại trong bảng thể loại thì lỗi
	Begin
		Raiserror ('Update error, this Type Film is already exists', 16, 1)----<bẩy>
		Return
	End
UPDATE [TypeFilm] SET [NameT] = @NameT,[Status] = @Status
WHERE  TypId= @TypId
Go

if exists (select * from dbo.sysobjects where name = 'sp_TypeFilm_Delete')---------xóa dữ liệu
	drop procedure [dbo].[sp_TypeFilm_Delete]
Go 
CREATE PROCEDURE dbo.sp_TypeFilm_Delete 
@TypId	int
AS
	If(@TypId In (Select TypId From [Film])) --------nếu id thể loại phim nằm trong bảng
	Begin
		Raiserror ('Can not delete this Type Film', 16, 1) --<bẩy>
		Return
	End
Delete FROM [TypeFilm] WHERE  TypId= @TypId
Go

if exists (select * from dbo.sysobjects where name = 'sp_TypeFilm_Update_Status') -----Trạng thái
	drop procedure [dbo].[sp_TypeFilm_Update_Status]
Go 
CREATE PROCEDURE dbo.sp_TypeFilm_Update_Status
(
	@TypId int,
	@Status int
)
AS
Update [TypeFilm] SET [Status]=@Status where TypId=@TypId
Go

------------------------------------------------------------------------------------------------------------------
--Table Film
if exists (select * from dbo.sysobjects where name = 'sp_Film_GetByAll') ------- Kt sự tồn tại của dữ liệu
	drop procedure [dbo].[sp_Film_GetByAll]
Go 
CREATE PROCEDURE dbo.sp_Film_GetByAll--------------Hiện thị toàn bộ bảng phim kết hợp cả bảng quốc gia, bảng thể loại
AS
SELECT	*,*,* FROM Film inner join Country on Film.CouId = Country.CouId
					   inner join TypeFilm on Film.TypId = TypeFilm.TypId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Film_GetById')
	drop procedure [dbo].[sp_Film_GetById]
Go 
CREATE PROCEDURE dbo.sp_Film_GetById    --------------------------- Hiện thị thông tin film theo id
@FilId	int
AS
SELECT *,*,* FROM Film inner join Country on Film.CouId = Country.CouId
					   inner join TypeFilm on Film.TypId = TypeFilm.TypId WHERE  FilId= @FilId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Film_GetByTop') 
	drop procedure [dbo].[sp_Film_GetByTop]
Go 
CREATE PROCEDURE dbo.sp_Film_GetByTop -------------------------top phim được đặt nhiều nhất
@Top nvarchar(10),
@Where nvarchar(500), 
@Order nvarchar(500)
AS
	Declare @SQL as nvarchar(500) 
Select @SQL = 'SELECT top (' + @Top + ') * FROM [Film]'
if len(@Top) = 0
BEGIN
Select @SQL = 'SELECT * FROM Film '
END
if len(@Where) >0
BEGIN
Select @SQL = @SQL + ' Where ' + @Where
END
if len(@Order) >0
BEGIN
Select @SQL = @SQL + ' Order by ' + @Order
END
EXEC (@SQL)
Go

if exists (select * from dbo.sysobjects where name = 'sp_Film_Insert') ------------Thêm
	drop procedure [dbo].[sp_Film_Insert]
Go 
CREATE PROCEDURE dbo.sp_Film_Insert
@TypId	int,
@CouId	int,
@NameF	nvarchar(100),
@Director	nvarchar(100),
@Actor	nvarchar(100),
@Duration	int,
@Description	ntext,
@Detail ntext,
@Picture	varchar(100),
@PictureBig varchar(100),
@Status	int
AS
	If(@NameF In (Select [NameF] From [Film])) ---------Nếu tên film update = tên phim có trong bảng thì lỗi
	Begin
		Raiserror ('This Film is already exists', 16, 1) --<bẩy>
		Return
	End
INSERT INTO [Film]([TypId],[CouId],[NameF],[Director],[Actor],[Duration],[Description],[Detail],[Picture],[PictureBig],[Status]) VALUES(@TypId ,@CouId ,@NameF ,@Director ,@Actor ,@Duration ,@Description ,@Detail,@Picture,@PictureBig ,@Status )
Go

if exists (select * from dbo.sysobjects where name = 'sp_Film_Update')------UPDATE
	drop procedure [dbo].[sp_Film_Update]
Go 
CREATE PROCEDURE dbo.sp_Film_Update
@FilId	int,
@TypId	int,
@CouId	int,
@NameF	nvarchar(100),
@Director	nvarchar(100),
@Actor	nvarchar(100),
@Duration	int,
@Description	ntext,
@Detail ntext,
@Picture	varchar(100),
@PictureBig varchar(100),
@Status	int
AS
	If(@NameF In (Select [NameF] From [Film] Where [FilId]<>@FilId))-----------Nếu tên phim update = tên phim trong csdl thì lỗi
	Begin
		Raiserror ('Update error, this Film is already exists', 16, 1)
		Return
	End
UPDATE [Film] SET [TypId] = @TypId,[CouId] = @CouId,[NameF] = @NameF,[Director] = @Director,[Actor] = @Actor,[Duration] = @Duration,[Description] = @Description,[Detail]=@Detail,[Picture] = @Picture,[PictureBig] = @PictureBig,[Status] = @Status
WHERE  FilId= @FilId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Film_Delete') ----xóa dữ liệu
	drop procedure [dbo].[sp_Film_Delete]
Go 
CREATE PROCEDURE dbo.sp_Film_Delete
@FilId	int
AS
	If(@FilId In (Select FilId From [ShowTimes])) -------nếu id film nằm trong lịch chiếu thì ko được xóa
	Begin
		Raiserror ('Can not delete this film', 16, 1)
		Return
	End
	If(@FilId In (Select FilId From [Feedback]))----------------nếu id film nằm trong bình luận/cảm nhận của khách hàng thì ko được xóa
	Begin
		Raiserror ('Can not delete this film', 16, 1)
		Return
	End
Delete FROM [Film] WHERE  FilId= @FilId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Film_GetByCouId') 
	drop procedure [dbo].[sp_Film_GetByCouId]
Go 
CREATE PROCEDURE dbo.sp_Film_GetByCouId---------------Tìm phim thông qua quốc gia sản xuất
@CouId int
AS
	SELECT * FROM [Film]
 WHERE CouId = @CouId 
Go

if exists (select * from dbo.sysobjects where name = 'sp_Film_GetByTypId') ----------tìm phim thông qua thể loại
	drop procedure [dbo].[sp_Film_GetByTypId]
Go 
CREATE PROCEDURE dbo.sp_Film_GetByTypId
@TypId int
AS
	SELECT * FROM [Film]
 WHERE TypId = @TypId 
Go

if exists (select * from dbo.sysobjects where name = 'sp_Film_Update_Status') ---------Trạng thái, on off/ 0 1
	drop procedure [dbo].[sp_Film_Update_Status]
Go 
CREATE PROCEDURE dbo.sp_Film_Update_Status
(
	@FilId int,
	@Status int
)
AS
Update [Film] SET [Status]=@Status where FilId=@FilId
Go
-----------------------------------------------------------------------------------------------------------------------------
--Table ShowTimes
if exists (select * from dbo.sysobjects where name = 'sp_ShowTimes_GetByAll')
	drop procedure [dbo].[sp_ShowTimes_GetByAll]
Go 
CREATE PROCEDURE dbo.sp_ShowTimes_GetByAll --------------------Hiện thị toàn bộ
AS
	SELECT *,*,* FROM ShowTimes inner join Film on Film.FilId = ShowTimes.FilId
								inner join Cinema on ShowTimes.CinId = Cinema.CinId
Go

if exists (select * from dbo.sysobjects where name = 'sp_ShowTimes_GetById')
	drop procedure [dbo].[sp_ShowTimes_GetById]
Go 
CREATE PROCEDURE dbo.sp_ShowTimes_GetById ---------------Hiện thị theo id
@ShoId	int
AS
SELECT *,*,* FROM ShowTimes inner join Film on Film.FilId = ShowTimes.FilId
								inner join Cinema on ShowTimes.CinId = Cinema.CinId WHERE  ShoId= @ShoId
Go

if exists (select * from dbo.sysobjects where name = 'sp_ShowTimes_GetByTop1')
	drop procedure [dbo].[sp_ShowTimes_GetByTop1]
Go 
CREATE PROCEDURE dbo.sp_ShowTimes_GetByTop1------------ Tìm lịch chiếu theo thông qua các bảng (rạp , film)
@Top nvarchar(10),
@Where nvarchar(500), 
@Order nvarchar(500)
AS
	Declare @SQL as nvarchar(500) 
Select @SQL = 'SELECT top (' + @Top + ') *,*,* FROM ShowTimes inner join Film on Film.FilId = ShowTimes.FilId
								inner join Cinema on ShowTimes.CinId = Cinema.CinId'
if len(@Top) = 0
BEGIN
Select @SQL = 'SELECT *,*,* FROM ShowTimes inner join Film on Film.FilId = ShowTimes.FilId
								inner join Cinema on ShowTimes.CinId = Cinema.CinId'
END
if len(@Where) >0
BEGIN
Select @SQL = @SQL + ' Where ' + @Where
END
if len(@Order) >0
BEGIN
Select @SQL = @SQL + ' Order by ' + @Order
END
EXEC (@SQL)
Go

if exists (select * from dbo.sysobjects where name = 'sp_ShowTimes_GetByTop2') ------------Tìm lịch chiếu theo bảng filmm
	drop procedure [dbo].[sp_ShowTimes_GetByTop2]
Go 
CREATE PROCEDURE dbo.sp_ShowTimes_GetByTop2
@Top nvarchar(10),
@Where nvarchar(500), 
@Order nvarchar(500)
AS
	Declare @SQL as nvarchar(500) 
Select @SQL = 'SELECT top (' + @Top + ') *,* FROM ShowTimes inner join Film on Film.FilId = ShowTimes.FilId'
if len(@Top) = 0
BEGIN
Select @SQL = 'SELECT *,* FROM ShowTimes inner join Film on Film.FilId = ShowTimes.FilId'
END
if len(@Where) >0
BEGIN
Select @SQL = @SQL + ' Where ' + @Where
END
if len(@Order) >0
BEGIN
Select @SQL = @SQL + ' Order by ' + @Order
END
EXEC (@SQL)
Go

if exists (select * from dbo.sysobjects where name = 'sp_ShowTimes_GetByTop')
	drop procedure [dbo].[sp_ShowTimes_GetByTop]
Go 
CREATE PROCEDURE dbo.sp_ShowTimes_GetByTop ----------lịch chiếu gần nhất / Hàm len tính độ dài chuỗi
@Top nvarchar(10),
@Where nvarchar(500), 
@Order nvarchar(500)
AS
	Declare @SQL as nvarchar(500) 
Select @SQL = 'SELECT top (' + @Top + ') * FROM [ShowTimes]'
if len(@Top) = 0
BEGIN
Select @SQL = 'SELECT * FROM ShowTimes '
END
if len(@Where) >0
BEGIN
Select @SQL = @SQL + ' Where ' + @Where
END
if len(@Order) >0
BEGIN
Select @SQL = @SQL + ' Order by ' + @Order
END
EXEC (@SQL)
Go

if exists (select * from dbo.sysobjects where name = 'sp_ShowTimes_Insert') --------Thêm
	drop procedure [dbo].[sp_ShowTimes_Insert]
Go 
CREATE PROCEDURE dbo.sp_ShowTimes_Insert
@FilId	int,
@CinId	int,
@ShowTime	datetime,
@Time time,
@Price	float,
@Status	int
AS
INSERT INTO [ShowTimes]([FilId],[CinId],[ShowTime],[Time],[Price],[Status]) VALUES(@FilId ,@CinId ,@ShowTime ,@Time,@Price ,@Status )
Go

if exists (select * from dbo.sysobjects where name = 'sp_ShowTimes_Update') ---------Cập nhật
	drop procedure [dbo].[sp_ShowTimes_Update]
Go 
CREATE PROCEDURE dbo.sp_ShowTimes_Update
@ShoId	int,
@FilId	int,
@CinId	int,
@ShowTime	datetime,
@Time time,
@Price	float,
@Status	int
AS
UPDATE [ShowTimes] SET [FilId] = @FilId,[CinId] = @CinId,[ShowTime] = @ShowTime,[Time]=@Time,[Price] = @Price,[Status] = @Status
WHERE  ShoId= @ShoId
Go

if exists (select * from dbo.sysobjects where name = 'sp_ShowTimes_Delete') --- xóa dữ liệu
	drop procedure [dbo].[sp_ShowTimes_Delete]
Go 
CREATE PROCEDURE dbo.sp_ShowTimes_Delete
@ShoId	int
AS
	If(@ShoId In (Select ShoId From [Booking]))
	Begin
		Raiserror ('Can not delete this ShowTimes', 16, 1)
		Return
	End
Delete FROM [ShowTimes] WHERE  ShoId= @ShoId
Go

if exists (select * from dbo.sysobjects where name = 'sp_ShowTimes_GetByCinId')
	drop procedure [dbo].[sp_ShowTimes_GetByCinId]
Go 
CREATE PROCEDURE dbo.sp_ShowTimes_GetByCinId ----------tìm lịch chiếu của từng rạp
@CinId int
AS
	SELECT * FROM [ShowTimes]
 WHERE CinId = @CinId 
Go

if exists (select * from dbo.sysobjects where name = 'sp_ShowTimes_GetByFilId') 
	drop procedure [dbo].[sp_ShowTimes_GetByFilId]
Go 
CREATE PROCEDURE dbo.sp_ShowTimes_GetByFilId -------------Tìm lịch chiếu của từng phim
@FilId int
AS
	SELECT * FROM ShowTimes inner join Cinema on ShowTimes.CinId = Cinema.CinId
 WHERE FilId = @FilId 
Go

if exists (select * from dbo.sysobjects where name = 'sp_ShowTimes_Update_Status') -------trạng tháo
	drop procedure [dbo].[sp_ShowTimes_Update_Status]
Go 
CREATE PROCEDURE dbo.sp_ShowTimes_Update_Status
(
	@ShoId int,
	@Status int
)
AS
Update [ShowTimes] SET [Status]=@Status where ShoId=@ShoId
Go

if exists (select * from dbo.sysobjects where name = 'sp_ShowTimes_Update_View')
	drop procedure [dbo].[sp_ShowTimes_Update_View]
Go 
CREATE PROCEDURE dbo.sp_ShowTimes_Update_View -------------lượt view
(
	@FilId int
)
AS
Update [ShowTimes] SET [View]=[View]+1 where FilId=@FilId
Go

if exists (select * from dbo.sysobjects where name = 'sp_ShowTimes_Update_Price')
	drop procedure [dbo].[sp_ShowTimes_Update_Price]
Go 
CREATE PROCEDURE dbo.sp_ShowTimes_Update_Price ----update giá
(
	@ShoId int,
	@Price float
)
AS
Update [ShowTimes] SET [Price]=@Price where ShoId=@ShoId
Go

Create Trigger tg_add_showtimes on ShowTimes ---------bẩy lỗi khi đưa dữ liệu vào bảng lịch chiếu- cập nhât thời gian chiếu- TRÁNH XUNG ĐỘT VỚI FLIM
for insert
as                                              ---Tránh xung đột khi update tg chiếu vơi fim
	declare @Filmid1 int, @Showid int, @Filmid2 int ---------tạo 3 biến
	select @Filmid2 = Filid from Showtimes ------ Kiểm tra fi2 phải nằm trong bảng phim
	select @Filmid1 = Inserted.Filid, 
	@Showid = Inserted.Shoid from Inserted
	if @Filmid1 = @Filmid2
		begin
			update Showtimes
			set [status] = 0 where Shoid = @Showid
		end
Go
---------------------------------------------------------------------------------------------------------------------
--------------------------------------------Create Booking-----------------------------------------------------------

if exists (select * from dbo.sysobjects where name = 'sp_Booking_GetByAll')
	drop procedure [dbo].[sp_Booking_GetByAll]
Go 
CREATE PROCEDURE dbo.sp_Booking_GetByAll----------hiện thị
AS
	
	select *,* from Booking inner join Customer on Booking.CusId = Customer.CusId
Go


if exists (select * from dbo.sysobjects where name = 'sp_Booking_Sum') ------Tổng vé được đặt
	drop procedure [dbo].[sp_Booking_Sum]
Go 
CREATE PROCEDURE dbo.sp_Booking_Sum
@ShoId int
AS
	SELECT Tickets=SUM(Quantity) FROM Booking Where ShoId = @ShoId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Booking_GetById')
	drop procedure [dbo].[sp_Booking_GetById]
Go 
CREATE PROCEDURE dbo.sp_Booking_GetById ----------Tìm thông tin tất cả  đã đặt thông qua id vé 
@BooId	int
AS
--SELECT * FROM [Booking] WHERE  BooId= @BooId
select *,*,Pic=Film.Picture,*,St=Booking.[Status] from Booking inner join Customer on Booking.CusId = Customer.CusId
						inner join ShowTimes on ShowTimes.ShoId = Booking.ShoId
						inner join Film on Film.FilId = ShowTimes.FilId WHERE  BooId= @BooId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Booking_GetByTop')
	drop procedure [dbo].[sp_Booking_GetByTop]
Go 
CREATE PROCEDURE dbo.sp_Booking_GetByTop---------------đếm số lượng 
@Top nvarchar(10),
@Where nvarchar(500), 
@Order nvarchar(500)
AS
	Declare @SQL as nvarchar(500) 
Select @SQL = 'SELECT top (' + @Top + ') * FROM [Booking]'
if len(@Top) = 0
BEGIN
Select @SQL = 'SELECT * FROM [Booking]'
END
if len(@Where) >0
BEGIN
Select @SQL = @SQL + ' Where ' + @Where
END
if len(@Order) >0
BEGIN
Select @SQL = @SQL + ' Order by ' + @Order
END
EXEC (@SQL)
Go

if exists (select * from dbo.sysobjects where name = 'sp_Booking_Insert') ------thêm
	drop procedure [dbo].[sp_Booking_Insert]
Go 
CREATE PROCEDURE dbo.sp_Booking_Insert
@CusId	int,
@ShoId	int,
@Bilmoney float,
@Quantity	int
AS
INSERT INTO [Booking]([CusId],[ShoId],[Bilmoney],[Quantity]) VALUES(@CusId ,@ShoId,@Bilmoney ,@Quantity )
Go

if exists (select * from dbo.sysobjects where name = 'sp_Booking_Update') ----------update
	drop procedure [dbo].[sp_Booking_Update]
Go 
CREATE PROCEDURE dbo.sp_Booking_Update
@BooId	int
AS
UPDATE [Booking] SET [Status] = 'Yes'
WHERE  BooId= @BooId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Booking_Delete')--------xóa dữ liệu
	drop procedure [dbo].[sp_Booking_Delete]
Go 
CREATE PROCEDURE dbo.sp_Booking_Delete
@BooId	int
AS
Delete FROM [Booking] WHERE  BooId= @BooId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Booking_GetByCusId')-----------tìm vé thông qua ID khách hàng
	drop procedure [dbo].[sp_Booking_GetByCusId]
Go 
CREATE PROCEDURE dbo.sp_Booking_GetByCusId
@CusId int
AS
	SELECT * FROM [Booking]
 WHERE CusId = @CusId 
Go

if exists (select * from dbo.sysobjects where name = 'sp_Booking_GetByShoId')---------------Tìm vé thông thời gian chiếu phim
	drop procedure [dbo].[sp_Booking_GetByShoId]
Go 
CREATE PROCEDURE dbo.sp_Booking_GetByShoId
@ShoId int
AS
	SELECT * FROM [Booking]
 WHERE ShoId = @ShoId 
Go
-------------------------------------------------------------------------------------------------------------------------------------
--Feedback 

if exists (select * from dbo.sysobjects where name = 'sp_Feedback_GetByAll')
	drop procedure [dbo].[sp_Feedback_GetByAll]
Go 
CREATE PROCEDURE dbo.sp_Feedback_GetByAll --------tìm, hiện thị phản hồi
AS
	SELECT * FROM Feedback
Go

if exists (select * from dbo.sysobjects where name = 'sp_Feedback_GetById')
	drop procedure [dbo].[sp_Feedback_GetById]
Go 
CREATE PROCEDURE dbo.sp_Feedback_GetById --------- qua id phản hồi xem toàn bộ phản hồi
@FeeId	int
AS
SELECT * FROM [Feedback] WHERE  FeeId= @FeeId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Feedback_GetByTop') ----------------đếm phản hồi
	drop procedure [dbo].[sp_Feedback_GetByTop]
Go 
CREATE PROCEDURE dbo.sp_Feedback_GetByTop
@Top nvarchar(10),
@Where nvarchar(500), 
@Order nvarchar(500)
AS
	Declare @SQL as nvarchar(500) 
Select @SQL = 'SELECT top (' + @Top + ') * FROM [Feedback]'
if len(@Top) = 0
BEGIN
Select @SQL = 'SELECT * FROM [Feedback]'
END
if len(@Where) >0
BEGIN
Select @SQL = @SQL + ' Where ' + @Where
END
if len(@Order) >0
BEGIN
Select @SQL = @SQL + ' Order by ' + @Order
END
EXEC (@SQL)
Go

if exists (select * from dbo.sysobjects where name = 'sp_Feedback_Insert')  -------------thêm
	drop procedure [dbo].[sp_Feedback_Insert]
Go 
CREATE PROCEDURE dbo.sp_Feedback_Insert
@FilId	int,
@Avata	nvarchar(100),
@FullName	nvarchar(100),
@Comment	nvarchar(500)
AS
INSERT INTO [Feedback]([FilId],[Avata],[FullName],[Comment]) VALUES(@FilId ,@Avata,@FullName ,@Comment )
Go

if exists (select * from dbo.sysobjects where name = 'sp_Feedback_Update')----------cập nhật
	drop procedure [dbo].[sp_Feedback_Update]
Go 
CREATE PROCEDURE dbo.sp_Feedback_Update
@FeeId	int,
@FilId	int,
@Avata	nvarchar(100),
@FullName	nvarchar(100),
@Comment	nvarchar(500)
AS
UPDATE [Feedback] SET [FilId] = @FilId,[Avata]=@Avata,[FullName] = @FullName,[Comment] = @Comment
WHERE  FeeId= @FeeId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Feedback_Delete') -----------xóa dữ liệu
	drop procedure [dbo].[sp_Feedback_Delete]
Go 
CREATE PROCEDURE dbo.sp_Feedback_Delete
@FeeId	int
AS
Delete FROM [Feedback] WHERE  FeeId= @FeeId
Go

if exists (select * from dbo.sysobjects where name = 'sp_Feedback_GetByFilId')-------------Tìm, hiên thi phản hồi thông qua id phim
	drop procedure [dbo].[sp_Feedback_GetByFilId]
Go 
CREATE PROCEDURE dbo.sp_Feedback_GetByFilId
@FilId int
AS
	SELECT * FROM [Feedback]
 WHERE FilId = @FilId 
Go
--------------------------------------------------------------------------------------------------------------------------
--Table Seat
if exists (select * from dbo.sysobjects where name = 'sp_Seat_GetByAll') 
	drop procedure [dbo].[sp_Seat_GetByAll]
Go 
CREATE PROCEDURE dbo.sp_Seat_GetByAll
AS
	SELECT * FROM Seat
Go

if exists (select * from dbo.sysobjects where name = 'sp_Seat_GetById')
	drop procedure [dbo].[sp_Seat_GetById]
Go 
CREATE PROCEDURE dbo.sp_Seat_GetById 
@SeatId	int
AS
SELECT * FROM [Seat] WHERE  SeatId = @SeatId
Go


------------------------------------------------------Query Insert And Check----------------------------------------------------------------------------
-- Lưu ý insert chỉ cần thay số vào chạy ko cần viết thêm câu lệnh, chỗ creditcard nhập số đừng to quá sẽ tràng bit int(đang xem và fix lại lỗi này)
--Table ADMIN
DELETE FROM Admin WHERE FullName=N'Đỗ Thị Như Trang'; 
SELECT * FROM Admin;
Insert into [Admin] values('Admin2', 'abc456bcv', N'Đỗ Thị Như Trang', '06/27/2001', N'Q.Thủ Đức', '0388276620', 'zbayby1saoz@gmail.com');
Go
UPDATE [Admin] SET [FullName] = N'Đỗ Thị Như Trang',[Bod] = '06/06/2001',[Address] = N'Q.1',[Phone] ='0398276690',[Email] = 'baybyxauxa@gmail.com'
WHERE  AdmId= '2';

-- Table Customer
DELETE FROM Customer
SELECT * FROM [Customer]
INSERT INTO [Customer]([Username],[Password],[CreditCard],[FullName],[Bod],[Address],[Phone],[Email],Avata,[Status]) 
VALUES('Alibaba','hellobaba' ,'1156890378' ,N'Nguyễn Văn Anh' ,'02/09/1998' ,N'H.Nhà Bè' ,'038 928 6730' ,'alibobo@gmail.com' ,'anhdaidien.jpg','0' )
Go
--Table Cinema
SELECT * FROM Cinema
INSERT INTO [Cinema]([NameCi],[Address],[Seats],[Phone],[Image],[Status])
VALUES(N'CINESTAR Nhà Văn Hóa Sinh Viên' ,N'P.Đông hòa, TP.Dĩ An, T.Bình Dương' ,'400' ,'028 7303 8881','anhrap.jpg' ,'1' )
Go
--Table Country
SELECT * FROM Country
INSERT INTO [Country]([NameCo],[Status]) VALUES(N'Trung Quốc' ,'1' )
Go
--Table TypeFilm
SELECT * FROM TypeFilm
INSERT INTO [TypeFilm]([NameT],[Status]) VALUES(N'Trinh Thám' ,'1' )

-- Table Film
SELECT * FROM Film
INSERT INTO [Film]([TypId],[CouId],[NameF],[Director],[Actor],[Duration],[Description],[Detail],[Picture],[PictureBig],[Status]) 
VALUES('1' ,'2' ,'Conan' ,'alexbo' ,'abcxy' ,'2' ,N'Hay abcz' ,'Chi tiết bộ phim..abc','anhphim.jpg','anhphimto.jpg' ,'0' )
Go
--Table Showtime
SELECT * FROM ShowTimes
INSERT INTO [ShowTimes]([FilId],[CinId],[ShowTime],[Time],[Price],[Status]) 
VALUES('6' ,'3' ,'07/28/2019' ,'13:00','50.000' ,'1' )
Go
--Table Booking
SELECT * FROM Booking
INSERT INTO [Booking]([CusId],[ShoId],[Bilmoney],[Quantity]) 
VALUES('10' ,'3','50.000' ,'4' )
Go
--Tabe Feeback

SELECT * FROM Feedback
INSERT INTO [Feedback]([FilId],[Avata],[FullName],[Comment]) 
VALUES('6' ,'anhpanh.jpg',N'Nguyễn Văn Anh' ,N'Phim rất hay, rạp rất tốt' )
Go