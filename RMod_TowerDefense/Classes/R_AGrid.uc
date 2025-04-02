//==============================================================================
// R_AGrid
// Abstract class which contains package-wide utility functions for snapping
// objects to a grid
//==============================================================================
class R_AGrid extends Object abstract;

const MathLibrary = Class'RBase.R_AMathLibrary';

/**
*   SnapLocationToGrid
*   Snaps a given world location to a grid with cell size = GridUnitSize
*   Returns the grid-confined world location
*/
static function Vector SnapLocationToGrid(int GridUnitSize, Vector InLocation)
{
    local int HalfGridUnitSize;
    local Vector OutLocation;
    
    HalfGridUnitSize = GridUnitSize >> 1;
    InLocation.X += HalfGridUnitSize;
    InLocation.Y += HalfGridUnitSize;
    InLocation.Z += HalfGridUnitSize;
    
    OutLocation.X = MathLibrary.Static.Floor(InLocation.X / GridUnitSize) * GridUnitSize;
    OutLocation.Y = MathLibrary.Static.Floor(InLocation.Y / GridUnitSize) * GridUnitSize;
    OutLocation.Z = MathLibrary.Static.Floor(InLocation.Z / GridUnitSize) * GridUnitSize;
    
    return OutLocation;
}