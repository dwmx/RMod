class R_ATest_Geometry_LocationWithinTriangle extends R_ATest_Geometry abstract;

static function String GetTestNameString()
{
	return "Location within triangle geometry functions";
}

static function bool RunTest(out String FailedReasonString)
{
    local bool bResult;

    // Inside case
    bResult = DoIsLocationWithinTriangle2DTest(
        "Point inside",
        Vect(0,0,0),
        Vect(-1,-1,0), Vect(0,1,0), Vect(1,-1,0),
        true,
        FailedReasonString);
    if(!bResult) return false;

    // Outside case
    bResult = DoIsLocationWithinTriangle2DTest(
        "Point outside",
        Vect(2,2,0),
        Vect(-1,-1,0), Vect(0,1,0), Vect(1,-1,0),
        false,
        FailedReasonString);
    if(!bResult) return false;

    // On edge case
    bResult = DoIsLocationWithinTriangle2DTest(
        "Point on edge",
        Vect(0,0,0),
        Vect(0,0,0), Vect(2,0,0), Vect(0,2,0),
        true, // Usually treated as inside
        FailedReasonString);
    if(!bResult) return false;

    // On vertex case
    bResult = DoIsLocationWithinTriangle2DTest(
        "Point on vertex",
        Vect(0,0,0),
        Vect(0,0,0), Vect(1,0,0), Vect(0,1,0),
        true, // Usually treated as inside
        FailedReasonString);
    if(!bResult) return false;

    // Skinny triangle case
    bResult = DoIsLocationWithinTriangle2DTest(
        "Skinny triangle outside",
        Vect(0,1,0),
        Vect(0,0,0), Vect(100,0,0), Vect(0.001,0,0),
        false,
        FailedReasonString);
    if(!bResult) return false;

    return true;
}


static function bool DoIsLocationWithinTriangle2DTest(
	String TestName,
	Vector Location,
	Vector P0, Vector P1, Vector P2,
	bool bExpectedReturnValue,
	out String OutFailedReasonString)
{
	local Vector VLoc[3];
	local bool bResult;

	VLoc[0] = P0;
	VLoc[1] = P1;
	VLoc[2] = P2;

	bResult = GeomLib.Static.IsLocationWithinTriangle2D(Location, VLoc);
	if(bResult != bExpectedReturnValue)
	{
		OutFailedReasonString = "IsLocationWithinTriangle2D failed for" @ TestName @ "test -- args:" @ GetArgString(Location, VLoc) @ "-- expected:" @ bExpectedReturnValue @ "got" @ bResult;
		return false;
	}

	return true;
}

static function String GetArgString(Vector Location, Vector VLoc[3])
{
	local String Result;
	Result = "";
	Result = Result $ "Location:" @ "(" $ Location $ ")";
	Result = Result @ "VLoc:[(" $ VLoc[0] $ "), (" $ VLoc[1] $ "), (" $ VLoc[2] $ ")]";
	return Result;
}