class R_ATest_Geometry_LineSegmentDistance extends R_ATest_Geometry abstract;

static function String GetTestNameString()
{
	return "Line segment distance geometry functions";
}

static function bool RunTest(out String FailedReasonString)
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
		OutFailedReasonString = "DistanceLineSegmentToLineSegment2D failed for" @ TestName @ "test -- args:" @ GetArgString(VLoc0, VLoc1) @ "-- expected:" @ ExpectedReturnValue @ "got" @ Result;
		return false;
	}

	return true;
}

static function String GetArgString(Vector VLoc0[2], Vector VLoc1[2])
{
	local String Result;
	Result = "";
	Result = Result $ "VLoc0:[(" $ VLoc0[0] $ "), (" $ VLoc0[1] $ ")]";
	Result = Result @ "VLoc1:[(" $ VLoc1[0] $ "), (" $ VLoc1[1] $ ")]";
	return Result;
}