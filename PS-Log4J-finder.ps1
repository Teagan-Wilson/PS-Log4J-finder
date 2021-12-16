$ErrorActionPreference='SILENTLYCONTINUE';

#Delete any previous run finds
del "%TEMP%\log4j1.log";
del "%TEMP%\log4j2.log";
del "%TEMP%\log4j3.log";

#Get all LOCAL drives and scan for log4j string in applicatble file types. 
get-wmiobject win32_volume|? {$_.DriveType-eq3}|% {(Get-Psdrive  $_.DriveLetter[0]).Name}|Foreach {$command='findstr /i /s /m "SocketServer.class JndiLookup.class" {0}:\*.jar >> "%TEMP%\log4j1.log" | findstr /i /s /m "SocketServer.class JndiLookup.class" {0}:\*.war >> "%TEMP%\log4j2.log\"| findstr /i /s /m "SocketServer.class JndiLookup.class" {0}:\*log4j*.dll  >> "%TEMP%\log4j3.log"'-f $_;cmd /c $command};

#Get all finds
$jar=Get-Content -Path ($Env:TEMP + '\log4j1.log');
$war=Get-Content -Path ($Env:TEMP + '\log4j2.log');
$dll=Get-Content -Path ($Env:TEMP + '\log4j3.log');

#Define message class
class GraylogMessage {[string] $short_message;[string] $full_message; [string] $source};

#Check for finds and report status
if($jar+$war+$dll){

$Uri='http://{GRAYLOGIP}:{GRAYLOGPORT}/gelf';
$Headers=@{'Content-Type'='application/json'};
$Message=[GraylogMessage]::New();
$Message.source=$Env:computername;
$Message.short_message='log4j Found';
$Message.full_message=($jar+$war+$dll);
Invoke-WebRequest -Uri $Uri -Method POST -Headers $Headers -Body (ConvertTo-Json $Message)

} else {

$Uri='http://{GRAYLOGIP}:{GRAYLOGPORT}/gelf';
$Headers=@{'Content-Type'='application/json'};
$Message=[GraylogMessage]::New();
$Message.source=$Env:computername;
$Message.short_message='NO LOG4J FOUND';
$Message.full_message=($jar+$war+$dll);
Invoke-WebRequest -Uri $Uri -Method POST -Headers $Headers -Body (ConvertTo-Json $Message)}"
}
