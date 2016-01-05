@echo off
:: Tweaked version of the original script authored by Eric Falsken

IF [%1]==[] GOTO usage
IF NOT "%2"=="" SET server=%2

SC %server% query %1 >NUL
IF errorlevel 1060 GOTO ServiceNotFound
IF errorlevel 1722 GOTO SystemOffline

:ResolveInitialState
SC %server% query %1 | FIND "STATE" | FIND "STOPPED" >NUL
IF errorlevel 0 IF NOT errorlevel 1 GOTO StartService
SC %server% query %1 | FIND "STATE" | FIND "RUNNING" >NUL
IF errorlevel 0 IF NOT errorlevel 1 GOTO StartedService
SC %server% query %1 | FIND "STATE" | FIND "PAUSED" >NUL
IF errorlevel 0 IF NOT errorlevel 1 GOTO SystemOffline
echo Service State is changing, waiting for service to resolve its state before making changes
sc %server% query %1 | Find "STATE" >NUL
ping -n 2 127.0.0.1 > NUL
GOTO ResolveInitialState

:StartService
echo Starting %1 on %server%
sc %server% start %1 >NUL

GOTO StartingService
:StartingServiceDelay
echo Waiting for %1 to start
ping -n 2 127.0.0.1 > NUL 
:StartingService
SC %server% query %1 | FIND "STATE" | FIND "RUNNING" >NUL
IF errorlevel 1 GOTO StartingServiceDelay

:StartedService
echo %1 on %server% is started
GOTO:eof

:SystemOffline
echo Server %server% is not accessible or is offline
GOTO:eof

:ServiceNotFound
echo Service %1 is not installed on Server %server%
exit /b 0

:usage
echo Will cause a local/remote service to START (if not already started).
echo This script will waiting for the service to enter the started state if necessary.
echo.
echo %0 [service name] [system name]
echo Example: %0 MyService server1
echo Example: %0 MyService (for local PC)
echo.

GOTO:eof