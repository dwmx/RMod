//==============================================================================
//	R_VirtualAsset
//	A Virtual Asset is any object which builds itself at runtime, but gets
//	treated as if it were an asset loaded from disk
//
//	Virtual Assets are created, managed, and distributed by the
//	Virtual Asset Manager class
//==============================================================================
class R_VirtualAsset extends R_RBotsObject abstract;

var private int AssetUID;

final function int GetAssetUID() { return AssetUID; }
final function SetAssetUID(int NewAssetUID) { AssetUID = NewAssetUID; }

function Load();