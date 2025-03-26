//==============================================================================
// R_Mob
// Abstract base class for all mob actors
//
// For simplicity, this class does not extend from Pawn
//==============================================================================
class R_Mob extends Pawn;

var Class<R_AMobAppearance> MobAppearanceClass;

// Animations
var Name A_Idle;            // Idle animation
var Name A_MoveForward;     // Move forward animation
var Name A_Dying[5];        // Dying animations
var int NumDyingAnimations; // Up to 5

// Test target
var Actor TargetActor;

// Overall speed scale for this mob
// i.e. When this mob is slowed, it will animate slower and run slower
var float MobSpeedScale;

// Whether or not towers should target this mob
var bool bTargetable;

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
    
    // Animations
    A_Idle = NewMobAppearanceClass.Default.A_Idle;
    A_MoveForward = NewMobAppearanceClass.Default.A_MoveForward;
    
    NumDyingAnimations = 0;
    for(i = 0; i < 5; ++i)
    {
        if(NewMobAppearanceClass.Default.A_Dying[i] != '')
        {
            A_Dying[NumDyingAnimations] = NewMobAppearanceClass.Default.A_Dying[i];
            ++NumDyingAnimations;
        }
    }
    
    // Update mob appearance which will replicated to clients
    MobAppearanceClass = NewMobAppearanceClass;
}

/**
*   PreBeginPlay (override)
*   Overridden for testing
*/
simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
}

/**
*   PostBeginPlay (override)
*   Game initialization
*/
simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    
    // Always targetable at initialization
    bTargetable = true;
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
*/
simulated event Tick(float DeltaSeconds)
{
    Super.Tick(DeltaSeconds);
}

/**
*   PlayMoving
*   Play this Mob's moving animations
*/
function PlayMoving(optional float Tween)
{
    LoopAnim(A_MoveForward, MobSpeedScale, 0.1);
}

/**
*   JointDamaged (override)
*   Pawn's JointDamaged function normally passes through DamageBodyPart which deals
*   with body part severing, gibs, etc
*   Mobs aren't that complicated, so this implements simpler damage functionality
*/
function bool JointDamaged(
    int Damage,
    Pawn EventInstigator,
    Vector HitLocation,
    Vector Momentum,
    Name DamageType,
    int Joint)
{
    Health = Max(Health - Damage, 0);
    if(Health == 0)
    {
        Died(Instigator, DamageType, HitLocation);
    }
}

/**
*   Died (override)
*/
function Died(Pawn Killer, Name DamageType, Vector HitLocation)
{
    local int i;
    local R_GameInfo_TD GI;
    
    Health = 0;
    
    if(Level.Game != None)
    {
        Level.Game.Killed(Killer, Self, DamageType);
    }

    i = Rand(NumDyingAnimations);
    PlayAnim(A_Dying[i], MobSpeedScale * 1.0, 0.1);
    
    GotoState('Dying');
}

/**
*   IsMobTargetable
*   Called by towers to see if this mob is a valid target
*/
function bool IsMobTargetable()
{
    return bTargetable;
}

auto state Neutral
{
    event BeginState()
    {
        SetPhysics(PHYS_Walking);
    }
    
Begin:
    GotoState('Pathing');
}

state Dying
{
    event BeginState()
    {
        // Not targetable when dead or dying
        bTargetable = false;
        
        Velocity.X = 0.0;
        Velocity.Y = 0.0;
        
        PlayRandomDeathAnimation();
    }
    
    function PlayRandomDeathAnimation()
    {
        local int i;
        
        i = Rand(NumDyingAnimations);
        PlayAnim(A_Dying[i], MobSpeedScale * 1.0, 0.1);
    }
    
    event Tick(float DeltaSeconds)
    {
        Velocity.X = 0.0;
        Velocity.Y = 0.0;
    }
    
Begin:
    SetCollision(false, false, false);
    SetPhysics(PHYS_Falling);
    WaitForLanding();
    FinishAnim();
    Sleep(5.0);
    Destroy();
}

state Pathing
{
    event Tick(float DeltaSeconds)
    {
        PlayMoving();
    }
    
    function UpdateTargetToNextPathNode()
    {
        local R_MobPathNode PathNode;
        
        PathNode = R_MobPathNode(TargetActor);
        if(PathNode != None)
        {
            if(PathNode.NextPathNode != None)
            {
                TargetActor = PathNode.NextPathNode;
                return;
            }
        }
        
        TargetActor = None;
    }
    
Begin:
FollowPath:
    MoveTo(TargetActor.Location, MovementSpeed * MobSpeedScale);
    Sleep(0.01);
    UpdateTargetToNextPathNode();
    if(TargetActor != None)
        GoTo('FollowPath');
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    DrawType=DT_SkeletalMesh
    CollisionRadius=24.000000
    CollisionHeight=46.000000
    MobSpeedScale=1.0
    MovementSpeed=220.0
}