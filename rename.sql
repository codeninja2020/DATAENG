IF COL_LENGTH('[TenMAID_Global].[Members]','Reference5') IS NULL
BEGIN
    EXEC sp_rename '[TenMAID_Global].[Members].Refrence5', 
    'Reference5', 'COLUMN';
END;

IF COL_LENGTH('[TenMAID_Global].[Members]','Reference6') IS NULL
BEGIN
    EXEC sp_rename '[TenMAID_Global].[Members].Refrence6', 
    'Reference6', 'COLUMN';
END;

