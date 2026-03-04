IF COL_LENGTH('[TenMAID_Global].[Members]','Reference5') IS NULL
BEGIN
    ALTER TABLE [TenMAID_Global].[Members]
    ADD [Refrence5] NVARCHAR(255) NULL;
END;

IF COL_LENGTH('[TenMAID_Global].[Members]','Reference6') IS NULL
BEGIN
    ALTER TABLE [TenMAID_Global].[Members]
    ADD [Refrence6] NVARCHAR(3000) NULL;
END;

