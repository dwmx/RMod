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

ln -s $RModPath/RMod/ $RunePath/RMod
ln -s $RModPath/RMod_Arena/ $RunePath/RMod_Arena
ln -s $RModPath/RMod_RuneRoyale/ $RunePath/RMod_RuneRoyale
ln -s $RModPath/RMod_Valball/ $RunePath/RMod_Valball