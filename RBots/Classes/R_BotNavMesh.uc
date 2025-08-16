//==============================================================================
//	R_BotNavMesh
//	Represents a NavMesh
//	This mesh needs to be manually constructed on a per-map basis
//==============================================================================
class R_BotNavMesh extends Actor;

const Utilities = Class'RBots.R_BotUtilities';

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
	var int IndexA, IndexB, IndexC;
};
var private AdjacencyList AdjacencyListArray[1024]; // Must match TRIANGLE_ARRAY_SIZE
var private bool bBadAdjacents; // If true, there are bad graph adjacencies

const INVALID_VERTEX_INDEX = -1;
const INVALID_TRIANGLE_INDEX = -1;

// Class and instance for path finding
var Class<R_PathFinder> PathFinderClass;
var R_PathFinder PathFinder;

event PreBeginPlay()
{
	Super.PreBeginPlay();
	Clear();
	InitPathFinder();
}

function InitPathFinder()
{
	if(PathFinder != None)
	{
		PathFinder = None;
	}

	if(PathFinderClass != None)
	{
		Utilities.Static.RLog("NavMesh initializing PathFinder from class" @ PathFinderClass);
		PathFinder = new(None) PathFinderClass;

		if(PathFinder == None)
		{
			Utilities.Static.RLog("Initialization of PathFinder for NavMesh failed -- failed to instantiate");
		}
		else
		{
			PathFinder.NavMesh = Self;
		}
	}
	else
	{
		Utilities.Static.RLog("Initialization of PathFinder for NavMesh failed -- PathFinderClass == None");
	}
	
}

function Clear()
{
	local int i;

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

		AdjacencyListArray[i].IndexA = INVALID_TRIANGLE_INDEX;
		AdjacencyListArray[i].IndexB = INVALID_TRIANGLE_INDEX;
		AdjacencyListArray[i].IndexC = INVALID_TRIANGLE_INDEX;
	}
}

function PushVertex(Vector Vertex)
{
	if(VertexCount < 0)
	{
		Utilities.Static.RLog("Bad VertexCount:" @ VertexCount);
		return;
	}
	if(VertexCount >= VERTEX_ARRAY_SIZE)
	{
		Utilities.Static.RLog("Attempted call to PushVertex on full VertexArray");
		return;
	}

	VertexArray[VertexCount] = Vertex;
	++VertexCount;
}

function PushTriangle(int VertexIndexA, int VertexIndexB, int VertexIndexC)
{
	if(TriangleCount < 0)
	{
		Utilities.Static.RLog("Bad TriangleCount:" @ TriangleCount);
		return;
	}
	if(TriangleCount >= TRIANGLE_ARRAY_SIZE)
	{
		Utilities.Static.RLog("Attempted call to PushTriangle on full TriangleArray");
		return;
	}

	TriangleArray[TriangleCount].IndexA = VertexIndexA;
	TriangleArray[TriangleCount].IndexB = VertexIndexB;
	TriangleArray[TriangleCount].IndexC = VertexIndexC;
	++TriangleCount;
}

function ValidateAndPostProcess()
{
	Utilities.Static.RLog("Validating NavMesh:" @ VertexCount @ "vertices," @ TriangleCount @ "triangles");

	BuildAdjacencyListArray();
}

function BuildAdjacencyListArray()
{
	local int i, j;
	local int NumSharedVertices;

	for(i = 0; i < TRIANGLE_ARRAY_SIZE; ++i)
	{
		AdjacencyListArray[i].IndexA = INVALID_TRIANGLE_INDEX;
		AdjacencyListArray[i].IndexB = INVALID_TRIANGLE_INDEX;
		AdjacencyListArray[i].IndexC = INVALID_TRIANGLE_INDEX;
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

	bBadAdjacents = false;

	// Check that triangles are not already marked adjacent
	if(	AdjacencyListArray[TriangleIndexA].IndexA != TriangleIndexB
	&&	AdjacencyListArray[TriangleIndexA].IndexB != TriangleIndexB
	&&	AdjacencyListArray[TriangleIndexA].IndexC != TriangleIndexB
	&&	AdjacencyListArray[TriangleIndexB].IndexA != TriangleIndexA
	&&	AdjacencyListArray[TriangleIndexB].IndexB != TriangleIndexA
	&&	AdjacencyListArray[TriangleIndexB].IndexC != TriangleIndexA)
	{
		i = INVALID_TRIANGLE_INDEX;
		if(AdjacencyListArray[TriangleIndexA].IndexA == INVALID_TRIANGLE_INDEX) i = 0;
		else if(AdjacencyListArray[TriangleIndexA].IndexB == INVALID_TRIANGLE_INDEX) i = 1;
		else if(AdjacencyListArray[TriangleIndexA].IndexC == INVALID_TRIANGLE_INDEX) i = 2;

		j = INVALID_TRIANGLE_INDEX;
		if(AdjacencyListArray[TriangleIndexB].IndexA == INVALID_TRIANGLE_INDEX) j = 0;
		else if(AdjacencyListArray[TriangleIndexB].IndexB == INVALID_TRIANGLE_INDEX) j = 1;
		else if(AdjacencyListArray[TriangleIndexB].IndexC == INVALID_TRIANGLE_INDEX) j = 2;

		if(i == INVALID_TRIANGLE_INDEX || j == INVALID_TRIANGLE_INDEX)
		{
			Utilities.Static.RLog("Bad adjacent triangles in NavMesh");
			bBadAdjacents = true;
			return;
		}
		else
		{
			if(i == 0)		AdjacencyListArray[TriangleIndexA].IndexA = TriangleIndexB;
			else if(i == 1)	AdjacencyListArray[TriangleIndexA].IndexB = TriangleIndexB;
			else if(i == 2)	AdjacencyListArray[TriangleIndexA].IndexC = TriangleIndexB;

			if(j == 0)		AdjacencyListArray[TriangleIndexB].IndexA = TriangleIndexA;
			else if(j == 1)	AdjacencyListArray[TriangleIndexB].IndexB = TriangleIndexA;
			else if(j == 2)	AdjacencyListArray[TriangleIndexB].IndexC = TriangleIndexA;
		}
	}
	else
	{
		Utilities.Static.RLog("Bad adjacent triangles in NavMesh -- attempted to double-add adjacents");
		bBadAdjacents = true;
	}
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
	OutIndexA = AdjacencyListArray[Index].IndexA;
	OutIndexB = AdjacencyListArray[Index].IndexB;
	OutIndexC = AdjacencyListArray[Index].IndexC;
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
function bool FindPath(Vector StartLocation, Vector EndLocation, out Vector PathPoints[32], out int NumPathPoints)
{
	local int StartIndex, EndIndex;
	local bool bResult;

	if(PathFinder == None)
	{
		Utilities.Static.RLog("NavMesh FindPath failed -- PathFinder is not initialized");
		return false;
	}

	if(!FindContainingNode(StartLocation, StartIndex))
	{
		return false;
	}

	if(!FindContainingNode(EndLocation, EndIndex))
	{
		return false;
	}

	bResult = PathFinder.FindPath(StartIndex, EndIndex, PathPoints, NumPathPoints);
	return bResult;
}

defaultproperties
{
	RemoteRole=ROLE_None
	PathFinderClass=Class'RBots.R_PathFinder_Dijkstras'
}