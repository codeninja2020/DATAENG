CREATE SCHEMA [RedShift_scotia_evasion]
    AUTHORIZATION [dbo];




GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[RedShift_scotia_evasion] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_RO];


GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[RedShift_scotia_evasion] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_Internal_RO];


GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[RedShift_scotia_evasion] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_Internal_QA_RO];


GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[RedShift_scotia_evasion] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_Internal_Access];

