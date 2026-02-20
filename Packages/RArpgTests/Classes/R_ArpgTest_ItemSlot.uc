//==============================================================================
//	R_ArpgTest_ItemSlot
//	Base class for ItemSlot tests
//==============================================================================
class R_ArpgTest_ItemSlot extends R_ArpgTest abstract;

static function R_ArpgItemSlot CreateMockItemSlot()
{
	local R_ArpgItemSlot ItemSlot;

	ItemSlot = R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgItemSlot'));

	return ItemSlot;
}