//==============================================================================
//	R_KeyValueStore
//	Key:Value mapping container for various types
//==============================================================================
class R_KeyValueStore extends R_RBotsObject abstract;

const LogCategory = 'KeyValueStore';

function bool Add(Name Key, int TypeCode);
function bool Set(Name Key, R_Variant Value);
function bool Get(Name Key, out R_Variant OutVariant);

function int GetMaxKeys();
function int GetNumKeys();
function bool GetKeyTypeAtIndex(int Index, out Name OutKey, out int OutTypeCode);