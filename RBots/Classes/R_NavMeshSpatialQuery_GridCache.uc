//==============================================================================
//	R_NavMeshSpatialQuery_GridCache
//	Overlays a grid onto a NavMesh, inserting triangle indices into every grid
//	cell they intersect
//==============================================================================
class R_NavMeshSpatialQuery_GridCache extends R_NavMeshSpatialQuery;

const NavLib = Class'RBots.R_NavLibrary';
const GeomLib = Class'RBase.R_AGeometryLibrary';
const GridLib = Class'RBase.R_AGridLibrary';
const MathLib = Class'RBase.R_AMathLibrary';

const IndexCacheClass = Class'RBots.R_IndexCache';

// CellSize * GridCacheSize will be the maximum size of the NavMesh AABB
// that will work with this
const CellSize = 64.0;
const CellCountX = 256;
const CellCountY = 256;

var private int MaxBoundsIndexX;
var private int MaxBoundsIndexY;
var private R_IndexCache GridCache[65536]; // CellCountX x CellCountY

var private Vector BoundsMin;
var private Vector BoundsMax;
var private Vector BoundsMid;

//------------------------------------------------------------------------------

function float GetCellSize()
{
	return CellSize;
}

function GetBounds(out Vector OutBoundsMin, out Vector OutBoundsMax)
{
	OutBoundsMin = BoundsMin;
	OutBoundsMax = BoundsMax;
}

function int GetGridIndexCacheSize()
{
	return ArrayCount(GridCache);
}

// Returns the 2D index in which no populated cells exist after GridCache[MaxX,Maxy]
function GetMax2DIndexInBounds(out int OutMaxX, out int OutMaxY)
{
	OutMaxX = MaxBoundsIndexX;
	OutMaxY = MaxBoundsIndexY;
}

function R_IndexCache GetIndexCacheFrom2DGridIndex(int GridIndexX, int GridIndexY)
{
	local int Index;

	Index = GetGridArrayIndexFromGrid2DIndex(GridIndexX, GridIndexY);
	if(Index < 0 || Index >= ArrayCount(GridCache))
	{
		return None;
	}
	return GridCache[Index];
}

//------------------------------------------------------------------------------

function int GetGridArrayIndexFromGrid2DIndex(int GridIndexX, int GridIndexY)
{
	return GridLib.Static.GetGridArrayIndexFromGrid2DIndex(CellCountX, CellCountY, GridIndexX, GridIndexY);
}

function GetGrid2DIndexFromGridArrayIndex(int GridArrayIndex, out int OutGridIndexX, out int OutGridIndexY)
{
	GridLib.Static.GetGrid2DIndexFromGridArrayIndex(CellCountX, CellCountY, GridArrayIndex, OutGridIndexX, OutGridIndexY);
}

function LocationToGrid2DIndex(out Vector Location, out int OutIndexX, out int OutIndexY)
{
	local float WithinX, WithinY;

	WithinX = Location.X - BoundsMin.X;
	WithinY = Location.Y - BoundsMin.Y;

	OutIndexX = int(MathLib.Static.Floor(WithinX / CellSize));
	OutIndexY = int(MathLib.Static.Floor(WithinY / CellSize));

	OutIndexX = Max(0, Min(OutIndexX, CellCountX - 1));
	OutIndexY = Max(0, Min(OutIndexY, CellCountY - 1));
}

function Grid2DIndexToLocation(int IndexX, int IndexY, out Vector OutLocation)
{
	OutLocation.X = BoundsMin.X + IndexX * CellSize;
	OutLocation.Y = BoundsMin.Y + IndexY * CellSize;
	OutLocation.Z = 0.0;
}

//------------------------------------------------------------------------------

function InitNavMeshSpatialQuery(R_NavMesh NavMesh)
{
	InitBoundsForNavMesh(NavMesh);
	InitGridCache();
	ProcessNavMesh(NavMesh);
}

function InitBoundsForNavMesh(R_NavMesh NavMesh)
{
	local Vector LocalBoundsMin, LocalBoundsMax;

	NavLib.Static.CalcNavMeshAABB(NavMesh, LocalBoundsMin, LocalBoundsMax);

	if((LocalBoundsMax.X - LocalBoundsMin.X) > CellSize * CellCountX
	|| (LocalBoundsMax.Y - LocalBoundsMin.Y) > CellSize * CellCountY)
	{
		Warn("GridCache cannot cover full range of NavMesh AABB");
		Utilities.Static.RLog("GridCache cannot cover full range of NavMesh AABB", LogCategory);
	}

	BoundsMin = LocalBoundsMin;
	BoundsMax = LocalBoundsMax;
	BoundsMid = BoundsMin + (BoundsMax - BoundsMin) * 0.5;

	// Calc the max X and Y indices based on AABB
	MaxBoundsIndexX = int(MathLib.Static.Ceil(BoundsMax.X - BoundsMin.X) / CellSize);
	MaxBoundsIndexY = int(MathLib.Static.Ceil(BoundsMax.Y - BoundsMin.Y) / CellSize);
}

function InitGridCache()
{
	local int X, Y;
	local int Index;

	// Make sure all cells are unallocated
	for(X = 0; X < CellCountX; ++X)
	{
		for(Y = 0; Y < CellCountY; ++Y)
		{
			Index = GetGridArrayIndexFromGrid2DIndex(X, Y);
			GridCache[Index] = None;
		}
	}
}

function InsertNodeIndex(int GridIndexX, int GridIndexY, int NodeIndex)
{
	local int Index;

	Index = GetGridArrayIndexFromGrid2DIndex(GridIndexX, GridIndexY);
	if(GridCache[Index] == None)
	{
		GridCache[Index] = new(None) IndexCacheClass;
	}

	GridCache[Index].Push(Index);
}

//------------------------------------------------------------------------------

function bool DoesTriangleIntersectGridCell(int GridIndexX, int GridIndexY, out Vector InVLoc[3])
{
	local Vector CellLocationMin, CellLocationMax;

	Grid2DIndexToLocation(GridIndexX, GridIndexY, CellLocationMin);
	CellLocationMax = CellLocationMin + Vect(1,1,0) * CellSize;

	return GeomLib.Static.DoesTriangleIntersectAABB2D(CellLocationMin, CellLocationMax, InVLoc);
}

function ProcessNavMesh(R_NavMesh NavMesh)
{
	local Vector VLoc[3];
	local int NumTriangles;
	local Vector NodeBoundsMin, NodeBoundsMax;
	local int GridMinX, GridMaxX, GridMinY, GridMaxY;
	local int IndexX, IndexY;
	local int i;

	NumTriangles = NavMesh.GetTriangleCount();
	for(i = 0; i < NumTriangles; ++i)
	{
		NavMesh.GetTriangleVertexLocationsUnchecked(i, VLoc);

		// Get triangle AABB
		NavLib.Static.CalcTriangleAABB(VLoc, NodeBoundsMin, NodeBoundsMax);

		// Get grid indices of triangle's AABB
		LocationToGrid2DIndex(NodeBoundsMin, GridMinX, GridMinY);
		LocationToGrid2DIndex(NodeBoundsMax, GridMaxX, GridMaxY);

		// Test triangle against all cells covered by the AABB
		for(IndexX = GridMinX; IndexX <= GridMaxX; ++IndexX)
		{
			for(IndexY = GridMinY; IndexY <= GridMaxY; ++IndexY)
			{
				if(DoesTriangleIntersectGridCell(IndexX, IndexY, VLoc))
				{
					InsertNodeIndex(IndexX, IndexY, i);
				}
			}
		}
	}
}

//------------------------------------------------------------------------------

function bool FindContainingNode(R_NavMesh NavMesh, Vector Location, out int OutNode)
{
	local int GridIndexX, GridIndexY;
	local int ArrayIndex;
	local R_IndexCache IndexCache;
	local int NumCachedIndices;
	local int NodeIndex, BestNodeIndex;
	local Vector Normal, Center;
	local Vector VLoc[3];
	local Vector LocationProjected;
	local float CurrentDist, BestDist;
	local int i;

	//return false;

	LocationToGrid2DIndex(Location, GridIndexX, GridIndexY);
	ArrayIndex = GetGridArrayIndexFromGrid2DIndex(GridIndexX, GridIndexY);

	IndexCache = GridCache[ArrayIndex];
	if(IndexCache == None)
	{
		OutNode = NavLib.Static.InvalidIndex();
		return false;
	}

	BestNodeIndex = NavLib.Static.InvalidIndex();
	BestDist = 99999.0;

	NumCachedIndices = IndexCache.GetNumIndices();
	for(i = 0; i < NumCachedIndices; ++i)
	{
		NodeIndex = IndexCache.GetUnchecked(i);

		// Location must be on positive side of triangle
		NavMesh.GetTriangleNormalAndCenterUnchecked(NodeIndex, Normal, Center);
		if((Location - Center) Dot Normal < 0.0)
		{
			continue;
		}

		// Get triangle
		NavMesh.GetTriangleVertexLocationsUnchecked(NodeIndex, VLoc);

		// Check location in triangle
		GeomLib.Static.ProjectLocationZOnPlane(Location, Center, Normal, LocationProjected);
		if(GeomLib.Static.IsLocationWithinTriangle2D(LocationProjected, VLoc))	// TODO: This keeps returning false
		{
			CurrentDist = VSize(LocationProjected - Location);
			if(CurrentDist < BestDist)
			{
				BestDist = CurrentDist;
				BestNodeIndex = NodeIndex;
			}
		}
	}

	OutNode = BestNodeIndex;
	if(OutNode == NavLib.Static.InvalidIndex())
	{
		return false;
	}
	return true;
}

function bool FindNodesInRadius(R_NavMesh NavMesh, Vector Origin, float Radius, out int OutNodes[32], out int OutNumNodes)
{
	return false;
}