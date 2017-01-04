Option Explicit
On Error Resume Next

Dim wsh
Dim baseKey
Dim regKey
Dim regVal

Set wsh = CreateObject("WScript.Shell")

baseKey = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Inetinfo\Parameters\"

regKey = baseKey & "DisableMemoryCache"
regVal =  wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

regKey = baseKey & "MaxCachedFileSize"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

regKey = baseKey & "MemCacheSize"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

regKey = baseKey & "ObjectCacheTTL"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

regKey = baseKey & "PoolThreadLimit"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

regKey = baseKey & "MaxPoolThreads"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

regKey = baseKey & "ListenBackLog"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

baseKey = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\"
regKey = baseKey & "ServerCacheTime"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

baseKey = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem\"
regKey = baseKey & "NtfsDisable8dot3NameCreation"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

regKey = baseKey & "NtfsDisableLastAccessUpdate"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

regKey = baseKey & "NtfsMftZoneReservation"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

baseKey = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\"
regKey = baseKey & "DisablePagingExecutive"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

regKey = baseKey & "PagedPoolSize"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

regKey = baseKey & "SystemPages"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

regKey = baseKey & "IoPageLockLimit"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

regKey = baseKey & "LargeSystemCache"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

regKey = baseKey & "DontVerifyRandomDrivers"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

baseKey = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\RpcXdr\Parameters\"
regKey = baseKey & "DefaultNumberofWorkerThreads"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

baseKey = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Executive\"
regKey = baseKey & "AdditionalDelayedWorkerThreads"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

regKey = baseKey & "AdditionalCriticalWorkerThreads"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

baseKey = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\"
regKey = baseKey & "TCPWindowSize"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

regKey = baseKey & "TCPTimedWaitDelay"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

regKey = baseKey & "MaxUserPort"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

regKey = baseKey & "MaxHashTableSize"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal

regKey = baseKey & "NumTcbTablePartitions"
regVal = wsh.RegRead (regKey)
WScript.Echo regKey & " = " & regVal