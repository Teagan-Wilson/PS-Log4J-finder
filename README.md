# PS-Log4J-finder
Powershell + Findstr script to detect potentially exploitable log4j 2.x.x (will not detect 1.x versions) and send the results to Graylog.


This scans all local drives for .jar,.war,.dll, and .ear files for strings containing "JndiLookup.class" per CVE-2021-44228. 
Note that CVE-2021-44228 is resolved in 2.8.16. 

Current mitigation for CVE-2021-44228 versions below 2.16.0 is to delete the class file (org/apache/logging/log4j/core/lookup/JndiLookup.class) completely from the jar/container file. 

See nist/cisa for latest guidence:
https://nvd.nist.gov/vuln/detail/CVE-2021-44228
https://www.cisa.gov/uscert/apache-log4j-vulnerability-guidance

Now has a version to send the results as log files to a shared network location instead of Graylog. 

Both versions include escaped and minimized versions designed to be able to run as a scheduled task. 
Personally I deployed this as a scheduled task via GPO running under system. 
