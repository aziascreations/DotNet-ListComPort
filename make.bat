@echo off

:: Keeping the starting CWD in memory and going into the script's directory.
pushd %~dp0
cd /D "%~dp0"

:: Calling the common script.
call .\NibblePoker.Packaging.ListComPort\Scripts\commons.bat

:: Checking the excutables in the PATH.
call .\NibblePoker.Packaging.ListComPort\Scripts\check-and-fix-path.bat

if %NP_PATH_OK% neq true (
	echo %NP_ESC%[31mFATAL ERROR:%NP_ESC%[0m Unable to continue without the required programs in the %%PATH%% !
	goto end-failure
)

:: Compiling the various builds.
call .\NibblePoker.Packaging.ListComPort\Scripts\compile.bat

:: Making the MSI files.
call .\NibblePoker.Packaging.ListComPort\Scripts\make-msi.bat

if %NP_MSI_OK% neq true (
	echo %NP_ESC%[31mFATAL ERROR:%NP_ESC%[0m Unable to continue the building process without the MSI files !
	goto end-failure
)

:: Making the final packages.
call .\NibblePoker.Packaging.ListComPort\Scripts\package.bat

goto end-success


:end-success
echo %NP_ESC%[32mThe building process has finished successfully !%NP_ESC%[0m
goto end-failure


:end-failure
:: Going back to the original directory
popd

:: Ringing the terminal's bell
echo 

pause
