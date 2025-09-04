//==============================================================================
//	R_NavMesh
//==============================================================================
class R_NavMesh_Implementation extends R_NavMesh;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'NavMesh';

const NavLib = Class'RBots.R_NavLibrary';
const GeomLib = Class'RBase.R_AGeometryLibrary';

// NavMesh vertex structure
struct NavMeshVertex
{
	var Vector Location;
};
var private NavMeshVertex VertexArray[10000];
var private int NumVertices;

// NavMesh edge structure
struct NavMeshEdge
{
	var int V[2];	// Indices into VertexArray
	var int Flags;	// Flags associated with this edge
};
var private NavMeshEdge EdgeArray[10000];
var private int NumEdges;

// NavMesh triangle structure
struct NavMeshTriangle
{
	var int V[3];	// Indices into VertexArray
	var int E[3];	// Indices into EdgeArray
};
var private NavMeshTriangle TriangleArray[10000];
var private int NumTriangles;

var private R_NavNeighborSet NeighborSets[ArrayCount(TriangleArray)];


function InitializeNavMesh()
{
	Clear();
}

function Clear()
{
	NumVertices = 0;
	NumEdges = 0;
	NumTriangles = 0;
}

function PushVertex(Vector VertexLocation)
{
	if(NumVertices < 0)
	{
		Utilities.Static.RLog("PushVertex failed -- bad index:" @ NumVertices, LogCategory);
		return;
	}
	if(NumVertices >= ArrayCount(VertexArray))
	{
		Utilities.Static.RLog("PushVertex failed -- array overflow", LogCategory);
		return;
	}

	VertexArray[NumVertices].Location = VertexLocation;
	++NumVertices;
}

function PushEdge(int VertexIndex0, int VertexIndex1)
{
	if(NumEdges < 0)
	{
		Utilities.Static.RLog("PushEdge failed -- bad index:" @ NumEdges, LogCategory);
		return;
	}
	if(NumEdges >= ArrayCount(EdgeArray))
	{
		Utilities.Static.RLog("PushEdge failed -- array overflow", LogCategory);
		return;
	}

	EdgeArray[NumEdges].V[0] = Min(VertexIndex0, VertexIndex1);
	EdgeArray[NumEdges].V[1] = Max(VertexIndex0, VertexIndex1);
	EdgeArray[NumEdges].Flags = 0x00;
	++NumEdges;
}

// Attempts to find a previously added edge, or adds a new one if there is not already an entry
// Returns the index of the found or newly created edge
function int FindOrPushEdge(int V0, int V1)
{
	local int MinIndex, MaxIndex;
	local int i;

	MinIndex = Min(V0, V1);
	MaxIndex = Max(V0, V1);

	for(i = 0; i < NumEdges; ++i)
	{
		if(EdgeArray[i].V[0] == MinIndex && EdgeArray[i].V[1] == MaxIndex)
		{
			return i;
		}
	}

	PushEdge(MinIndex, MaxIndex);
	return NumEdges - 1;
}

function int FindEdge(int V0, int V1)
{
	local int MinIndex, MaxIndex;
	local int i;

	MinIndex = Min(V0, V1);
	MaxIndex = Max(V0, V1);

	for(i = 0; i < NumEdges; ++i)
	{
		if(EdgeArray[i].V[0] == MinIndex && EdgeArray[i].V[1] == MaxIndex)
		{
			return i;
		}
	}

	return NavLib.Static.InvalidIndex();
}

// Given three vertices in clockwise winding order, adds them as a triangle
function PushTriangleAsVertices(int V0, int V1, int V2)
{
	local int E0, E1, E2;

	if(NumTriangles < 0)
	{
		Utilities.Static.RLog("PushTriangleAsVertices failed -- bad index:" @ NumTriangles, LogCategory);
		return;
	}
	if(NumTriangles >= ArrayCount(TriangleArray))
	{
		Utilities.Static.RLog("PushTriangleAsVertices failed -- array overflow", LogCategory);
		return;
	}

	E0 = FindOrPushEdge(V0, V1);
	E1 = FindOrPushEdge(V1, V2);
	E2 = FindOrPushEdge(V2, V0);

	TriangleArray[NumTriangles].V[0] = V0;
	TriangleArray[NumTriangles].V[1] = V1;
	TriangleArray[NumTriangles].V[2] = V2;
	TriangleArray[NumTriangles].E[0] = E0;
	TriangleArray[NumTriangles].E[1] = E1;
	TriangleArray[NumTriangles].E[2] = E2;
	++NumTriangles;
}

// Validate the NavMesh
function bool ValidateNavMesh(out String OutFailedLogString)
{
	OutFailedLogString = "";

	if(!ValidateNavMeshVertices(OutFailedLogString))
	{
		return false;
	}
	if(!ValidateNavMeshEdges(OutFailedLogString))
	{
		return false;
	}
	if(!ValidateNavMeshTriangles(OutFailedLogString))
	{
		return false;
	}

	return true;
}

//	Validate vertex data in the NavMesh
function bool ValidateNavMeshVertices(out String OutFailedLogString)
{
	if(NumVertices < 0 || NumVertices > ArrayCount(VertexArray))
	{
		OutFailedLogString = "Bad NumVertices:" @ NumVertices;
		return false;
	}

	return true;
}

//	Validate edge data in the NavMesh
//	Assumes that Vertex data has already been validated
function bool ValidateNavMeshEdges(out String OutFailedLogString)
{
	local int i, j;

	if(NumEdges < 0 || NumEdges > ArrayCount(EdgeArray))
	{
		OutFailedLogString = "Bad NumEdges:" @ NumEdges;
		return false;
	}

	for(i = 0; i < NumEdges; ++i)
	{
		for(j = 0; j < 2; ++j)
		{
			if(EdgeArray[i].V[j] < 0 || EdgeArray[i].V[j] >= NumVertices)
			{
				OutFailedLogString = "Edge index" @ i @ "has bad V[" $ j $ "] index:" @ EdgeArray[i].V[j];
				return false;
			}
		}
	}

	return true;
}

//	Validate NavMesh Triangle data
//	Assumes that Edge and Vertex data have both been validated
function bool ValidateNavMeshTriangles(out String OutFailedLogString)
{
	local int i, j;

	if(NumTriangles < 0 || NumTriangles > ArrayCount(TriangleArray))
	{
		OutFailedLogString = "Bad NumTriangles:" @ NumTriangles;
		return false;
	}

	for(i = 0; i < NumTriangles; ++i)
	{
		for(j = 0; j < 3; ++j)
		{
			if(TriangleArray[i].E[j] < 0 || TriangleArray[i].E[j] >= NumEdges)
			{
				OutFailedLogString = "Triangle index" @ i @ "has bad E[" $ j $ "] index:" @ TriangleArray[i].E[j];
				return false;
			}
		}
	}

	return true;
}

// Perform post-build and post-validation processing
function PostProcessNavMesh()
{
	InitializePostProcessEdgeFlags();
	InitializeNeighborSets();
	BuildAdjacentSet();
	BuildProximalSet();
}

function InitializePostProcessEdgeFlags()
{
	local int i;

	// Mark all edges in the mesh as borders
	// They will be unmarked one at a time as they are discovered to be shared by two triangles
	// This occurs in BuildAdjacentSet
	for(i = 0; i < NumEdges; ++i)
	{
		EdgeArray[i].Flags = EdgeArray[i].Flags | NavLib.Static.EdgeFlag_Border();
	}
}

function InitializeNeighborSets()
{
	local int i;

	// Init all neighbor sets
	for(i = 0; i < NumTriangles; ++i)
	{
		NeighborSets[i].NumNeighbors = 0;
	}
}

// Generates all data in the AdjacencyArray, identifying which nodes are connected, which
// edges are shared, and the costs between connections
function BuildAdjacentSet()
{
	local float Cost;
	local int EdgeIndex;
	local int i, j;

	Utilities.Static.RLog("Building adjacent set", LogCategory);

	for(i = 0; i < NumTriangles - 1; ++i)
	{
		for(j = i + 1; j < NumTriangles; ++j)
		{
			EdgeIndex = FindSharedEdgeIndex(i, j);
			if(EdgeIndex != NavLib.Static.InvalidIndex())
			{
				Cost = CalcAdjacencyCost(i, j, EdgeIndex);
				NavObjectClass.Static.NavNeighborSet_AddNeighbor(NeighborSets[i], NeighborType_Adjacent, Cost, j);
				NavObjectClass.Static.NavNeighborSet_AddNeighbor(NeighborSets[j], NeighborType_Adjacent, Cost, i);

				// Unmark this edge as a border edge
				EdgeArray[EdgeIndex].Flags = EdgeArray[EdgeIndex].Flags & ~NavLib.Static.EdgeFlag_Border();
			}
		}
	}
}

// If an edge is shared between the two triangles, returns the index of that edge
// Returns InvalidIndex otherwise
function int FindSharedEdgeIndex(int T0, int T1)
{
	local int i;

	for(i = 0; i < 3; ++i)
	{
		if(TriangleArray[T0].E[0] == TriangleArray[T1].E[i])
		{
			return TriangleArray[T0].E[0];
		}
		if(TriangleArray[T0].E[1] == TriangleArray[T1].E[i])
		{
			return TriangleArray[T0].E[1];
		}
		if(TriangleArray[T0].E[2] == TriangleArray[T1].E[i])
		{
			return TriangleArray[T0].E[2];
		}
	}

	return NavLib.Static.InvalidIndex();
}

function float CalcAdjacencyCost(int T0, int T1, int E)
{
	local int V0[3], V1[3], EV[2];
	local Vector VLoc0[3], VLoc1[3], EVLoc[2];
	local float Distance0, Distance1;
	local int i;

	GetTriangleVertexIndicesUnchecked(T0, V0[0], V0[1], V0[2]);
	GetTriangleVertexIndicesUnchecked(T1, V1[0], V1[1], V1[2]);
	GetEdgeVertexIndicesUnchecked(E, EV[0], EV[1]);

	for(i = 0; i < 3; ++i)	GetVertexUnchecked(V0[i], VLoc0[i]);
	for(i = 0; i < 3; ++i)	GetVertexUnchecked(V1[i], VLoc1[i]);
	for(i = 0; i < 2; ++i)	GetVertexUnchecked(EV[i], EVLoc[i]);
	
	Distance0 = NavLib.Static.CalcTriangleCenterEdgeDistance(VLoc0, EVLoc);
	Distance1 = NavLib.Static.CalcTriangleCenterEdgeDistance(VLoc1, EVLoc);
	return Distance0 + Distance1;
}

function BuildProximalSet()
{
	local Vector VLoc0[3], VLoc1[3];
	local float ProximalDistance;
	local float ProximalCost;
	local int i, j;

	Utilities.Static.RLog("Building proximal set", LogCategory);

	for(i = 0; i < NumTriangles - 1; ++i)
	{
		GetTriangleVertexLocationsUnchecked(i, VLoc0);
		for(j = i + 1; j < NumTriangles; ++j)
		{
			if(NavObjectClass.Static.NavNeighborSet_ContainsNeighbor(NeighborSets[i], j))
			{ 	// If i already contains j, continue
				continue;
			}
			if(NavObjectClass.Static.NavNeighborSet_AtMaxCapacity(NeighborSets[i]))
			{	// Break to outer loop if index i is full
				break;
			}
			if(NavObjectClass.Static.NavNeighborSet_AtMaxCapacity(NeighborSets[j]))
			{	// Skip if index j is full
				continue;
			}

			GetTriangleVertexLocationsUnchecked(j, VLoc1);
			ProximalDistance = GeomLib.Static.DistanceTriangleToTriangle2D(VLoc0, VLoc1);
			if(ProximalDistance <= 128.0) // Will need to figure this value out, use 128 for now
			{
				ProximalCost = CalcProximalNeighborCost(VLoc0, VLoc1, ProximalDistance);

				// Mark i and j as proximal neighbors
				// TODO: Right now, they have the same cost, but the cost from i to j and j to i will not be the same
				// i.e. if you can drop from i to j, but you have to climb from j to get to i
				NavObjectClass.Static.NavNeighborSet_AddNeighbor(NeighborSets[i], NeighborType_Proximal, ProximalCost, j);
				NavObjectClass.Static.NavNeighborSet_AddNeighbor(NeighborSets[j], NeighborType_Proximal, ProximalCost, i);
			}
		}
	}
}

// CalcProximalCost
// Calculate the cost to go from Node0 to Node1, given the XY proximal distance
function float CalcProximalNeighborCost(out Vector InVLoc0[3], out Vector InVLoc1[3], float ProximalXYDistance)
{
	local Vector C0, C1;
	local int i;

	// For now, just return distance from centers
	for(i = 0; i < 3; ++i)
	{
		C0 += InVLoc0[i];
		C1 += InVLoc1[i];
	}
	C0 *= (1.0/3.0);
	C1 *= (1.0/3.0);

	return (ProximalXYDistance + Abs(C1.Z - C0.Z)) * 0.1; // XY Distance between nodes + Z difference
}

function int GetVertexCount() { return NumVertices; }
function int GetEdgeCount() { return NumEdges; }
function int GetTriangleCount() { return NumTriangles; }

function GetVertexUnchecked(int Index, out Vector OutLocation)
{
	OutLocation = VertexArray[Index].Location;
}

function GetEdgeVertexIndicesUnchecked(int Index, out int OutV0, out int OutV1)
{
	OutV0 = EdgeArray[Index].V[0];
	OutV1 = EdgeArray[Index].V[1];
}

function GetEdgeFlagsUnchecked(int Index, out int OutEdgeFlags)
{
	OutEdgeFlags = EdgeArray[Index].Flags;
}

function SetEdgePassable(int V0, int V1, bool bPassable)
{
	local int EdgeIndex;

	EdgeIndex = FindEdge(V0, V1);
	if(EdgeIndex == NavLib.Static.InvalidIndex())
	{
		Utilities.Static.RLog("SetEdgePassable failed for:" @ V0 $ "," $ V1);
		return;
	}

	if(!bPassable)
	{
		EdgeArray[EdgeIndex].Flags = EdgeArray[EdgeIndex].Flags | NavLib.Static.EdgeFlag_Impassable();
	}
	else
	{
		EdgeArray[EdgeIndex].Flags = EdgeArray[EdgeIndex].Flags & ~NavLib.Static.EdgeFlag_Impassable();
	}
	
}

function GetTriangleVertexLocationsUnchecked(int Index, out Vector VLoc[3])
{
	VLoc[0] = VertexArray[TriangleArray[Index].V[0]].Location;
	VLoc[1] = VertexArray[TriangleArray[Index].V[1]].Location;
	VLoc[2] = VertexArray[TriangleArray[Index].V[2]].Location;
}

function GetTriangleVertexIndicesUnchecked(int Index, out int OutV0, out int OutV1, out int OutV2)
{
	OutV0 = TriangleArray[Index].V[0];
	OutV1 = TriangleArray[Index].V[1];
	OutV2 = TriangleArray[Index].V[2];
}

function GetTriangleEdgeIndicesUnchecked(int Index, out int OutE0, out int OutE1, out int OutE2)
{
	OutE0 = TriangleArray[Index].E[0];
	OutE1 = TriangleArray[Index].E[1];
	OutE2 = TriangleArray[Index].E[2];
}

function GetTriangleNeighborSetUnchecked(int Index, out R_NavNeighborSet OutNodeNeighborSet)
{
	NavObjectClass.Static.NavNeighborSet_Copy(NeighborSets[Index], OutNodeNeighborSet);
}

function bool GetTriangleSharedEdgeLocationsUnchecked(int IndexA, int IndexB, out Vector OutLeftLocation, out Vector OutRightLocation)
{
	local int VerticesA[3], VerticesB[3];
	local int Shared[3], SharedCount;
	local Vector EdgePoints[2];
	local Vector NormalA, CenterA;
	local Vector NormalB, CenterB;
	local Vector TravelDirection, EdgeDirection;
	local Vector CrossDirections;
	local float NormalDotCross;
	local int i, j;

	GetTriangleVertexIndicesUnchecked(IndexA, VerticesA[0], VerticesA[1], VerticesA[2]);
	GetTriangleVertexIndicesUnchecked(IndexB, VerticesB[0], VerticesB[1], VerticesB[2]);

	SharedCount = 0;
	for(i = 0; i < 3; ++i)
	{
		for(j = 0; j < 3; ++j)
		{
			if(VerticesA[i] == VerticesB[j])
			{
				Shared[SharedCount] = VerticesA[i];
				++SharedCount;
			}
		}
	}

	if(SharedCount != 2)
	{
		OutLeftLocation = Vect(0,0,0);
		OutRightLocation = Vect(0,0,0);
		return false;
	}

	GetVertexUnchecked(Shared[0], EdgePoints[0]);
	GetVertexUnchecked(Shared[1], EdgePoints[1]);

	GetTriangleNormalAndCenterUnchecked(IndexA, NormalA, CenterA);
	GetTriangleNormalAndCenterUnchecked(IndexB, NormalB, CenterB);

	TravelDirection = CenterB - CenterA;
	EdgeDirection = EdgePoints[1] - EdgePoints[0];
	CrossDirections = TravelDirection Cross EdgeDirection;
	NormalDotCross = NormalA Dot CrossDirections;

	if(NormalDotCross > 0)
	{
		OutLeftLocation = EdgePoints[0];
		OutRightLocation = EdgePoints[1];
	}
	else
	{
		OutLeftLocation = EdgePoints[1];
		OutRightLocation = EdgePoints[0];
	}

	return true;
}

function GetTriangleNormalAndCenterUnchecked(int Index, out Vector OutNormal, out Vector OutCenter)
{
	local int V[3];
	local Vector VLoc[3];
	local int i;

	GetTriangleVertexIndicesUnchecked(Index, V[0], V[1], V[2]);
	for(i = 0; i < 3; ++i)
	{
		GetVertexUnchecked(V[i], VLoc[i]);
	}

	OutNormal = Normal((VLoc[1] - VLoc[0]) Cross (VLoc[2] - VLoc[0]));
	OutCenter = VLoc[0] + VLoc[1] + VLoc[2];
	OutCenter.X /= 3.0;
	OutCenter.Y /= 3.0;
	OutCenter.Z /= 3.0;
}