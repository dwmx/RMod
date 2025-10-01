//==============================================================================
//	R_NavMeshPortal_Impl
//	A collection of edges separating two groups of polygons
//==============================================================================
class R_NavMeshPortal_Impl extends R_NavMeshPortal;

const Utilities = Class'RBots.R_BotUtilities';
const NavLib = Class'RBots.R_NavLibrary';

const LogCategory = 'NavMeshPortal';

// The NavMesh Edges defining this Portal
var private int EdgeIndexArray[32];
var private int NumEdgeIndices;

// Precomputed costs from this Portal to every other PolyGroup in the NavMesh
// Indexed directly by PolyGroupIndex
// Note that the size of this array must be at least NavMesh Portal array size
var private float PolyGroupCostArray[32];

// The PolyGroup indices on either side of this Portal, no particular order
var private int AdjacentPolyGroupIndices[2];

//------------------------------------------------------------------------------

function InitializePortal()
{
	NumEdgeIndices = 0;
}

function SetAdjacentPolyGroupIndices(int PolyGroupIndexA, int PolyGroupIndexB)
{
	AdjacentPolyGroupIndices[0] = PolyGroupIndexA;
	AdjacentPolyGroupIndices[1] = PolyGroupIndexB;
}

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

function PushEdge(int EdgeNavMeshIndex)
{
	if(NumEdgeIndices >= ArrayCount(EdgeIndexArray))
	{
		Utilities.Static.RLog("PushEdge failed -- array overflow", LogCategory);
		return;
	}
	EdgeIndexArray[NumEdgeIndices] = EdgeNavMeshIndex;
	++NumEdgeIndices;
}

function int GetEdgeCount()
{
	return NumEdgeIndices;
}