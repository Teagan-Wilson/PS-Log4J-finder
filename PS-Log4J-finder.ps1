$ErrorActionPreference='SILENTLYCONTINUE';

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

#Define message class
class GraylogMessage {[string] $short_message;[string] $full_message; [string] $source};

#Check for finds and report status
if($jar+$war+$dll+$ear){

$Uri='http://10.3.20.46:12001/gelf';
$Headers=@{'Content-Type'='application/json'};
$Message=[GraylogMessage]::New();
$Message.source=$Env:computername;
$Message.short_message='log4j Found';
$Message.full_message=($jar+$war+$dll+$ear);
Invoke-WebRequest -Uri $Uri -Method POST -Headers $Headers -Body (ConvertTo-Json $Message)

} else {

$Uri='http://10.3.20.46:12001/gelf';
$Headers=@{'Content-Type'='application/json'};
$Message=[GraylogMessage]::New();
$Message.source=$Env:computername;
$Message.short_message='NO LOG4J FOUND';
$Message.full_message=($jar+$war+$dll+$ear);
Invoke-WebRequest -Uri $Uri -Method POST -Headers $Headers -Body (ConvertTo-Json $Message)}

