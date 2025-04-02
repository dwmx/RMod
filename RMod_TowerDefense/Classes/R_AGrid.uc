//==============================================================================
// R_AGrid
// Abstract class which contains package-wide utility functions for snapping
// objects to a grid
//==============================================================================
class R_AGridLibrary extends R_ALibrary abstract;

const MathLibrary = Class'RBase.R_AMathLibrary';
const CanvasLibrary = Class'RBase.R_ACanvasLibrary';

/**
*   SnapLocationToGrid
*   Snaps a given world location to a grid with cell size = GridUnitSize
*   Returns the grid-confined world location
*/
static function Vector SnapLocationToGrid(int GridUnitSize, Vector InLocation)
{
    local Vector OutLocation;
    
    OutLocation.X = MathLibrary.Static.Round(InLocation.X / GridUnitSize) * GridUnitSize;
    OutLocation.Y = MathLibrary.Static.Round(InLocation.Y / GridUnitSize) * GridUnitSize;
    OutLocation.Z = InLocation.Z;
    
    return OutLocation;
}

/**
*	SnapAreaLocationToGrid
*	Given some area of X cells and Y cells (rows and columns) and some origin world location,
*	this returns the area's center-point origin snapped to the grid
*
*	CellCount arguments are constrainted to minimum of 1
*/
static function Vector SnapAreaLocationToGrid(
	int GridUnitSize, Vector InLocation,
	int XCellCount, int YCellCount)
{
	local float AlignmentX, AlignmentY;
	local Vector Offset;
	local Vector Result;

	XCellCount = Max(1, XCellCount);
	YCellCount = Max(1, YCellCount);

	// If cell count is even -- snap to edge
	// If cell count is odd -- snap to middle
	if(XCellCount % 2 == 0) AlignmentX = 0.0;
	else					AlignmentX = 0.5;

	if(YCellCount % 2 == 0)	AlignmentY = 0.0;
	else					AlignmentY = 0.5;

	Result.X = MathLibrary.Static.Round(InLocation.X / GridUnitSize) * GridUnitSize;
	Result.Y = MathLibrary.Static.Round(InLocation.Y / GridUnitSize) * GridUnitSize;

	Offset = InLocation - Result;
	Offset.X = (Offset.X / Abs(Offset.X)) * GridUnitSize;
	Offset.Y = (Offset.Y / Abs(Offset.Y)) * GridUnitSize;
	Offset.Z = 0.0;;

	Result.X += Offset.X * AlignmentX;
	Result.Y += offset.Y * AlignmentY;
	Result.Z = InLocation.Z;

	return Result;
}

//==============================================================================
//	Canvas drawing utility functions
//==============================================================================

/**
*	DrawAreaSnappedToGrid
*	Given a Row x Col grid area and a location in space, this will draw
*	that area with its mid-point snapped to the grid
*/
static function DrawAreaSnappedToGrid(
	Canvas C,
	int GridUnitSize, Vector InLocation,
	int XCellCount, int YCellCount,
	float R, float G, float B)
{
	local Vector SnappedAreaLocation;

	XCellCount = Max(1, XCellCount);
	YCellCount = Max(1, YCellCount);
	SnappedAreaLocation = SnapAreaLocationToGrid(GridUnitSize, InLocation, XCellCount, YCellCount);

	// Draw a rectangle to represent the area
	CanvasLibrary.Static.DrawRectAxisAligned3D(
		C, SnappedAreaLocation, Vect(0.5, 0.5, 0.0),
		GridUnitSize * XCellCount,
		GridUnitSize * YCellCount,
		R, G, B);
	
	// Draw the snapping origin
	CanvasLibrary.Static.DrawAxes3D(C, SnappedAreaLocation, GridUnitSize * 0.75, R, G, B);
}

/**
*	DrawLocationSnappedToGrid
*	Given some world location, this will draw where that location snaps to the specific grid
*/
static function DrawLocationSnappedToGrid(
	Canvas C,
	int GridUnitSize, Vector InLocation,
	float R, float G, float B)
{
	local Vector SnappedLocation;
	local float LineLength;
	local Vector LineStart, LineStop;

	SnappedLocation = SnapLocationToGrid(GridUnitSize, InLocation);
	LineLength = 16.0;

	CanvasLibrary.Static.DrawAxes3D(C, SnappedLocation, GridUnitSize * 0.75, R, G, B);
}

/**
*	DrawGridLines
*	Draw some number of grid lines at the specified world location
*/
static function DrawGridLines(
	Canvas C,
	int GridUnitSize, Vector InLocation,
	int XGridLines, int YGridLines, Vector Alignment,
	float R, float G, float B)
{
	local Vector LocationSnapped;
	local Vector LineStart, LineStop;
	local float XLineLength, YLineLength;
	local int i;

	XGridLines = Clamp(XGridLines, 2, 100);
	YGridLines = Clamp(YGridLines, 2, 100);
	Alignment.X = FClamp(Alignment.X, 0.0, 1.0);
	Alignment.Y = FClamp(Alignment.Y, 0.0, 1.0);

	LocationSnapped = SnapLocationToGrid(GridUnitSize, InLocation);

	XLineLength = GridUnitSize * YGridLines;
	YLineLength = GridUnitSize * XGridLines;

	// Draw X axis lines
	LineStart = LocationSnapped;
	LineStart += Vect(-1,0,0) * XLineLength * Alignment.X;
	LineStart += Vect(0,-1,0) * YLineLength * Alignment.Y;
	LineStop = LineStart + Vect(1,0,0) * XLineLength;
	for(i = 0; i < XGridLines - 1; ++i)
	{
		LineStart += Vect(0,1,0) * GridUnitSize;
		LineStop += Vect(0,1,0) * GridUnitSize;
		C.DrawLine3D(LineStart, LineStop, R, G, B);
	}

	// Draw Y axis lines
	LineStart = LocationSnapped;
	LineStart += Vect(-1,0,0) * XLineLength * Alignment.X;
	LineStart += Vect(0,-1,0) * YLineLength * Alignment.Y;
	LineStop = LineStart + Vect(0,1,0) * YLineLength;
	for(i = 0; i < YGridLines - 1; ++i)
	{
		LineStart += Vect(1,0,0) * GridUnitSize;
		LineStop += Vect(1,0,0) * GridUnitSize;
		C.DrawLine3D(LineStart, LineStop, R, G, B);
	}
}