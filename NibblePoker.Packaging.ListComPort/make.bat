@echo off

cd /D "%~dp0"

del *.msi
del *.wixobj
del *.wixpdb

set WixTargetPlatform=x64

echo Executing "candle.exe" for x64...
"C:\Program Files (x86)\WiX Toolset v3.14\bin\candle.exe" -nologo "ListComPort.wxs" -out "ListComPort_x64.wixobj" -ext WixUIExtension

echo Executing "light.exe" for x64...
"C:\Program Files (x86)\WiX Toolset v3.14\bin\light.exe" "ListComPort_x64.wixobj" -loc en-us.wxl -out "ListComPort_x64.msi" -ext WixUIExtension -cultures:en-us

set WixTargetPlatform=x86

echo Executing "candle.exe" for x86...
"C:\Program Files (x86)\WiX Toolset v3.14\bin\candle.exe" -nologo "ListComPort.wxs" -out "ListComPort_x86.wixobj" -ext WixUIExtension

echo Executing "light.exe" for x86...
"C:\Program Files (x86)\WiX Toolset v3.14\bin\light.exe" "ListComPort_x86.wixobj" -loc en-us.wxl -out "ListComPort_x86.msi" -ext WixUIExtension -cultures:en-us

del *.wixobj
del *.wixpdb

pause
