//==============================================================================
//	R_IndexCache
//	Stores a list of integers intended to represent indices
//	Note, users of this class are expected to call InitIndexCache manually
//==============================================================================
class R_IndexCache extends Object abstract;

const Utilities = Class'RBots.R_BotUtilities';
const NavLib = Class'RBots.R_NavLibrary';

const LogCategory = 'IndexCache';

function InitIndexCache();
function int GetNumIndices();
function bool IsFull();
function Push(int Index);
function int Get(int CacheIndex);
function int GetUnchecked(int CacheIndex);