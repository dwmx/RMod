//==============================================================================
//	R_BotNavMesh
//	Represents a NavMesh
//	This mesh needs to be manually constructed on a per-map basis
//==============================================================================
class R_BotNavMesh extends Actor;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'NavMesh';

const VERTEX_ARRAY_SIZE = 1024;
var private Vector VertexArray[1024]; // Must match VERTEX_ARRAY_SIZE
var private int VertexCount;

struct NavMeshTriangle
{
	var int IndexA, IndexB, IndexC;
};
const TRIANGLE_ARRAY_SIZE = 1024;
var private NavMeshTriangle TriangleArray[1024]; // Must match TRIANGLE_ARRAY_SIZE
var private int TriangleCount;

struct AdjacencyList
{
	//var int IndexA, IndexB, IndexC;
	//var float CostA, CostB, CostC;
	var int Indices[3];
	var float Costs[3];
};
var private AdjacencyList AdjacencyListArray[1024]; // Must match TRIANGLE_ARRAY_SIZE
var private bool bBadAdjacents; // If true, there are bad graph adjacencies

const INVALID_VERTEX_INDEX = -1;
const INVALID_TRIANGLE_INDEX = -1;

// Class and instance for path finding
var Class<R_PathFinder> PathFinderClass;
var R_PathFinder PathFinder;

var Class<R_PathPostProcessor> PathPostProcessorClass;
var R_PathPostProcessor PathPostProcessor;

event PreBeginPlay()
{
	Super.PreBeginPlay();
	Clear();
	InitPathFinder();
}

function InitPathFinder()
{
	// Instantiate PathFinder
	if(PathFinder != None)
	{
		PathFinder = None;
	}

	if(PathFinderClass != None)
	{
		Utilities.Static.RLog("NavMesh initializing PathFinder from class" @ PathFinderClass, LogCategory);
		PathFinder = new(None) PathFinderClass;

		if(PathFinder == None)
		{
			Utilities.Static.RLog("Initialization of PathFinder for NavMesh failed -- failed to instantiate", LogCategory);
		}
	}
	else
	{
		Utilities.Static.RLog("Initialization of PathFinder for NavMesh failed -- PathFinderClass == None", LogCategory);
	}
	
	// Instantiate PathPostProcessor
	if(PathPostProcessor != None)
	{
		PathPostProcessor = None;
	}

	if(PathPostProcessorClass != None)
	{
		Utilities.Static.RLog("NavMesh initializing PathPostProcessor from class" @ PathPostProcessorClass, LogCategory);
		PathPostProcessor = new(None) PathPostProcessorClass;

		if(PathPostProcessor == None)
		{
			Utilities.Static.RLog("Initialization of PathPostProcessor for NavMesh failed -- failed to instantiate", LogCategory);
		}
	}
	else
	{
		Utilities.Static.RLog("Initialization of PathPostProcess for NavMesh failed -- PathPostProcessClass == None", LogCategory);
	}
}

function Clear()
{
	local int i, j;

	VertexCount = 0;
	TriangleCount = 0;

	for(i = 0; i < VERTEX_ARRAY_SIZE; ++i)
	{
		VertexArray[i] = Vect(0,0,0);
	}

	for(i = 0; i < TRIANGLE_ARRAY_SIZE; ++i)
	{
		TriangleArray[i].IndexA = INVALID_VERTEX_INDEX;
		TriangleArray[i].IndexB = INVALID_VERTEX_INDEX;
		TriangleArray[i].IndexC = INVALID_VERTEX_INDEX;

		for(j = 0; j < 3; ++j)
		{
			AdjacencyListArray[i].Indices[j] = INVALID_TRIANGLE_INDEX;
		}
	}
}

function PushVertex(Vector Vertex)
{
	if(VertexCount < 0)
	{
		Utilities.Static.RLog("Bad VertexCount:" @ VertexCount, LogCategory);
		return;
	}
	if(VertexCount >= VERTEX_ARRAY_SIZE)
	{
		Utilities.Static.RLog("Attempted call to PushVertex on full VertexArray", LogCategory);
		return;
	}

	VertexArray[VertexCount] = Vertex;
	++VertexCount;
}

function PushTriangle(int VertexIndexA, int VertexIndexB, int VertexIndexC)
{
	if(TriangleCount < 0)
	{
		Utilities.Static.RLog("Bad TriangleCount:" @ TriangleCount, LogCategory);
		return;
	}
	if(TriangleCount >= TRIANGLE_ARRAY_SIZE)
	{
		Utilities.Static.RLog("Attempted call to PushTriangle on full TriangleArray", LogCategory);
		return;
	}

	TriangleArray[TriangleCount].IndexA = VertexIndexA;
	TriangleArray[TriangleCount].IndexB = VertexIndexB;
	TriangleArray[TriangleCount].IndexC = VertexIndexC;
	++TriangleCount;
}

function ValidateAndPostProcess()
{
	Utilities.Static.RLog("Validating NavMesh:" @ VertexCount @ "vertices," @ TriangleCount @ "triangles", LogCategory);

	BuildAdjacencyListArray();
}

function BuildAdjacencyListArray()
{
	local int i, j;
	local int NumSharedVertices;

	for(i = 0; i < TRIANGLE_ARRAY_SIZE; ++i)
	{
		for(j = 0; j < 3; ++j)
		{
			AdjacencyListArray[i].Indices[j] = INVALID_TRIANGLE_INDEX;
		}
	}

	for(i = 0; i < TriangleCount - 1; ++i)
	{
		for(j = i + 1; j < TriangleCount; ++j)
		{
			if(ShareAtLeastTwoVertices(i, j))
			{
				MarkTrianglesAdjacent(i, j);
			}
		}
	}
}

function bool ShareAtLeastTwoVertices(int TriangleIndexA, int TriangleIndexB)
{
	local int NumMatches;

	NumMatches = 0;

	if(	TriangleArray[TriangleIndexA].IndexA == TriangleArray[TriangleIndexB].IndexA
	|| 	TriangleArray[TriangleIndexA].IndexA == TriangleArray[TriangleIndexB].IndexB
	||	TriangleArray[TriangleIndexA].IndexA == TriangleArray[TriangleIndexB].IndexC)
	{
		++NumMatches;
	}

	if(	TriangleArray[TriangleIndexA].IndexB == TriangleArray[TriangleIndexB].IndexA
	|| 	TriangleArray[TriangleIndexA].IndexB == TriangleArray[TriangleIndexB].IndexB
	||	TriangleArray[TriangleIndexA].IndexB == TriangleArray[TriangleIndexB].IndexC)
	{
		++NumMatches;
		if(NumMatches == 2)
		{
			return true;
		}
	}

	if(	TriangleArray[TriangleIndexA].IndexC == TriangleArray[TriangleIndexB].IndexA
	|| 	TriangleArray[TriangleIndexA].IndexC == TriangleArray[TriangleIndexB].IndexB
	||	TriangleArray[TriangleIndexA].IndexC == TriangleArray[TriangleIndexB].IndexC)
	{
		++NumMatches;
		if(NumMatches == 2)
		{
			return true;
		}
	}

	return false;
}

function MarkTrianglesAdjacent(int TriangleIndexA, int TriangleIndexB)
{
	local int i, j;
	local float Cost;

	bBadAdjacents = false;

	// Ensure that triangles are not already marked adjacent
	for(i = 0; i < 3; ++i)
	{
		if(	AdjacencyListArray[TriangleIndexA].Indices[i] == TriangleIndexB
		||	AdjacencyListArray[TriangleIndexB].Indices[i] == TriangleIndexA)
		{
			bBadAdjacents = true;
			Utilities.Static.RLog("NavMesh bad adjacents -- attempted to double-add adjacent triangles", LogCategory);
			return;
		}
	}

	// Find indices for each triangle
	for(i = 0; i < 3; ++i)
	{
		if(AdjacencyListArray[TriangleIndexA].Indices[i] == INVALID_TRIANGLE_INDEX)
		{
			break;
		}
	}

	for(j = 0; j < 3; ++j)
	{
		if(AdjacencyListArray[TriangleIndexB].Indices[j] == INVALID_TRIANGLE_INDEX)
		{
			break;
		}
	}

	if(i == 3 || i == INVALID_TRIANGLE_INDEX || j == 3 || j == INVALID_TRIANGLE_INDEX)
	{
		bBadAdjacents = true;
		Utilities.Static.RLog("NavMesh bad adjacents -- attempted to add more than 3 adjacents", LogCategory);
		return;
	}

	// Mark triangles adjacent
	AdjacencyListArray[TriangleIndexA].Indices[i] = TriangleIndexB;
	AdjacencyListArray[TriangleIndexB].Indices[j] = TriangleIndexA;

	Cost = CalcAdjacentTriangleDistance(TriangleIndexA, TriangleIndexB);
	AdjacencyListArray[TriangleIndexA].Costs[i] = Cost;
	AdjacencyListArray[TriangleIndexB].Costs[j] = Cost;
}

// Given two adjacent triangles, calculates the distance between them
function float CalcAdjacentTriangleDistance(int IndexA, int IndexB)
{
	local Vector NormalA, CenterA;
	local Vector NormalB, CenterB;
	local Vector Delta, DeltaProjA, DeltaProjB;
	local int i;

	if(IndexA == INVALID_TRIANGLE_INDEX || IndexB == INVALID_TRIANGLE_INDEX)
	{
		return 0.0f;
	}

	GetTriangleNormalAndCenterUnchecked(IndexA, NormalA, CenterA);
	GetTriangleNormalAndCenterUnchecked(IndexB, NormalB, CenterB);
	
	Delta = CenterB - CenterA;
	DeltaProjA = Delta - (NormalA * (Delta Dot NormalA));
	DeltaProjB = Delta - (NormalB * (Delta Dot NormalB));

	return 0.5 * (VSize(DeltaProjA) + VSize(DeltaProjB));
}

function bool HasBadAdjacents()
{
	return bBadAdjacents;
}

function int GetVertexCount()
{
	return VertexCount;
}

function GetVertexUnchecked(int Index, out Vector OutVertex)
{
	OutVertex = VertexArray[Index];
}

function int GetTriangleCount()
{
	return TriangleCount;
}

function GetTriangleUnchecked(int Index, out int OutIndexA, out int OutIndexB, out int OutIndexC)
{
	OutIndexA = TriangleArray[Index].IndexA;
	OutIndexB = TriangleArray[Index].IndexB;
	OutIndexC = TriangleArray[Index].IndexC;
}

function GetTriangleVerticesUnchecked(int Index, out Vector OutVertexA, out Vector OutVertexB, out Vector OutVertexC)
{
	local int IndexA, IndexB, IndexC;

	GetTriangleUnchecked(Index, IndexA, IndexB, IndexC);
	GetVertexUnchecked(IndexA, OutVertexA);
	GetVertexUnchecked(IndexB, OutVertexB);
	GetVertexUnchecked(IndexC, OutVertexC);
}

// Returns the normal for the specified triangle index
function GetTriangleNormalUnchecked(int Index, out Vector OutNormal)
{
	local int IndexA, IndexB, IndexC;
	local Vector VertexA, VertexB, VertexC;

	GetTriangleUnchecked(Index, IndexA, IndexB, IndexC);
	GetVertexUnchecked(IndexA, VertexA);
	GetVertexUnchecked(IndexB, VertexB);
	GetVertexUnchecked(IndexC, VertexC);

	OutNormal = Normal((VertexB - VertexA) Cross (VertexC - VertexA));
}

// Returns both the normal and the center for the specified triangle index
function GetTriangleNormalAndCenterUnchecked(int Index, out Vector OutNormal, out Vector OutCenter)
{
	local int IndexA, IndexB, IndexC;
	local Vector VertexA, VertexB, VertexC;

	GetTriangleUnchecked(Index, IndexA, IndexB, IndexC);
	GetVertexUnchecked(IndexA, VertexA);
	GetVertexUnchecked(IndexB, VertexB);
	GetVertexUnchecked(IndexC, VertexC);

	OutNormal = Normal((VertexB - VertexA) Cross (VertexC - VertexA));
	OutCenter.X = (VertexA.X + VertexB.X + VertexC.X) / 3.0;
	OutCenter.Y = (VertexA.Y + VertexB.Y + VertexC.Y) / 3.0;
	OutCenter.Z = (VertexA.Z + VertexB.Z + VertexC.Z) / 3.0;
}

// Returns the three adjacent indices for the specified triangle index
// Out indices will be -1 to indicate no adjacency
function GetTriangleAdjacentsUnchecked(int Index, out int OutIndexA, out int OutIndexB, out int OutIndexC)
{
	OutIndexA = AdjacencyListArray[Index].Indices[0];
	OutIndexB = AdjacencyListArray[Index].Indices[1];
	OutIndexC = AdjacencyListArray[Index].Indices[2];
}

// Returns the three adjacent indices and their travel costs for the specified triangle index
// Out indices will be -1 to indicate no adjacency
function GetTriangleAdjacentsAndCostsUnchecked(int Index, out int OutIndexA, out int OutIndexB, out int OutIndexC, out float OutCostA, out float OutCostB, out float OutCostC)
{
	GetTriangleAdjacentsUnchecked(Index, OutIndexA, OutIndexB, OutIndexC);
	OutCostA = AdjacencyListArray[Index].Costs[0];
	OutCostB = AdjacencyListArray[Index].Costs[1];
	OutCostC = AdjacencyListArray[Index].Costs[2];
}

// Returns the locations of the two vertices in the edge shared by the specified triangles
// Left and Right are in reference to travel direction when going from IndexA to IndexB
function bool GetSharedEdgePointsUnchecked(int IndexA, int IndexB, out Vector OutLeft, out Vector OutRight)
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

	GetTriangleUnchecked(IndexA, VerticesA[0], VerticesA[1], VerticesA[2]);
	GetTriangleUnchecked(IndexB, VerticesB[0], VerticesB[1], VerticesB[2]);

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
		OutLeft = Vect(0,0,0);
		OutRight = Vect(0,0,0);
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
		OutLeft = EdgePoints[0];
		OutRight = EdgePoints[1];
	}
	else
	{
		OutLeft = EdgePoints[1];
		OutRight = EdgePoints[0];
	}

	return true;
}

// Finds the node (polygon) which contains the given location and returns index
// If no containing node found, returns false and -1 index
function bool FindContainingNode(Vector WorldLocation, out int OutIndex)
{
	local int i;

	for(i = 0; i < TriangleCount; ++i)
	{
		if(DoesTriangleContainLocationUnchecked(i, WorldLocation))
		{
			OutIndex = i;
			return true;
		}
	}

	OutIndex = -1;
	return false;
}

// Returns true if the specified WorldLocation is contained within the given triangle within
// some tolerance
function bool DoesTriangleContainLocationUnchecked(int Index, Vector WorldLocation)
{
	local Vector TriangleNormal, TriangleCenter;
	local Vector VertexA, VertexB, VertexC;
	local Vector v0, v1, v2;
	local float d00, d01, d11, d20, d21;
	local float Alpha, Beta, Gamma;
	local float Denominator;

	// Location must be on positive side of triangle
	GetTriangleNormalAndCenterUnchecked(Index, TriangleNormal, TriangleCenter);
	if((WorldLocation - TriangleCenter) Dot TriangleNormal < 0.0)
	{
		return false;
	}

	GetTriangleVerticesUnchecked(Index, VertexA, VertexB, VertexC);

	v0 = VertexB - VertexA;
	v1 = VertexC - VertexA;
	v2 = WorldLocation - VertexA;

	d00 = v0 Dot v0;
	d01 = v0 Dot v1;
	d11 = v1 Dot v1;
	d20 = v2 Dot v0;
	d21 = v2 Dot v1;
	Denominator = d00 * d11 - d01 * d01;

	Beta = (d11 * d20 - d01 * d21) / Denominator;
	Gamma = (d00 * d21 - d01 * d20) / Denominator;
	Alpha = 1.0 - Beta - Gamma;

	if(Alpha >= 0.0 && Beta >= 0.0 && Gamma >= 0.0)
	{
		return true;
	}

	return false;
}

// Finds a path from StartLocation to EndLocation as an array of path points
// Returns true if a path was successfully found
//	PathFinder -- Performs index-based search on NavMesh nodes
//	PathPostProcessor -- Translates indices to a list of world-space path points
function bool FindPath(
	Vector StartLocation, Vector EndLocation,
	out Vector OutPathPoints[32], out int OutPathPointCount,
	optional R_PathFindData OptionalPathFindData)
{
	local int StartIndex, EndIndex;
	local int PathIndices[32];
	local int PathIndexCount;

	// Must have a PathFinder and a PathPostProcessor
	if(PathFinder == None)
	{
		Utilities.Static.RLog("NavMesh FindPath failed -- PathFinder is not initialized", LogCategory);
		return false;
	}
	if(PathPostProcessor == None)
	{
		Utilities.Static.RLog("NavMesh FindPath failed -- PathPostProcessor is not initialized", LogCategory);
		return false;
	}

	// Find start and end nodes
	if(!FindContainingNode(StartLocation, StartIndex) || !FindContainingNode(EndLocation, EndIndex))
	{
		Utilities.Static.RLog("NavMesh FindPath failed --  Failed to find StartIndex or EndIndex", LogCategory);
		return false;
	}

	// If a PathFindData object was provided, initialize it before execution
	if(OptionalPathFindData != None)
	{
		OptionalPathFindData.Clear();
		OptionalPathFindData.SetPathFinderClass(PathFinder.Class);
		OptionalPathFindData.SetPathPostProcessorClass(PathPostProcessor.Class);
	}

	// Find path indices
	if(!PathFinder.FindPath(Self, StartIndex, EndIndex, PathIndices, PathIndexCount, OptionalPathFindData))
	{
		Utilities.Static.RLog("NavMesh FindPath failed -- Failed to find path indices", LogCategory);
		return false;
	}

	// Post-process to get path points
	if(!PathPostProcessor.PostProcessPath(Self, StartLocation, EndLocation, PathIndices, PathIndexCount, OutPathPoints, OutPathPointCount, OptionalPathFindData))
	{
		Utilities.Static.RLog("NavMesh FindPath failed -- Failed to post-process path indices", LogCategory);
		return false;
	}

	return true;
}

defaultproperties
{
	RemoteRole=ROLE_None
	PathFinderClass=Class'RBots.R_PathFinder_Dijkstras'
	//PathPostProcessorClass=Class'RBots.R_PathPostProcessor_NodeCenter'
	PathPostProcessorClass=Class'RBots.R_PathPostProcessor_Funnel'
}