//==============================================================================
//	R_NavMeshLibrary
//	Shared static data to be used across multiple classes
//	UC does not permit the useage of consts, structs or enums outside of their
//	defined classes, so this is just a workaround
//==============================================================================
class R_NavMeshLibrary extends Object abstract;

// Invalid index used across all navmesh index types
static function int InvalidIndex() 			{ return -1; }

// Edge Flags
static function int EdgeFlag_Border()		{ return 0x01; }
static function int EdgeFlag_Impassable()	{ return 0x02; }