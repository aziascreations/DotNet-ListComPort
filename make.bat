@echo off

:: Keeping the starting CWD in memory and going into the script's directory.
pushd %~dp0
cd /D "%~dp0"

:: User-configurable %PATH% entries.
set PATH_MAKEAPPX=C:\Program Files (x86)\Windows Kits\10\App Certification Kit\
set PATH_WIX=C:\Program Files (x86)\WiX Toolset v3.14\bin\

:: Defining the %NP_ESC% variable for later use.
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set NP_ESC=%%b
)

:: Making a copy of the original %PATH% variable
set PATH_ORIGINAL=%PATH%

:: Checking the PATH environment variable.
call :verify-path

set NP_REDO_PATH_CHECK=false

if %NP_PATH_DOTNET% neq true (
	echo %NP_ESC%[31mFATAL ERROR:%NP_ESC%[0m The .NET SDK couldn't be found !
	echo.             You can download it from Microsoft here:
	echo.               https://dotnet.microsoft.com/en-us/download
	goto end
)

set NP_IS_WIX_VALID=true
if %NP_PATH_WIXLIGHT% neq true set NP_IS_WIX_VALID=false
if %NP_PATH_WIXCANDLE% neq true set NP_IS_WIX_VALID=false
if %NP_IS_WIX_VALID% neq true (
	echo %NP_ESC%[33mWARNING:%NP_ESC%[0m Unable to find the complete Wix Toolset in your %%PATH%% !
	echo.         We will attempt to use the predefined one present at the top of "make.bat"...
	echo.
	set "PATH=%PATH%;%PATH_WIX%"
)

:: TODO: MakeAppx !

if %NP_REDO_PATH_CHECK% equ true (
	goto build-start
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
	goto end
)


:build-start
echo Removing any old binaries and any intermidate files...
rmdir /Q /S NibblePoker.Application.ListComPort\bin 2>nul
rmdir /Q /S NibblePoker.Application.ListComPort\obj 2>nul
rmdir /Q /S NibblePoker.Library.ComPortHelpers\bin 2>nul
rmdir /Q /S NibblePoker.Library.ComPortHelpers\obj 2>nul
rmdir /Q /S Builds 2>nul
mkdir Builds
echo.

echo Building "Any" target...
dotnet publish "./NibblePoker.Application.ListComPort/NibblePoker.Application.ListComPort.csproj" --nologo -o "./Builds/any/"
echo.

echo Building "Single" targets...
dotnet publish "./NibblePoker.Application.ListComPort/NibblePoker.Application.ListComPort.csproj" --nologo -r win-x86   -c Release -o "./Builds/x86_single"   --no-self-contained -p:PublishSingleFile=true -p:PublishReadyToRun=true
dotnet publish "./NibblePoker.Application.ListComPort/NibblePoker.Application.ListComPort.csproj" --nologo -r win-x64   -c Release -o "./Builds/x64_single"   --no-self-contained -p:PublishSingleFile=true -p:PublishReadyToRun=true
dotnet publish "./NibblePoker.Application.ListComPort/NibblePoker.Application.ListComPort.csproj" --nologo -r win-arm   -c Release -o "./Builds/arm_single"   --no-self-contained -p:PublishSingleFile=true -p:PublishReadyToRun=true
dotnet publish "./NibblePoker.Application.ListComPort/NibblePoker.Application.ListComPort.csproj" --nologo -r win-arm64 -c Release -o "./Builds/arm64_single" --no-self-contained -p:PublishSingleFile=true -p:PublishReadyToRun=true
echo.

echo Building "Optimized Single" targets...
dotnet publish "./NibblePoker.Application.ListComPort/NibblePoker.Application.ListComPort.csproj" --nologo -r win-x86   -c Release -o "./Builds/x86_single_sc_trim_comp"   --self-contained true -p:PublishReadyToRun=true -p:PublishTrimmed=true -p:PublishSingleFile=true -p:EnableCompressionInSingleFile=true
dotnet publish "./NibblePoker.Application.ListComPort/NibblePoker.Application.ListComPort.csproj" --nologo -r win-x64   -c Release -o "./Builds/x64_single_sc_trim_comp"   --self-contained true -p:PublishReadyToRun=true -p:PublishTrimmed=true -p:PublishSingleFile=true -p:EnableCompressionInSingleFile=true
dotnet publish "./NibblePoker.Application.ListComPort/NibblePoker.Application.ListComPort.csproj" --nologo -r win-arm   -c Release -o "./Builds/arm_single_sc_trim_comp"   --self-contained true -p:PublishReadyToRun=true -p:PublishTrimmed=true -p:PublishSingleFile=true -p:EnableCompressionInSingleFile=true
dotnet publish "./NibblePoker.Application.ListComPort/NibblePoker.Application.ListComPort.csproj" --nologo -r win-arm64 -c Release -o "./Builds/arm64_single_sc_trim_comp" --self-contained true -p:PublishReadyToRun=true -p:PublishTrimmed=true -p:PublishSingleFile=true -p:EnableCompressionInSingleFile=true
echo.

goto msi-start

:: Unused
::set %MakeAppx% = "C:\Program Files (x86)\Windows Kits\10\App Certification Kit\makeappx.exe"
::%MakeAppx% --help


:msi-start
cd NibblePoker.Packaging.ListComPort

echo Removing old MSI-related files...
del *.msi >nul 2>&1
del *.wixobj >nul 2>&1
del *.wixpdb >nul 2>&1
echo.

echo Creating x64 MSI package...
set WixTargetPlatform=x64
candle -nologo ListComPort.wxs -out ListComPort_x64.wixobj -ext WixUIExtension
if ERRORLEVEL 1 (
	echo.
	echo %NP_ESC%[31mFATAL ERROR:%NP_ESC%[0m Failed to preprocess and compile the .wix file !
	echo.
	goto end-msi-error
)
light ListComPort_x64.wixobj -out ListComPort_x64.msi -ext WixUIExtension -cultures:en-us
if ERRORLEVEL 1 (
	echo.
	echo %NP_ESC%[31mFATAL ERROR:%NP_ESC%[0m Failed to link and create the final MSI package !
	echo.
	goto end-msi-error
)

echo Creating x86 MSI package...
set WixTargetPlatform=x86
candle -nologo ListComPort.wxs -out ListComPort_x86.wixobj -ext WixUIExtension
if ERRORLEVEL 1 (
	echo.
	echo %NP_ESC%[31mFATAL ERROR:%NP_ESC%[0m Failed to preprocess and compile the .wix file !
	echo.
	goto end-msi-error
)
light ListComPort_x86.wixobj -out ListComPort_x86.msi -ext WixUIExtension -cultures:en-us
if ERRORLEVEL 1 (
	echo.
	echo %NP_ESC%[31mFATAL ERROR:%NP_ESC%[0m Failed to link and create the final MSI package !
	echo.
	goto end-msi-error
)

cd ..

:: TODO: Packages

goto end-success


:end-msi-error
cd ..

goto end


:verify-path
echo Checking %%PATH%% for required programs...

set NP_PATH_DOTNET=false
set NP_PATH_MAKEAPPX=false
set NP_PATH_WIXLIGHT=false
set NP_PATH_WIXCANDLE=false

where /q dotnet
if ERRORLEVEL 1 (
	echo. * .NET SDK/Runtime:   %NP_ESC%[31mNOT FOUND !%NP_ESC%[0m
) else (
	echo. * .NET SDK/Runtime:   %NP_ESC%[32mFOUND !%NP_ESC%[0m
	set NP_PATH_DOTNET=true
)

where /q makeappx
if ERRORLEVEL 1 (
	echo. * Microsoft MakeAppx: %NP_ESC%[31mNOT FOUND !%NP_ESC%[0m
) else (
	echo. * Microsoft MakeAppx: %NP_ESC%[32mFOUND !%NP_ESC%[0m
	set NP_PATH_MAKEAPPX=true
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

echo.

exit /b


:end-success
echo %NP_ESC%[32mThe building process has finished successfully !%NP_ESC%[0m
goto end


:end
set PATH=%PATH_ORIGINAL%

set NP_ESC=
set NP_PATH_DOTNET=
set NP_PATH_MAKEAPPX=
set NP_PATH_WIXCANDLE=
set NP_PATH_WIXLIGHT=
set NP_IS_WIX_VALID=
set NP_REDO_PATH_CHECK=
set WixTargetPlatform=

popd

:: Ringing the terminal's bell
echo 

pause
