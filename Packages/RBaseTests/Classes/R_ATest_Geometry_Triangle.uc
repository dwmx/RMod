class R_ATest_Geometry_Triangle extends R_ATest_Geometry abstract;

const AcceptableResultDeviance = 0.000001;

static function String GetTestNameString()
{
	return "Triangle geometry functions";
}

static function bool RunTest(out String FailedReasonString)
{
	local bool bResult;

	// Identical triangle test (overlap)
	bResult = DoDistanceTriangleToTriangle2DTest(
		"Identical triangles",
		Vect(-1,-1,0), Vect(0,1,0), Vect(1,-1,0),
		Vect(-1,-1,0), Vect(0,1,0), Vect(1,-1,0),
		0.0, FailedReasonString);
	if(!bResult) return false;

	// Overlapping triangles (partial edge overlap)
	bResult = DoDistanceTriangleToTriangle2DTest(
		"Triangles sharing edge",
		Vect(0,0,0), Vect(2,0,0), Vect(1,2,0),
		Vect(1,2,0), Vect(2,0,0), Vect(3,2,0),
		0.0, FailedReasonString);
	if(!bResult) return false;

	// One triangle completely inside the other
	bResult = DoDistanceTriangleToTriangle2DTest(
		"One inside another",
		Vect(-2,-2,0), Vect(2,-2,0), Vect(0,2,0),
		Vect(-1,-1,0), Vect(1,-1,0), Vect(0,1,0),
		0.0, FailedReasonString);
	if(!bResult) return false;

	// Separated horizontally
	bResult = DoDistanceTriangleToTriangle2DTest(
		"Separated horizontally",
		Vect(0,0,0), Vect(2,0,0), Vect(1,2,0),
		Vect(4,0,0), Vect(6,0,0), Vect(5,2,0),
		2.0, FailedReasonString); // gap = 2 units
	if(!bResult) return false;

	// Separated vertically
	bResult = DoDistanceTriangleToTriangle2DTest(
		"Separated vertically",
		Vect(0,0,0), Vect(2,0,0), Vect(1,2,0),
		Vect(0,4,0), Vect(2,4,0), Vect(1,6,0),
		2.0, FailedReasonString); // gap = 2 units
	if(!bResult) return false;

	// Touching at a single vertex
	bResult = DoDistanceTriangleToTriangle2DTest(
		"Touching at vertex",
		Vect(0,0,0), Vect(2,0,0), Vect(1,2,0),
		Vect(2,0,0), Vect(4,0,0), Vect(3,2,0),
		0.0, FailedReasonString);
	if(!bResult) return false;

	// Touching along an edge (collinear)
	bResult = DoDistanceTriangleToTriangle2DTest(
		"Touching along edge",
		Vect(0,0,0), Vect(2,0,0), Vect(1,2,0),
		Vect(2,0,0), Vect(4,0,0), Vect(3,-2,0),
		0.0, FailedReasonString);
	if(!bResult) return false;

	// Skew, closest point vertex-to-edge
	bResult = DoDistanceTriangleToTriangle2DTest(
		"Closest point vertex-to-edge",
		Vect(0,0,0), Vect(2,0,0), Vect(1,2,0),
		Vect(3,1,0), Vect(5,1,0), Vect(4,3,0),
		1.341641, FailedReasonString);
	if(!bResult) return false;

	// Nearly parallel edges, small gap
	bResult = DoDistanceTriangleToTriangle2DTest(
		"Nearly parallel edges",
		Vect(0,0,0), Vect(2,0,0), Vect(1,2,0),
		Vect(0.1,3,0), Vect(2.1,3,0), Vect(1.1,5,0),
		1.0, FailedReasonString); // expected ~1 gap
	if(!bResult) return false;

	// Degenerate triangles test
	bResult = DoDistanceTriangleToTriangle2DTest(
		"Degenerate triangles",
		Vect(299,299,0), Vect(299,299,0), Vect(299,299,0),
		Vect(-50,-50,0), Vect(-50,-50,0), Vect(-50,-50,0),
		493.560547, FailedReasonString);
	if(!bResult)	return false;

	return true;
}

static function bool DoDistanceTriangleToTriangle2DTest(
	String TestName,
	Vector P0, Vector P1, Vector P2,
	Vector Q0, Vector Q1, Vector Q2,
	float ExpectedReturnValue,
	out String OutFailedReasonString)
{
	local Vector VLoc0[3], VLoc1[3];
	local float Result;

	VLoc0[0] = P0;
	VLoc0[1] = P1;
	VLoc0[2] = P2;
	VLoc1[0] = Q0;
	VLoc1[1] = Q1;
	VLoc1[2] = Q2;

	Result = GeomLib.Static.DistanceTriangleToTriangle2D(VLoc0, VLoc1);
	if(Abs(Result - ExpectedReturnValue) > AcceptableResultDeviance)
	{
		OutFailedReasonString = "DistanceTriangleToTriangle2D failed for" @ TestName @ "test -- args:" @ GetArgString(VLoc0, VLoc1) @ "-- expected:" @ ExpectedReturnValue @ "got" @ Result;
		return false;
	}

	return true;
}

static function String GetArgString(Vector VLoc0[3], Vector VLoc1[3])
{
	local String Result;
	Result = "";
	Result = Result $ "VLoc0:[(" $ VLoc0[0] $ "), (" $ VLoc0[1] $ "), " $ VLoc0[2] $ ")]";
	Result = Result @ "VLoc1:[(" $ VLoc1[0] $ "), (" $ VLoc1[1] $ "), " $ VLoc1[2] $ ")]";
	return Result;
}