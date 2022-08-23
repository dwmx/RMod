echo "Building RMod"

# Create an Engine and RuneI package folder so that core game files can be modded
mkdir $RUNE_PATH/Engine/
mkdir $RUNE_PATH/RuneI/

# Link asset directories from the min Rune106 installation so that UC will compile correctly
ln -s $RUNE_PATH/EngineAssets/Textures $RUNE_PATH/Engine/Textures
ln -s $RUNE_PATH/RuneIAssets/MODELS $RUNE_PATH/RuneI/MODELS
ln -s $RUNE_PATH/RuneIAssets/Sounds $RUNE_PATH/RuneI/Sounds
ln -s $RUNE_PATH/RuneIAssets/Textures $RUNE_PATH/RuneI/Textures

# Link ONLY the Classes directories from RMod packages to override the original game code
ln -s $REPOSITORY_PATH/RMod_Override_Engine/Classes $RUNE_PATH/Engine/Classes
ln -s $REPOSITORY_PATH/RMod_Override_RuneI/Classes $RUNE_PATH/RuneI/Classes

# Link all other RMod package directories
ln -s $REPOSITORY_PATH/RMod/ $RUNE_PATH/RMod
ln -s $REPOSITORY_PATH/RMod_Arena/ $RUNE_PATH/RMod_Arena
ln -s $REPOSITORY_PATH/RMod_RuneRoyale/ $RUNE_PATH/RMod_RuneRoyale
ln -s $REPOSITORY_PATH/RMod_Valball/ $RUNE_PATH/RMod_Valball

# Rename original package files so that UCC make will recompile the game code
mv $RUNE_PATH/System/Engine.u $RUNE_PATH/System/Engine.backup.u
mv $RUNE_PATH/System/RuneI.u $RUNE_PATH/System/RuneI.backup.u