Param 
      (
      
        
        [parameter(Mandatory=$true)] 
        [String]        
        $DBinstancename,
        
        [parameter(Mandatory=$true)] 
        [String]        
        $reportinginstance,
        
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
        $ReportingServiceAccountPassword

)

if (-not (Test-Path $path))
{
net localgroup administrators CLOUD\sqlsvrsvc /add
Get-Disk | Where-Object Number -eq '2' | Initialize-Disk -PartitionStyle GPT -PassThru -confirm:$false | New-Partition -DriveLetter F  -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "SQLDrive" -Confirm:$false
Get-Disk | Where-Object Number -eq '3' | Initialize-Disk -PartitionStyle GPT -PassThru -confirm:$false | New-Partition -DriveLetter G  -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "EnvDatabases" -Confirm:$false
New-Item -Path "F:\" -Name "SQLData" -ItemType "directory"
New-Item -Path "G:\" -Name "Data" -ItemType "directory"
New-Item -Path "G:\" -Name "Logs" -ItemType "directory"
New-Item -Path "C:\" -Name "cert" -ItemType "directory"
New-Item -Path "C:\" -Name "SQLPostConfigScripts" -ItemType "directory"
DISM /Online /Enable-Feature /FeatureName:NetFx3 /All
write-output "SQL Server Installation source $sourceFolder"


$connectTestResult = Test-NetConnection -ComputerName contososa.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"paragonsysengsa.file.core.windows.net`" /user:`"Azure\contososa`" /pass:`"PQbVQ1/3CoBGjtTizQj++grJOmiWvWDXho+vzSnwByOkLs6wD3RTEcdy0bFM1RyYBlH+40N/RbWojkImgmIyTQ==`""
    # Mount the drive
    New-PSDrive -Name Z -PSProvider FileSystem -Root "\\contososa.file.core.windows.net\sqlbuild" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}

cd Z:
cd "SQL2019\en_sql_server_2019_enterprise_x64_dvd_cdcd4b9f"
./Setup.exe /ACTION=INSTALL /CONFIGURATIONFILE=ConfigurationFile.ini /INSTANCENAME="$DBinstancename" /INSTANCEID="$DBinstancename" /AGTSVCACCOUNT="$SQLServiceAccountName" /AGTSVCPASSWORD="$SQLServiceAccountPassword" /SQLSVCACCOUNT="$SQLServiceAccountName" /SQLSVCPASSWORD="$SQLServiceAccountPassword" /SQLSYSADMINACCOUNTS="$SQLSYSADMINAccountName" /INDICATEPROGRESS /IAcceptSQLServerLicenseTerms=true
Start-Sleep -Seconds 240
cd\
cd SQL2019
.\SQLServerReportingServices.exe /passive /norestart /IAcceptLicenseTerms /PID=HMWJ3-KY3J2-NMVD7-KG4JR-X2G8G
Start-Sleep -Seconds 120
.\SSMS-Setup-ENU_18.4.exe /install /quiet /passive /norestart
Start-Sleep -Seconds 240
cd \SQL2019\CU3
.\SQLServer2019-KB4538853-x64.exe /ACTION=INSTALL /ALLINSTANCES /ENU /IACCEPTSQLSERVERLICENSETERMS /QS
Start-Sleep -Seconds 180

cd C:
cd C:\SQLPostConfigScripts
.\Server_Modern_FireAMPSetup.exe /S /desktopicon 0 /startmenu 0 /D="C:\Program Files\Cisco\AMP"
shutdown -r -t 00

Exit
}