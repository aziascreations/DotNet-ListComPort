@echo off

:: Keeping the starting CWD in memory and going into the script's directory.
pushd %~dp0
cd /D "%~dp0"

:: Calling the common script
call .\commons.bat

:: Checking the PATH environment variable.
call :verify-path

set NP_REDO_PATH_CHECK=false
set NP_PATH_OK=true

if %NP_PATH_DOTNET% neq true (
	echo %NP_ESC%[31mFATAL ERROR:%NP_ESC%[0m The .NET SDK couldn't be found !
	echo.             You can download it from Microsoft here:
	echo.               https://dotnet.microsoft.com/en-us/download
	set NP_PATH_OK=false
	goto end-path
)

set NP_IS_WIX_VALID=true
if %NP_PATH_WIXLIGHT% neq true set NP_IS_WIX_VALID=false
if %NP_PATH_WIXCANDLE% neq true set NP_IS_WIX_VALID=false
if %NP_IS_WIX_VALID% neq true (
	echo %NP_ESC%[33mWARNING:%NP_ESC%[0m Unable to find the complete Wix Toolset in your %%PATH%% !
	echo.         We will attempt to use the predefined one present at the top of "make.bat"...
	echo.
	set "PATH=%PATH%;%PATH_WIX%"
	set NP_REDO_PATH_CHECK=true
)

if %NP_PATH_7ZIP% neq true (
	echo %NP_ESC%[33mWARNING:%NP_ESC%[0m Unable to find the 7-Zip in your %%PATH%% !
	echo.         We will attempt to use the predefined one present at the top of "make.bat"...
	set "PATH=%PATH%;%PATH_7ZIP%"
	set NP_REDO_PATH_CHECK=true
)

if %NP_REDO_PATH_CHECK% neq true (
	goto end-path
)

:: Redoing the %PATH% check...
call :verify-path

set NP_IS_WIX_VALID=true
if %NP_PATH_WIXLIGHT% neq true set NP_IS_WIX_VALID=false
if %NP_PATH_WIXCANDLE% neq true set NP_IS_WIX_VALID=false
if %NP_IS_WIX_VALID% neq true (
	echo %NP_ESC%[31mFATAL ERROR:%NP_ESC%[0m Unable to find the complete Wix Toolset in your %%PATH%% !
	echo.             You need to download Wix Toolset 3.14+ from one of these links:
	echo.               https://wixtoolset.org/releases/
	echo.               https://wixtoolset.org/releases/development/
	echo.
	set NP_PATH_OK=false
	goto end-path
)

if %NP_PATH_7ZIP% neq true (
	echo %NP_ESC%[31mFATAL ERROR:%NP_ESC%[0m Unable to find the 7-Zip in your %%PATH%% !
	echo.             You need to download it from their website:
	echo.               https://www.7-zip.org/
	echo.
	set NP_PATH_OK=false
	goto end-path
)

goto end-path


:verify-path
echo Checking %%PATH%% for required programs...

set NP_PATH_DOTNET=false
set NP_PATH_WIXLIGHT=false
set NP_PATH_WIXCANDLE=false
set NP_PATH_7ZIP=false

where /q dotnet
if ERRORLEVEL 1 (
	echo. * .NET SDK/Runtime:   %NP_ESC%[31mNOT FOUND !%NP_ESC%[0m
) else (
	echo. * .NET SDK/Runtime:   %NP_ESC%[32mFOUND !%NP_ESC%[0m
	set NP_PATH_DOTNET=true
)

where /q candle
if ERRORLEVEL 1 (
	echo. * Wix Toolset Candle: %NP_ESC%[31mNOT FOUND !%NP_ESC%[0m
) else (
	echo. * Wix Toolset Candle: %NP_ESC%[32mFOUND !%NP_ESC%[0m
	set NP_PATH_WIXCANDLE=true
)

where /q light
if ERRORLEVEL 1 (
	echo. * Wix Toolset Light:  %NP_ESC%[31mNOT FOUND !%NP_ESC%[0m
) else (
	echo. * Wix Toolset Light:  %NP_ESC%[32mFOUND !%NP_ESC%[0m
	set NP_PATH_WIXLIGHT=true
)

where /q 7z
if ERRORLEVEL 1 (
	echo. * 7-Zip Archiver:     %NP_ESC%[31mNOT FOUND !%NP_ESC%[0m
) else (
	echo. * 7-Zip Archiver:     %NP_ESC%[32mFOUND !%NP_ESC%[0m
	set NP_PATH_7ZIP=true
)

echo.

exit /b


:end-path
:: Going back to the original directory
popd
