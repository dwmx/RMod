class R_ATest_Geometry_LineStrip extends R_ATest_Geometry abstract;

static function String GetTestNameString()
{
	return "Line strip geometry functions";
}

static function bool RunTest(out String FailedReasonString)
{
	local bool bResult;
	local Vector TestLineStrip[64];
	local int NumVertices;

	// -----------------------------
	// LineStripLength Tests
	// -----------------------------

	// 1. Zero vertices
	NumVertices = 0;
	bResult = DoLineStripLengthTest("Zero vertices", TestLineStrip, NumVertices, 0.0, FailedReasonString);
	if(!bResult) return false;

	// 2. One vertex
	TestLineStrip[0] = Vect(1,2,3);
	NumVertices = 1;
	bResult = DoLineStripLengthTest("One vertex", TestLineStrip, NumVertices, 0.0, FailedReasonString);
	if(!bResult) return false;

	// 3. Two vertices, axis-aligned
	TestLineStrip[0] = Vect(0,0,0);
	TestLineStrip[1] = Vect(10,0,0);
	NumVertices = 2;
	bResult = DoLineStripLengthTest("Two vertices axis-aligned", TestLineStrip, NumVertices, 10.0, FailedReasonString);
	if(!bResult) return false;

	// 4. Two vertices, diagonal
	TestLineStrip[0] = Vect(0,0,0);
	TestLineStrip[1] = Vect(3,4,0);
	NumVertices = 2;
	bResult = DoLineStripLengthTest("Two vertices diagonal (3-4-5)", TestLineStrip, NumVertices, 5.0, FailedReasonString);
	if(!bResult) return false;

	// 5. Three vertices, straight line
	TestLineStrip[0] = Vect(0,0,0);
	TestLineStrip[1] = Vect(0,5,0);
	TestLineStrip[2] = Vect(0,10,0);
	NumVertices = 3;
	bResult = DoLineStripLengthTest("Three vertices straight line", TestLineStrip, NumVertices, 10.0, FailedReasonString);
	if(!bResult) return false;

	// 6. Three vertices, kinked path
	TestLineStrip[0] = Vect(0,0,0);
	TestLineStrip[1] = Vect(3,0,0);
	TestLineStrip[2] = Vect(3,4,0);
	NumVertices = 3;
	bResult = DoLineStripLengthTest("Three vertices kinked path", TestLineStrip, NumVertices, 7.0, FailedReasonString);
	if(!bResult) return false;

	// 7. Three vertices, non-planar
	TestLineStrip[0] = Vect(0,0,0);
	TestLineStrip[1] = Vect(0,0,5);
	TestLineStrip[2] = Vect(0,12,5);
	NumVertices = 3;
	bResult = DoLineStripLengthTest("Three vertices non-planar", TestLineStrip, NumVertices, 17.0, FailedReasonString);
	if(!bResult) return false;

	// 8. Degenerate zero-length segment
	TestLineStrip[0] = Vect(0,0,0);
	TestLineStrip[1] = Vect(0,0,0);
	TestLineStrip[2] = Vect(0,5,0);
	NumVertices = 3;
	bResult = DoLineStripLengthTest("Degenerate zero-length segment", TestLineStrip, NumVertices, 5.0, FailedReasonString);
	if(!bResult) return false;


	// -----------------------------
	// LocationAlongLineStrip Tests
	// -----------------------------

	// 1. Zero vertices
	NumVertices = 0;
	bResult = DoLocationAlongLineStripTest("Zero vertices", TestLineStrip, NumVertices, 5.0, Vect(0,0,0), FailedReasonString);
	if(!bResult) return false;

	// 2. One vertex
	TestLineStrip[0] = Vect(7,8,9);
	NumVertices = 1;
	bResult = DoLocationAlongLineStripTest("One vertex", TestLineStrip, NumVertices, 123.4, Vect(7,8,9), FailedReasonString);
	if(!bResult) return false;

	// 3. Two vertices, distance = 0
	TestLineStrip[0] = Vect(0,0,0);
	TestLineStrip[1] = Vect(10,0,0);
	NumVertices = 2;
	bResult = DoLocationAlongLineStripTest("Distance = 0", TestLineStrip, NumVertices, 0.0, Vect(0,0,0), FailedReasonString);
	if(!bResult) return false;

	// 4. Two vertices, distance = total length
	bResult = DoLocationAlongLineStripTest("Distance = total length", TestLineStrip, NumVertices, 10.0, Vect(10,0,0), FailedReasonString);
	if(!bResult) return false;

	// 5. Two vertices, distance > total length
	bResult = DoLocationAlongLineStripTest("Distance > total length", TestLineStrip, NumVertices, 15.0, Vect(10,0,0), FailedReasonString);
	if(!bResult) return false;

	// 6. Two vertices, midpoint
	bResult = DoLocationAlongLineStripTest("Midpoint", TestLineStrip, NumVertices, 5.0, Vect(5,0,0), FailedReasonString);
	if(!bResult) return false;

	// 7. Three vertices, distance exactly at junction
	TestLineStrip[0] = Vect(0,0,0);
	TestLineStrip[1] = Vect(3,0,0);
	TestLineStrip[2] = Vect(3,4,0);
	NumVertices = 3;
	bResult = DoLocationAlongLineStripTest("At segment junction", TestLineStrip, NumVertices, 3.0, Vect(3,0,0), FailedReasonString);
	if(!bResult) return false;

	// 8. Three vertices, inside second segment
	bResult = DoLocationAlongLineStripTest("Inside second segment", TestLineStrip, NumVertices, 5.0, Vect(3,2,0), FailedReasonString);
	if(!bResult) return false;

	// 9. Non-planar
	TestLineStrip[0] = Vect(0,0,0);
	TestLineStrip[1] = Vect(0,0,5);
	TestLineStrip[2] = Vect(0,12,5);
	NumVertices = 3;
	bResult = DoLocationAlongLineStripTest("Non-planar case", TestLineStrip, NumVertices, 6.0, Vect(0,1,5), FailedReasonString);
	if(!bResult) return false;

	// 10. Degenerate segment
	TestLineStrip[0] = Vect(0,0,0);
	TestLineStrip[1] = Vect(0,0,0);
	TestLineStrip[2] = Vect(0,5,0);
	NumVertices = 3;
	bResult = DoLocationAlongLineStripTest("Degenerate zero-length segment", TestLineStrip, NumVertices, 2.0, Vect(0,2,0), FailedReasonString);
	if(!bResult) return false;

	return true;
}


static function bool DoLineStripLengthTest(
	String TestName,
	out Vector InVLoc[64], int NumVertices,
	float ExpectedReturnValue,
	out String OutFailedReasonString)
{
	local float Result;

	Result = GeomLib.Static.LineStripLength(InVLoc, NumVertices);
	if(Result != ExpectedReturnValue)
	{
		OutFailedReasonString = "LineStripLength test failed for test '" $ TestName $ "' : NumVertices:" @ NumVertices @ "expected:" @ ExpectedReturnValue @ "got:" @ Result;
		return false;
	}
	return true;
}

static function bool DoLocationAlongLineStripTest(
	String TestName,
	out Vector InVLoc[64], int NumVertices, float Distance,
	Vector ExpectedReturnValue,
	out String OutFailedReasonString)
{
	local Vector Result;

	Result = GeomLib.Static.LocationAlongLineStrip(InVLoc, NumVertices, Distance);
	if(Result != ExpectedReturnValue)
	{
		OutFailedReasonString = "LocationAlongLineStrip failed for test '" $ TestName $ "' ': NumVertices:" @ NumVertices @ "exptect:" @ ExpectedReturnValue @ "got:" @ Result;
		return false;
	}
	return true;
}