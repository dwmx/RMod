//==============================================================================
//	R_BlackBoard
//	Contains AI context state shared over multiple behaviors
//==============================================================================
class R_BlackBoard extends R_RBotsObject abstract;

const LogCategory = 'BlackBoard';

function bool Add(Name Key, int TypeCode);
function bool Get(Name Key, out R_Variant OutValue);
function bool Set(Name Key, R_Variant Value);

function int GetMaxKeys();
function int GetNumKeys();
function bool GetKeyTypeAtIndex(int Index, out Name OutKey, out int OutTypeCode);