//==============================================================================
//	R_VirtualAssetManager
//==============================================================================
class R_VirtualAssetManager extends R_RBotsObject abstract;

function R_VirtualAsset LoadAsset(Class<R_VirtualAsset> AssetClass);

defaultproperties
{
	bLogCreation=true
}