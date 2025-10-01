//==============================================================================
//	R_IndexCache_Circular
//	Implements IndexCache as a circular array
//	This cache is never full -- it overwrites oldest entries to insert new ones
//==============================================================================
class R_IndexCache_Circular extends R_IndexCache;

var private int CacheArray[16];
var private int CacheIndexFront, CacheIndexBack;

function InitIndexCache()
{
	CacheIndexFront = NavLib.Static.InvalidIndex();
	CacheIndexBack = NavLib.Static.InvalidIndex();
}

function int GetNumIndices()
{
	local int FrontAdjusted;

	if(CacheIndexFront == NavLib.Static.InvalidIndex())
	{
		return 0;
	}

	FrontAdjusted = CacheIndexFront;
	if(FrontAdjusted <= CacheIndexBack)
	{
		FrontAdjusted = FrontAdjusted + ArrayCount(CacheArray);
	}

	return FrontAdjusted - CacheIndexBack;
}

function bool IsFull()
{	// Circular array is never full
	return false;
}

function Push(int Index)
{
	local int NewFront;

	if(CacheIndexFront == NavLib.Static.InvalidIndex())
	{
		CacheArray[0] = Index;
		CacheIndexFront = 1 % ArrayCount(CacheArray);
		CacheIndexBack = 0;
	}
	else
	{
		NewFront = (CacheIndexFront + 1) % ArrayCount(CacheArray);
		if(CacheIndexBack == CacheIndexFront)
		{
			CacheIndexBack = NewFront;
		}
		
		CacheArray[CacheIndexFront] = Index;
		CacheIndexFront = NewFront;
	}
}

function int GetInternalIndex(int CacheIndex)
{
	local int RemappedIndex;

	RemappedIndex = ((CacheIndexFront + (ArrayCount(CacheArray) - 1)) - CacheIndex) % ArrayCount(CacheArray);
	return RemappedIndex;
}

function int Get(int CacheIndex)
{
	local int RemappedIndex;
	local int NumIndices;
	local int MinIndex, MaxIndex;

	NumIndices = GetNumIndices();
	if(CacheIndex >= NumIndices)
	{
		return NavLib.Static.InvalidIndex();
	}

	RemappedIndex = GetInternalIndex(CacheIndex);
	return CacheArray[RemappedIndex];
}

function int GetUnchecked(int CacheIndex)
{
	local int RemappedIndex;

	RemappedIndex = GetInternalIndex(CacheIndex);
	return CacheArray[RemappedIndex];
}

defaultproperties
{
	CacheIndexFront=-1	// Need to match NavLib.Static.InvalidIndex()
	CacheIndexBack=-1	// Need to match NavLib.Static.InvalidIndex()
}