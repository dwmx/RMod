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

const INVALID_VERTEX_INDEX = -1;
const INVALID_TRIANGLE_INDEX = -1;

event PreBeginPlay()
{
	Super.PreBeginPlay();
	Clear();
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
	}
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

// Finds the node (polygon) which contains the given location and returns index
// If no containing node found, returns false
function bool FindContainingNode(Vector WorldLocation, out int OutIndex)
{
	local Vector TriangleNormal, TriangleCenter;
	local int i;

	for(i = 0; i < TriangleCount; ++i)
	{
		GetTriangleNormalUnchecked(i, TriangleNormal);
	}
}

defaultproperties
{
	RemoteRole=ROLE_None
}