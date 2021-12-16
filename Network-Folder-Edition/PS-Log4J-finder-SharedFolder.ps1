$ErrorActionPreference='SILENTLYCONTINUE';

#Network location to send files
$networklocation = '\\mis.local\share\testbed\o365installlogs'


#Delete any previous run finds
del "%TEMP%\log4j1.log";
del "%TEMP%\log4j2.log";
del "%TEMP%\log4j3.log";

#Get all LOCAL drives and scan for log4j string in applicatble file types. 
get-wmiobject win32_volume|? {$_.DriveType-eq3}|% {(Get-Psdrive  $_.DriveLetter[0]).Name}|Foreach {$command='findstr /i /s /m "SocketServer.class JndiLookup.class" {0}:\*.jar >> "%TEMP%\log4j1.log" | findstr /i /s /m "SocketServer.class JndiLookup.class" {0}:\*.war >> "%TEMP%\log4j2.log"| findstr /i /s /m "SocketServer.class JndiLookup.class" {0}:\*log4j*.dll  >> "%TEMP%\log4j3.log"'-f $_;cmd /c $command};

#Get all finds
$jar=Get-Content -Path ($Env:TEMP + '\log4j1.log');
$war=Get-Content -Path ($Env:TEMP + '\log4j2.log');
$dll=Get-Content -Path ($Env:TEMP + '\log4j3.log');

#Check for finds and copy files to network location
if($jar){
Get-Content -Path ($Env:TEMP + '\log4j1.log') | Out-file ($networklocation + '\' + $Env:COMPUTERNAME + '-log4j-jar-FOUND.log')
} else {
Get-Content -Path ($Env:TEMP + '\log4j1.log') | Out-file  ($networklocation + '\' + $Env:COMPUTERNAME + '-log4j-jar-NOTF.log')
}
if($war){
Get-Content -Path ($Env:TEMP + '\log4j2.log') | Out-file ($networklocation + '\' + $Env:COMPUTERNAME + '-log4j-war-FOUND.log')
} else {
Get-Content -Path ($Env:TEMP + '\log4j2.log') | Out-file  ($networklocation + '\' + $Env:COMPUTERNAME + '-log4j-war-NOTF.log')
}
if($dll){
Get-Content -Path ($Env:TEMP + '\log4j3.log') | Out-file ($networklocation + '\' + $Env:COMPUTERNAME + '-log4j-dll-FOUND.log')
} else {
Get-Content -Path ($Env:TEMP + '\log4j3.log') | Out-file  ($networklocation + '\' + $Env:COMPUTERNAME + '-log4j-dll-NOTF.log')
}


