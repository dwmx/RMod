// Tests the robustness of indexing within the grid library
class R_ATest_Grid_DuplexIndexing extends R_ATest_Grid abstract;

static function String GetTestNameString()
{
	return "Grid duplex indexing";
}

static function bool RunTest(out String FailedReasonString)
{
	local bool bResult;

	// --- Flattening tests (2D -> 1D) ---

	// Origin (0,0)
	bResult = DoGetGridArrayIndexFromGrid2DIndexTest(
		"Flatten Origin",
		64, 64,
		0, 0,
		0,
		FailedReasonString);
	if(!bResult) return false;

	// First row, X=5
	bResult = DoGetGridArrayIndexFromGrid2DIndexTest(
		"Flatten Row0 Col5",
		64, 64,
		5, 0,
		5,
		FailedReasonString);
	if(!bResult) return false;

	// First column, Y=10
	bResult = DoGetGridArrayIndexFromGrid2DIndexTest(
		"Flatten Col0 Row10",
		64, 64,
		0, 10,
		10 * 64 + 0,
		FailedReasonString);
	if(!bResult) return false;

	// Middle point (X=20,Y=20)
	bResult = DoGetGridArrayIndexFromGrid2DIndexTest(
		"Flatten Middle",
		64, 64,
		20, 20,
		20 * 64 + 20,
		FailedReasonString);
	if(!bResult) return false;

	// Max edge (X=63,Y=63)
	bResult = DoGetGridArrayIndexFromGrid2DIndexTest(
		"Flatten MaxEdge",
		64, 64,
		63, 63,
		63 * 64 + 63,
		FailedReasonString);
	if(!bResult) return false;

	// Clamping below range
	bResult = DoGetGridArrayIndexFromGrid2DIndexTest(
		"Flatten ClampLow",
		64, 64,
		-5, -5,
		0, // clamps to (0,0)
		FailedReasonString);
	if(!bResult) return false;

	// Clamping above range
	bResult = DoGetGridArrayIndexFromGrid2DIndexTest(
		"Flatten ClampHigh",
		64, 64,
		100, 100,
		(63 * 64) + 63, // clamps to (63,63)
		FailedReasonString);
	if(!bResult) return false;


	// --- Unflattening tests (1D -> 2D) ---

	// Index 0 -> (0,0)
	bResult = DoGetGrid2DIndexFromGridArrayIndexTest(
		"Unflatten Origin",
		64, 64,
		0,
		0, 0,
		FailedReasonString);
	if(!bResult) return false;

	// Index 5 -> (5,0)
	bResult = DoGetGrid2DIndexFromGridArrayIndexTest(
		"Unflatten Row0 Col5",
		64, 64,
		5,
		5, 0,
		FailedReasonString);
	if(!bResult) return false;

	// Index 64 -> (0,1)
	bResult = DoGetGrid2DIndexFromGridArrayIndexTest(
		"Unflatten NextRow",
		64, 64,
		64,
		0, 1,
		FailedReasonString);
	if(!bResult) return false;

	// Middle point index = 20*64+20 = 1300
	bResult = DoGetGrid2DIndexFromGridArrayIndexTest(
		"Unflatten Middle",
		64, 64,
		1300,
		20, 20,
		FailedReasonString);
	if(!bResult) return false;

	// Max index (last cell)
	bResult = DoGetGrid2DIndexFromGridArrayIndexTest(
		"Unflatten MaxEdge",
		64, 64,
		4095, // 64*64 - 1
		63, 63,
		FailedReasonString);
	if(!bResult) return false;


	// --- Roundtrip consistency tests ---
	// Flatten then unflatten should match original (X,Y)
	bResult = DoGetGrid2DIndexFromGridArrayIndexTest(
		"RoundTrip Test (X=7,Y=13)",
		64, 64,
		13*64 + 7,
		7, 13,
		FailedReasonString);
	if(!bResult) return false;

	bResult = DoGetGrid2DIndexFromGridArrayIndexTest(
		"RoundTrip Test (X=63,Y=0)",
		64, 64,
		0*64 + 63,
		63, 0,
		FailedReasonString);
	if(!bResult) return false;

	bResult = DoGetGrid2DIndexFromGridArrayIndexTest(
		"RoundTrip Test (X=0,Y=63)",
		64, 64,
		63*64 + 0,
		0, 63,
		FailedReasonString);
	if(!bResult) return false;

	return true;
}


static function bool DoGetGridArrayIndexFromGrid2DIndexTest(
	String TestName,
	int CellCountX, int CellCountY,
	int GridIndexX, int GridIndexY,
	int ExpectedReturnValue,
	out String OutFailedReasonString)
{
	local int Result;

	Result = GridLibrary.Static. GetGridArrayIndexFromGrid2DIndex(CellCountX, CellCountY, GridIndexX, GridIndexY);
	if(Result != ExpectedReturnValue)
	{
		OutFailedReasonString =
			"GetGridArrayIndexFromGrid2DIndex failed for" @ TestName @ "test -- args:"
			@ GetArgString_GetGridArrayIndexFromGrid2DIndex(CellCountX, CellCountY, GridIndexX, GridIndexY) @ "-- expected:" @ ExpectedReturnValue @ "got" @ Result;
		return false;
	}
	return true;
}

static function String GetArgString_GetGridArrayIndexFromGrid2DIndex(int CellCountX, int CellCountY, int GridIndexX, int GridIndexY)
{
	local String Result;

	Result = "";
	Result = Result $ "CellCountX:" @ CellCountX;
	Result = Result @ "CellCountY:" @ CellCountY;
	Result = Result @ "GridIndexX:" @ GridIndexX;
	Result = Result @ "GridIndexY:" @ GridIndexY;
	return Result;
}

static function bool DoGetGrid2DIndexFromGridArrayIndexTest(
	String TestName,
	int CellCountX, int CellCountY,
	int GridArrayIndex,
	int ExpectedGridIndexX, int ExpectedGridIndexY,
	out String OutFailedReasonString)
{
	local int ResultGridIndexX, ResultGridIndexY;

	GridLibrary.Static.GetGrid2DIndexFromGridArrayIndex(CellCountX, CellCountY, GridArrayIndex, ResultGridIndexX, ResultGridIndexY);
	if(ResultGridIndexX != ExpectedGridIndexX || ResultGridIndexY != ExpectedGridIndexY)
	{
		OutFailedReasonString =
			"GetGridArrayIndexFromGrid2DIndex failed for" @ TestName @ "test -- args:"
			@ GetArgString_GetGrid2DIndexFromGridArrayIndex(CellCountX, CellCountY, GridArrayIndex)
			@ "-- expected:" @ ExpectedGridIndexX $ "," @ ExpectedGridIndexY
			@ "got" @ ResultGridIndexX $ "," @ ResultGridIndexY;
		return false;
	}
	return true;
}

static function String GetArgString_GetGrid2DIndexFromGridArrayIndex(int CellCountX, int CellCountY, int GridArrayIndex)
{
	local String Result;

	Result = "";
	Result = Result $ "CellCountX:" @ CellCountX;
	Result = Result @ "CellCountY:" @ CellCountY;
	Result = Result @ "GridArrayIndex:" @ GridArrayIndex;
	return Result;
}