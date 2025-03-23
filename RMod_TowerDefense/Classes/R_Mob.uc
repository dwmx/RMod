//==============================================================================
// R_Mob
// Abstract base class for all mob pawns
//==============================================================================
class R_Mob extends Actor;

var Class<R_AMobAppearance> MobAppearanceClass;

// Animations
var Name A_MoveForward; // Move forward animation

// Overall speed scale for this mob
// i.e. When this mob is slowed, it will animate slower and run slower
var float MobSpeedScale;

replication
{
    // Server --> Client Variables
    reliable if(Role == ROLE_Authority)
        MobAppearanceClass,
        MobSpeedScale;
}

/**
*   ApplyMobAppearance
*   Apply all appearance traits of the given mob class to this mob
*/
simulated function ApplyMobAppearance(Class<R_AMobAppearance> NewMobAppearanceClass)
{
    local int i;

    // Mesh and texture
    Skeletal = NewMobAppearanceClass.Default.Skeletal;
    SkelMesh = NewMobAppearanceClass.Default.SkelMeshIndex;
    
    for(i = 0; i < 16; ++i)
    {
        SkelGroupSkins[i] = NewMobAppearanceClass.Default.SkelGroupSkins[i];
        SkelGroupFlags[i] = NewMobAppearanceClass.Default.SkelGroupFlags[i];
    }
    
    // Animation
    A_MoveForward = NewMobAppearanceClass.Default.A_MoveForward;
    
    // Update mob appearance which will replicated to clients
    MobAppearanceClass = NewMobAppearanceClass;
}

/**
*   PreBeginPlay (override)
*   Overridden to apply replicated initialization variables
*   Client picks up these changes in PostNetBeginPlay, so only perform initialization
*   in this function for the server
*/
simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    
    // Test mob appearance
    if(Role == ROLE_Authority)
    {
        ApplyMobAppearance(Class'R_AMobAppearance_Viking_Elder');
    }
}

/**
*   PostNetBeginPlay (override)
*   Note that this function does NOT get called on the server, it is client only
*   This function is called after initial replication of the actor
*   Replicated variabled in PreBehinPlay will be valid on the client when this function
*   is called
*/
simulated event PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    // Clients need to apply mob appearance here
    if(Role < ROLE_Authority)
    {
        ApplyMobAppearance(MobAppearanceClass);
    }
}

/**
*   Tick (override)
*   Overridden to play animations and update behaviors
*/
simulated event Tick(float DeltaSeconds)
{
    Super.Tick(DeltaSeconds);
    
    Velocity.X = 32.0;
    AutonomousPhysics(DeltaSeconds);
    
    PlayMoving();
}

/**
*   PlayMoving
*   Play this Mob's moving animations
*/
simulated function PlayMoving()
{
    LoopAnim(A_MoveForward, MobSpeedScale, 0.1);
}

auto state Neutral
{
    event BeginState()
    {
        SetPhysics(PHYS_Walking);
    }
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    DrawType=DT_SkeletalMesh
    MobSpeedScale=1.0
}