class R_ATest_Geometry_LineSegmentIntersect extends R_ATest_Geometry abstract;

static function String GetTestNameString()
{
	return "Line segment intersection geometry functions";
}

static function bool RunTest(out String FailedReasonString)
{
    local bool bResult;

    // 1. Intersecting in the middle (X shape)
    bResult = DoDoLineSegmentsIntersect2D(
        "Cross intersection",
        Vect(0,0,0), Vect(2,2,0),
        Vect(0,2,0), Vect(2,0,0),
        true,
        FailedReasonString);
    if(!bResult) return false;

    // 2. Touching at a shared endpoint
    bResult = DoDoLineSegmentsIntersect2D(
        "Shared endpoint",
        Vect(0,0,0), Vect(1,0,0),
        Vect(1,0,0), Vect(1,1,0),
        true,
        FailedReasonString);
    if(!bResult) return false;

    // 3. Touching at midpoint
    bResult = DoDoLineSegmentsIntersect2D(
        "Touching at midpoint",
        Vect(0,0,0), Vect(2,0,0),
        Vect(1,0,0), Vect(1,1,0),
        true,
        FailedReasonString);
    if(!bResult) return false;

    // 4. Parallel disjoint
    bResult = DoDoLineSegmentsIntersect2D(
        "Parallel disjoint",
        Vect(0,0,0), Vect(2,0,0),
        Vect(0,1,0), Vect(2,1,0),
        false,
        FailedReasonString);
    if(!bResult) return false;

    // 5. Collinear but disjoint
    bResult = DoDoLineSegmentsIntersect2D(
        "Collinear disjoint",
        Vect(0,0,0), Vect(1,0,0),
        Vect(2,0,0), Vect(3,0,0),
        false,
        FailedReasonString);
    if(!bResult) return false;

    // 6. Collinear overlapping
    bResult = DoDoLineSegmentsIntersect2D(
        "Collinear overlapping",
        Vect(0,0,0), Vect(3,0,0),
        Vect(2,0,0), Vect(4,0,0),
        true,
        FailedReasonString);
    if(!bResult) return false;

    // 7. One contained in the other
    bResult = DoDoLineSegmentsIntersect2D(
        "Contained segment",
        Vect(0,0,0), Vect(5,0,0),
        Vect(2,0,0), Vect(3,0,0),
        true,
        FailedReasonString);
    if(!bResult) return false;

    // 8. No intersection, clearly separate
    bResult = DoDoLineSegmentsIntersect2D(
        "Separate segments",
        Vect(0,0,0), Vect(1,0,0),
        Vect(2,1,0), Vect(3,1,0),
        false,
        FailedReasonString);
    if(!bResult) return false;

    return true;
}

static function bool DoDoLineSegmentsIntersect2D(
	String TestName,
	Vector P0, Vector P1,
	Vector Q0, Vector Q1,
	bool bExpectedReturnValue,
	out String OutFailedReasonString)
{
	local Vector VLoc0[2], VLoc1[2];
	local bool bResult;

	VLoc0[0] = P0;
	VLoc0[1] = P1;
	VLoc1[0] = Q0;
	VLoc1[1] = Q1;

	bResult = GeomLib.Static.DoLineSegmentsIntersect2D(VLoc0, VLoc1);
	if(bResult != bExpectedReturnValue)
	{
		OutFailedReasonString = "DoLineSegmentsIntersect2D failed for" @ TestName @ "test -- args:" @ GetArgString(VLoc0, VLoc1) @ "-- expected:" @ bExpectedReturnValue @ "got" @ bResult;
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