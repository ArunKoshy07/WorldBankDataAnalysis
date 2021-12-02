import requests, os
from sqlalchemy import create_engine, exc
import pandas as pd
from configparser import ConfigParser
import psycopg2
import urllib
import zipfile


def get_api_results(endpoint):
    """
    Function to query a api endpoint and converts the results to a json.
    the json data is converted to pandas dataframe before its returned.

    params:
      endpoint (String) - the api endpoint link
    return:
      Dataframe (pandas dataframe) - returns the api results as pandas dataframe.
    """
    response = requests.get(endpoint, timeout=20)
    response = response.json()
    return_lst = response[1]

    while response[0]["page"] < response[0]["pages"]:
        endpoint_pg = f"{endpoint}&page={int(response[0]['page'])+1}"
        response = requests.get(endpoint_pg, timeout=20)
        response = response.json()
        return_lst = return_lst + response[1]
    return pd.json_normalize(return_lst)


def get_csv_data(csv_endpoint, filename):
    """
    Function downloads a zip file from the api endpoint. The zip file is extracted and the files are stored to
    a local folder. The requested csv file is read and is converted to a pandas dataframe before returning it.

    params:
      csv_endpoint (String) - the api endpoint link for the zip file
      filename (String)     - csv filename in the format <filename>.csv
    return:
      Dataframe (pandas dataframe) - returns the csv data as a pandas dataframe.
    """
    zip_path, _ = urllib.request.urlretrieve(csv_endpoint)
    with zipfile.ZipFile(zip_path, "r") as f:
        f.extractall("./data")

    return pd.read_csv(f"./data/{filename}")


def get_db_engine(filename="database.ini", section="postgresql"):
    """
    This function reads database properties file and extracts the postgres db properties. It then creates
    a database engine using these properties and returns the same.

    params
      filename (String) - database properties file (default value is database.ini)
      section (String) - its the section in the properties file that needs to be read (default value is postgresql)
    return
      database engine  - returns a database engine object.
    """
    parser = ConfigParser()

    # read config file
    parser.read(filename)

    # get section, default to postgresql
    params = {}
    if parser.has_section(section):
        params_ext = parser.items(section)
        for param in params_ext:
            params[param[0]] = param[1]
    else:
        raise Exception(
            "Section {0} not found in the {1} file".format(section, filename)
        )

    # intialise the engine variable
    engine = create_engine

    try:

        connect = "postgresql+psycopg2://%s:%s@%s:5432/%s" % (
            params["user"],
            params["password"],
            params["host"],
            params["database"],
        )
        engine = create_engine(connect)
    except (exc.SQLAlchemyError) as error:
        print(error)

    return engine


def write_to_db(df, engine, tableName):
    """
    This function writes the pandas dataframe to the database using the db engine object passed as a
    parameter. The table is replaced evertime its called.

    parameters:
      df (pandas dataframe) : dataframe to be written to the database
      engine(db engine)     : db engine object to write to the database
      tableName(String)     : table name
    """
    df.to_sql(tableName, con=engine, index=False, if_exists="replace")


def main(gdp_api, catl_api, catl_file):
    """
    This is the main funtion which does the data extraction, transformation and loading to database.
    it call various other sub functions to carry these steps.

    parameters:
      gdp_api (endpoint)   : endpoint to world bank gdp API
      catl_api(endpoint)   : endpoint to world bank catalogue data.
      catl_file(String)    : world bank catalogue data file name.
    """

    # Extract the datasets from the API endpoints and conver them to pandas dataframe
    worldbank_gdp_df = get_api_results(gdp_api)
    worldbank_catl_gep_df = get_csv_data(catl_api, catl_file)

    # format the dataframe column names to remove spaces and dots.
    worldbank_gdp_df.columns = worldbank_gdp_df.columns.str.replace(".", "", regex=True)
    worldbank_catl_gep_df.columns = worldbank_catl_gep_df.columns.str.replace(" ", "")

    # write the gdp data to the local folder
    worldbank_gdp_df.to_csv("./data/worldbankgdp.csv")

    # Split the the gdp data into countries and regions.
    worldbank_gdp_cnty_df = worldbank_gdp_df.loc[worldbank_gdp_df["regionid"] != "NA"]
    worldbank_gdp_regn_df = worldbank_gdp_df.loc[worldbank_gdp_df["regionid"] == "NA"]

    # Create a postgres db engine using the properties in the database.ini file
    engine = get_db_engine()

    # write the dataframes to the postgres database.
    write_to_db(worldbank_gdp_cnty_df, engine, "worldBankGdpCnty")
    write_to_db(worldbank_gdp_regn_df, engine, "worldBankGdpRegn")
    write_to_db(worldbank_catl_gep_df, engine, "worldBankDataCatalogueGep")
    print("Data Successfully extracted, transformed and loaded to the database")


if __name__ == "__main__":

    # Get the endpoints and filename from the terminal
    gdp_api = os.getenv("WB_GDP_API", "http://api.worldbank.org/v2/country?format=json")
    catl_api = os.getenv(
        "WB_CATL_API", "https://databank.worldbank.org/data/download/GEP_CSV.zip"
    )
    catl_file = os.getenv("WB_CATL_FILE", "GEPData.csv")

    # call the main funtion to extract, transform and write the data to the database
    main(gdp_api, catl_api, catl_file)
