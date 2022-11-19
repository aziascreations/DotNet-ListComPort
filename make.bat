@echo off

:: Keeping the starting CWD in memory and going into the script's directory.
pushd %~dp0
cd /D "%~dp0"

:: User-configurable %PATH% entries.
set PATH_MAKEAPPX=C:\Program Files (x86)\Windows Kits\10\App Certification Kit\
set PATH_WIX=C:\Program Files (x86)\WiX Toolset v3.14\bin\
set PATH_7ZIP=C:\Program Files\7-Zip\7z.exe

:: Setting some naming constants
set NP_LSCOM_VERSION=3.0.0

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
	set NP_REDO_PATH_CHECK=true
)

if %NP_PATH_7ZIP% neq true (
	echo %NP_ESC%[33mWARNING:%NP_ESC%[0m Unable to find the 7-Zip in your %%PATH%% !
	echo.         We will attempt to use the predefined one present at the top of "make.bat"...
	set "PATH=%PATH%;%PATH_7ZIP%"
	set NP_REDO_PATH_CHECK=true
)

:: TODO: MakeAppx !

if %NP_REDO_PATH_CHECK% neq true (
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

if %NP_PATH_7ZIP% neq true (
	echo %NP_ESC%[31mFATAL ERROR:%NP_ESC%[0m Unable to find the 7-Zip in your %%PATH%% !
	echo.             You need to download it from their website:
	echo.               https://www.7-zip.org/
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
light ListComPort_x64.wixobj -loc en-us.wxl -out ListComPort_x64.msi -ext WixUIExtension -cultures:en-us
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
light ListComPort_x86.wixobj -loc en-us.wxl -out ListComPort_x86.msi -ext WixUIExtension -cultures:en-us
if ERRORLEVEL 1 (
	echo.
	echo %NP_ESC%[31mFATAL ERROR:%NP_ESC%[0m Failed to link and create the final MSI package !
	echo.
	goto end-msi-error
)

cd ..

:: TODO: Packages

goto packages


:end-msi-error
cd ..

goto end


:packages
echo Removing old final distributable packages...
rmdir /Q /S Packages 2>nul
echo.

echo Preparing folders...
mkdir Packages
mkdir Packages\any
mkdir Packages\x86_DotNet6
mkdir Packages\x86_SelfContained
mkdir Packages\x64_DotNet6
mkdir Packages\x64_SelfContained
mkdir Packages\arm_DotNet6
mkdir Packages\arm_SelfContained
mkdir Packages\arm64_DotNet6
mkdir Packages\arm64_SelfContained
mkdir Packages\licenses_Others
mkdir Packages\licenses_Others\Licenses
mkdir Packages\licenses_SelfContained
mkdir Packages\licenses_SelfContained\Licenses
echo.

echo Copying final distributable files...
xcopy /E /v NibblePoker.Packaging.ListComPort\Licenses Packages\licenses_SelfContained\Licenses
del Packages\licenses_SelfContained\Licenses\*.rtf
copy Packages\licenses_SelfContained\Licenses\License_NibblePoker.pdf Packages\licenses_Others\Licenses\License_NibblePoker.pdf

xcopy /E /v Builds\any Packages\any
del Packages\any\*.pdb

copy /B /V NibblePoker.Packaging.ListComPort\ListComPort_x86.msi Packages\ListComPort_v%NP_LSCOM_VERSION%_x86.msi
copy /B /V NibblePoker.Packaging.ListComPort\ListComPort_x64.msi Packages\ListComPort_v%NP_LSCOM_VERSION%_x64.msi

copy /B /V Builds\x86_single\NibblePoker.Application.ListComPort.exe Packages\x86_DotNet6\lscom.exe
copy /B /V Builds\x86_single_sc_trim_comp\NibblePoker.Application.ListComPort.exe Packages\x86_SelfContained\lscom.exe

copy /B /V Builds\x64_single\NibblePoker.Application.ListComPort.exe Packages\x64_DotNet6\lscom.exe
copy /B /V Builds\x64_single_sc_trim_comp\NibblePoker.Application.ListComPort.exe Packages\x64_SelfContained\lscom.exe

copy /B /V Builds\arm_single\NibblePoker.Application.ListComPort.exe Packages\arm_DotNet6\lscom.exe
copy /B /V Builds\arm_single_sc_trim_comp\NibblePoker.Application.ListComPort.exe Packages\arm_SelfContained\lscom.exe

copy /B /V Builds\arm64_single\NibblePoker.Application.ListComPort.exe Packages\arm64_DotNet6\lscom.exe
copy /B /V Builds\arm64_single_sc_trim_comp\NibblePoker.Application.ListComPort.exe Packages\arm64_SelfContained\lscom.exe
echo.

echo Renaming some files...
ren Packages\any\NibblePoker.Application.ListComPort.exe lscom.exe
echo.

echo Creating final distributable packages...
7z a -mx9 "./Packages/ListComPort_v%NP_LSCOM_VERSION%_AnyCPU.zip" ./Packages/any/* ./Packages/licenses_Others/* > nul
7z a -mx9 "./Packages/ListComPort_v%NP_LSCOM_VERSION%_x86_Single.zip" ./Packages/x86_DotNet6/* ./Packages/licenses_Others/* > nul
7z a -mx9 "./Packages/ListComPort_v%NP_LSCOM_VERSION%_x86_SelfContained.zip" ./Packages/x86_SelfContained/* ./Packages/licenses_SelfContained/* > nul
7z a -mx9 "./Packages/ListComPort_v%NP_LSCOM_VERSION%_x64_Single.zip" ./Packages/x64_DotNet6/* ./Packages/licenses_Others/* > nul
7z a -mx9 "./Packages/ListComPort_v%NP_LSCOM_VERSION%_x64_SelfContained.zip" ./Packages/x64_SelfContained/* ./Packages/licenses_SelfContained/* > nul
7z a -mx9 "./Packages/ListComPort_v%NP_LSCOM_VERSION%_arm_Single.zip" ./Packages/arm_DotNet6/* ./Packages/licenses_Others/* > nul
7z a -mx9 "./Packages/ListComPort_v%NP_LSCOM_VERSION%_arm_SelfContained.zip" ./Packages/arm_SelfContained/* ./Packages/licenses_SelfContained/* > nul
7z a -mx9 "./Packages/ListComPort_v%NP_LSCOM_VERSION%_arm64_Single.zip" ./Packages/arm64_DotNet6/* ./Packages/licenses_Others/* > nul
7z a -mx9 "./Packages/ListComPort_v%NP_LSCOM_VERSION%_arm64_SelfContained.zip" ./Packages/arm64_SelfContained/* ./Packages/licenses_SelfContained/* > nul

echo.

goto end-success


:verify-path
echo Checking %%PATH%% for required programs...

set NP_PATH_DOTNET=false
set NP_PATH_MAKEAPPX=false
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

where /q 7z
if ERRORLEVEL 1 (
	echo. * 7-Zip Archiver:     %NP_ESC%[31mNOT FOUND !%NP_ESC%[0m
) else (
	echo. * 7-Zip Archiver:     %NP_ESC%[32mFOUND !%NP_ESC%[0m
	set NP_PATH_7ZIP=true
)

echo.

exit /b


:end-success
echo %NP_ESC%[32mThe building process has finished successfully !%NP_ESC%[0m
goto end


:end
set PATH=%PATH_ORIGINAL%

set PATH_MAKEAPPX=
set PATH_WIX=
set PATH_7ZIP=
set PATH_ORIGINAL=
set NP_ESC=
set NP_PATH_DOTNET=
set NP_PATH_MAKEAPPX=
set NP_PATH_WIXCANDLE=
set NP_PATH_WIXLIGHT=
set NP_PATH_7ZIP=
set NP_IS_WIX_VALID=
set NP_REDO_PATH_CHECK=
set WixTargetPlatform=
set NP_LSCOM_VERSION=

popd

:: Ringing the terminal's bell
echo 

pause
