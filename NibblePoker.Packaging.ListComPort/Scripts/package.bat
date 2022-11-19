@echo off

:: Keeping the starting CWD in memory and going into the script's directory.
pushd %~dp0
cd /D "%~dp0"

:: Calling the common script.
call .\commons.bat

:: Moving to the project's root.
cd .\..\..

:: Creating the packages.
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

copy /B /V NibblePoker.Packaging.ListComPort\Wix\ListComPort_x86.msi Packages\ListComPort_v%NP_LSCOM_VERSION%_x86.msi
copy /B /V NibblePoker.Packaging.ListComPort\Wix\ListComPort_x64.msi Packages\ListComPort_v%NP_LSCOM_VERSION%_x64.msi

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

:: Going back to the original directory
popd
