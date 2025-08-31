//==============================================================================
//	R_NavLibrary
//	Shared static data to be used across multiple classes
//	UC does not permit the useage of consts, structs or enums outside of their
//	defined classes, so this is just a workaround
//==============================================================================
class R_NavLibrary extends Object abstract;

// Invalid index used across all navmesh index types
static function int InvalidIndex() 			{ return -1; }

// Edge Flags
static function int EdgeFlag_Border()		{ return 0x01; }
static function int EdgeFlag_Impassable()	{ return 0x02; }

// IsLocationWithinTriangle
// Given 3 triangle vertex locations (InVLoc), and a world-space location (InWorldLocation),
// returns true if that location is considered to be within the triangle vertices
static function bool IsLocationWithinTriangle(out Vector InVLoc[3], out Vector InWorldLocation)
{
	local Vector DV0, DV1, DV2;				// Delta vectors
	local float D00, D01, D11, D20, D21;	// Dot products
	local float Denom;
	local float A, B, G;					// Alpha, Beta, Gamma barycentric factors

	DV0 = InVLoc[1] - InVLoc[0];
	DV1 = InVLoc[2] - InVLoc[0];
	DV2 = InWorldLocation - InVLoc[0];

	D00 = DV0 Dot DV0;
	D01 = DV0 Dot DV1;
	D11 = DV1 Dot DV1;
	D20 = DV2 Dot DV0;
	D21 = DV2 Dot DV1;
	Denom = D00 * D11 - D01 * D01;

	B = (D11 * D20 - D01 * D21) / Denom;
	G = (D00 * D21 - D01 * D20) / Denom;
	A = 1.0 - B - G;

	if(A >= 0.0 && B >= 0.0 && G >= 0.0)
	{
		return true;
	}

	return false;
}

// CalcTriangleCenter
// Calculates the center point of the triangles defined by 3 world-space locations,
// returns in OutCenter
static function CalcTriangleCenter(out Vector InVLoc[3], out Vector OutCenter)
{
	OutCenter = (InVLoc[0] + InVLoc[1] + InVLoc[2]) * (1.0 / 3.0);
}

// CalcTriangleNormal
// Calculates the normal of the triangle defined by 3 world-space locations,
// returns in OutNormal
static function CalcTriangleNormal(out Vector InVLoc[3], out Vector OutNormal)
{
	OutNormal = Normal((InVLoc[1] - InVLoc[0]) Cross (InVLoc[2] - InVLoc[0]));
}

// CalcTriangleCenterLinearDistance
// Given two triangles as vector locations, calculates the straight-line distance between
// triangle center points
static function float CalcTriangleCenterLinearDistance(out Vector InVLoc0[3], out Vector InVLoc1[3])
{
	local Vector Center0, Center1;

	CalcTriangleCenter(InVLoc0, Center0);
	CalcTriangleCenter(InVLoc1, Center1);

	return VSize(Center1 - Center0);
}

// CalcTriangleCenterSurfaceDistance
// Given two triangles as vector locations, calculates the distance from one center point to another
// if you were to travel along the planes of the triangles
// This is a much more accurate representation of travel distance between adjacent nodes
// Note that this does not work for triangles whos planes form a concave angle
static function float CalcTriangleCenterSurfaceDistance(out Vector InVLoc0[3], out Vector InVLoc1[3])
{
	local Vector Center0, Center1;
	local Vector Normal0, Normal1;
	local Vector Delta, DeltaProj0, DeltaProj1;

	CalcTriangleCenter(InVLoc0, Center0);
	CalcTriangleCenter(InVLoc1, Center1);
	CalcTriangleNormal(InVLoc0, Normal0);
	CalcTriangleNormal(InVLoc1, Normal1);

	Delta = Center1 - Center0;
	DeltaProj0 = Delta - (Normal0 * (Delta Dot Normal0));
	DeltaProj1 = Delta - (Normal1 * (Delta Dot Normal1));

	return 0.5 * (VSize(DeltaProj0) + VSize(DeltaProj1));
}

// CalcTriangleCenterEdgeDistance
// Given a triangle defined by 3 vertex locations and an edge defined by 2 vertex locations, calculates
// the distance from triangle center point to that edge
static function float CalcTriangleCenterEdgeDistance(out Vector InVLoc[3], out Vector InELoc[2])
{
	local Vector Center;
	local Vector EdgeDir;
	local Vector Delta;
	local Vector Closest;
	local float t;

	CalcTriangleCenter(InVLoc, Center);
	Center = Center - InELoc[0];
	EdgeDir = InELoc[1] - InELoc[0];

	t = (Delta Dot EdgeDir) / (EdgeDir Dot EdgeDir);
	t = Clamp(t, 0.0, 1.0);

	Closest = InELoc[0] + t * EdgeDir;
	return VSize(Closest - Center);
}

// CalcTriangleAABB
// Calculates the Min/Max AABB for a given triangle
static function CalcTriangleAABB(out Vector InVLoc[3], out Vector OutMin, out Vector OutMax)
{
	OutMin.X = Min(InVLoc[0].X, Min(InVLoc[1].X, InVLoc[2].X));
	OutMin.Y = Min(InVLoc[0].Y, Min(InVLoc[1].Y, InVLoc[2].Y));
	OutMin.Z = Min(InVLoc[0].Z, Min(InVLoc[1].Z, InVLoc[2].Z));

	OutMax.X = Max(InVLoc[0].X, Max(InVLoc[1].X, InVLoc[2].X));
	OutMax.Y = Max(InVLoc[0].Y, Max(InVLoc[1].Y, InVLoc[2].Y));
	OutMax.Z = Max(InVLoc[0].Z, Max(InVLoc[1].Z, InVLoc[2].Z));
}

// CalcNavMeshAABB
// Calculates the Min/Max AABB for all triangles in a NavMesh
static function CalcNavMeshAABB(R_NavMesh NavMesh, out Vector OutMin, out Vector OutMax)
{
	local int TriangleCount;
	local int V[3];
	local Vector VLoc[3];
	local Vector TempMin, TempMax;
	local int i, j;

	TriangleCount = NavMesh.GetTriangleCount();
	if(TriangleCount <= 0)
	{
		OutMin = Vect(0,0,0);
		OutMax = Vect(0,0,0);
		return;
	}

	// Initialize to first triangle
	NavMesh.GetTriangleVertexIndicesUnchecked(0, V[0], V[1], V[2]);
	for(j = 0; j < 3; ++j)
	{
		NavMesh.GetVertexUnchecked(V[j], VLoc[j]);
	}
	CalcTriangleAABB(VLoc, OutMin, OutMax);

	// Calculate the rest
	for(i = 1; i < TriangleCount; ++i)
	{
		NavMesh.GetTriangleVertexIndicesUnchecked(i, V[0], V[1], V[2]);
		for(j = 0; j < 3; ++j)
		{
			NavMesh.GetVertexUnchecked(V[j], VLoc[j]);
		}

		CalcTriangleAABB(VLoc, TempMin, TempMax);

		OutMin.X = Min(TempMin.X, OutMin.X);
		OutMin.Y = Min(TempMin.Y, OutMin.Y);
		OutMin.Z = Min(TempMin.Z, OutMin.Z);

		OutMax.X = Max(TempMax.X, OutMax.X);
		OutMax.Y = Max(TempMax.Y, OutMax.Y);
		OutMax.Z = Max(TempMax.Z, OutMax.Z); 
	}
}

// -----------------------------------------------------------------------------
// Math functions
// These should probably be merged up to RBase

// DistanceLocationToLineSegment
// Returns the shortest possible distance from Location to the line segment formed
// by P0 and P1
static function float DistanceLocationToLineSegment(Vector Location, Vector P0, Vector P1)
{
	local Vector Delta0, Delta1;
	local Vector Offset;

	Delta0 = P1 - P0;
	Delta0 = Normal(Delta0);
	Delta1 = Location - P0;

	return VSize(Delta1 - (Delta0 * (Delta1 Dot Delta0)));
}

static function float DistanceLocationToLineSegment2D(Vector Location, Vector P0, Vector P1)
{
	Location *= Vect(1,1,0);
	P0 *= Vect(1,1,0);
	P1 *= Vect(1,1,0);
	return DistanceLocationToLineSegment(Location, P0, P1);
}

// DistanceLocationToTriangle
// Given a location and a triangle defined by 3 vertex locations (P0, P1, P2), returns the shortest
// distance from that location to any edge of the triangle
static function float DistanceLocationToTriangle(Vector Location, Vector VLoc[3])
{
	local float Distance0, Distance1, Distance2;

	if(IsLocationWithinTriangle(VLoc, Location))
	{
		return 0.0;
	}

	Distance0 = DistanceLocationToLineSegment(Location, VLoc[0], VLoc[1]);
	Distance1 = DistanceLocationToLineSegment(Location, VLoc[1], VLoc[2]);
	Distance2 = DistanceLocationToLineSegment(Location, VLoc[2], VLoc[0]);

	return Min(Distance0, Min(Distance1, Distance2));
}

static function float DistanceLocationToTriangle2D(Vector Location, Vector VLoc[3])
{
	local int i;
	Location *= Vect(1,1,0);
	for(i = 0; i < 3; ++i)
	{
		VLoc[i] *= Vect(1,1,0);
	}
	return DistanceLocationToTriangle(Location, VLoc);
}