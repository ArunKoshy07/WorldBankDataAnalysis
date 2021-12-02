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

1. Install Python (version 3 or above). once the python is installed run the following pip command to 
install the package 'pip install -r requirements.txt'

2. run the python script extractGdpData.py to extract the data from the end points 




### To Run above as a notebook in a container 
Docker compose commands to be run to start two containers one for jupyter server and other for postgresql db. 
the command to be run on the terminal is  'docker-compose up'

access the link 'localhost:8888' through the browser for jupyter notebook. 
the python notebooks availbale in the notebooks folder is made available on the notebook session. 

Inorder to stop and kill the containers, please press "Ctrl+c" on the terminal to end the session 
and followed by "docker-compose down" to kill the containers. 