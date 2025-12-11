class R_ATest_Geometry_LineSegmentDistance extends R_ATest_Geometry abstract;

static function String GetTestNameString()
{
	return "Line segment distance geometry functions";
}

static function bool RunTest(out String FailedReasonString)
{
	if(!RunTest_DistanceLocationToLineSegment2D(FailedReasonString))	return false;
	if(!RunTest_DistanceLineSegmentToLineSegment2D(FailedReasonString))	return false;

	return true;
}

//------------------------------------------------------------------------------
//	DistanceLocationToLineSegment2D
static function bool RunTest_DistanceLocationToLineSegment2D(out String FailedReasonString)
{
	local bool bResult;

    // 1. Point lies exactly on the segment
    bResult = DoDistanceLocationToLineSegment2DTest(
        "OnSegment",
        Vect(5,0,0),   // Location
        Vect(0,0,0), Vect(10,0,0),  // Segment along X axis
        0.0,           // Expected distance
        FailedReasonString);
    if(!bResult) return false;

    // 2. Point projects inside the segment, non-zero distance
    bResult = DoDistanceLocationToLineSegment2DTest(
        "InsideProjection",
        Vect(5,5,0),   // Location above the midpoint
        Vect(0,0,0), Vect(10,0,0),
        5.0,           // Closest point is (5,0), so distance = 5
        FailedReasonString);
    if(!bResult) return false;

    // 3. Point projects outside, closer to P0
    bResult = DoDistanceLocationToLineSegment2DTest(
        "OutsideNearP0",
        Vect(-5,0,0),  // Left of P0
        Vect(0,0,0), Vect(10,0,0),
        5.0,           // Closest point is P0 = (0,0), distance = 5
        FailedReasonString);
    if(!bResult) return false;

    // 4. Point projects outside, closer to P1
    bResult = DoDistanceLocationToLineSegment2DTest(
        "OutsideNearP1",
        Vect(15,0,0),  // Right of P1
        Vect(0,0,0), Vect(10,0,0),
        5.0,           // Closest point is P1 = (10,0), distance = 5
        FailedReasonString);
    if(!bResult) return false;

    // 5. Vertical segment, point off to the side
    bResult = DoDistanceLocationToLineSegment2DTest(
        "VerticalSegment",
        Vect(5,5,0),   // To the right of the segment
        Vect(0,0,0), Vect(0,10,0),
        5.0,           // Closest point is (0,5), distance = 5
        FailedReasonString);
    if(!bResult) return false;

    // 6. Degenerate segment (P0 == P1)
    bResult = DoDistanceLocationToLineSegment2DTest(
        "DegenerateSegment",
        Vect(3,4,0),   // 5 units away from origin
        Vect(0,0,0), Vect(0,0,0),
        5.0,           // Distance to that single point
        FailedReasonString);
    if(!bResult) return false;

    return true;
}

static function bool DoDistanceLocationToLineSegment2DTest(String TestName, Vector Location, Vector Q0, Vector Q1, float ExpectedReturnValue, out String OutFailedReasonString)
{
	local Vector VLoc[2];
	local float Result;

	VLoc[0] = Q0;
	VLoc[1] = Q1;

	Result = GeomLib.Static.DistanceLocationToLineSegment2D(Location, VLoc);
	if(Result != ExpectedReturnValue)
	{
		OutFailedReasonString = "DistanceLocationToLineSegment2D failed for" @ TestName @ "test -- args:" @ GetArgString_DistanceLocationToLineSegment2D(Location, VLoc) @ "-- expected:" @ ExpectedReturnValue @ "got" @ Result;
		return false;
	}

	return true;
}

static function String GetArgString_DistanceLocationToLineSegment2D(Vector Location, Vector VLoc[2])
{
	local String Result;
	Result = "";
	Result = Result $ "Location: (" $ Location $ ")";
	Result = Result @ "VLoc:[(" $ VLoc[0] $ "), (" $ VLoc[1] $ ")]";
	return Result;
}

//------------------------------------------------------------------------------
//	DistanceLineSegmentToLineSegment2D
static function bool RunTest_DistanceLineSegmentToLineSegment2D(out String FailedReasonString)
{
    local bool bResult;

    // 1. Intersection test (crossing)
    bResult = DoDistanceLineSegmentToLineSegment2DTest(
        "Intersection",
        Vect(1,0,0), Vect(-1,0,0),
        Vect(0,1,0), Vect(0,-1,0),
        0.0, FailedReasonString);
    if(!bResult) return false;

    // 2. Touching at an endpoint
    bResult = DoDistanceLineSegmentToLineSegment2DTest(
        "Touching endpoint",
        Vect(0,0,0), Vect(1,0,0),
        Vect(1,0,0), Vect(2,1,0),
        0.0, FailedReasonString);
    if(!bResult) return false;

    // 3. Collinear overlapping
    bResult = DoDistanceLineSegmentToLineSegment2DTest(
        "Collinear overlapping",
        Vect(0,0,0), Vect(2,0,0),
        Vect(1,0,0), Vect(3,0,0),
        0.0, FailedReasonString);
    if(!bResult) return false;

    // 4. Collinear disjoint
    bResult = DoDistanceLineSegmentToLineSegment2DTest(
        "Collinear disjoint",
        Vect(0,0,0), Vect(1,0,0),
        Vect(2,0,0), Vect(3,0,0),
        1.0, FailedReasonString);
    if(!bResult) return false;

    // 5. Parallel, separated
    bResult = DoDistanceLineSegmentToLineSegment2DTest(
        "Parallel separated",
        Vect(0,0,0), Vect(1,0,0),
        Vect(0,1,0), Vect(1,1,0),
        1.0, FailedReasonString);
    if(!bResult) return false;

    // 6. Skew (non-parallel, not intersecting)
    bResult = DoDistanceLineSegmentToLineSegment2DTest(
        "Skew non-intersecting",
        Vect(0,0,0), Vect(1,0,0),
        Vect(2,1,0), Vect(2,-1,0),
        1.0, FailedReasonString);
    if(!bResult) return false;

    // 7. Vertex-to-edge perpendicular
    bResult = DoDistanceLineSegmentToLineSegment2DTest(
        "Vertex-to-edge perpendicular",
        Vect(0,0,0), Vect(2,0,0),
        Vect(1,1,0), Vect(1,2,0),
        1.0, FailedReasonString);
    if(!bResult) return false;

    // 8. Degenerate segment (point vs segment)
    bResult = DoDistanceLineSegmentToLineSegment2DTest(
        "Point vs segment",
        Vect(0,0,0), Vect(0,0,0),   // point
        Vect(1,1,0), Vect(2,1,0),
        Sqrt(2.0), FailedReasonString);
    if(!bResult) return false;

    return true;
}

static function bool DoDistanceLineSegmentToLineSegment2DTest(String TestName, Vector P0, Vector P1, Vector Q0, Vector Q1, float ExpectedReturnValue, out String OutFailedReasonString)
{
	local Vector VLoc0[2], VLoc1[2];
	local float Result;

	VLoc0[0] = P0;
	VLoc0[1] = P1;
	VLoc1[0] = Q0;
	VLoc1[1] = Q1;

	Result = GeomLib.Static.DistanceLineSegmentToLineSegment2D(VLoc0, VLoc1);
	if(Result != ExpectedReturnValue)
	{
		OutFailedReasonString = "DistanceLineSegmentToLineSegment2D failed for" @ TestName @ "test -- args:" @ GetArgString_DistanceLineSegmentToLineSegment2D(VLoc0, VLoc1) @ "-- expected:" @ ExpectedReturnValue @ "got" @ Result;
		return false;
	}

	return true;
}

static function String GetArgString_DistanceLineSegmentToLineSegment2D(Vector VLoc0[2], Vector VLoc1[2])
{
	local String Result;
	Result = "";
	Result = Result $ "VLoc0:[(" $ VLoc0[0] $ "), (" $ VLoc0[1] $ ")]";
	Result = Result @ "VLoc1:[(" $ VLoc1[0] $ "), (" $ VLoc1[1] $ ")]";
	return Result;
}