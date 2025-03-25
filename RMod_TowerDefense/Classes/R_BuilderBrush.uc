class R_BuilderBrush extends Actor;

// Static utility classes
var Class<R_AUtilities> UtilitiesClass;
var Class<R_AGrid> GridClass;

// Grid snapping vars
var float BrushPlacementOffset; // How far in front of the player to place the brush
var int BrushGridUnitSnapping;  // Grid unit size

// The buildable class that this builder brush is currently representing
var private Class<R_ABuildableActor> BuildableActorClass;

var Vector DesiredBrushLocation;

/**
*   PostBeginPlay (override)
*   Overridden for styling
*/
event PostBeginPlay()
{
    local Player LocalPlayer;
    
    Super.PostBeginPlay();
    
    Style = STY_Translucent;
    ScaleGlow = 100.0;
    AmbientGlow = 100.0;
}

/**
*   Tick (override)
*   BuilderBrush will self-update, snapping itself to the world grid depending on where the
*   owning player is looking
*/
event Tick(float DeltaSeconds)
{
    local Rotator ViewRotation;
    local Vector PawnOrigin;
    //local Vector DesiredLocation;
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
    //DesiredLocation = PawnOrigin + Vector(ViewRotation) * BrushPlacementOffset;
    
    SnappedLocation = GridClass.Static.SnapLocationToGrid(BrushGridUnitSnapping, DesiredBrushLocation);
    
    SetLocation(SnappedLocation);
}

function SetDesiredBrushLocation(Vector NewDesiredLocation)
{
    DesiredBrushLocation = NewDesiredLocation;
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
    
    // Don't draw grid when no class is selected
    if(BuildableActorClass == None)
    {
        return;
    }
    
    //SnappedLocation = GridClass.Static.SnapLocationToGrid(BrushGridUnitSnapping, Location);
    SnappedLocation = GridClass.Static.SnapLocationToGrid(BrushGridUnitSnapping, Owner.Location);

    NumRowsAndColsToDraw = 60;
    
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
        
        C.DrawLine3D(LineStart, LineEnd, 0.0, 0.0, 0.0);
        
        // Draw Cols
        LineStart = SnappedLocation;
        LineStart.Y -= (NumRowsAndColsToDraw >> 1) * BrushGridUnitSnapping;
        LineStart.X -= (NumRowsAndColsToDraw >> 1) * BrushGridUnitSnapping;
        LineStart.X += i * BrushGridUnitSnapping;
        
        LineEnd.Y = LineStart.Y + NumRowsAndColsToDraw * BrushGridUnitSnapping;
        LineEnd.X = LineStart.X;
        LineEnd.Z = LineStart.Z;
        
        C.DrawLine3D(LineStart, LineEnd, 0.0, 0.0, 0.0);
    }
}

/**
*   SetBuildableActorClass
*   Sets the current buildable actor class represented by this builder brush and updates
*   appearance
*/
function SetBuildableActorClass(Class<R_ABuildableActor> NewBuildableActorClass)
{
    if(BuildableActorClass == NewBuildableActorClass)
    {
        return;
    }
    
    BuildableActorClass = NewBuildableActorClass;
    if(BuildableActorClass == None)
    {
        Skeletal = None;
    }
    else
    {
        Skeletal = BuildableActorClass.Default.Skeletal;
        DrawScale = BuildableActorClass.Default.DrawScale;
    }
}

/**
*   GetBuildableActorClass
*   Returns the current BuildableActorClass, called locally by the owning R_RunePlayer_TD
*/
function Class<R_ABuildableActor> GetBuildableActorClass()
{
    return BuildableActorClass;
}

defaultproperties
{
    DrawType=DT_SkeletalMesh
    Skeletal=None
    bCollideActors=False
    bCollideWorld=False
    bBlockActors=False
    bBlockPlayers=False
    UtilitiesClass=Class'RMod.R_AUtilities'
    GridClass=Class'RMod_TowerDefense.R_AGrid'
    BrushPlacementOffset=64.0
    BrushGridUnitSnapping=64
}