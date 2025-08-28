//==============================================================================
//	R_NavMeshBVH_Implementation2D
//	First implementation of NavMeshBVH
//	This BVH is a quad tree, and ignores Z component of inputs
//	Only splits on the XY plane
//
// Viewing down -Z axis (Top-Down)
//	0  |  1
// ----|----
//	2  |  3
//==============================================================================
class R_NavMeshBVH_Implementation2D extends R_NavMeshBVH;

var private R_NavMeshBVH_Implementation2D Children[4];
var private Vector BoundsMin, BoundsMax;

const MAX_BEFORE_TRY_SUBDIVIDE = 16;		// After this number of triangles, this node will attempt to split
var private int TriangleIndices[128];	// The maximum triangles this node can possibly contain
var private int NumTriangles;
var private bool bIsBVHValid;
var private R_NavMesh NavMesh;

function Clear()
{
	local int i;

	for(i = 0; i < 4; ++i)
	{
		if(Children[i] != None)
		{
			Children[i].Clear();
			Children[i] = None;
		}
	}

	NumTriangles = 0;
	BoundsMin = Vect(0,0,0);
	BoundsMax = Vect(0,0,0);
}

function SetNavMesh(R_NavMesh NewNavMesh)
{
	NavMesh = NewNavMesh;
}

function SetBounds(Vector NewBoundsMin, Vector NewBoundsMax)
{
	BoundsMin = NewBoundsMin;
	BoundsMax = NewBoundsMax;
}

function GetBounds(out Vector OutBoundsMin, out Vector OutBoundsMax)
{
	OutBoundsMin = BoundsMin;
	OutBoundsMax = BoundsMax;
}

function InsertTriangle(int Index, out Vector InVLoc[3])
{
}

function bool IsBVHValid()
{
	return bIsBVHValid;
}

defaultproperties
{
	bIsBVHValid=true
}