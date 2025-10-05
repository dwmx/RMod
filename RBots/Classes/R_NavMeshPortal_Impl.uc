//==============================================================================
//	R_NavMeshPortal_Impl
//	A collection of edges separating two groups of polygons
//==============================================================================
class R_NavMeshPortal_Impl extends R_NavMeshPortal;

const Utilities = Class'RBots.R_BotUtilities';
const NavLib = Class'RBots.R_NavLibrary';

const LogCategory = 'NavMeshPortal';

// This Portal's index into the owning NavMesh PortalArray
var private int PortalIndex;

// The NavMesh Edges defining this Portal
var private int EdgeIndexArray[32];
var private int NumEdgeIndices;

// Polygons touching this Portal
var private int PolygonIndexArray[64];
var private int NumPolygonIndices;

// The PolyGroup indices on either side of this portal, ordered {MinIndex,MaxIndex}
var private int AdjacentPolyGroupIndices[2];
var private R_NavMeshPolyGroup AdjacentPolyGroupReferences[ArrayCount(AdjacentPolyGroupIndices)];

//------------------------------------------------------------------------------

function InitializePortal(R_NavMesh NavMesh)
{
	local int i;

	NumEdgeIndices = 0;

	for(i = 0; i < ArrayCount(AdjacentPolyGroupIndices); ++i)
	{
		AdjacentPolyGroupIndices[i] = NavLib.Static.InvalidIndex();
	}
}

function FinalizePortal(R_NavMesh NavMesh)
{
	UpdateCachedPolyGroupReferences(NavMesh);
}

function ClearCachedPolyGroupReferences()
{
	local int i;
	for(i = 0; i < ArrayCount(AdjacentPolyGroupIndices); ++i)
	{
		AdjacentPolyGroupReferences[i] = None;
	}
}

function UpdateCachedPolyGroupReferences(R_NavMesh NavMesh)
{
	local String LogWarning;
	local int i;
	ClearCachedPolyGroupReferences();
	for(i = 0; i < ArrayCount(AdjacentPolyGroupIndices); ++i)
	{
		if(NavMesh.IsValidPolyGroupIndex(AdjacentPolyGroupIndices[i]))
		{
			AdjacentPolyGroupReferences[i] = NavMesh.GetPolyGroupByIndex(AdjacentPolyGroupIndices[i]);
		}
		else
		{
			LogWarning = "UpdateCachedPolyGroupReferences error -- Invalid PolyGroup index:" @ i;
			Warn(LogWarning);
			Utilities.Static.RLog(LogWarning, LogCategory);
			continue;
		}
	}
}

//------------------------------------------------------------------------------

function SetPortalIndex(int NewPortalIndex)
{
	PortalIndex = NewPortalIndex;
}

function int GetPortalIndex()
{
	return PortalIndex;
}

//------------------------------------------------------------------------------

function CanonicalizeIndexPair(out int OutPolyGroupIndexA, out int OutPolyGroupIndexB)
{
	local int MinIndex, MaxIndex;

	MinIndex = Min(OutPolyGroupIndexA, OutPolyGroupIndexB);
	MaxIndex = Max(OutPolyGroupIndexA, OutPolyGroupIndexB);

	OutPolyGroupIndexA = MinIndex;
	OutPolyGroupIndexB = MaxIndex;
}

function SetAdjacentPolyGroupIndices(int PolyGroupIndexA, int PolyGroupIndexB)
{
	CanonicalizeIndexPair(PolyGroupIndexA, PolyGroupIndexB);
	AdjacentPolyGroupIndices[0] = PolyGroupIndexA;
	AdjacentPolyGroupIndices[1] = PolyGroupIndexB;
}

function GetAdjacentPolyGroupIndices(out int OutPolyGroupIndexA, out int OutPolyGroupIndexB)
{
	OutPolyGroupIndexA = AdjacentPolyGroupIndices[0];
	OutPolyGroupIndexB = AdjacentPolyGroupIndices[1];
}

function bool IsPortalBetween(int PolyGroupIndexA, int PolyGroupIndexB)
{
	CanonicalizeIndexPair(PolyGroupIndexA, PolyGroupIndexB);
	return AdjacentPolyGroupIndices[0] == PolyGroupIndexA && AdjacentPolyGroupIndices[1] == PolyGroupIndexB;
}

function int GetOtherPolyGroupIndex(int PolyGroupIndex)
{
	if(AdjacentPolyGroupIndices[0] == PolyGroupIndex)
	{
		return AdjacentPolyGroupIndices[1];
	}
	else if(AdjacentPolyGroupIndices[1] == PolyGroupIndex)
	{
		return AdjacentPolyGroupIndices[0];
	}
	return NavLib.Static.InvalidIndex();
}

//------------------------------------------------------------------------------

function int GetEdgeNavMeshIndex(int EdgePortalIndex)
{
	if(EdgePortalIndex >= 0 && EdgePortalIndex < NumEdgeIndices)
	{
		return EdgeIndexArray[EdgePortalIndex];
	}
	return NavLib.Static.InvalidIndex();
}

function int GetEdgePortalIndex(int EdgeNavMeshIndex)
{
	local int i;

	for(i = 0; i < NumEdgeIndices; ++i)
	{
		if(EdgeIndexArray[i] == EdgeNavMeshIndex)
		{
			return i;
		}
	}
	return NavLib.Static.InvalidIndex();
}

function AddEdgeUnique(int EdgeNavMeshIndex)
{
	local String LogWarning;
	local int i;

	if(NumEdgeIndices >= ArrayCount(EdgeIndexArray))
	{
		LogWarning = "AddEdgeUnique failed -- Array overflow";
		Warn(LogWarning);
		Utilities.Static.RLog(LogWarning, LogCategory);
		return;
	}

	for(i = 0; i < NumEdgeIndices; ++i)
	{
		if(EdgeIndexArray[i] == EdgeNavMeshIndex)
		{
			return;
		}
	}

	EdgeIndexArray[NumEdgeIndices] = EdgeNavMeshIndex;
	++NumEdgeIndices;
}

function int GetEdgeCount()
{
	return NumEdgeIndices;
}

//------------------------------------------------------------------------------

function int GetPolygonNavMeshIndex(int PolygonPortalIndex)
{
	if(PolygonPortalIndex >= 0 && PolygonPortalIndex < NumPolygonIndices)
	{
		return PolygonIndexArray[PolygonPortalIndex];
	}
	return NavLib.Static.InvalidIndex();
}

function int GetPolygonPortalIndex(int PolygonNavMeshIndex)
{
	local int i;

	for(i = 0; i < NumPolygonIndices; ++i)
	{
		if(PolygonIndexArray[i] == PolygonNavMeshIndex)
		{
			return i;
		}
	}
	return NavLib.Static.InvalidIndex();
}

function AddPolygonUnique(int PolygonNavMeshIndex)
{
	local String LogWarning;
	local int i;

	if(NumPolygonIndices >= ArrayCount(PolygonIndexArray))
	{
		LogWarning = "AddPolygonUnique failed -- Array overflow";
		Warn(LogWarning);
		Utilities.Static.RLog(LogWarning, LogCategory);
		return;
	}

	for(i = 0; i < NumPolygonIndices; ++i)
	{
		if(PolygonIndexArray[i] == PolygonNavMeshIndex)
		{
			return;
		}
	}

	PolygonIndexArray[NumPolygonIndices] = PolygonNavMeshIndex;
	++NumPolygonIndices;
}

function int GetPolygonCount()
{
	return NumPolygonIndices;
}

function bool ContainsPolygon(int PolygonNavMeshIndex)
{
	local int i;

	for(i = 0; i < NumPolygonIndices; ++i)
	{
		if(PolygonIndexArray[i] == PolygonNavMeshIndex)
		{
			return true;
		}
	}
	return false;
}