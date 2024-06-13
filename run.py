import sqla

def _main():
    s = sqla.DbEngine
    # s.reinit_engine_with_URL_create(
    #     driver_str='mssql+pymssql',
    #     #driver_str='mssql+pyodbc',
    #     #driver_str='mssql+aioodbc',
    #     #user_name='sa',
    #     #password='Exptsci123',
    #     host='PIF1-DB-T-01',
    #     database_name='master'
    # )
    #s.reinit_engine_with_connstr('mssql+pymssql://PIF1-DB-T-01/fst')
    s.check_dbconn()

def main():
    s = sqla.DbEngine
    # try with AD
    s.reinit_pymssql_with_ad(
        host='PIF1-DB-T-01',
        database_name='master'
    )
    s.check_dbconn()
    # try without AD
    s.reinit_pymssql_without_ad(
        host='PIF1-DB-T-01',
        database_name='master',
        user_name='sa',
        password='Exptsci123'
    )
    s.check_dbconn()

# ---------------------------------------------------------------------------------------
if __name__ == '__main__':
    main()