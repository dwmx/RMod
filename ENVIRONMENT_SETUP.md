Windows Users:

- Clone RMod from the official github repository (https://github.com/dwmx/rmod) into either:
	A: An isolated local repository directory
	or
	B: Directly into the top level of a local Rune installation directory

- If using approach A:
	- In order for the build script to work correctly, create the following symlinks:
		- In your local Rune directory, create a directory symlink targeted to your local RMod repository
		- In your local RMod repository, create a directory symlink target to your local Rune installation directory