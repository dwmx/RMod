@echo off
:Begin
if exist ..\Rune\System\UCC.exe (
    goto RunAllTests
) else (
    goto NoUCC
)

:RunAllTests
..\Rune\System\UCC.exe RTest.R_TestCommandlet RBaseTests.R_ATestCollection_RBase

:NoUCC