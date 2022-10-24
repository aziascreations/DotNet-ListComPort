@echo off

echo Fixing CWD...
cd /D "%~dp0"

echo Deleting build directories...
rmdir /Q /S .\ComPortHelpers\bin 2>nul
rmdir /Q /S .\ComPortHelpers\obj 2>nul
rmdir /Q /S .\ComPortWatcher\bin 2>nul
rmdir /Q /S .\ComPortWatcher\obj 2>nul
rmdir /Q /S .\ListComPort\bin 2>nul
rmdir /Q /S .\ListComPort\obj 2>nul
rmdir /Q /S .\Builds 2>nul

echo Building...

dotnet publish "./NibblePoker.Application.ListComPort/NibblePoker.Application.ListComPort.csproj" --nologo -o "./Builds/any/"

dotnet publish "./NibblePoker.Application.ListComPort/NibblePoker.Application.ListComPort.csproj" --nologo -r win-x86   -c Release -o "./Builds/x86_single"   --no-self-contained -p:PublishSingleFile=true -p:PublishReadyToRun=true
dotnet publish "./NibblePoker.Application.ListComPort/NibblePoker.Application.ListComPort.csproj" --nologo -r win-x64   -c Release -o "./Builds/x64_single"   --no-self-contained -p:PublishSingleFile=true -p:PublishReadyToRun=true
dotnet publish "./NibblePoker.Application.ListComPort/NibblePoker.Application.ListComPort.csproj" --nologo -r win-arm   -c Release -o "./Builds/arm_single"   --no-self-contained -p:PublishSingleFile=true -p:PublishReadyToRun=true
dotnet publish "./NibblePoker.Application.ListComPort/NibblePoker.Application.ListComPort.csproj" --nologo -r win-arm64 -c Release -o "./Builds/arm64_single" --no-self-contained -p:PublishSingleFile=true -p:PublishReadyToRun=true

dotnet publish "./NibblePoker.Application.ListComPort/NibblePoker.Application.ListComPort.csproj" --nologo -r win-x86   -c Release -o "./Builds/x86_single_sc_trim_comp"   --self-contained true -p:PublishReadyToRun=true -p:PublishTrimmed=true -p:PublishSingleFile=true -p:EnableCompressionInSingleFile=true
dotnet publish "./NibblePoker.Application.ListComPort/NibblePoker.Application.ListComPort.csproj" --nologo -r win-x64   -c Release -o "./Builds/x64_single_sc_trim_comp"   --self-contained true -p:PublishReadyToRun=true -p:PublishTrimmed=true -p:PublishSingleFile=true -p:EnableCompressionInSingleFile=true
dotnet publish "./NibblePoker.Application.ListComPort/NibblePoker.Application.ListComPort.csproj" --nologo -r win-arm   -c Release -o "./Builds/arm_single_sc_trim_comp"   --self-contained true -p:PublishReadyToRun=true -p:PublishTrimmed=true -p:PublishSingleFile=true -p:EnableCompressionInSingleFile=true
dotnet publish "./NibblePoker.Application.ListComPort/NibblePoker.Application.ListComPort.csproj" --nologo -r win-arm64 -c Release -o "./Builds/arm64_single_sc_trim_comp" --self-contained true -p:PublishReadyToRun=true -p:PublishTrimmed=true -p:PublishSingleFile=true -p:EnableCompressionInSingleFile=true

pause
