@echo off

echo Executing "candle.exe"...
"C:\Program Files (x86)\WiX Toolset v3.11\bin\candle.exe" -nologo "D:\DevelopmentNew\DotNet\ComPortWatcher\NibblePoker.Packaging.ListComPort\untitled.wxs" -out "D:\DevelopmentNew\DotNet\ComPortWatcher\NibblePoker.Packaging.ListComPort\untitled.wixobj" -ext WixUIExtension

echo Executing "light.exe"...
"C:\Program Files (x86)\WiX Toolset v3.11\bin\light.exe" "untitled.wixobj" -out "untitled.msi" -ext WixUIExtension -cultures:en-us

pause
