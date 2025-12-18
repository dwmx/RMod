//==============================================================================
//	R_ArpgItem
//	Base class for item data
//==============================================================================
class R_ArpgItem extends R_ArpgObject;

var private SkelModel ItemSkelModel;

function SkelModel GetItemSkelModel() { return ItemSkelModel; }

defaultproperties
{
	ItemSkelModel=SkelModel'objects.Barrel'
}