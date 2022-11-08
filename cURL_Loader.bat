@ECHO Off && TITLE cURL Loader && COLOR 0D

::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                                                  ::
::                   cURL Loader                    ::
:: Simple batch to load and install/update cURL.exe ::
::                   Version 1.0                    ::
::         Coded by Prinzessin@flampinko.it         ::
::                                                  ::
::     use on your own. no warranty for nothing.    ::
::                                                  ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::

REM Switches: /i /f /d""
REM /i install cURL to System
REM use with /d else it will only downloaded to actual dir of this batch.
REM /f Force update
REM Downloads curl and ignore local and system version number
REM /d "full/path/for/installing/curl/"
REM e.g. "C:\Programms\curl\"


:VORBEREITUNG
IF EXIST "%TEMP%\curl-latest.zip" DEL /F /S /Q "%TEMP%\curl-latest.zip" >NUL 2>NUL
IF EXIST "%TEMP%\version.txt" DEL /F /S /Q "%TEMP%\version.txt" >NUL 2>NUL
IF EXIST "%TEMP%\curl" RD /S /Q "%TEMP%\curl" >NUL 2>NUL

:CURL_SETS
SET _CURL_=
SET _CURL_LINK_=
SET _AUSGABE_CURL_ONLINE_=
SET _AUSGABE_CURL_LOKALE_=
SET _AUSGABE_CURL_SYSTEM_=
SET _AUSGABE_CURL_SYSTEM_64_=
SET _AUSGABE_CURL_SYSTEM_32_=

:TODO
GOTO :SET_LINKS
_FORCE_UPDATE_
_INSTALL_CURL_
_CURL_INS_DIR_
INFO_UND_COPYRIGHT

:SET_LINKS
IF "%PROCESSOR_ARCHITECTURE%" == "AMD64" (SET _CURL_LINK_=https://curl.se/windows/latest.cgi?p=win64-mingw.zip)
IF "%PROCESSOR_ARCHITECTURE%" == "x86"   (SET _CURL_LINK_=https://curl.se/windows/latest.cgi?p=win32-mingw.zip)
IF "%PROCESSOR_ARCHITECTURE%" == "ARM64" (SET _CURL_LINK_=https://curl.se/windows/latest.cgi?p=win64a-mingw.zip)
IF "%_CURL_LINK_%" == "" (SET _CURL_LINK_=https://curl.se/windows/latest.cgi?p=win32-mingw.zip)

:SET_CURL
SET _NO_CURL_=0
IF NOT EXIST "%~dp0curl.exe" (
	IF EXIST "%windir%\syswow64\curl.exe" (
		SET _CURL_="%windir%\syswow64\curl.exe"
	) ELSE (
		IF EXIST "%windir%\system32\curl.exe" (
			SET _CURL_="%windir%\system32\curl.exe"
		)
	)
) ELSE (
	SET _CURL_="%~dp0curl.exe"
)

:CURL_ONLINE_VERSION
@ECHO Checking newest cURL Version...
IF NOT %_CURL_% == "" (
	%_CURL_% --silent https://curl.se/windows/ | FIND /I "<!-- version:">"%TEMP%\version.txt"
	FOR /F "tokens=3" %%A IN (%TEMP%\version.txt) DO SET _AUSGABE_CURL_ONLINE_=%%A
	IF EXIST "%TEMP%\version.txt" DEL /F /S /Q "%TEMP%\version.txt" >NUL 2>NUL
) ELSE (
	SET _NO_CURL_=1
	GOTO :CURL_DOWNLOAD
)
@ECHO cURL Online Version: %_AUSGABE_CURL_ONLINE_%

:CURL_LOKALE_VERSION
@ECHO.
@ECHO Checking local cURL Version...
IF EXIST "%~dp0curl.exe" (
	"%~dp0curl.exe" -V | find /I "curl ">"%TEMP%\version.txt"
	FOR /F "tokens=2" %%A IN (%TEMP%\version.txt) DO SET _AUSGABE_CURL_LOKALE_=%%A
	IF EXIST "%TEMP%\version.txt" DEL /F /S /Q "%TEMP%\version.txt" >NUL 2>NUL
) ELSE (
	SET _AUSGABE_CURL_LOKALE_=None
)
@ECHO cURL Lokale Version: %_AUSGABE_CURL_LOKALE_%

:CURL_SYSTEM_VERSION
@ECHO.
@ECHO Checking System cURL Version...
IF EXIST "%windir%\syswow64\curl.exe" (
	"%windir%\syswow64\curl.exe" -V | find /I "curl ">"%TEMP%\version.txt"
	FOR /F "tokens=2" %%A IN (%TEMP%\version.txt) DO SET _AUSGABE_CURL_SYSTEM_64_=%%A
	IF EXIST "%TEMP%\version.txt" DEL /F /S /Q "%TEMP%\version.txt" >NUL 2>NUL
)
@ECHO cURL System x64 Version: %_AUSGABE_CURL_SYSTEM_64_%
IF EXIST "%windir%\system32\curl.exe" (
	"%windir%\system32\curl.exe" -V | find /I "curl ">"%TEMP%\version.txt"
	FOR /F "tokens=2" %%A IN (%TEMP%\version.txt) DO SET _AUSGABE_CURL_SYSTEM_32_=%%A
	IF EXIST "%TEMP%\version.txt" DEL /F /S /Q "%TEMP%\version.txt" >NUL 2>NUL
)
@ECHO cURL System x86 Version: %_AUSGABE_CURL_SYSTEM_32_%

:CURL_VERSION_VERGLEICH
IF "%_AUSGABE_CURL_SYSTEM_64_%" == "%_AUSGABE_CURL_SYSTEM_32_%" (
	SET _AUSGABE_CURL_SYSTEM_=%_AUSGABE_CURL_SYSTEM_32_%
)

IF "%_AUSGABE_CURL_SYSTEM_%" == "%_AUSGABE_CURL_ONLINE_%" (
	GOTO :CURL_FERTIG_NO_UPDATE
) ELSE (
	IF NOT "%_AUSGABE_CURL_ONLINE_%" == "%_AUSGABE_CURL_LOKALE_%" (
		IF EXIST "%~dp0curl.exe" DEL /F /S /Q "%~dp0curl.exe" >NUL 2>NUL
		IF EXIST "%~dp0libcurl*.dll" DEL /F /S /Q "%~dp0libcurl*.dll" >NUL 2>NUL
		IF EXIST "%~dp0curl-ca-bundle.crt" DEL /F /S /Q "%~dp0curl-ca-bundle.crt" >NUL 2>NUL
	) ELSE (
		GOTO :CURL_FERTIG_NO_UPDATE
	)
)

:CURL_DOWNLOAD
@ECHO.
@ECHO Downloading latest cURL zip from https://curl.se...
IF NOT %_CURL_% == "" (
	%_CURL_% -# -k -L %_CURL_LINK_% -o "%TEMP%\curl-latest.zip"
) ELSE (
	powershell -command $progressPreference = 'silentlyContinue'; Invoke-RestMethod -Uri %_CURL_LINK_% -OutFile "%TEMP%\curl-latest.zip"
	@ECHO ################################################################################################################ 100,0%%
)
@ECHO Finischd Download.
	
:CURL_ENTPACKEN
@ECHO.
@ECHO Unzip cURL...
powershell -command $progressPreference = 'silentlyContinue'; "Expand-Archive -Path %TEMP%\curl-latest.zip -DestinationPath '%TEMP%\curl' -force | out-null"
DEL /F /S /Q "%TEMP%\curl-latest.zip" >NUL 2>NUL
@ECHO Finischd Unzipping.

:CURL_VERSCHIEBEN
@ECHO.
@ECHO Moving Files...
for /R "%TEMP%\curl" %%A in (curl.exe,curl-ca-bundle.crt,libcurl*.dll) do (
	MOVE /Y "%%A" ".\" >NUL 2>NUL
)
RD /S /Q "%TEMP%\curl" >NUL 2>NUL
@ECHO Finischd moving Files...
IF "%_NO_CURL_%" == "1" GOTO :SET_CURL

:CURL_FERTIG_UPDATE
COLOR 02
@ECHO.
@ECHO Everithing is fine. You have cURL Version %_AUSGABE_CURL_ONLINE_% in %~dp0
@ECHO.
@ECHO Press any key to Exit.
PAUSE>NUL
EXIT

:CURL_FERTIG_NO_UPDATE
COLOR 02
@ECHO.
@ECHO Everithing is fine. No Update needet. You have cURL Version %_AUSGABE_CURL_ONLINE_%.
@ECHO.
@ECHO Press any key to Exit.
PAUSE>NUL
EXIT