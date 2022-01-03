# PS-Log4J-finder
Powershell + Findstr script to detect potentially exploitable log4j 2.x.x (will not detect 1.x versions) and send the results to Graylog.


This scans all local drives for .jar,.war,.dll, and .ear files for strings containing "JndiLookup.class" per CVE-2021-44228. 
Patched versions include Log4j 2.17.1 (Java 8), 2.12.4 (Java 7) and 2.3.2 (Java 6); these will still be detected by this script.

Current mitigation for CVE-2021-44228 impacted versions to delete the class file (org/apache/logging/log4j/core/lookup/JndiLookup.class) completely from the jar/container file. 

See nist/cisa for latest guidence:
https://nvd.nist.gov/vuln/detail/CVE-2021-44228
https://www.cisa.gov/uscert/apache-log4j-vulnerability-guidance

Now has a version to send the results as log files to a shared network location instead of Graylog. 

Both versions include escaped and minimized versions designed to be able to run as a scheduled task. 
Personally I deployed this as a scheduled task via GPO running under system. 

The Graylog ip and ports need to be filled in on the graylog version.
The Shared Network version needs the network path filled in.
