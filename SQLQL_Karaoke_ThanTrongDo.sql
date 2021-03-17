create database QL_KARAOKE_ThanTrongDo
use QL_KARAOKE_ThanTrongDo

create table NhanVien
(
	MaNV char(10) not null,
	Pass char(16) not null,
	TenNV nvarchar(70),
	NgaySinh date,
	Phai nvarchar(5),
	SDT char(11),
	DiaChi nvarchar(255),
	LuongNV int,
	primary key(MaNV)
)
create table LoaiKH(
	MaLoaiKH char(10) not null,
	TenLoaiKH nvarchar(50),
	primary key (MaLoaiKH)
)
CREATE TABLE KhachHang
(
	MaKH VARCHAR(10) not null,
	HoTenKH NVARCHAR(50),
	Phai NVARCHAR(5),
	DIENTHOAIKH CHAR(12),
	MaLoaiKH char(10),
	primary key (MaKH)
)
alter table KhachHang
add constraint fk_MaLoaiKH foreign key (MaLoaiKH) references LoaiKH(MaLoaiKH)
CREATE FUNCTION AUTO_MAKH()
RETURNS VARCHAR(5)
AS
BEGIN
	DECLARE @ID VARCHAR(5)
	IF (SELECT COUNT(MAKH) FROM KHACHHANG) = 0
		SET @ID = '0'
	ELSE
		SELECT @ID = MAX(RIGHT(MAKH, 2)) FROM KHACHHANG
		SELECT @ID = CASE
			WHEN @ID >= 0 and @ID < 9 THEN 'KH00' + CONVERT(CHAR, CONVERT(INT, @ID) + 1)
			WHEN @ID >= 9 THEN 'KH0' + CONVERT(CHAR, CONVERT(INT, @ID) + 1)
		END
	RETURN @ID
END

ALTER TABLE KHACHHANG ADD CONSTRAINT df_MAKH DEFAULT DBO.AUTO_MAKH() FOR MAKH;

create table PhongHat(
	MaPhong char(10) not null,
	TenPhong nvarchar(255),
	TrangThai int,
	GioVao datetime,
	GioRa  datetime,
	gia float,
	primary key(MaPhong)
)

create table DSDichVu(
	MaDV char(20) not null,
	TenDV nvarchar(255),
	DonGia float,
	primary key(MaDV)
)
create table HoaDon(
	MaHoaDon varchar(10) not null,
	MaPhong char(10),
	MaNV char(10),
	MaKH VARCHAR(10),
	MaKM char(10),
	TienDV float,
	TongTien float,
	TrangThai int,
	NgayLap int,
	ThangLap int,
	NamLap int,
	primary key (MaHoaDon)
)
alter table HoaDon
add constraint fk_MaPhong_HD foreign key (MaPhong) references PhongHat(MaPhong)
alter table HoaDon
add constraint fk_MaNV_HD foreign key (MaNV) references NhanVien(MaNV)
alter table HoaDon
add constraint fk_MaKH_HD foreign key (MaKH) references KhachHang(MaKH)

create table CTDichVu(
	MaDV char(20) not null,
	MaHoaDon varchar(10) not null,
	SoLuong int,
	ThanhTien float,
	primary key(MaDV,MaHoaDon)
)

alter table CTDichVu
add constraint fk_MaHoaDon foreign key (MaHoaDon) references HoaDon(MaHoaDon)
alter table CTDichVu
add constraint fk_MaDV foreign key (MaDV) references DSDichVu(MaDV)


set dateformat DMY
insert into NhanVien
values ('ADMIN','123',N'Thân Trọng Độ','20/11/2000',N'Nam','0964979147',N'3 Sơn kỳ',5000000),
	   ('TN1','123',N'Bùi Nhật Khang','02/01/2000',N'Nam','0964858159',N'47 Phạm Ngọc Thảo',3000000)

insert into LoaiKH
values ('VIP',N'Khách hàng thân thiết'),
	   ('VL',N'Khách hàng vãng lai')

insert into KhachHang
values ('KH01',N'Ngô Văn Mười',N'Nam','0964979148','VIP'),
	   ('KH02',N'Phan Thành Đạt',N'Nam','0964979145','VL')

insert into DSDichVu
values ('NS',N'Nước suối',7000),
	   ('TIGER',N'Bia Tiger',20000),
	   ('SAIGON',N'Bia Sài Gòn',15000),
	   ('Osi',N'Bánh Osi',10000),
	   ('MUCKHO',N'Mực khô',100000),
	   ('STING',N'Nước ngọt sting',15000),
	   ('COCA',N'Nước ngọt Cocacola',15000)

set dateformat DMY
insert into PhongHat
values ('P100',N'Phòng 100',0,Null,Null,120000),
	   ('P101',N'Phòng 101',0,Null,Null,120000)


create trigger capnhattien on CTDichVu
for insert
as
begin
	update CTDichVu
	set ThanhTien = (select SoLuong*DonGia from CTDichVu as CTDV,DSDichVu where CTDichVu.MaDV = CTDV.MaDV and CTDichVu.MaHoaDon = CTDV.MaHoaDon and CTDV.MaDV = DSDichVu.MaDV)
end
go
create trigger capnhatTTHD on CTDichVu
for insert 
as
begin
	update HoaDon
	set TienDV = (select sum(ThanhTien) from CTDichVu where CTDichVu.MaHoaDon = HoaDon.MaHoaDon)
end
go
INSERT INTO KhachHang
VALUES(DBO.AUTO_MAKH(),N'Thân Trọng Độ','Nam','0123456789','VIP')
CREATE FUNCTION AUTO_MAHD()
RETURNS VARCHAR(5)
AS
BEGIN
	DECLARE @ID VARCHAR(5)
	IF (SELECT COUNT(MaHoaDon) FROM HoaDon) = 0
		SET @ID = '0'
	ELSE
		SELECT @ID = MAX(RIGHT(MaHoaDon, 2)) FROM HoaDon
		SELECT @ID = CASE
			WHEN @ID >= 0 and @ID < 9 THEN 'HD00' + CONVERT(CHAR, CONVERT(INT, @ID) + 1)
			WHEN @ID >= 9 THEN 'HD0' + CONVERT(CHAR, CONVERT(INT, @ID) + 1)
		END
	RETURN @ID
END

SELECT SUM(TongTien) FROM HoaDon WHERE DAY(GETDATE()) = NgayLap AND MONTH(GETDATE()) = ThangLap AND YEAR(GETDATE()) = NamLap
SELECT COUNT(*) FROM HoaDon WHERE DAY(GETDATE()) = NgayLap AND MONTH(GETDATE()) = ThangLap AND YEAR(GETDATE()) = NamLap

SELECT SUM(TongTien) FROM HoaDon WHERE  MONTH(GETDATE()) = ThangLap AND YEAR(GETDATE()) = NamLap
SELECT COUNT(*) FROM HoaDon WHERE  MONTH(GETDATE()) = ThangLap AND YEAR(GETDATE()) = NamLap

set dateformat DMY
insert into PhongHat
values ('P102',N'Phòng 102',0,Null,Null,120000),
	   ('P103',N'Phòng 103',0,Null,Null,120000),
	   ('P104',N'Phòng 104',0,Null,Null,120000),
	   ('P105',N'Phòng 105',0,Null,Null,120000),
	   ('P106',N'Phòng 106',0,Null,Null,120000)
		