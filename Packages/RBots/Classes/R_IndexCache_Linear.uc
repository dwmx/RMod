//==============================================================================
//	R_IndexCache_Linear
//	Implements IndexCache as a linear array
//==============================================================================
class R_IndexCache_Linear extends R_IndexCache;

var private int Indices[64];
var private int NumIndices;

function Initialize()
{
	NumIndices = 0;
}

function int GetNumIndices()
{
	return NumIndices;
}

function bool IsFull()
{
	return NumIndices >= ArrayCount(Indices);
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

function int Get(int CacheIndex)
{
	if(CacheIndex < 0 || CacheIndex >= NumIndices)
	{
		return InvalidIndex;
	}
	return Indices[CacheIndex];
}

function int GetUnchecked(int CacheIndex)
{
	return Indices[CacheIndex];
}