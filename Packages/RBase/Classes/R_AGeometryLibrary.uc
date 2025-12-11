//==============================================================================
//	R_AGeometryLibrary
//	Library class
//
//	Provides geometric math functions
//==============================================================================
class R_AGeometryLibrary extends R_ALibrary abstract;

// Consts
static function float MaximumDistance()	{ return 9999999.0; }
static function float Epsilon()	{ return 0.00006; }

//	DistanceLocationToLineSegment2D
//	Given a location and a line segment, returns the shortest possible distance from the location
//	to any point on that line segment
static function float DistanceLocationToLineSegment2D(Vector Location, Vector VLoc[2])
{
	local Vector Segment, ToLoc;
	local Vector Closest;
	local float t;

	Location *= Vect(1,1,0);
	VLoc[0] *= Vect(1,1,0);
	VLoc[1] *= Vect(1,1,0);

	Segment = VLoc[1] - VLoc[0];
	ToLoc = Location - VLoc[0];

	if(VSize(Segment) < Epsilon())
	{	// Degenerate line segment
		return VSize(Location - VLoc[0]);
	}

	t = (ToLoc Dot Segment) / (Segment Dot Segment);
	t = FClamp(t, 0.0, 1.0);

	Closest = VLoc[0] + Segment * t;
	return VSize(Location - Closest);
}

//	DistanceLineSegmentToLineSegment2D
//	Given two line segments, returns the shortest possible distance between them
static function float DistanceLineSegmentToLineSegment2D(Vector VLoc0[2], Vector VLoc1[2])
{
	local Vector U, V, W, DP;
	local float A, B, C, D, E, Denom;
	local float SC, SN, SD;
	local float TC, TN, TD;

	VLoc0[0] *= Vect(1,1,0);
	VLoc0[1] *= Vect(1,1,0);
	VLoc1[0] *= Vect(1,1,0);
	VLoc1[1] *= Vect(1,1,0);

	U = VLoc0[1] - VLoc0[0];
	V = VLoc1[1] - VLoc1[0];
	W = VLoc0[0] - VLoc1[0];

	A = U Dot U;
	B = U Dot V;
	C = V Dot V;
	D = U Dot W;
	E = V Dot W;
	Denom = A*C - B*B;

	SN = 0.0;
	SD = Denom;
	TN = 0.0;
	TD = Denom;

	if(Denom < Epsilon())
	{	// Lines are nearly parallel
		SN = 0.0;
		SD = 1.0;
		TN = E;
		TD = C;
	}
	else
	{
		SN = (B*E - C*D);
		TN = (A*E - B*D);

		if(SN < 0.0)
		{
			SN = 0.0;
			TN = E;
			TD = C;
		}
		else if(SN > SD)
		{
			SN = SD;
			TN = E + B;
			TD = C;
		}
	}

	if(TN < 0.0)
	{
		TN = 0.0;
		if(-D< 0.0)
		{
			SN = 0.0;
		}
		else if(-D > A)
		{
			SN = SD;
		}
		else
		{
			SN = -D;
			SD = A;
		}
	}
	else if (TN > TD)
	{
		TN = TD;
		if((-D + B) < 0.0)
		{
			SN = 0.0;
		}
		else if((-D + B) > A)
		{
			SN = SD;
		}
		else
		{
			SN = (-D + B);
			SD = A;
		}
	}

	if(Abs(SN) < Epsilon())
	{
		SC = 0.0;
	}
	else
	{
		SC = SN / SD;
	}

	if(Abs(TN) < Epsilon())
	{
		TC = 0.0;
	}
	else
	{
		TC = TN / TD;
	}

	DP = W + (SC * U) - (TC * V);

	return VSize(DP);
}

//	DistanceTriangleToTriangle2D
//	Calculates the shortest possible distance from the boundary of triangle 0 to the
//	boundary of triangle 1
//	If the triangles overlap, distance returned is 0
static function float DistanceTriangleToTriangle2D(Vector VLoc0[3], Vector VLoc1[3])
{
	local float MinDist, Dist;
	local Vector Edge0[2], Edge1[2];
	local int i, j;

	// Check for triangle edge intersection
	for(i = 0; i < 3; ++i)
	{
		Edge0[0] = VLoc0[i];
		Edge0[1] = VLoc0[(i+1) % 3];

		for(j = 0; j < 3; ++j)
		{
			Edge1[0] = VLoc1[j];
			Edge1[1] = VLoc1[(j+1) % 3];

			if(DoLineSegmentsIntersect2D(Edge0, Edge1))
			{	// Triangle edge intersection, return 0 distance
				return 0.0;
			}
		}
	}

	// Check if one triangle is entirely inside the other
	if(	IsLocationWithinTriangle2D(VLoc0[0], VLoc1)
	||	IsLocationWithinTriangle2D(Vloc1[0], VLoc0))
	{	// One triangle fully contained in the other, return 0 distance
		return 0.0;
	}

	// No overlap, return shortest distance between any two line segments
	MinDist = MaximumDistance();
	for(i = 0; i < 3; ++i)
	{
		Edge0[0] = VLoc0[i];
		Edge0[1] = VLoc0[(i+1) % 3];

		for(j = 0; j < 3; ++j)
		{
			Edge1[0] = VLoc1[j];
			Edge1[1] = VLoc1[(j+1) % 3];

			Dist = DistanceLineSegmentToLineSegment2D(Edge0, Edge1);
			if(Dist < MinDist)
			{
				MinDist = Dist;
			}
		}
	}

	return MinDist;
}

//	DoLineSegmentsIntersect2D
//	Returns true if the line segments defined by the provided vertex locations intersect
static function bool DoLineSegmentsIntersect2D(Vector VLoc0[2], Vector VLoc1[2])
{
	local float D1, D2, D3, D4;
	local Vector A, B, C, D;

	A = VLoc0[0];
	B = VLoc0[1];
	C = VLoc1[0];
	D = VLoc1[1];

	D1 = (B.X - A.X) * (C.Y - A.Y) - (B.Y - A.Y) * (C.X - A.X);
    D2 = (B.X - A.X) * (D.Y - A.Y) - (B.Y - A.Y) * (D.X - A.X);
    D3 = (D.X - C.X) * (A.Y - C.Y) - (D.Y - C.Y) * (A.X - C.X);
    D4 = (D.X - C.X) * (B.Y - C.Y) - (D.Y - C.Y) * (B.X - C.X);

	// General case
	if((D1  * D2 < 0.0) && (D3 * D4 < 0.0))
	{
		return true;
	}

	// Colinear case
    if (D1 == 0.0 && IsPointOnLineSegment(A, B, C)) return true;
    if (D2 == 0.0 && IsPointOnLineSegment(A, B, D)) return true;
    if (D3 == 0.0 && IsPointOnLineSegment(C, D, A)) return true;
    if (D4 == 0.0 && IsPointOnLineSegment(C, D, B)) return true;

    return false;
}

//	IsPointOnLineSegment
// 	Returns true if point R lies on segment PQ (collinear assumed)
static function bool IsPointOnLineSegment(Vector P, Vector Q, Vector R)
{
    return (Min(P.X, Q.X) <= R.X && R.X <= Max(P.X, Q.X)) &&
           (Min(P.Y, Q.Y) <= R.Y && R.Y <= Max(P.Y, Q.Y));
}

//	IsLocationWithinTriangle2D
//	Returns true if the given Location lies within the triangle defined by the given vertex locations
static function bool IsLocationWithinTriangle2D(Vector Location, Vector VLoc[3])
{
	local float A, B, C;
	local float Det, U, V;

	Det = (VLoc[1].Y - VLoc[2].Y) * (VLoc[0].X - VLoc[2].X) + (VLoc[2].X - VLoc[1].X) * (VLoc[0].Y - VLoc[2].Y);

	U = ((VLoc[1].Y - VLoc[2].Y) * (Location.X - VLoc[2].X) + (VLoc[2].X - VLoc[1].X) * (Location.Y - VLoc[2].Y)) / Det;
	V = ((VLoc[2].Y - VLoc[0].Y) * (Location.X - VLoc[2].X) + (VLoc[0].X - VLoc[2].X) * (Location.Y - VLoc[2].Y)) / Det;
	A = 1.0 - U - V;

	return (U >= 0.0) && (V >= 0.0) && (A >= 0.0);
}

//	ProjectLocationZOnPlane
//	Given a location and a plane defined by an origin and a normal, projects that location onto the plane
//	along only the world Z axis
static function ProjectLocationZOnPlane(Vector Location, Vector PlaneOrigin, Vector PlaneNormal, out Vector OutProjectedLocation)
{
	local Vector Dir;
	local float Denom;
	local float t;

	Dir = Vect(0,0,1);
	Denom = PlaneNormal Dot Dir;

	if(Abs(Denom) < Epsilon())
	{
		OutProjectedLocation = Location;
		return;
	}

	t = ((PlaneOrigin - Location) Dot PlaneNormal) / Denom;
	OutProjectedLocation = Location + t * Dir;
}

// RayIntersectPlane
// Given a Ray and a Plane, both defined by an origin and a normal, find the world-space location at which the
// ray will intersect the plane
static function bool RayIntersectPlane(Vector RayOrigin, Vector RayDir, Vector PlaneOrigin, Vector PlaneNormal, out Vector OutIntersection)
{
	local float Denom;
	local float t;

	RayDir = Normal(RayDir);
	PlaneNormal = Normal(PlaneNormal);

	Denom = RayDir Dot PlaneNormal;

	if(Abs(Denom) < 0.0001)
	{
		return false;
	}

	t = ((PlaneOrigin - RayOrigin) Dot PlaneNormal) / Denom;

	if(t < 0)
	{
		return false;
	}

	OutIntersection = RayOrigin + RayDir * t;
	return true;
}

// Returns true if the triangle defined by VLoc intersects with the provided AABB
static function bool DoesTriangleIntersectAABB2D(Vector AABBMin, Vector AABBMax, Vector VLoc[3])
{
	local Vector Corners[4];
	local Vector SegmentA[2], SegmentB[2];
	local int i, j;

	// Vertex inside box?
	for(i = 0; i < 3; ++i)
	{
		if(VLoc[i].X >= AABBMin.X && VLoc[i].X <= AABBMax.X
		&& VLoc[i].Y >= AABBMin.Y && VLoc[i].Y <= AABBMax.Y)
		{
			return true;
		}
	}

	Corners[0] = Vect(1,0,0) * AABBMin + Vect(0,1,0) * AABBMin;
	Corners[1] = Vect(1,0,0) * AABBMax + Vect(0,1,0) * AABBMin;
	Corners[2] = Vect(1,0,0) * AABBMax + Vect(0,1,0) * AABBMax;
	Corners[3] = Vect(1,0,0) * AABBMin + Vect(0,1,0) * AABBMax;

	// Box corner inside triangle?
	for(i = 0; i < 4; ++i)
	{
		if(IsLocationWithinTriangle2D(Corners[i], VLoc))
		{
			return true;
		}
	}

	// Line segments intersect?
	for(i = 0; i < 3; ++i)
	{
		SegmentA[0] = VLoc[i];
		SegmentA[1] = VLoc[(i+1)%3];
		for(j = 0; j < 4; ++j)
		{
			SegmentB[0] = Corners[j];
			SegmentB[1] = Corners[(j+1)%4];

			if(DoLineSegmentsIntersect2D(SegmentA, SegmentB))
			{
				return true;
			}
		}
	}

	return false;
}

// Returns true if a triangle intersects or lies within a circle (2D, XY plane).
static function bool IsTriangleWithinRadius2D(Vector Origin, float Radius, Vector VLoc[3])
{
	local Vector Delta;
    local float RadiusSq;
    local int i, j;
    local Vector A, B, Edge, ToOrigin, Projection;
    local float t, DistSq;

    RadiusSq = Radius * Radius;

    // Any vertex inside circle
    for(i = 0; i < 3; ++i)
    {
		Delta = VLoc[i] - Origin;
		DistSq = Delta.X * Delta.X + Delta.Y * Delta.Y;
        if(DistSq <= RadiusSq)
		{
			return true;
		}
    }

    // Circle center inside triangle
	if(IsLocationWithinTriangle2D(Origin, VLoc))
	{
		return true;
	}

    // Circle intersects an edge
    for(i = 0; i < 3; ++i)
    {
        j = (i + 1) % 3;
        A = VLoc[i];
        B = VLoc[j];

        Edge = B - A;
        ToOrigin = Origin - A;

        // Project Origin onto AB, clamp to segment
        t = (ToOrigin.X * Edge.X + ToOrigin.Y * Edge.Y) / (Edge.X * Edge.X + Edge.Y * Edge.Y);
        t = FClamp(t, 0.0, 1.0);

        Projection = A + t * Edge;
		Delta = Projection - Origin;
		DistSq = Delta.X * Delta.X + Delta.Y * Delta.Y;

        if(DistSq <= RadiusSq)
		{
			return true;
		}
    }

    return false;
}

// Given a line strip defined by a sequential array of vertices, returns the full length of that line strip
static function float LineStripLength(out Vector InVLoc[64], int NumVertices)
{
	local float Result;
	local int i;

	NumVertices = Clamp(NumVertices, 0, ArrayCount(InVLoc));
	Result = 0.0;

	for(i = 1; i < NumVertices; ++i)
	{
		Result += VSize(InVLoc[i] - InVLoc[i-1]);
	}
	return Result;
}

// Given a line strip defined by a sequential array of vertices, returns a location on that line strip
// Distance units from the first vertex, clamped to first and last vertex locations
static function Vector LocationAlongLineStrip(out Vector InVLoc[64], int NumVertices, float Distance)
{
	local float CurrentDistance, NextDistance;
	local int i;
	local Vector Delta;
	local float t;

	NumVertices = Clamp(NumVertices, 0, ArrayCount(InVLoc));
	if(NumVertices == 0)
	{
		return Vect(0,0,0);
	}

	Distance = FMax(0.0, Distance);
	if(Distance == 0.0)
	{
		return InVLoc[0];
	}

	CurrentDistance = 0.0;

	for(i = 1; i < NumVertices; ++i)
	{
		Delta = InVLoc[i] - InVLoc[i-1];
		NextDistance = CurrentDistance + VSize(Delta);
		if(NextDistance > Distance)
		{
			t = (Distance - CurrentDistance) / (NextDistance - CurrentDistance);
			return InVLoc[i-1] + Delta * t;
		}
		CurrentDistance = NextDistance;
	}
	return InVLoc[NumVertices - 1];
}