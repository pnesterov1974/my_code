import sqla

def main():
    s = sqla.DbEngine
    s.reinit_engine_with_URL_create(
        #driver_str='mssql+pymssql',
        driver_str='mssql+pyodbc',
        #driver_str='mssql+aioodbc',
        user_name='sa',
        password='Exptsci123',
        host='192.168.1.78:1433',
        database_name='kladr'
    )
    s.check_dbconn()

# ---------------------------------------------------------------------------------------
if __name__ == '__main__':
    main()