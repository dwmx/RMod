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
var private int PolygonIndexArrayA[64];
var private int NumPolygonIndicesA;

var private int PolygonIndexArrayB[64];
var private int NumPolygonIndicesB;

// The PolyGroup indices on either side of this portal, ordered {MinIndex,MaxIndex}
var private int AdjacentPolyGroupIndices[2];
var private R_NavMeshPolyGroup AdjacentPolyGroupReferences[ArrayCount(AdjacentPolyGroupIndices)];

// This Portal's NeighborSet
// A Portal is neighbors with every Portal inside both of its associated PolyGroups, where the
// Portals are nodes, and the PolyGroups are edges
// Costs between Portals are pulled from the associated PolyGroup's cost layers
var private R_NavNeighborSet NeighborSet;

// Costs from this Portal to each PolyGroup in the NavMesh
// This is set by the owning NavMesh during the precomputed cost building stage
// NOTE: This needs to match R_NavMesh.PolyGroupArray size
var private float PolyGroupCosts[128];

// Representative location for this Portal
var private Vector PortalLocation;

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

//------------------------------------------------------------------------------

function FinalizePortal(R_NavMesh NavMesh)
{
	UpdateCachedPolyGroupReferences(NavMesh);
	BuildNeighborSet();

	PortalLocation = CalcPortalLocation(NavMesh);
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

function Vector CalcPortalLocation(R_NavMesh NavMesh)
{
	// TODO: Update this to return some point along the edge strip of the Portal
	// For now, just returns the center point of the first edge
	local Vector VLocEdge[2];

	if(NumEdgeIndices <= 0)
	{
		return Vect(0,0,0);
	}

	NavMesh.GetEdgeVertexLocationsUnchecked(EdgeIndexArray[0], VLocEdge);
	return (VLocEdge[0] + VLocEdge[1]) * 0.5;
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

function Vector GetPortalLocation()
{
	return PortalLocation;
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

function int GetPolygonNavMeshIndexForPolyGroup(int PolyGroupNavMeshIndex, int PolygonPortalIndex)
{
	if(AdjacentPolyGroupIndices[0] == PolyGroupNavMeshIndex)
	{
		return PolygonIndexArrayA[PolygonPortalIndex];
	}
	else if(AdjacentPolyGroupIndices[1] == PolyGroupNavMeshIndex)
	{
		return PolygonIndexArrayB[PolygonPortalIndex];
	}
	return NavLib.Static.InvalidIndex();
}

function int InternalGetPolygonPortalIndex(out int InPolygonIndexArray[ArrayCount(PolygonIndexArrayA)], out int InNumPolygonIndices, int PolygonNavMeshIndex)
{
	local int i;

	for(i = 0; i < InNumPolygonIndices; ++i)
	{
		if(InPolygonIndexArray[i] == PolygonNavMeshIndex)
		{
			return i;
		}
	}
	return NavLib.Static.InvalidIndex();
}

function int GetPolygonPortalIndexForPolyGroup(int PolyGroupNavMeshIndex, int PolygonNavMeshIndex)
{
	if(AdjacentPolyGroupIndices[0] == PolyGroupNavMeshIndex)
	{
		return InternalGetPolygonPortalIndex(PolygonIndexArrayA, NumPolygonIndicesA, PolygonNavMeshIndex);
	}
	else if(AdjacentPolyGroupIndices[1] == PolyGroupNavMeshIndex)
	{
		return InternalGetPolygonPortalIndex(PolygonIndexArrayB, NumPolygonIndicesB, PolygonNavMeshIndex);
	}
	return NavLib.Static.InvalidIndex();
}

function InternalAddPolygonUnique(out int OutPolygonIndexArray[ArrayCount(PolygonIndexArrayA)], out int OutNumPolygonIndices, int PolygonNavMeshIndex)
{
	local String LogWarning;
	local int i;

	if(OutNumPolygonIndices >= ArrayCount(OutPolygonIndexArray))
	{
		LogWarning = "InternalAddPolygonUnique failed -- Array overflow";
		Warn(LogWarning);
		Utilities.Static.RLog(LogWarning, LogCategory);
		return;
	}

	for(i = 0; i < OutNumPolygonIndices; ++i)
	{
		if(OutPolygonIndexArray[i] == PolygonNavMeshIndex)
		{
			return;
		}
	}

	OutPolygonIndexArray[OutNumPolygonIndices] = PolygonNavMeshIndex;
	++OutNumPolygonIndices;
}

function AddPolygonUniqueForPolyGroupA(int PolygonNavMeshIndex)
{
	InternalAddPolygonUnique(PolygonIndexArrayA, NumPolygonIndicesA, PolygonNavMeshIndex);
}

function AddPolygonUniqueForPolyGroupB(int PolygonNavMeshIndex)
{
	InternalAddPolygonUnique(PolygonIndexArrayB, NumPolygonIndicesB, PolygonNavMeshIndex);
}

function int GetPolygonCountForPolyGroupA() { return NumPolygonIndicesA; }
function int GetPolygonCountForPolyGroupB() { return NumPolygonIndicesB; }

function int GetPolygonCountForPolyGroup(int PolyGroupNavMeshIndex)
{
	if(AdjacentPolyGroupIndices[0] == PolyGroupNavMeshIndex)
	{
		return GetPolygonCountForPolyGroupA();
	}
	if(AdjacentPolyGroupIndices[1] == PolyGroupNavMeshIndex)
	{
		return GetPolygonCountForPolyGroupB();
	}
	return 0;
}

function bool ContainsPolygon(int PolygonNavMeshIndex)
{
	local int i;

	for(i = 0; i < NumPolygonIndicesA; ++i)
	{
		if(PolygonIndexArrayA[i] == PolygonNavMeshIndex)
		{
			return true;
		}
	}

	for(i = 0; i < NumPolygonIndicesB; ++i)
	{
		if(PolygonIndexArrayB[i] == PolygonNavMeshIndex)
		{
			return true;
		}
	}

	return false;
}

//------------------------------------------------------------------------------

function BuildNeighborSet()
{
	local R_NavMeshPolyGroup PolyGroup;
	local int NumNeighborPortals;
	local int NeighborPortalIndex;
	local float NeighborCost;
	local int i, j;

	NavObjectClass.Static.NavNeighborSet_Clear(NeighborSet);

	for(i = 0; i < ArrayCount(AdjacentPolyGroupIndices); ++i)
	{
		PolyGroup = AdjacentPolyGroupReferences[i];
		if(PolyGroup == None)
		{
			continue;
		}

		NumNeighborPortals = PolyGroup.GetPortalCount();
		for(j = 0; j < NumNeighborPortals; ++j)
		{
			NeighborPortalIndex = PolyGroup.GetPortalNavMeshIndex(j);
			if(NeighborPortalIndex == PortalIndex)
			{
				continue;
			}

			NeighborCost = PolyGroup.GetCostBetweenLocalPortals(NeighborPortalIndex, PortalIndex);

			if(!NavObjectClass.Static.NavNeighborSet_AddNeighbor(
				NeighborSet,
				R_NavNeighborType.NeighborType_Adjacent,
				NeighborCost,
				NeighborPortalIndex))
			{
				break;
			}
		}
	}
}

function SetCostToPolyGroup(int PolyGroupIndex, float Cost)
{
	PolyGroupCosts[PolyGroupIndex] = Cost;
}

function float GetCostToPolyGroup(int PolyGroupIndex)
{
	return PolyGroupCosts[PolyGroupIndex];
}

function GetNeighborSet(out R_NavNeighborSet OutNeighborSet)
{
	NavObjectClass.Static.NavNeighborSet_Copy(NeighborSet, OutNeighborSet);
}