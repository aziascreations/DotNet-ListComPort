@echo off

:: Defining the %ESC% variable for later use.
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set ESC=%%b
)

echo Checking %%PATH%% for required programs...

where /q dotnet
if ERRORLEVEL 1 (
    echo. * .NET SDK/Runtime:   %ESC%[31mNOT FOUND !%ESC%[0m
) else (
    echo. * .NET SDK/Runtime:   %ESC%[32mFOUND !%ESC%[0m
)

where /q makeappx
if ERRORLEVEL 1 (
    echo. * Microsoft MakeAppx: %ESC%[31mNOT FOUND !%ESC%[0m
) else (
    echo. * Microsoft MakeAppx: %ESC%[32mFOUND !%ESC%[0m
)

where /q candle
if ERRORLEVEL 1 (
    echo. * Wix Toolset Candle: %ESC%[31mNOT FOUND !%ESC%[0m
) else (
    echo. * Wix Toolset Candle: %ESC%[32mFOUND !%ESC%[0m
)

where /q light
if ERRORLEVEL 1 (
    echo. * Wix Toolset Light:  %ESC%[31mNOT FOUND !%ESC%[0m
) else (
    echo. * Wix Toolset Light:  %ESC%[32mFOUND !%ESC%[0m
)

echo.

pause
