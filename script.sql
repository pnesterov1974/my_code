USE [kladr_old]
GO
/****** Object:  View [dbo].[v_doma]    Script Date: 04.07.2024 21:22:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[v_doma]
AS
SELECT [code]                       AS [KladrCode],
       LEFT([code], 11)             AS [KladrSubCode],
       LEFT([code], 2)              AS [AreaCodee],
	   SUBSTRING([code],  3, 3)     AS [DistrictCode],
	   SUBSTRING([code],  6, 3)     AS [CitryCode],
	   SUBSTRING([code],  9, 3)     AS [TownCode],
	   SUBSTRING([code], 12, 4)     AS [StreetCode],
	   SUBSTRING([code], 16, 4)     AS [BldCode],
	   6                            AS [KladrLevel], 
	   [name]                       AS [KladrName],
	   [socr]                       AS [KladrSocr],
	   [index]                      AS [KladrIndex],
	   [gninmb]                     AS [KladrGninmb],
	   [uno]                        AS [KladrUno],
	   [ocatd]                      AS [KladrOcatd]
FROM kladr.[doma]
GO
/****** Object:  View [dbo].[v_kladr]    Script Date: 04.07.2024 21:22:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[v_kladr]
AS

SELECT [code]                                      AS [KladrCode],
       LEFT([code], 11)                            AS [KladrSubCode],
       LEFT([Code], 2)                             AS [AreaCode],
       SUBSTRING([code], 3, 3)                     AS [DistrictCode],
       SUBSTRING([code], 6, 3)                     AS [CityCode],
       SUBSTRING([code], 9, 3)                     AS [TownCode],
		-------------------
       IIF(SUBSTRING([code], 9, 3) <> N'000', 4,
            (IIF(SUBSTRING([code], 6, 3) <> N'000', 3,
                   (IIF(SUBSTRING([code], 3, 3) <> N'000', 2, 1))
                )
            )
          )                                        AS [KladrLevel],
            ------------------- 
       RIGHT([code], 2)                            AS [ActualityStatus],
       [name]                                      AS [KladrName],
       [socr]                                      AS [KladrSocr],
       [index]                                     AS [KladrIndex],
       [gninmb]                                    AS [KladrGninmb],
       [uno]                                       AS [KladrUno],
       [ocatd]                                     AS [KladrOcatd],
       [status]                                    AS [KladrStatus]
FROM kladr.[kladr]
WHERE (RIGHT([code], 2) = N'00')
GO
/****** Object:  View [dbo].[v_street]    Script Date: 04.07.2024 21:22:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[v_street]
AS
SELECT [code]                        AS [KladrCode],
       LEFT([code], 11)              AS [KladrSubCode],
       LEFT([code], 2)               AS [AreaCode],
	   SUBSTRING([code], 3, 3)       AS [DistrictCode],
	   SUBSTRING([code], 6, 3)       AS [CityCode],
	   SUBSTRING([code], 9, 3)       AS [TownCode],
	   SUBSTRING([code], 12, 4)      AS [StreetCode],
	   RIGHT([code], 2)              AS [ActualityStatus],
	   5                             AS [KladrLevel],
	   [name]                        AS [KladrName],
	   [socr]                        AS [KladrSocr],
	   [index]                       AS [KladrIndex],
	   [gninmb]                      AS [KladrGninmd],
	   [uno]                         AS [KladrUno],
	   [ocatd]                       AS [KLadrOkatd]
FROM kladr.[Street]
WHERE (RIGHT([code], 2) = N'00')
GO
/****** Object:  View [kladr].[v_CheckAltNames]    Script Date: 04.07.2024 21:22:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****** Скрипт для команды SelectTopNRows из среды SSMS  ******/
CREATE VIEW [kladr].[v_CheckAltNames]
AS
SELECT [Pid],
       [OldCode],
       [NewCode],
       [Level],
	   HASHBYTES('SHA2_256', CONCAT([OldCode], [NewCode], [Level])) AS [Check]
  FROM [kladr2].[kladr].[AltNames]
GO
/****** Object:  View [kladr].[v_CheckDoma]    Script Date: 04.07.2024 21:22:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Скрипт для команды SelectTopNRows из среды SSMS  ******/
CREATE VIEW [kladr].[v_CheckDoma]
AS
SELECT [Code],
       [Name],
       [Korp],
       [Socr],
       [Index],
       [Gninmb],
       [Uno],
       [Ocatd],
	   HASHBYTES('SHA2_256', 
			CONCAT([Code], [Name], [Korp], [Socr], [Index], [Gninmb], [Uno], [Ocatd])
	    ) AS [Check]
  FROM [kladr2].[kladr].[Doma]
GO
/****** Object:  View [kladr].[v_CheckKladr]    Script Date: 04.07.2024 21:22:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Скрипт для команды SelectTopNRows из среды SSMS  ******/
CREATE VIEW [kladr].[v_CheckKladr]
AS
SELECT [Code],
       [Name],
       [Socr],
       [Index],
       [Gninmb],
       [Uno],
       [Ocatd],
       [Status],
	   HASHBYTES(
		'SHA2_256', CONCAT([Code], [Name], [Socr], [Index], [Gninmb], [Uno], [Ocatd], [Status])
		) AS [check]
  FROM [kladr2].[kladr].[Kladr]
GO
/****** Object:  View [kladr].[v_CheckNameMap]    Script Date: 04.07.2024 21:22:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Скрипт для команды SelectTopNRows из среды SSMS  ******/
CREATE VIEW [kladr].[v_CheckNameMap]
AS
SELECT [Code],
       [Name],
       [ShName],
       [ScName],
	   HASHBYTES('SHA2_256', 
			CONCAT([Code], [Name], [ShName], [ScName])
		) AS [Check]
  FROM [kladr2].[kladr].[NameMap]
GO
/****** Object:  View [kladr].[v_CheckSocrBase]    Script Date: 04.07.2024 21:22:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****** Скрипт для команды SelectTopNRows из среды SSMS  ******/
CREATE VIEW [kladr].[v_CheckSocrBase]
AS
SELECT [Pid],
       [Level],
       [ScName],
       [SocrName],
       [KodTST],
	   HASHBYTES('SHA2_256', CONCAT([Level], [ScName], [SocrName], [KodTST])) AS [check]
  FROM [kladr2].[kladr].[SocrBase]
GO
/****** Object:  View [kladr].[v_CheckStreet]    Script Date: 04.07.2024 21:22:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****** Скрипт для команды SelectTopNRows из среды SSMS  ******/
CREATE VIEW [kladr].[v_CheckStreet]
AS
SELECT [Code],
       [Name],
       [Socr],
       [Index],
       [Gninmb],
       [Uno],
       [Ocatd],
	   HASHBYTES(
		'SHA2_256', CONCAT([Code], [Name], [Socr], [Index], [Gninmb], [Uno], [Ocatd])
		) AS [Check]
  FROM [kladr2].[kladr].[Street]
GO
/****** Object:  View [kladr].[v_CompareAltNames]    Script Date: 04.07.2024 21:22:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [kladr].[v_CompareAltNames]
AS
SELECT b.[OldCode] AS [baseOldCode], 
       b.[NewCode] AS [baseNewCode], 
	   b.[Level] AS [baseLevel], 
	   b.[Check] AS [baseCheck],
	   c.[OldCode] AS [currentOldCode], 
       c.[NewCode] AS [currentNewCode], 
	   c.[Level] AS [currentLevel], 
	   c.[Check] AS [currentCheck]
FROM [kladr].[t_AltNames_Base] b
FULL JOIN [kladr].[t_AltNames_Current] c ON c.[Check] = b.[Check]
WHERE (b.[Check] IS NULL) OR (c.[Check] IS NULL);
GO
/****** Object:  View [kladr].[v_CompareDoma]    Script Date: 04.07.2024 21:22:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [kladr].[v_CompareDoma]
AS
SELECT b.[Code] AS [baseCode],
       b.[Name] AS [baseName],
       b.[Korp] AS [baseKorp],
       b.[Socr] AS [baseSocr],
       b.[Index] AS [baseIndex],
       b.[Gninmb] AS [baseGninmb],
       b.[Uno] AS [baseUno],
       b.[Ocatd] AS [baseOcatd],
       b.[Check] AS [baseCheck],

	   c.[Code] AS [currentCode],
       c.[Name] AS [currentName],
       c.[Korp] AS [currentKorp],
       c.[Socr] AS [currentSocr],
       c.[Index] AS [currentIndex],
       c.[Gninmb] AS [currentGninmb],
       c.[Uno] AS [currentUno],
       c.[Ocatd] AS [currentOcatd],
       c.[Check] AS [currentCheck]

FROM [kladr].[t_Doma_Base] b
FULL JOIN [kladr].[t_Doma_Current] c ON c.[Check] = b.[Check]
WHERE (b.[Check] IS NULL) OR (c.[Check] IS NULL);
GO
