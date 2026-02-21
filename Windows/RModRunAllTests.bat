@echo off
:Begin
if exist ..\Rune\System\UCC.exe (
    goto RunAllTests
) else (
    goto NoUCC
)

:RunAllTests
rem ..\Rune\System\UCC.exe RTest.R_TestCommandlet RBaseTests.R_ATestCollection_RBase
..\Rune\System\UCC.exe RTest.R_TestCommandlet RArpgTests.R_ATestCollection_RArpg

:NoUCC