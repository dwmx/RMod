//==============================================================================
//	R_VirtualAsset
//	A Virtual Asset is any object which builds itself at runtime, but gets
//	treated as if it were an asset loaded from disk
//
//	Virtual Assets are created, managed, and distributed by the
//	Virtual Asset Manager class
//==============================================================================
class R_VirtualAsset extends R_RBotsObject abstract;

function Load();