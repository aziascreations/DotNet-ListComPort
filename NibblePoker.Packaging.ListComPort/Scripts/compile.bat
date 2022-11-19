@echo off

:: Keeping the starting CWD in memory and going into the script's directory.
pushd %~dp0
cd /D "%~dp0"

:: Calling the common script
call .\commons.bat

:: Moving to the project's root
cd .\..\..

:: Cleaning
echo Removing any old binaries and any intermediate files...
rmdir /Q /S NibblePoker.Application.ListComPort\bin 2>nul
rmdir /Q /S NibblePoker.Application.ListComPort\obj 2>nul
rmdir /Q /S NibblePoker.Library.ComPortHelpers\bin 2>nul
rmdir /Q /S NibblePoker.Library.ComPortHelpers\obj 2>nul
rmdir /Q /S Builds 2>nul
mkdir Builds
echo.

:: Compiling
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

:: Going back to the original directory
popd
