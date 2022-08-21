Windows Users:

- Clone RMod from the official project repository (https://github.com/dwmx/rmod) into an isolated local repository directory.

- Inside of the local repository, create the following symlinks:
	- mklink /D .\Rune <local rune installation path>

- Inside of your local rune installation directory, create the following symlinks:
	- If you wish to build RMod: 		mklink /D .\RMod <RepositoryDirectory\RMod>
	- If you wish to build RMod_Arena:	mklink /D .\RMod_Arena <RepositoryDirectory\RMod_Arena>
	- If you wish to build RMod_RuneRoyale:	mklink /D .\RMod_RuneRoyale <RepositoryDirectory\RMod_RuneRoyale>
	- If you wish to build RMod_Valball:	mklink /D .\RMod_Valball <RepositoryDirectory\RMod_Valball>

- By default, the project is set up to build RMod and RMod_Arena. If you wish to build additional packages, edit RMod_Config\RModBuild.ini and add the appropriate packages as EditPackages entries. The appropriate symlinks for those packages are also required in your rune directory.

- To build, execute the RModBuild.bat script