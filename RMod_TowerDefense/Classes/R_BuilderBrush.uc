//==============================================================================
//	R_BuilderBrush
//	The builder brush is an actor class used for placing buildable actors in
//	the level
//==============================================================================
class R_BuilderBrush extends Actor;

const LogCategory = 'RModTowerDefense';

// Libraries
const GridLibrary = Class'RMod_TowerDefense.R_AGridLibrary';

// Grid snapping vars
var int BrushGridUnitSnapping;  // Grid unit size

// The buildable class that this builder brush is currently representing
var private Class<R_ABuildableActor> BuildableActorClass;

var Vector DesiredBrushLocation;

var R_GridActor GridActor;

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

	GridActor = Spawn(Class'R_GridActor', Self);
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
    local Vector SnappedLocation;
    local R_RunePlayer RPOwner;
	local int GridCellXCount, GridCellYCount;
    
    RPOwner = R_RunePlayer(Owner);
    
    // Self-destroy if the owner was somehow lost
    if(RPOwner == None)
    {
        Warn("BuilderBrush has no R_RunePlayer owner, self-destroying");
        Destroy();
        return;
    }
    
    ViewRotation = RPOwner.ViewRotation;
    PawnOrigin = RPOwner.Location;
    
	if(BuildableActorClass != None)
	{
		GridCellXCount = BuildableActorClass.Default.GridCellsX;
		GridCellYCount = BuildableActorClass.Default.GridCellsY;
		SnappedLocation = GridLibrary.Static.SnapAreaLocationToGrid(
			BrushGridUnitSnapping, DesiredBrushLocation,
			GridCellXCount, GridCellYCount);
	}
	
	// Update grid actor
	if(GridActor != None)
	{
		GridActor.EmphasisLocation = DesiredBrushLocation;
		GridActor.ConstrainedLocation = SnappedLocation;
	}

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
	if(GridActor != None)
	{
		GridActor.GridActorPostRender(C);
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
    BrushGridUnitSnapping=64
}