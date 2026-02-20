//==============================================================================
//	R_ArpgTest
//	Base class for all Arpg tests
//	Common functions for creating mock objects
//==============================================================================
class R_ArpgTest extends R_ATest abstract;

const ArpgLib = Class'RArpg.R_ArpgLibrary';

static function R_ArpgItem CreateMockItem()
{
	local R_ArpgItem Item;

	Item = R_ArpgItem(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgItem'));
	Item.SetItemGridSize(3, 3);

	return Item;
}