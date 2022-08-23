if [ "$#" -ne 2 ]; then
	echo "Usage: build_setup.sh <rmod directory> <rune directory>"
	exit 1;
fi

RModPath=$1
if [ ! -d $RModPath ]; then
	echo "Invalid RMod directory $RModPath"
	exit 2;
fi

RunePath=$2;
if [ ! -d $RunePath ]; then
	echo "Invalid Rune directory $RunePath"
	exit 2;
fi

# Create an Engine and RuneI package folder so that core game files can be modded
mkdir $RunePath/Engine/
mkdir $RunePath/RuneI/

# Link asset directories from the min Rune106 installation so that UC will compile correctly
ln -s $RunePath/EngineAssets/Textures $RunePath/Engine/Textures
ln -s $RunePath/RuneIAssets/MODELS $RunePath/RuneI/MODELS
ln -s $RunePath/RuneIAssets/Sounds $RunePath/RuneI/Sounds
ln -s $RunePath/RuneIAssets/Textures $RunePath/RuneI/Textures

# Link ONLY the Classes directories from RMod packages to override the original game code
ln -s $RModPath/RMod_Override_Engine/Classes $RunePath/Engine/Classes
ln -s $RModPath/RMod_Override_RuneI/Classes $RunePath/RuneI/Classes

# Link all other RMod package directories
ln -s $RModPath/RMod/ $RunePath/RMod
ln -s $RModPath/RMod_Arena/ $RunePath/RMod_Arena
ln -s $RModPath/RMod_RuneRoyale/ $RunePath/RMod_RuneRoyale
ln -s $RModPath/RMod_Valball/ $RunePath/RMod_Valball

# Rename original package files so that UCC make will recompile the game code
mv $RunePath/System/Engine.u $RunePath/System/Engine.backup.u
mv $RunePath/System/RuneI.u $RunePath/System/RuneI.backup.u