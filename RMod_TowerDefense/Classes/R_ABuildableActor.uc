//==============================================================================
// R_ABuildableActor
// Abstract Actor class which is the base for all actors that can be built by
// the R_RunePlayer_TD player class via the R_BuilderBrush Actor
//==============================================================================
class R_ABuildableActor extends Actor abstract;

// Static utilities
var Class<R_AUtilities> UtilitiesClass;

// Grid dimensions -- how many rows and columns this actor takes up
var int GridCellsX;
var int GridCellsY;

// Cost associated with this tower
// If the player doesn't have enough Gold, then main game info will reject
// requests to build this actor
var int GoldCost;

defaultproperties
{
    DrawType=DT_SkeletalMesh
    CollisionHeight=80.0
    UtilitiesClass=Class'RMod.R_AUtilities'
	GridCellsX=1
	GridCellsY=1
	GoldCost=0
}