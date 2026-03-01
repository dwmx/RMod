//==============================================================================
//	R_ArpgData_ItemType
//	Defines an item type
//==============================================================================
class R_ArpgData_ItemType extends R_ArpgObject;

// The Tag defining this item
// ItemTag is used heavily throughout all systems
// It is used as a hierarchical index into data stores to get data associated with this item type
// It is also used to determine what inventory slots the item is valid to be used in
var R_ArpgTag ItemTag;

var int ItemSizeX;	// Grid size X
var int ItemSizeY;	// Grid size Y