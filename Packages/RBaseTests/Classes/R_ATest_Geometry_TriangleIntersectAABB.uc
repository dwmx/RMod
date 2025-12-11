class R_ATest_Geometry_TriangleIntersectAABB extends R_ATest_Geometry abstract;

static function String GetTestNameString()
{
	return "Location intersect AABB geometry functions";
}

static function bool RunTest(out String FailedReasonString)
{
    local bool bResult;

    // 1. Triangle fully inside cell
    bResult = DoDoesTriangleIntersectAABB2DTest(
        "Triangle Inside",
        Vect(0,0,0), Vect(10,10,0),
        Vect(2,2,0), Vect(8,2,0), Vect(5,8,0),
        true,
        FailedReasonString);
    if(!bResult) return false;

    // 2. Triangle fully outside cell (no overlap)
    bResult = DoDoesTriangleIntersectAABB2DTest(
        "Triangle Outside",
        Vect(0,0,0), Vect(10,10,0),
        Vect(20,20,0), Vect(30,20,0), Vect(25,30,0),
        false,
        FailedReasonString);
    if(!bResult) return false;

    // 3. Triangle fully covering the cell
    bResult = DoDoesTriangleIntersectAABB2DTest(
        "Triangle Covers Cell",
        Vect(0,0,0), Vect(10,10,0),
        Vect(-10,-10,0), Vect(20,-10,0), Vect(5,30,0),
        true,
        FailedReasonString);
    if(!bResult) return false;

    // 4. Triangle just touching one edge
    bResult = DoDoesTriangleIntersectAABB2DTest(
        "Triangle Touches Edge",
        Vect(0,0,0), Vect(10,10,0),
        Vect(0,5,0), Vect(-5,0,0), Vect(-5,10,0),
        true,
        FailedReasonString);
    if(!bResult) return false;

    // 5. Triangle just touching one corner
    bResult = DoDoesTriangleIntersectAABB2DTest(
        "Triangle Touches Corner",
        Vect(0,0,0), Vect(10,10,0),
        Vect(-5,-5,0), Vect(0,0,0), Vect(-5,0,0),
        true,
        FailedReasonString);
    if(!bResult) return false;

    // 6. Triangle straddling across the cell
    bResult = DoDoesTriangleIntersectAABB2DTest(
        "Triangle Straddles Cell",
        Vect(0,0,0), Vect(10,10,0),
        Vect(5,-5,0), Vect(15,5,0), Vect(5,15,0),
        true,
        FailedReasonString);
    if(!bResult) return false;

    // 7. Degenerate triangle (line) intersecting cell
    bResult = DoDoesTriangleIntersectAABB2DTest(
        "Degenerate Triangle Line Through Cell",
        Vect(0,0,0), Vect(10,10,0),
        Vect(-5,5,0), Vect(15,5,0), Vect(5,5,0), // collinear
        true,
        FailedReasonString);
    if(!bResult) return false;

    // 8. Degenerate triangle (point) inside cell
    bResult = DoDoesTriangleIntersectAABB2DTest(
        "Degenerate Triangle Point Inside",
        Vect(0,0,0), Vect(10,10,0),
        Vect(5,5,0), Vect(5,5,0), Vect(5,5,0),
        true,
        FailedReasonString);
    if(!bResult) return false;

    // 9. Degenerate triangle (point) outside cell
    bResult = DoDoesTriangleIntersectAABB2DTest(
        "Degenerate Triangle Point Outside",
        Vect(0,0,0), Vect(10,10,0),
        Vect(20,20,0), Vect(20,20,0), Vect(20,20,0),
        false,
        FailedReasonString);
    if(!bResult) return false;

    return true;
}

static function bool DoDoesTriangleIntersectAABB2DTest(
	String TestName,
	Vector AABBMin,
	Vector AABBMax,
	Vector P0, Vector P1, Vector P2,
	bool bExpectedReturnValue,
	out String OutFailedReasonString)
{
	local Vector VLoc[3];
	local bool bResult;

	VLoc[0] = P0;
	VLoc[1] = P1;
	VLoc[2] = P2;

	bResult = GeomLib.Static.DoesTriangleIntersectAABB2D(AABBMin, AABBMax, VLoc);
	if(bResult != bExpectedReturnValue)
	{
		OutFailedReasonString = "DoesTriangleIntersectAABB2D failed for" @ TestName @ "test -- args:" @ GetArgString(AABBMin, AABBMax, VLoc) @ "-- expected:" @ bExpectedReturnValue @ "got" @ bResult;
	}

	return true;
}

static function String GetArgString(Vector AABBMin, Vector AABBMax, Vector VLoc[3])
{
	local String Result;

	Result = "";
	Result = Result $ "AABBMin: (" $ AABBMin $ ")";
	Result = Result @ "AABBMax: (" $ AABBMax $ ")";
	Result = Result @ "VLoc:[(" $ VLoc[0] $ "), (" $ VLoc[1] $ "), (" $ VLoc[2] $ ")]";

	return Result;
}