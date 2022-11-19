@echo off

:: Setting some naming constants.
set NP_LSCOM_VERSION=3.0.0

:: Defining the %NP_ESC% variable for later use.
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set NP_ESC=%%b
)

:: User-configurable %PATH% entries.
set PATH_WIX=C:\Program Files (x86)\WiX Toolset v3.14\bin\
set PATH_7ZIP=C:\Program Files\7-Zip\7z.exe
