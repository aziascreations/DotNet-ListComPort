@echo off

:: Keeping the starting CWD in memory and going into the script's directory.
pushd %~dp0
cd /D "%~dp0"

:: Calling the common script.
call .\commons.bat

:: Moving to the "NibblePoker.Packaging.ListComPort\Wix" folder.
cd .\..\Wix

:: Cleaning.
echo Removing old MSI-related files...
del *.msi >nul 2>&1
del *.wixobj >nul 2>&1
del *.wixpdb >nul 2>&1
echo.

:: Packaging into MSI.
echo Creating x64 MSI package...
set WixTargetPlatform=x64
set NP_MSI_OK=false

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

set NP_MSI_OK=true


:end-msi-error
:: Going back to the original directory.
popd
