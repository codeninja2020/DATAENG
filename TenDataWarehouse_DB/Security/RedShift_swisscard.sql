CREATE SCHEMA [RedShift_swisscard]
    AUTHORIZATION [dbo];




GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[RedShift_swisscard] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_RO];


GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[RedShift_swisscard] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_Internal_RO];


GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[RedShift_swisscard] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_Internal_QA_RO];


GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[RedShift_swisscard] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_Internal_Access];

