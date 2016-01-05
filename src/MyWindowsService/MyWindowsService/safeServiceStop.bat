@echo off
:: Tweaked version of the original script authored by Eric Falsken

IF [%1]==[] GOTO usage
IF NOT "%2"=="" SET server=%2

SC %server% query %1 >NUL
IF errorlevel 1060 GOTO ServiceNotFound
IF errorlevel 1722 GOTO SystemOffline

:ResolveInitialState
SC %server% query %1 | FIND "STATE" | FIND "RUNNING" >NUL
IF errorlevel 0 IF NOT errorlevel 1 GOTO StopService
SC %server% query %1 | FIND "STATE" | FIND "STOPPED" >NUL
IF errorlevel 0 IF NOT errorlevel 1 GOTO StoppedService
SC %server% query %1 | FIND "STATE" | FIND "PAUSED" >NUL
IF errorlevel 0 IF NOT errorlevel 1 GOTO SystemOffline
echo Service State is changing, waiting for service to resolve its state before making changes
sc %server% query %1 | Find "STATE" >NUL
ping -n 2 127.0.0.1 > NUL
GOTO ResolveInitialState

:StopService
echo Stopping %1 on %server%
sc %server% stop %1 %3 >NUL

GOTO StoppingService
:StoppingServiceDelay
echo Waiting for %1 to stop
ping -n 2 127.0.0.1 > NUL
:StoppingService
SC %server% query %1 | FIND "STATE" | FIND "STOPPED" >NUL
IF errorlevel 1 GOTO StoppingServiceDelay

:StoppedService
echo %1 on %server% is stopped
GOTO:eof

:SystemOffline
echo Server %server% is not accessible or is offline
GOTO:eof

:ServiceNotFound
echo Service %1 is not installed on Server %server%
exit /b 0

:usage
echo Will cause a local/remote service to STOP (if not already stopped).
echo This script will waiting for the service to enter the stopped state if necessary.
echo.
echo %0 [service name] [system name] {reason}
echo Example: %0 MyService server1 {reason}
echo Example: %0 MyService (for local PC, DO NOT specify reason)
echo.
echo For reason codes, run "sc stop"


GOTO:eof