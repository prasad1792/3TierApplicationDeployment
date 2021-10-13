# Runbook used to deploy set of 5 servers for paragon environment version 1502 or higher
# you need to enter the ServerOS parameter either 2012 or 2019

################################################################### 
##                      Input Parameters from user               ##
###################################################################

Param
    (
        
        [parameter(Mandatory=$true)]
        [string]
        $websrv,
        [parameter(Mandatory=$true)]
        [string]
        $connect,

        [parameter(Mandatory=$true)]
        [string]
        $ntier,

        [parameter(Mandatory=$true)]
        [string]
        $svcbus,
    
        [parameter(Mandatory=$true)]
        [string]
        $sqlsrv,

        [parameter(Mandatory=$true)] 
        [String]        
        $DBinstancename,

        [parameter(Mandatory=$true)] 
        [String]
        $SQLServiceAccountName,
        
        [parameter(Mandatory=$true)] 
        [String]
        $SQLServiceAccountPassword,
        
        [parameter(Mandatory=$true)] 
        [String]
        $ReportingServiceAccountName,
        
        [parameter(Mandatory=$true)] 
        [String]
        $ReportingServiceAccountPassword,
        
        [parameter(Mandatory=$true)] 
        [String]        
        $location,
        [parameter(Mandatory=$true)] 
        [String]        
        $virtualMachineRG


    )

################################################################### 
##                       Derived values                          ##
###################################################################
    	


################################################################### 
##                      Login to Azure                           ##
###################################################################

$SubscriptionID = Get-AutomationVariable -Name SubscriptionID
Write-Output "Logging to AzureRMAccount"
$spn = Get-AutomationConnection -Name AzureRunAsConnection
$null = Add-AzureRMAccount  -ServicePrincipal -Tenant $spn.TenantID -ApplicationId $spn.ApplicationID -CertificateThumbprint $spn.CertificateThumbprint
Set-AzureRmContext -SubscriptionId $SubscriptionID
Write-Output "Login Completed with Azure"

################################################################### 
##   Verify and Deploy New Resource Group does not exists        ##
###################################################################

if(!(Get-AzureRmResourceGroup -Name $virtualMachineRG -ErrorAction SilentlyContinue)) {
    New-AzureRmResourceGroup -Name $virtualMachineRG -Location 'eastus' -ErrorAction Stop 
    Write-Output "Deploying new resource group $virtualMachineRG as it is not present"
}

################################################################### 
##      Parameter Declaration for Template Deployment            ##
###################################################################


$location = $location
$sqlsrv = $SQLserverName
$websrv = $webservername
$connect = $connectservername
$ntier = $ntierservername
$svcbus =$servicebusname

$virtualMachineSize = 'Standard_E4s_v3'
$virtualMachineRG = $RGName
$virtualNetworkName = 'VNET1'
$virtualNetworkResourceGroup = 'VNetRG'
# $networkInterfaceName = $virtualMachineName + '-Nic'
$localadminUsername = $localuser
$localadminPassword = $localpwd
$subnetName1 = 'Subnet-1'
$subnetName2 = 'Subnet-2'
$subnetName3 = 'Subnet-3'
$domainname='contoso.com'
$parameters = @{}

$parameters.Add("location",$location)
$parameters.Add("sqlsrv",$SQLserverName)
$parameters.Add("websrv",$webservername)
$parameters.Add("connect",$connectservername)
$parameters.Add("svcbus",$servicebusname)
$parameters.Add("ntier",$ntierservername)

$parameters.Add("virtualMachinesize",$virtualMachineSize)
$parameters.Add("localadminUsername",$localadminUsername)
$parameters.Add("localadminPassword",$localadminPassword)
$parameters.Add("virtualNetworkName",$virtualNetworkName)
$parameters.Add("virtualNetworkResourceGroup",$virtualNetworkResourceGroup)

$parameters.Add("subnetName1",$subnetName1)
$parameters.Add("subnetName2",$subnetName2)
$parameters.Add("subnetName3",$subnetName3)


$parameters.Add("virtualMachineRG",$virtualMachineRG)
$parameters.Add("domainname",$domainname)
$parameters.Add("DomUsername",$DomUserName)
$parameters.Add("DomPassword",$DomPassword)




$saname='contososa'
$sarg='contososarg'
$sacontainer='allbuildssetup'
$safileshare ='envbuild'
$templateblob='3tierEnvironment.Json'
$saKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $sarg -Name $saname)[0].Value
$context = New-AzureStorageContext -StorageAccountName $saname -StorageAccountKey $saKey

$templateURI = New-AzureStorageBlobSASToken `
    -Container $sacontainer `
    -Blob $templateblob `
    -Permission r `
    -ExpiryTime (Get-Date).AddHours(2.0) `
    -Context $context -FullUri


################################################################### 
##                    Deploy VM from Template                    ##
################################################################### 

Write-Output "Deploying new VM from Template"

New-AzureRmResourceGroupDeployment -Name $DeploymentName  -ResourceGroupName $virtualMachineRG -TemplateUri $templateuri -TemplateParameterObject $parameters


###################################################################
##              Post Build Installation                         ##
###################################################################

Set-AzureRmVMCustomScriptExtension -ResourceGroupName $RGName -VMName $webservername -Name 'Web-Install' -Location $location -StorageAccountName $saname -StorageAccountKey $saKey -FileName "WebInstall.ps1" -ContainerName "allbuildssetup" -RunFile "WebInstall.ps1"

Write-Output "WebServer is now ready. You can access the $VMName and verify all the settings"

Set-AzureRmVMCustomScriptExtension -ResourceGroupName $RGName -VMName $ntierservername -Name 'nsc-Install' -Location $location -StorageAccountName $saname -StorageAccountKey $saKey -FileName "nsc-Install.ps1" -ContainerName "allbuildssetup" -RunFile "nsc-Install.ps1"

Write-Output "Ntier Server is now ready. You can access the $VMName and verify all the settings"

Set-AzureRmVMCustomScriptExtension -ResourceGroupName $RGName -VMName $servicebusname -Name 'nsc-Install' -Location $location -StorageAccountName $saname -StorageAccountKey $saKey -FileName "nsc-Install.ps1" -ContainerName "allbuildssetup" -RunFile "nsc-Install.ps1"

Write-Output "ServiceBus Server is now ready. You can access the $VMName and verify all the settings"

Set-AzureRmVMCustomScriptExtension -ResourceGroupName $RGName -VMName $connectservername -Name 'nsc-Install' -Location $location -StorageAccountName $saname -StorageAccountKey $saKey -FileName "nsc-Install.ps1" -ContainerName "allbuildssetup" -RunFile "nsc-Install.ps1"

Write-Output "Connect Server is now ready. You can access the $VMName and verify all the settings"

Set-AzureRmVMCustomScriptExtension -ResourceGroupName $RGName -VMName $SQLserverName -Name 'SQL-Install' -Location $location -StorageAccountName $saname -StorageAccountKey $saKey -FileName "SQL-SSRS.ps1" -ContainerName "allbuildssetup" -RunFile "SQL-SSRS.ps1" -Argument "$DBinstancename $reportinginstance $SQLServiceAccountName $SQLServiceAccountPassword $ReportingServiceAccountName $ReportingServiceAccountPassword" 

Write-Output "SQL Server is now ready. You can access the $VMName and verify all the settings"
