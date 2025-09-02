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