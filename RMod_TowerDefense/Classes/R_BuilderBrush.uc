class R_BuilderBrush extends Actor;

// Static utility classes
var Class<R_AUtilities> UtilitiesClass;
var Class<R_AGrid> GridClass;

// Grid snapping vars
var float BrushPlacementOffset; // How far in front of the player to place the brush
var int BrushGridUnitSnapping;  // Grid unit size

/**
*   Tick (override)
*   BuilderBrush will self-update, snapping itself to the world grid depending on where the
*   player is looking
*/
event Tick(float DeltaSeconds)
{
    local Rotator ViewRotation;
    local Vector PawnOrigin;
    local Vector DesiredLocation;
    local Vector SnappedLocation;
    local R_RunePlayer RPOwner;
    
    RPOwner = R_RunePlayer(Owner);
    
    // Self-destroy if the owner was somehow lost
    if(RPOwner == None)
    {
        UtilitiesClass.Static.RModWarn("BuilderBrush has no R_RunePlayer owner, self-destroying");
        Destroy();
        return;
    }
    
    ViewRotation = RPOwner.ViewRotation;
    PawnOrigin = RPOwner.Location;
    DesiredLocation = PawnOrigin + Vector(ViewRotation) * BrushPlacementOffset;
    
    SnappedLocation = GridClass.Static.SnapLocationToGrid(BrushGridUnitSnapping, DesiredLocation);
    
    SetLocation(SnappedLocation);
}

/**
*   BuilderBrushPostRender
*   Called from owning R_RunePlayer_TD.PostRender
*   Draws the buildable grid and any other HUD related info
*/
function BuilderBrushPostRender(Canvas C)
{
    local Vector SnappedLocation;
    local int NumRowsAndColsToDraw;
    local int i;
    local Vector LineStart, LineEnd;
    
    SnappedLocation = GridClass.Static.SnapLocationToGrid(BrushGridUnitSnapping, Location);
    
    NumRowsAndColsToDraw = 6;
    
    for(i = 1; i < NumRowsAndColsToDraw; ++i)
    {
        // Draw Rows
        LineStart = SnappedLocation;
        LineStart.X -= (NumRowsAndColsToDraw >> 1) * BrushGridUnitSnapping;
        LineStart.Y -= (NumRowsAndColsToDraw >> 1) * BrushGridUnitSnapping;
        LineStart.Y += i * BrushGridUnitSnapping;
        
        LineEnd.X = LineStart.X + NumRowsAndColsToDraw * BrushGridUnitSnapping;
        LineEnd.Y = LineStart.Y;
        LineEnd.Z = LineStart.Z;
        
        C.DrawLine3D(LineStart, LineEnd, 1.0, 1.0, 1.0);
        
        // Draw Cols
        LineStart = SnappedLocation;
        LineStart.Y -= (NumRowsAndColsToDraw >> 1) * BrushGridUnitSnapping;
        LineStart.X -= (NumRowsAndColsToDraw >> 1) * BrushGridUnitSnapping;
        LineStart.X += i * BrushGridUnitSnapping;
        
        LineEnd.Y = LineStart.Y + NumRowsAndColsToDraw * BrushGridUnitSnapping;
        LineEnd.X = LineStart.X;
        LineEnd.Z = LineStart.Z;
        
        C.DrawLine3D(LineStart, LineEnd, 1.0, 1.0, 1.0);
    }
    
    
}

defaultproperties
{
    DrawType=DT_SkeletalMesh
    Skeletal=SkelModel'objects.Barrel'
    bCollideActors=False
    bCollideWorld=False
    bBlockActors=False
    bBlockPlayers=False
    UtilitiesClass=Class'RMod.R_AUtilities'
    GridClass=Class'RMod_TowerDefense.R_AGrid'
    BrushPlacementOffset=64.0
    BrushGridUnitSnapping=64
}