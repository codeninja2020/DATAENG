
/*
This SQL script checks for null or empty values in the Reference1 column of the Members table for specific SchemeIDs.
This value corresponds with the RPINs
SQL option 
*/

/*SELECT 'Required - Reference1 (Primary member reference) must not be null',   
 MemberID, 'Reference1', Reference1 FROM dbo.Members 
 WHERE SchemeID IN (2388, 2378) AND (Reference1 IS NULL OR LTRIM(RTRIM(Reference1)) = '')*/

SELECT 'Required - Reference1 (Primary member reference) must not be null' AS Error,
     MemberID, 'Reference1' AS Field, Reference1 AS Value FROM dbo.Members
    WHERE SchemeID IN (2388, 2378, 774,2249,2248) AND (Reference1 IS NULL OR LTRIM(RTRIM(Reference1)) = '')


