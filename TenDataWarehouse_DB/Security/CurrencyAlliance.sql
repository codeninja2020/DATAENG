CREATE SCHEMA [CurrencyAlliance]
    AUTHORIZATION [dbo];




GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[CurrencyAlliance] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_RO];


GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[CurrencyAlliance] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_Internal_RO];


GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[CurrencyAlliance] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_Internal_QA_RO];


GO
GRANT VIEW CHANGE TRACKING
    ON SCHEMA::[CurrencyAlliance] TO [TENUK\DB_LDCSQLPD22_TenDataWarehouse_Internal_Access];

