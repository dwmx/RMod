//==============================================================================
//	R_NavMeshPolyGroup
//	Manages data associated with a poly group in a nav mesh
//==============================================================================
class R_NavMeshPolyGroup_Impl extends R_NavMeshPolyGroup;

const Utilities = Class'RBots.R_BotUtilities';
const NavLib = Class'RBots.R_NavLibrary';

const LogCategory = 'NavMeshPolyGroup';

const MaxCost = 999999.0;

var private Name PolyGroupName;				// This polygroup's name
var private int PolyGroupIndex;				// Index as assigned by the owning NavMesh
var private int TriangleIndexArray[2048];	// Indices of triangles in this group
var private int NumTriangleIndices;

var private int PortalIndexArray[32];
var private R_NavMeshPortal PortalArray[ArrayCount(PortalIndexArray)];
var private int NumPortals;

// Layers are structs which assign a float value to every triangle index contained
// in this PolyGroup
// This is used to hold precomputed costs from each triangle to each portal,
// allowing bots to navigate between areas without pathfinding
struct R_NavMeshPolyGroupLayer
{
	var float Data[ArrayCount(TriangleIndexArray)];
};
var private R_NavMeshPolyGroupLayer PortalCostLayerArray[ArrayCount(PortalIndexArray)];

//------------------------------------------------------------------------------

function InitializePolyGroup(R_NavMesh NavMesh)
{
	ClearTriangles();
	ClearPortals();
}

function ClearTriangles()
{
	NumTriangleIndices = 0;
}

function ClearPortals()
{
	local int i;

	NumPortals = 0;
	ClearCachedPortalReferences();
}

function ClearCachedPortalReferences()
{
	local int i;

	for(i = 0; i < ArrayCount(PortalArray); ++i)
	{
		PortalArray[i] = None;
	}
}

//------------------------------------------------------------------------------

function FinalizePolyGroup(R_NavMesh NavMesh)
{
	UpdateCachedPortalReferences(NavMesh);
	BuildPortalCostLayers(NavMesh);
}

// Update the PortalArray
function UpdateCachedPortalReferences(R_NavMesh NavMesh)
{
	local String LogWarning;
	local int i;

	ClearCachedPortalReferences();
	for(i = 0; i < NumPortals; ++i)
	{
		if(NavMesh.IsValidPortalIndex(PortalIndexArray[i]))
		{
			PortalArray[i] = NavMesh.GetPortalByIndex(PortalIndexArray[i]);
		}
		else
		{
			LogWarning = "UpdateCachedPortalReferences error -- Invalid Portal index";
			Warn(LogWarning);
			Utilities.Static.RLog(LogWarning, LogCategory);
			continue;
		}
	}
}

//------------------------------------------------------------------------------

function SetPolyGroupName(Name NewPolyGroupName)
{
	PolyGroupName = NewPolyGroupName;
}

function Name GetPolyGroupName()
{
	return PolyGroupName;
}

function SetPolyGroupIndex(int NewPolyGroupIndex)
{
	PolyGroupIndex = NewPolyGroupIndex;
}

function int GetPolyGroupIndex()
{
	return PolyGroupIndex;
}

function int GetTriangleIndexCount()
{
	return NumTriangleIndices;
}

function PushTriangleIndex(int TriangleNavMeshIndex)
{
	local int i;

	if(NumTriangleIndices >= ArrayCount(TriangleIndexArray))
	{
		Utilities.Static.RLog("PushTriangleIndex failed -- array overflow", LogCategory);
		return;
	}

	// Triangle can be added only once
	for(i = 0; i < NumTriangleIndices; ++i)
	{
		if(TriangleIndexArray[i] == TriangleNavMeshIndex)
		{
			Utilities.Static.RLog("Attempted to double-add triangle to PolyGroup" @ String(PolyGroupName), LogCategory);
			return;
		}
	}

	// Add triangle
	TriangleIndexArray[NumTriangleIndices] = TriangleNavMeshIndex;
	++NumTriangleIndices;
}

function int GetTriangleNavMeshIndex(int TrianglePolyGroupIndex)
{
	if(TrianglePolyGroupIndex < 0 || TrianglePolyGroupIndex >= NumTriangleIndices)
	{
		return NavLib.Static.InvalidIndex();
	}
	return TriangleIndexArray[TrianglePolyGroupIndex];
}

function int GetTrianglePolyGroupIndex(int TriangleNavMeshIndex)
{
	local int i;

	for(i = 0; i < NumTriangleIndices; ++i)
	{
		if(TriangleIndexArray[i] == TriangleNavMeshIndex)
		{
			return i;
		}
	}
	return NavLib.Static.InvalidIndex();
}

function int GetPortalCount()
{
	return NumPortals;
}

function int GetNumEdgesInPortal(int PortalIndex)
{
	return PortalArray[PortalIndex].GetEdgeCount();
	//return PortalArray[PortalIndex].NumEdgeIndices;
}

function int GetPortalEdge(int PortalIndex, int EdgeIndex)
{
	return PortalArray[PortalIndex].GetEdgeNavMeshIndex(EdgeIndex);
	//return PortalArray[PortalIndex].EdgesIndices[EdgeIndex];
}

// Returns true if this PolyGroup contains a portal to DestPolyGroup
function bool DoesPortalExistToDest(int DestPolyGroupIndex)
{
	local R_NavMeshPortal Portal;
	local int i;

	for(i = 0; i < NumPortals; ++i)
	{
		Portal = PortalArray[i];
		if(Portal != None && Portal.IsPortalBetween(PolyGroupIndex, DestPolyGroupIndex))
		{
			return true;
		}
	}
	return false;
}

/*
// Build this PolyGroup's portal array using triangles from NavMesh
function BuildPortals(R_NavMesh NavMesh)
{
	if(Navmesh == None)
	{
		return;
	}

	Utilities.Static.RLog("Building PolyGroup portals for '" $ PolyGroupName $ "'", LogCategory);

	ClearPortals();
	BuildPortalEdges(NavMesh);
	BuildPortalCostLayers(NavMesh);
}
	*/

/*
function BuildPortalEdges(R_NavMesh NavMesh)
{
	local R_NavNeighborSet NeighborSet;
	local int TriangleIndex;
	local int NeighborTriangleIndex;
	local int NeighborPolyGroupIndex;
	local int SharedEdgeIndex;
	local int PortalIndex;
	local int i, j;

	Utilities.Static.RLog("Building PolyGroup portal edges for '" $ PolyGroupName $ "'", LogCategory);

	// Init portals
	NumPortals = 0;
	for(i = 0; i < ArrayCount(PortalArray); ++i)
	{
		PortalArray[i].NumEdgeIndices = 0;
	}

	// Create portals
	for(i = 0; i < NumTriangleIndices; ++i)
	{
		TriangleIndex = TriangleIndexArray[i];
		NavMesh.GetTriangleNeighborSetUnchecked(TriangleIndex, NeighborSet);
		for(j = 0; j < NeighborSet.NumNeighbors; ++j)
		{
			// For now, only mark portals between adjacent neighbors
			// TODO: Portals between proximal neighbors
			if(NeighborSet.Neighbors[j].NeighborType == NeighborType_Adjacent)
			{
				NeighborTriangleIndex = NeighborSet.Neighbors[j].NeighborIndex;
				NavMesh.GetTrianglePolyGroupIndexUnchecked(NeighborTriangleIndex, NeighborPolyGroupIndex);

				//if(NeighborPolyGroupIndex == NavLib.Static.InvalidIndex()
				//|| NeighborPolyGroupIndex == Self.PolyGroupIndex)
				
				// Only take neighbors from a different poly group
				if(NeighborPolyGroupIndex == Self.PolyGroupIndex)
				{
					continue;
				}

				SharedEdgeIndex = NavMesh.FindSharedEdgeIndex(TriangleIndex, NeighborTriangleIndex);
				if(SharedEdgeIndex != NavLib.Static.InvalidIndex())
				{
					PortalIndex = FindOrCreatePortalForPolyGroup(NeighborPolyGroupIndex);
					if(PortalIndex != NavLib.Static.InvalidIndex())
					{
						AddEdgeToPortal(PortalIndex, SharedEdgeIndex);
						AddPolygonToPortal(PortalIndex, TriangleIndex);
					}
				}
			}
		}
	}
}
	*/

function BuildPortalCostLayers(R_NavMesh NavMesh)
{
	local int PortalIndex;
	local int TriangleIndex, NeighborIndex;
	local int NeighborPolyGroupIndex;
	local int i, j, k;
	local int LocalTriangleIndexArray[ArrayCount(TriangleIndexArray)];
	local int LocalTriangleIndexCount;
	local int LocalVisitedIndexArray[ArrayCount(TriangleIndexArray)];
	local int LocalVisitedIndexCount;
	local R_NavNeighborSet NeighborSet;
	local int InternalTriangleIndex, InternalNeighborIndex;
	local int TempCost;
	local R_NavMeshPortal Portal;

	Utilities.Static.RLog("Building PolyGroup portal cost layers for '" $ PolyGroupName $ "'", LogCategory);

	for(PortalIndex = 0; PortalIndex < NumPortals; ++PortalIndex)
	{
		Portal = PortalArray[PortalIndex];

		// 1: Initialize entire layer to MaxCost
		for(i = 0; i < NumTriangleIndices; ++i)
		{
			PortalCostLayerArray[PortalIndex].Data[i] = MaxCost;
		}

		// 2: Queue all triangles at the interface and calc initial cost
		LocalTriangleIndexCount = 0;
		LocalVisitedIndexCount = 0;
		for(i = 0; i < NumTriangleIndices; ++i)
		{
			TriangleIndex = TriangleIndexArray[i];

			if(Portal.ContainsPolygon(TriangleIndex))
			{
				PortalCostLayerArray[PortalIndex].Data[i] = 0.0;
				LocalTriangleIndexArray[LocalTriangleIndexCount] = TriangleIndex;
				++LocalTriangleIndexCount;
				LocalVisitedIndexArray[LocalVisitedIndexCount] = TriangleIndex;
				++LocalVisitedIndexCount;
			}
		}

		// 3: Starting from the interface, build costs front-to-back
		while(LocalTriangleIndexCount > 0)
		{
			--LocalTriangleIndexCount;
			TriangleIndex = LocalTriangleIndexArray[LocalTriangleIndexCount];

			// Get the internal index of the triangle
			InternalTriangleIndex = GetTrianglePolyGroupIndex(TriangleIndex);

			// Get this triangle's neighbors
			NavMesh.GetTriangleNeighborSetUnchecked(TriangleIndex, NeighborSet);
			for(j = 0; j < NeighborSet.NumNeighbors; ++j)
			{
				NeighborIndex = NeighborSet.Neighbors[j].NeighborIndex;

				NavMesh.GetTrianglePolyGroupIndexUnchecked(NeighborIndex, NeighborPolyGroupIndex);
				if(NeighborPolyGroupIndex != PolyGroupIndex)
				{	// Ignore neighbors from other PolyGroups
					continue;
				}

				// Get neighbor's internal index
				InternalNeighborIndex = GetTrianglePolyGroupIndex(NeighborIndex);
				if(InternalNeighborIndex == NavLib.Static.InvalidIndex())
				{	// Shouldn't happen, but continue if it does
					continue;
				}

				// Calculate candidate cost and update if it's better
				TempCost = PortalCostLayerArray[PortalIndex].Data[InternalTriangleIndex] + NeighborSet.Neighbors[j].NeighborCost;
				if(TempCost < PortalCostLayerArray[PortalIndex].Data[InternalNeighborIndex])
				{
					PortalCostLayerArray[PortalIndex].Data[InternalNeighborIndex] = TempCost;
				}

				// Push neighbor if it has not yet been visited
				for(k = 0; k < LocalVisitedIndexCount; ++k)
				{
					if(LocalVisitedIndexArray[k] == NeighborIndex)
					{
						break;
					}
				}
				if(k == LocalVisitedIndexCount)
				{
					LocalVisitedIndexArray[LocalVisitedIndexCount] = NeighborIndex;
					++LocalVisitedIndexCount;
					LocalTriangleIndexArray[LocalTriangleIndexCount] = NeighborIndex;
					++LocalTriangleIndexCount;
				}
			}
		}
	}
}

/*
// Given a Triangle's NavMesh index, returns the index of that triangle inside the PolyGroup
function int FindInternalTriangleIndex(int TriangleIndex)
{
	local int i;

	for(i = 0; i < NumTriangleIndices; ++i)
	{
		if(TriangleIndexArray[i] == TriangleIndex)
		{
			return i;
		}
	}
	return NavLib.Static.InvalidIndex();
}
	*/

	/*
function bool DoesTriangleContainAnyOfPortalsEdges(R_NavMesh NavMesh, out R_NavMeshPolyGroupPortal InPortal, int TriangleIndex)
{
	local int E0, E1, E2;
	local int i;

	for(i = 0; i < InPortal.NumEdgeIndices; ++i)
	{
		NavMesh.GetTriangleEdgeIndicesUnchecked(TriangleIndex, E0, E1, E2);
		if(InPortal.EdgesIndices[i] == E0
		|| InPortal.EdgesIndices[i] == E1
		|| InPortal.EdgesIndices[i] == E2)
		{
			return true;
		}
	}
	return false;
}
	*/

function float GetPortalCostFromIndex(int TrianglePolyGroupIndex, int PortalIndex)
{
	if(PortalIndex < 0 || PortalIndex >= NumPortals
	|| TrianglePolyGroupIndex < 0 || TrianglePolyGroupIndex >= NumTriangleIndices)
	{
		return 0.0;
	}

	return PortalCostLayerArray[PortalIndex].Data[TrianglePolyGroupIndex];
}

function int GetNeighborPolyGroupIndexForPortalIndex(int PortalIndex)
{
	if(PortalIndex >= 0 && PortalIndex < NumPortals)
	{
		return PortalArray[PortalIndex].GetOtherPolyGroupIndex(PolyGroupIndex);
	}
	return NavLib.Static.InvalidIndex();
}

function int GetPortalIndexForNeighborPolyGroupIndex(int NeighborPolyGroupIndex)
{
	local R_NavMeshPortal Portal;
	local int i;

	for(i = 0; i < NumPortals; ++i)
	{
		Portal = PortalArray[i];
		if(Portal != None && Portal.IsPortalBetween(PolyGroupIndex, NeighborPolyGroupIndex))
		{
			return i;
		}
	}
	return NavLib.Static.InvalidIndex();
}

function bool GetCostFromTriangleToNeighborPolyGroup(
	int TriangleNavMeshIndex,
	int PolyGroupIndex,
	out float OutCost)
{
	local int TrianglePolyGroupIndex;
	local int PortalIndex;

	PortalIndex = GetPortalIndexForNeighborPolyGroupIndex(PolyGroupIndex);
	if(PortalIndex == NavLib.Static.InvalidIndex())
	{
		OutCost = 0.0;
		return false;
	}

	TrianglePolyGroupIndex = GetTrianglePolyGroupIndex(TriangleNavMeshIndex);
	if(TrianglePolyGroupIndex == NavLib.Static.InvalidIndex())
	{
		OutCost = 0.0;
		return false;
	}

	OutCost = PortalCostLayerArray[PortalIndex].Data[TrianglePolyGroupIndex];
	return true;
}

function GetNeighborSet(out R_NavNeighborSet OutNeighborSet)
{
	local float NeighborCost;
	local int i;
	local int PolyGroupA, PolyGroupB;
	local int OtherPolyGroup;
	local R_NavMeshPortal Portal;

	NavObjectClass.Static.NavNeighborSet_Clear(OutNeighborSet);
	for(i = 0; i < NumPortals; ++i)
	{
		NeighborCost = CalcCostToPortal(i);

		Portal = PortalArray[i];
		if(Portal != None)
		{
			Portal.GetAdjacentPolyGroupIndices(PolyGroupA, PolyGroupB);
			if(PolyGroupA == PolyGroupIndex)	OtherPolyGroup = PolyGroupB;
			else								OtherPolyGroup = PolyGroupA;
		}

		if(!NavObjectClass.Static.NavNeighborSet_AddNeighbor(
			OutNeighborSet,
			R_NavNeighborType.NeighborType_Adjacent,
			NeighborCost,
			OtherPolyGroup))
		{
			break;
		}
	}
}

// Return the inner polygroup cost to get to a given portal
function float CalcCostToPortal(int PortalIndex)
{
	local float TotalCosts;
	local R_NavMeshPortal Portal;
	local int NumPolygonIndices;
	local int PolygonNavMeshIndex;
	local int PolygonPolyGroupIndex;
	local int i, j;

	TotalCosts = 0.0;
	for(i = 0; i < NumPortals; ++i)
	{
		Portal = PortalArray[i];
		if(Portal == None)
		{
			continue;
		}

		NumPolygonIndices = Portal.GetPolygonCount();
		for(j = 0; j < NumPolygonIndices; ++j)
		{
			PolygonNavMeshIndex = Portal.GetPolygonNavMeshIndex(j);
			PolygonPolyGroupIndex = GetTrianglePolyGroupIndex(PolygonNavMeshIndex);
			if(PolygonPolyGroupIndex != NavLib.Static.InvalidIndex())
			{
				TotalCosts += PortalCostLayerArray[PortalIndex].Data[PolygonPolyGroupIndex];
			}
		}
	}
	return TotalCosts / NumPortals;
}

function AddPortalUnique(int PortalNavMeshIndex)
{
	local String LogWarning;
	local int i;

	for(i = 0; i < NumPortals; ++i)
	{
		if(PortalIndexArray[i] == PortalNavMeshIndex)
		{
			return;
		}
	}

	PortalIndexArray[NumPortals] = PortalNavMeshIndex;
	++NumPortals;
}