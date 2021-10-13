# 3TierApplicationDeployment
The repository facilitates to deploy 1 WebServer, 3 Logic Servers & 1 SQL server in Azure Cloud.

-----------------Architecture Description---------------------------------------------------

This template can be used to deploy simple 3 Tier applications for Clinical System.

TIER-1
The system consist of single Web server known as CCS, that acts first point of communication with users through hosted web application.
The web server is exposed to internet on Port 80 & 443 only.

TIER-2
3 Business Logic Servers such as 1 Ntier, 1 Service Bus & 1 Connect that serves different purpose based on user input and requirement.
These servers hosted private subnet and communicates with Web server on private address for specific application ports only.

TIER -3 
SQL Server that stores all clinical data with the help of Database engine.
SQL server communicates with Logic servers on private subnet on allowed ports only.

---------------Assumptions--------------------------------------------------------------

1) All servers will be no 2019 Platform.
2) Web Server will be exposed on Internet for Port 80 & 443 only.
3) All Tier-2 servers will have custom parameters that nee to set.
4) Tier-3 SQL server would be needed to store all data objects.
5) All the servers will exist on Single Virtual Network with each different Subnet for every Tier.
6) Subnetting is already restricted as per Tier communications.
7) A storage account "contososa" already exist & a container called "allbuildsetup" exist to store 3TierEnvironment.Json file.
   a file share called "envbuild" exist and all setup files, installers & script are stored on this share.
8) All server will be in contoso.com domain.


---------------------Execution Details-----------------------------------------------------
1) Pre-requisites : Identify Server Names, Location, SQL Instance Name, Service Account, VirtualMachine Resource Group.

2) Execute the DeployServer.ps1 script. 
   a) DeployServer.ps1  : The script accepts user input & deploy all resources with the help of 3tierEnvironment.json file.
   b) 3tierEnvironment.Json : The JSON file is used to deploy all the above mentioned resources in Azure. No user action neeeded.
   c) Web-Install : The script executes the IIS feature that needs to be installed on WebServer after the server is deployed. No user action needed.
   d) NSC-Install : The script sets the system parameters that is part of requirement on Ntier, Connect & ServiceBus server. No user action needed.
   e) SQL-Install : The script installs SQL 2019 installation silently without any user interaction. No user action needed.
   
 
   
