/*
    BAÞLAMADAN ÖNCE:
    1. SSMS'de "LaboratuvarDB" adýnda YENÝ bir veritabaný oluþturun.
    2. Sol üstteki dropdown menüden bu "LaboratuvarDB" veritabanýný seçin.
    3. Bu script'in tamamýný kopyalayýp "Execute" (Çalýþtýr) butonuna basýn.
*/
GO

----------------------------------------------------------------
-- 1. ADIM: TABLOLARIN OLUÞTURULMASI
-- (Sadece EÐER YOKSA oluþturur)
----------------------------------------------------------------

PRINT '1. Hastalar Tablosu Kontrol Ediliyor/Oluþturuluyor...';
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Hastalar]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Hastalar](
        [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [TCKimlikNo] [varchar](11) NOT NULL UNIQUE,
        [Ad] [varchar](100) NOT NULL,
        [Soyad] [varchar](100) NOT NULL,
        [DogumTarihi] [date] NOT NULL,
        [Cinsiyet] [varchar](10) NULL,
        [Telefon] [varchar](15) NULL,
        [Adres] [varchar](500) NULL,
        [Aktif] [bit] NOT NULL DEFAULT 1
    );
END
GO

PRINT '2. Doktorlar Tablosu Kontrol Ediliyor/Oluþturuluyor...';
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Doktorlar]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Doktorlar](
        [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [AdSoyad] [varchar](200) NOT NULL,
        [UzmanlikAlani] [varchar](100) NULL,
        [DiplomaNo] [varchar](50) NULL
    );
END
GO

PRINT '3. TestTanimlari Tablosu Kontrol Ediliyor/Oluþturuluyor...';
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TestTanimlari]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[TestTanimlari](
        [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [TestKodu] [varchar](50) NOT NULL UNIQUE,
        [TestAdi] [varchar](200) NOT NULL,
        [Birim] [varchar](50) NULL,
        [ReferansAralik] [varchar](100) NULL
    );
END
GO

PRINT '4. Raporlar Tablosu Kontrol Ediliyor/Oluþturuluyor...';
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Raporlar]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Raporlar](
        [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [HastaId] [int] NOT NULL,
        [DoktorId] [int] NOT NULL,
        [RaporTarihi] [datetime] NOT NULL DEFAULT GETDATE(),
        [Durum] [varchar](50) NOT NULL DEFAULT 'Bekliyor',
        [Aciklama] [varchar](1000) NULL,
        
        CONSTRAINT [FK_Rapor_Hasta] FOREIGN KEY ([HastaId]) REFERENCES [dbo].[Hastalar]([Id]),
        CONSTRAINT [FK_Rapor_Doktor] FOREIGN KEY ([DoktorId]) REFERENCES [dbo].[Doktorlar]([Id])
    );
END
GO

PRINT '5. Sonuclar Tablosu Kontrol Ediliyor/Oluþturuluyor...';
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Sonuclar]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Sonuclar](
        [Id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [RaporId] [int] NOT NULL,
        [TestTanimiId] [int] NOT NULL,
        [Deger] [varchar](100) NOT NULL,
        [Aciklama] [varchar](500) NULL,
        
        CONSTRAINT [FK_Sonuc_Rapor] FOREIGN KEY ([RaporId]) REFERENCES [dbo].[Raporlar]([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_Sonuc_TestTanimi] FOREIGN KEY ([TestTanimiId]) REFERENCES [dbo].[TestTanimlari]([Id])
    );
END
GO

PRINT 'Tüm Tablolar Kontrol Edildi/Oluþturuldu.';
GO

----------------------------------------------------------------
-- 2. ADIM: STORED PROCEDURE (SP) OLUÞTURULMASI/GÜNCELLENMESÝ
-- (Varsa GÜNCELLER, yoksa OLUÞTURUR)
----------------------------------------------------------------

PRINT 'sp_Hasta_Yonet Oluþturuluyor/Güncelleniyor...';
GO
CREATE OR ALTER PROCEDURE sp_Hasta_Yonet
    @Operation      VARCHAR(10),
    @Id             INT = NULL,
    @TCKimlikNo     VARCHAR(11) = NULL,
    @Ad             VARCHAR(100) = NULL,
    @Soyad          VARCHAR(100) = NULL,
    @DogumTarihi    DATE = NULL,
    @Cinsiyet       VARCHAR(10) = NULL,
    @Telefon        VARCHAR(15) = NULL,
    @Adres          VARCHAR(500) = NULL,
    @Aktif          BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Operation = 'list'
    BEGIN
        SELECT Id, TCKimlikNo, Ad, Soyad, DogumTarihi, Cinsiyet, Telefon, Adres, Aktif 
        FROM Hastalar 
        ORDER BY Ad, Soyad;
    END
    ELSE IF @Operation = 'insert'
    BEGIN
        INSERT INTO Hastalar (TCKimlikNo, Ad, Soyad, DogumTarihi, Cinsiyet, Telefon, Adres, Aktif)
        VALUES (@TCKimlikNo, @Ad, @Soyad, @DogumTarihi, @Cinsiyet, @Telefon, @Adres, @Aktif);
    END
    ELSE IF @Operation = 'update'
    BEGIN
        UPDATE Hastalar
        SET TCKimlikNo = @TCKimlikNo,
            Ad = @Ad,
            Soyad = @Soyad,
            DogumTarihi = @DogumTarihi,
            Cinsiyet = @Cinsiyet,
            Telefon = @Telefon,
            Adres = @Adres,
            Aktif = @Aktif
        WHERE Id = @Id;
    END
    ELSE IF @Operation = 'delete'
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Raporlar WHERE HastaId = @Id)
        BEGIN
            DELETE FROM Hastalar WHERE Id = @Id;
        END
        ELSE
        BEGIN
            UPDATE Hastalar SET Aktif = 0 WHERE Id = @Id;
        END
    END
END
GO

PRINT 'sp_TestTanimi_Yonet Oluþturuluyor/Güncelleniyor...';
GO
CREATE OR ALTER PROCEDURE sp_TestTanimi_Yonet
    @Operation      VARCHAR(10),
    @Id             INT = NULL,
    @TestKodu       VARCHAR(50) = NULL,
    @TestAdi        VARCHAR(200) = NULL,
    @Birim          VARCHAR(50) = NULL,
    @ReferansAralik VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Operation = 'list'
    BEGIN
        SELECT Id, TestKodu, TestAdi, Birim, ReferansAralik 
        FROM TestTanimlari 
        ORDER BY TestAdi;
    END
    ELSE IF @Operation = 'insert'
    BEGIN
        INSERT INTO TestTanimlari (TestKodu, TestAdi, Birim, ReferansAralik)
        VALUES (@TestKodu, @TestAdi, @Birim, @ReferansAralik);
    END
    ELSE IF @Operation = 'update'
    BEGIN
        UPDATE TestTanimlari
        SET TestKodu = @TestKodu,
            TestAdi = @TestAdi,
            Birim = @Birim,
            ReferansAralik = @ReferansAralik
        WHERE Id = @Id;
    END
    ELSE IF @Operation = 'delete'
    BEGIN
        DELETE FROM TestTanimlari WHERE Id = @Id;
    END
END
GO

PRINT 'sp_Doktor_Listele Oluþturuluyor/Güncelleniyor...';
GO
CREATE OR ALTER PROCEDURE sp_Doktor_Listele
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, AdSoyad, UzmanlikAlani 
    FROM Doktorlar 
    ORDER BY AdSoyad;
END
GO

PRINT 'sp_Rapor_Olustur Oluþturuluyor/Güncelleniyor...';
GO
CREATE OR ALTER PROCEDURE sp_Rapor_Olustur
    @HastaId INT,
    @DoktorId INT,
    @Aciklama VARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Raporlar (HastaId, DoktorId, Aciklama, RaporTarihi, Durum)
    VALUES (@HastaId, @DoktorId, @Aciklama, GETDATE(), 'Bekliyor');
END
GO

PRINT 'sp_Rapor_Listele_Bekleyen Oluþturuluyor/Güncelleniyor...';
GO
CREATE OR ALTER PROCEDURE sp_Rapor_Listele_Bekleyen
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        r.Id,
        r.HastaId,
        r.DoktorId,
        r.RaporTarihi,
        r.Durum,
        r.Aciklama,
        h.Ad + ' ' + h.Soyad AS HastaAdSoyad,
        d.AdSoyad AS DoktorAdSoyad
    FROM
        Raporlar r
    LEFT JOIN
        Hastalar h ON r.HastaId = h.Id
    LEFT JOIN
        Doktorlar d ON r.DoktorId = d.Id
    WHERE
        r.Durum = 'Bekliyor'
    ORDER BY
        r.RaporTarihi DESC;
END
GO

PRINT 'sp_Sonuc_Listele_ByRaporId Oluþturuluyor/Güncelleniyor...';
GO
CREATE OR ALTER PROCEDURE sp_Sonuc_Listele_ByRaporId
    @RaporId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        s.Id,
        s.RaporId,
        s.TestTanimiId,
        s.Deger,
        s.Aciklama,
        t.TestAdi,
        t.Birim,
        t.ReferansAralik
    FROM 
        Sonuclar s
    LEFT JOIN 
        TestTanimlari t ON s.TestTanimiId = t.Id
    WHERE 
        s.RaporId = @RaporId;
END
GO

PRINT 'sp_Sonuc_Ekle Oluþturuluyor/Güncelleniyor...';
GO
CREATE OR ALTER PROCEDURE sp_Sonuc_Ekle
    @RaporId INT,
    @TestTanimiId INT,
    @Deger VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Sonuclar (RaporId, TestTanimiId, Deger)
    VALUES (@RaporId, @TestTanimiId, @Deger);
END
GO

PRINT 'sp_Rapor_Onayla Oluþturuluyor/Güncelleniyor...';
GO
CREATE OR ALTER PROCEDURE sp_Rapor_Onayla
    @RaporId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Raporlar
    SET Durum = 'Onaylandý'
    WHERE Id = @RaporId;
END
GO

PRINT 'Tüm Stored Procedureler Baþarýyla Oluþturuldu/Güncellendi.';
GO

----------------------------------------------------------------
-- 3. ADIM: (OPSÝYONEL) BAÞLANGIÇ VERÝLERÝ EKLEME
-- (Sadece EÐER YOKSA ekler)
----------------------------------------------------------------

PRINT 'Baþlangýç verileri ekleniyor...';
GO

-- Doktorlar
IF NOT EXISTS (SELECT 1 FROM Doktorlar WHERE DiplomaNo = '12345')
BEGIN
    INSERT INTO Doktorlar (AdSoyad, UzmanlikAlani, DiplomaNo) VALUES 
    ('Dr. Ahmet Yýlmaz', 'Dahiliye', '12345');
END
IF NOT EXISTS (SELECT 1 FROM Doktorlar WHERE DiplomaNo = '67890')
BEGIN
    INSERT INTO Doktorlar (AdSoyad, UzmanlikAlani, DiplomaNo) VALUES 
    ('Dr. Elif Kaya', 'Laboratuvar Uzmaný', '67890');
END
GO

-- Test Tanýmlarý
IF NOT EXISTS (SELECT 1 FROM TestTanimlari WHERE TestKodu = 'HB')
BEGIN
    INSERT INTO TestTanimlari (TestKodu, TestAdi, Birim, ReferansAralik) VALUES
    ('HB', 'Hemoglobin', 'g/dL', '13.5 - 17.5');
END
IF NOT EXISTS (SELECT 1 FROM TestTanimlari WHERE TestKodu = 'TSH')
BEGIN
    INSERT INTO TestTanimlari (TestKodu, TestAdi, Birim, ReferansAralik) VALUES
    ('TSH', 'Tiroid Uyarýcý Hormon', 'µIU/mL', '0.4 - 4.0');
END
IF NOT EXISTS (SELECT 1 FROM TestTanimlari WHERE TestKodu = 'CRP')
BEGIN
    INSERT INTO TestTanimlari (TestKodu, TestAdi, Birim, ReferansAralik) VALUES
    ('CRP', 'C-Reaktif Protein', 'mg/L', '0 - 5.0');
END
IF NOT EXISTS (SELECT 1 FROM TestTanimlari WHERE TestKodu = 'GLU')
BEGIN
    INSERT INTO TestTanimlari (TestKodu, TestAdi, Birim, ReferansAralik) VALUES
    ('GLU', 'Glikoz (Açlýk)', 'mg/dL', '70 - 100');
END
GO

PRINT 'Script Tamamlandý.';
