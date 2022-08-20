:Begin
if exist Rune\System\UCC.exe (
    goto Build
) else  (
    goto Error
)

:Build
if exist Rune\System\RMod.u (
    del Rune\System\RMod.u
)
if exist Rune\System\RMod_Arena.u (
    del Rune\System\RMod_Arena.u
)
Rune\System\UCC.exe make ini=.\..\RMod_Config\RModBuild.ini
goto End

:Error
echo You messed it up
goto End

:End