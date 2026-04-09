CREATE SCHEMA [RedShift_hsbc_vi]
    AUTHORIZATION [dbo];




GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[RedShift_hsbc_vi] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_RO];


GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[RedShift_hsbc_vi] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_Internal_RO];


GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[RedShift_hsbc_vi] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_Internal_QA_RO];


GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[RedShift_hsbc_vi] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_Internal_Access];

