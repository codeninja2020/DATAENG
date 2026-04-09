CREATE SCHEMA [RedShift_scotia_pursuits]
    AUTHORIZATION [dbo];




GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[RedShift_scotia_pursuits] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_RO];


GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[RedShift_scotia_pursuits] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_Internal_RO];


GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[RedShift_scotia_pursuits] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_Internal_QA_RO];


GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[RedShift_scotia_pursuits] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_Internal_Access];

