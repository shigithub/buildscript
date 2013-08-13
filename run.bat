@ECHO OFF

SET SVN_USERNAME=autobuild_ps
SET SVN_PASSWORD=Qwerty12
SET DOTNETFRAMEWORK=C:\Windows\Microsoft.NET\Framework\v4.0.30319
SET ORIG_PCKG=%1
SET RESULT_PCKG=%2
SET SVN_ORIG_REV_URI=%3
SET SVN_REVISION_URI=%4
SET SVN_REVISION_RANGE=%5
SET SLN_FILE_PATH=%6

SET CCD=%CD%
SET SCRIPT_CWD=%~dp0%
 
IF [%1] == []  GOTO usage
IF [%1] == [/?]  GOTO usage

ECHO ------------------------------------------------------------
ECHO Original package: %ORIG_PCKG%
ECHO Resulting package: %RESULT_PCKG%
ECHO Original package revision URI: %SVN_ORIG_REV_URI%
ECHO Revision range URI: %SVN_REVISION_URI%
ECHO Revision range: %SVN_REVISION_RANGE%
ECHO Solution file path: %SLN_FILE_PATH%
ECHO ------------------------------------------------------------

set /p correct=Is above correct (Y/N)? 
IF NOT [%correct%] == [Y] GOTO end


ECHO Cleaning temp directories...
call :clean


ECHO Checking out revision: %SVN_ORIG_REV_URI%
call :checkout %SVN_ORIG_REV_URI% sources\orig


ECHO Generating and applying source patch...
cd sources\orig
call :apply_patch ..\patch.diff
cd /D %CCD%

ECHO Unpacking source package...
%SCRIPT_CWD%zipper.py unzip %ORIG_PCKG% %CD%\build\orig


ECHO Building patched sources...
call :buildsolution %CD%\sources\orig\%SLN_FILE_PATH%  %CD%\build\patched


ECHO Building tree patch...
%SCRIPT_CWD%diff.py %CCD%\build\orig %CCD%\build\patched %CCD%\diff


ECHO Applying tree patch...
%SCRIPT_CWD%patch.py %CD%\build\orig %CD%\diff %CD%\build\final


ECHO Creating patched archive...
%SCRIPT_CWD%zipper.py zip %RESULT_PCKG% %CD%\build\final

call :clean

ECHO Done.
goto end


:apply_patch
svn diff -r %SVN_REVISION_RANGE%  %SVN_REVISION_URI% > %1
svn patch %1 
exit /b

:checkout

set SVN_CMD=svn checkout %1 %2
IF NOT [%SVN_USERNAME%] == []  set SVN_CMD=%SVN_CMD% --username %SVN_USERNAME%
IF NOT [%SVN_PASSWORD%] == [] set SVN_CMD=%SVN_CMD%  --password %SVN_PASSWORD%
%SVN_CMD% > nul

exit /b

:buildsolution
%DOTNETFRAMEWORK%\msbuild  %1 /p:DeployOnBuild=true /p:PublishProfile=%SCRIPT_CWD%buildprofile.pubxml /p:PublishUrlRoot=%2 
exit /b 

:clean
rmdir /S /Q sources > nul 2>nul
rmdir /S /Q build > nul 2>nul
rmdir /S /Q diff > nul 2>nul
exit /b

:usage
ECHO Usage:
ECHO run [original_package] [result_package] [svn_orig_package_revision_uri] [svn_revision_range_uri] [svn_revision_range] [sln_file_path]


:end