//==============================================================================
// R_AGrid
// Abstract class which contains package-wide utility functions for snapping
// objects to a grid
//==============================================================================
class R_AGrid extends Object abstract;

/**
*   Floor
*/
static function float Floor(float InFloat)
{
    return InFloat - (InFloat % 1.0);
}

/**
*   SnapLocationToGrid
*   Snaps a given world location to a grid with cell size = GridUnitSize
*   Returns the grid-confined world location
*/
static function Vector SnapLocationToGrid(int GridUnitSize, Vector InLocation)
{
    local Vector OutLocation;
    
    OutLocation.X = Floor(InLocation.X / GridUnitSize) * GridUnitSize;
    OutLocation.Y = Floor(InLocation.Y / GridUnitSize) * GridUnitSize;
    OutLocation.Z = Floor(InLocation.Z / GridUnitSize) * GridUnitSize;
    
    return OutLocation;
}