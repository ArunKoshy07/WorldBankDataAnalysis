import requests
import json
from sqlalchemy import create_engine, exc
import pandas as pd
from configparser import ConfigParser
import psycopg2


def get_api_results(endpoint):
 
    response = requests.get(endpoint,timeout=20)
    response = response.json()
    return_lst = response[1]

    while response[0]['page']<response[0]['pages']:
        endpoint_pg = f"{endpoint}&page={int(response[0]['page'])+1}"
        response = requests.get(endpoint_pg,timeout=20)
        response = response.json()
        return_lst = return_lst + response[1]
    return pd.json_normalize(return_lst)

def read_csv(filename):
    return pd.read_csv(filename)

def get_config(filename='database.ini', section='postgresql'):
    # create a parser
    parser = ConfigParser()
    # read config file
    parser.read(filename)

    # get section, default to postgresql
    db = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            db[param[0]] = param[1]
    else:
        raise Exception('Section {0} not found in the {1} file'.format(section, filename))

    return db



def connect_db():
    """ Connect to the PostgreSQL database server """
    conn = None
    engine = create_engine
    try:
        # read connection parameters
        params = get_config()
        
        connect = "postgresql+psycopg2://%s:%s@%s:5432/%s" % (
                    params['user'],
                    params['password'],
                    params['host'],
                    params['database']
                    )
        engine = create_engine(connect)
    except (exc.SQLAlchemyError) as error:
        print(error)

    return engine

def write_to_db(df,engine,tableName):
    df.to_sql(
        tableName, 
        con=engine, 
        index=False, 
        if_exists='replace'
    )

def main():
    worldbank_gdp_df = get_api_results("http://api.worldbank.org/v2/country?format=json")
    worldbank_catl_gep_df = read_csv("./Data/GEPData.csv")
    worldbank_gdp_df.columns = worldbank_gdp_df.columns.str.replace(".", "", regex=True)
    worldbank_catl_gep_df.columns = worldbank_catl_gep_df.columns.str.replace(' ','')

    worldbank_gdp_df.to_csv('./Data/worldbankgdp.csv')          

    worldbank_gdp_cnty_df = worldbank_gdp_df.loc[worldbank_gdp_df['regionid']!='NA']
    worldbank_gdp_regn_df = worldbank_gdp_df.loc[worldbank_gdp_df['regionid']=='NA']
     
    engine = connect_db()
    
    worldbank_gdp_cnty_df.to_sql(
        'worldBankGdpCnty', 
        con=engine, 
        index=False, 
        if_exists='replace'
    )
    
    worldbank_gdp_regn_df.to_sql(
        'worldBankGdpRegn', 
        con=engine, 
        index=False, 
        if_exists='replace'
    )
    worldbank_catl_gep_df.to_sql(
        'worldBankDataCatalogueGep', 
        con=engine, 
        index=False, 
        if_exists='replace'
    )

if __name__ == "__main__":
    main()