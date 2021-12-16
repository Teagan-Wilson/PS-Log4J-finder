$ErrorActionPreference='SILENTLYCONTINUE';

#Network location to send files
$networklocation = '\\server\share'


#Delete any previous run finds
del "$Env:TEMP\log4j1.log" -Force;
del "$Env:TEMP\log4j2.log" -Force;
del "$Env:TEMP\log4j3.log" -Force;
del "$Env:TEMP\log4j4.log" -Force;

#Get all LOCAL drive letters
$drives = get-wmiobject win32_volume|? {$_.DriveType-eq3}|% {(Get-Psdrive  $_.DriveLetter[0]).Name}

#scan for log4j string in applicable file types, ignore anything with Windows or Sophos in the path (some locations were causing findstr to hang)
$drives|Foreach {$command='dir /S /B {0}:\*.jar | findstr /v /i Windows | findstr /v /i Sophos | findstr /i /s /m /F:/ "jndilookup.class" >> "%TEMP%\log4j1.log"'-f $_, $Env:TEMP;cmd /c $command};
$drives|Foreach {$command='dir /S /B {0}:\*.war | findstr /v /i Windows | findstr /v /i Sophos | findstr /i /s /m /F:/ "jndilookup.class" >> "%TEMP%\log4j2.log" '-f $_, $Env:TEMP;cmd /c $command};
$drives|Foreach {$command='dir /S /B {0}:\*log4j*.dll | findstr /v /i Windows | findstr /v /i Sophos | findstr /i /s /m /F:/ "jndilookup.class" >> "%TEMP%\log4j3.log"'-f $_, $Env:TEMP;cmd /c $command};
$drives|Foreach {$command='dir /S /B {0}:\*.ear | findstr /v /i Windows | findstr /v /i Sophos | findstr /i /s /m /F:/ "jndilookup.class" >> "%TEMP%\log4j4.log"'-f $_, $Env:TEMP;cmd /c $command};

#Get all finds
$jar=Get-Content -Path ($Env:TEMP + '\log4j1.log');
$war=Get-Content -Path ($Env:TEMP + '\log4j2.log');
$dll=Get-Content -Path ($Env:TEMP + '\log4j3.log');
$ear=Get-Content -Path ($Env:TEMP + '\log4j4.log');

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
if($ear){
Get-Content -Path ($Env:TEMP + '\log4j4.log') | Out-file ($networklocation + '\' + $Env:COMPUTERNAME + '-log4j-ear-FOUND.log')
} else {
Get-Content -Path ($Env:TEMP + '\log4j4.log') | Out-file  ($networklocation + '\' + $Env:COMPUTERNAME + '-log4j-ear-NOTF.log')
}


