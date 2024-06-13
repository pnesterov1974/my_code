from sqlalchemy import create_engine, URL, text

class DbEngine:
    CONN_STR = ''
    ENGINE = None

    @classmethod
    def reinit_engine_with_connstr(cls, conn_string: str):
        cls.CONN_STR = conn_string
        cls._reinit_engine()

    @classmethod
    def _reinit_engine(cls):
        cls.ENGINE = create_engine(cls.CONN_STR, isolation_level="READ COMMITTED", echo=False)

    # @classmethod
    # def reinit_engine_with_driver(cls, driver_str: str, server_db_str: str):
    #     valid_server_db_strs = ['mssql+pyodbc', 'mssql+pymssql']
    #     if server_db_str in valid_server_db_strs:
    #         cls.CONN_STR = f"{driver_str}://{server_db_str}"
    #         cls.ENGINE = create_engine(cls.CONN_STR, isolation_level="READ COMMITTED", echo=False)
    #     else:
    #         raise Exception(f'Не верная строка {driver_str}, необходима {valid_server_db_strs}')
    
    # @classmethod
    # def reinit_engine_with_URL_create(
    #     cls, driver_str: str, user_name: str, password: str, host: str, database_name: str
    #     ):
    #     cls.CONN_STR = URL.create(
    #         drivername=driver_str,
    #         username=user_name,
    #         password=password,  # plain (unescaped) text
    #         host=host,
    #         database=database_name
    #     )
    #     cls.ENGINE = create_engine(cls.CONN_STR, isolation_level="READ COMMITTED", echo=False)

    # @classmethod
    # def check_dbconn(cls):
    #     with cls.ENGINE.connect() as conn:
    #         result = conn.execute(text("select 'hello world'"))
    #         r = result.fetchone()
    #         print(r)

    # ---------------------------
    @classmethod
    def reinit_pymssql_with_ad(cls, host: str, database_name: str):
        cls.CONN_STR = URL.create(
            drivername='mssql+pymssql',
            host=host,
            database=database_name
        )
        cls._reinit_engine()

    @classmethod
    def reinit_pymssql_without_ad(cls, host: str, database_name: str, user_name: str, password: str):
        cls.CONN_STR = URL.create(
            drivername='mssql+pymssql',
            username=user_name,
            password=password,  # plain (unescaped) text
            host=host,
            database=database_name
        )
        cls._reinit_engine()

    @classmethod
    def reinit_pyodbc_without_ad(cls, host: str, database_name: str, user_name: str, password: str):
        # cls.CONN_STR = URL.create(
        #     drivername='mssql+pymssql',
        #     username=user_name,
        #     password=password,  # plain (unescaped) text
        #     host=host,
        #     database=database_name
        # )
        cls._reinit_engine()

# URL create - pymssql ad auth and noAD auth
# URL create - pyodbc the same -> watch pl

# ---------------------------------------------------------------------------------------
if __name__ == '__main__':pass