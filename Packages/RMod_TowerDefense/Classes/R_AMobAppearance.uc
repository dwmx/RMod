//==============================================================================
// R_AMobAppearance
// Abstract base class for mob appearance variables
//
// The point of this class is to associate all mesh, texture and animation
// data together so that it can all be applied to a mob at once
//
// This class is not meant to be instantiated
// Instead, R_AMob will take a class type of R_AMobAppearance and apply its
// defaultproperties to itself
//==============================================================================
class R_AMobAppearance extends Object abstract;

var SkelModel   Skeletal;           // Applied to R_AMob.Skeletal
var byte        SkelMeshIndex;      // Applied to R_AMob.SkelMesh
var Texture     SkelGroupSkins[16]; // Applied to R_AMob.SkelGroupSkins
var int         SkelGroupFlags[16]; // Applied to R_AMob.SkelGroupFlags;

var Name        A_Idle;             // Idle animation
var Name        A_MoveForward;      // Move forward animation
var Name        A_Dying[5];         // Dying animation

defaultproperties
{
    Skeletal=None
    SkelMeshIndex=0
    A_MoveForward=None
}