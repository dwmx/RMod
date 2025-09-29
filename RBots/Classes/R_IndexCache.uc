//==============================================================================
//	R_IndexCache
//	Stores a list of indices
//==============================================================================
class R_IndexCache extends Object;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'IndexCache';

var private int Indices[64];
var private int NumIndices;

function InitIndexCache()
{
	NumIndices = 0;
}

function int GetNumIndices()
{
	return NumIndices;
}

function Push(int Index)
{
	if(NumIndices >= ArrayCount(Indices))
	{
		Utilities.Static.RLog("Push failed -- array overflow", LogCategory);
		return;
	}

	Indices[NumIndices] = Index;
	++NumIndices;
}

function int GetUnchecked(int CacheIndex)
{
	return Indices[CacheIndex];
}