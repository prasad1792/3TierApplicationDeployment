Install-WindowsFeature -name Web-Server -IncludeManagementTools
SET-ITEMPROPERTY HKLM:\software\microsoft\MSDTC\security -name "networkdtcaccess" -value "1" -ErrorAction Stop
SET-ITEMPROPERTY HKLM:\software\microsoft\MSDTC\security -name "networkdtcaccessadmin" -value "1" -ErrorAction Stop
SET-ITEMPROPERTY HKLM:\software\microsoft\MSDTC\security -name "networkdtcaccessinbound" -value "1" -ErrorAction Stop
SET-ITEMPROPERTY HKLM:\software\microsoft\MSDTC\security -name "networkdtcaccessoutbound" -value "1" -ErrorAction Stop
SET-ITEMPROPERTY HKLM:\software\microsoft\MSDTC\security -name "networkdtcaccesstransactions" -value "1" -ErrorAction Stop
SET-ITEMPROPERTY HKLM:\software\microsoft\MSDTC\security -name "XAtransactions" -value "1" -ErrorAction Stop
SET-ITEMPROPERTY HKLM:\software\microsoft\MSDTC\security -name "LuTransactions" -value "1" -ErrorAction Stop
SET-ITEMPROPERTY HKLM:\software\microsoft\MSDTC -name "turnoffrpcsecurity" -value "1" -ErrorAction Stop
SET-ITEMPROPERTY HKLM:\software\microsoft\MSDTC -name "AllowonlySecureRPCCalls" -value "0" -ErrorAction Stop