ARTIFACT_PATH_SOURCE=$(pwd)/RMod_Build/RModBuildArtifacts
ARTIFACT_PATH_TARGET=/RuneBase/RModBuildArtifacts

if [ -d $ARTIFACT_PATH_SOURCE ]; then
	rm -r $ARTIFACT_PATH_SOURCE
fi

mkdir $ARTIFACT_PATH_SOURCE

docker build -t runebuilder -f ./RMod_Build/RuneBuilder.dockerfile .
docker run \
	-e REPOSITORY=https://github.com/dwmx/rmod \
	-e BUILD_SCRIPT=./RMod_Build/RModContainerBuild.sh \
	-e ARTIFACT_PATH=$ARTIFACT_PATH_TARGET \
	--mount type=bind,source=$ARTIFACT_PATH_SOURCE,target=$ARTIFACT_PATH_TARGET \
	runebuilder
