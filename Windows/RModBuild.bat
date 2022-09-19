:Begin
if exist ..\Rune\System\UCC.exe (
    goto Build
) else  (
    goto Error
)

:Build
if exist ..\Rune\System\RMod.u (
    del ..\Rune\System\RMod.u
)
if exist ..\Rune\System\RMod_Arena.u (
    del ..\Rune\System\RMod_Arena.u
)
if exist ..\Rune\System\RMod_RuneRoyale.u (
    del ..\Rune\System\RMod_RuneRoyale.u
)
if exist ..\Rune\System\RMod_Valball.u (
    del ..\Rune\System\RMod_Valball.u
)
if exist ..\Rune\System\RMod_FreezeTag.u (
    del ..\Rune\System\RMod_FreezeTag.u 
)
..\Rune\System\UCC.exe make ini=.\..\RMod_Build\RModBuild.ini
goto Finish

:Error
echo You messed it up
goto Finish

:Finish
