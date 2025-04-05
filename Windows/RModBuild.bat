@echo off
:Begin
if exist ..\Rune\System\UCC.exe (
    goto Build
) else (
    goto Error
)

:Build
setlocal enabledelayedexpansion

:: List of files to delete
set files=RTest.u RBase.u RBaseTests.u RGameUI.u RMod.u RMod_Arena.u RMod_FreezeTag.u RMod_TowerDefense.u

:: Loop through each file in the list and delete if it exists
for %%f in (%files%) do (
    if exist ..\Rune\System\%%f (
        del ..\Rune\System\%%f
    )
)

:: Run UCC.exe
..\Rune\System\UCC.exe make ini=.\..\RMod_Build\RModBuild.ini
goto Finish

:Error
echo You messed it up
goto Finish

:Finish
endlocal
