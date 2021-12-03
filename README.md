# World Bank Data Analysis Repo
### World bank gdp data analysis of countries - 
This repo uses the publicly available data at the World Bank websites for analysis.  
Two datasets are used for this analysis,

1. First dataset is the information about countries and its documentation available through 
World Bank API from the link
 https://datahelpdesk.worldbank.org/knowledgebase/articles/898590-api-country-queries

2. Second dataset the Gross Domestic Product (GDP) data in CSV format available for download 
from World Bank Data Catalog available at 
https://datacatalog.worldbank.org/dataset/global-economic-prospects

### To run the scripts as standalone tasks

1. Install Python version 3 or above from [python.org](https://docs.python.org/3/using/index.html). Once python is installed run the following pip command to 
install the package 

```
pip install -r requirements.txt
```

2. update the database.ini file to point to the postgres sql db on your machine. if not installed please 
follow this link https://www.postgresql.org/download/ to install postgressql locally.  

3. run the python script extractGdpData.py to extract the data from the end points 

```
python extractGdpData.py
```

4. the postgresql queries are provide in the postgreSqlScripts.sql file. 

### To run as a notebook in a container 

Docker and Docker compose is used to run the containers. Docker compose command is to be 
executed to start the two containers one for jupyter server and other for postgresql db. 
the command to be run on the terminal from the repo folder is 

```
docker-compose up
```

Docker compose startup logs on the terminal will provide the link to access the jupyter instance via browser. 

```
worldbankdataanalysis-jupyter-1   |     Or copy and paste one of these URLs:
worldbankdataanalysis-jupyter-1   |         http://65eb15cb8a18:8888/?token=7544c0c1fbb..........41b9b77b846485945
worldbankdataanalysis-jupyter-1   |      or http://127.0.0.1:8888/?token=7544c0........77b846485945 
```

access jupyter notebook using the link through the browser. the python notebooks availbale in the notebooks folder 
is made available on the notebook session. 

Inorder to stop and kill the containers, please press '''Ctrl+c''' on the terminal to end the session 
and followed by the below command to kill the containers. 

```
docker-compose down
```

the notebook output has been saved as a pdf in this repo for refeference (worldbankdataanalysis_ipynb.pdf)