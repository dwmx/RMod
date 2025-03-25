//==============================================================================
// R_AProjectile
//
// Abstract base projectile class with some additional behavior features
//
// These projectiles are meant to be spawned and then torn off, so callers
// should spawn a projectile and then immediately set all variables desired
// for replication
//==============================================================================
class R_AProjectile extends Projectile abstract;

// Static utilities
var Class<R_AUtilities> UtilitiesClass;

// Target actor for this projectile
var Actor ProjectileTarget;

//
// Projectile behavior enumerator
//
// PB_FireAndForget:
// When spawned, this projectile will move along its X axis until it collides
// with something or otherwise destroyed
//
// PB_VelocityTowardsTarget:
// Each Tick this projectile will orient its velocity towards ProjectileTarget
// If ProjectileTarget is None, then it reverts back to FireAndForget
//
enum EProjectileBehavior
{
    PB_FireAndForget,
    PB_VelocityTowardsTarget
};
var EProjectileBehavior ProjectileBehavior;

//
// Projectile orientation axis enumerator
//
// Tells this projectile what axis it should align itself with when aiming
// at a target
//
enum EProjectileOrientationAxis
{
    PA_AxisX,
    PA_AxisY,
    PA_AxisZ
};
var EProjectileOrientationAxis ProjectileOrientationAxis;

// Projectile tracer
// If true, this projectile will spawn a ProjectileTracer particle
// system locally (non-replicated)
var bool bUseProjectileTracer;
var Class<R_ProjectileTracer> ProjectileTracerClass;
var R_ProjectileTracer ProjectileTracer;

replication
{
    reliable if(Role == ROLE_Authority)
        ProjectileTarget;
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    
    Velocity = Vector(Rotation) * Speed;
    
    // This allows projectiles to initially orient themselves
    OrientProjectileTowards(Location + Vector(Rotation));
    
    if(ShouldSpawnProjectileTracer())
    {
        SpawnProjectileTracer();
    }
}

/**
*   ShouldSpawnProjectileTracer
*   Returns whether or not projectile tracer should be spawned
*   Accounts for net mode and role
*/
simulated function bool ShouldSpawnProjectileTracer()
{
    // Setting must be enabled
    if(!bUseProjectileTracer)
    {
        return false;
    }
    
    // No reason for this to spawn on dedicated server authority
    if(Level.NetMode == NM_DedicatedServer && Role == ROLE_Authority)
    {
        return false;
    }
    
    return true;
}

/**
*   SpawnProjectileTracer
*   Spawns and initializes a tracer projectile
*   Important to note that projectiles are simulated proxies, but tracer
*   effects have no role -- you must spawn them on the local machine
*/
simulated function SpawnProjectileTracer()
{
    if(ProjectileTracer != None)
    {
        ProjectileTracer.Destroy();
    }
    
    if(ProjectileTracerClass == None)
    {
        UtilitiesClass.Static.RModWarn(
            "Tried to spawn projectile tracer but ProjectileTracerClass is improperly configured");
        return;
    }
    
    ProjectileTracer = Spawn(ProjectileTracerClass, Self, /*Tag*/, /*Location*/, /*Rotation*/);
    if(ProjectileTracer == None)
    {
        UtilitiesClass.Static.RModWarn(
            "Failed to spawn projectile tracer from class" @ ProjectileTracerClass);
    }
}

/**
*   GetProjectileEffectBaseOffset
*   Spawned projectile effects call this so they know where they should play their
*   effects from
*   i.e. this would be where the tracer creates its particles from
*/
simulated function Vector GetProjectileEffectBaseOffset()
{
    local Vector Result;
    
    Result.X = 0.0;
    Result.Y = 0.0;
    Result.Z = 0.0;
    
    return Result;
}

function SetProjectileTarget(Actor NewProjectileTarget)
{
    ProjectileTarget = NewProjectileTarget;
}

/**
*   OrientProjectileTowards
*   Called by Tick when this projectile needs to re-orient itself towards a point
*   This allows different projectiles to orient themselves in unique ways if desired
*/
simulated function OrientProjectileTowards(Vector TargetLocation)
{
    local Vector TargetDeltaVector;
    local Rotator NewRotation;
    local Vector RX, RY, RZ;
    
    TargetDeltaVector = TargetLocation - Location;
    NewRotation = Rotator(TargetDeltaVector);
    
    GetAxes(NewRotation, RX, RY, RZ);
    switch(ProjectileOrientationAxis)
    {
        case PA_AxisX:  NewRotation = Rotator(RX);  break;
        case PA_AxisY:  NewRotation = Rotator(RY);  break;
        case PA_AxisZ:  NewRotation = Rotator(RZ);  break;
    }
    
    SetRotation(NewRotation);
}

/**
*   Tick (override)
*   Overridden to implement the different projectile behaviors
*/
simulated event Tick(float DeltaSeconds)
{
    local float CurrentSpeed;
    
    Super.Tick(DeltaSeconds);
    
    // FireAndForget is a projectile's default behavior, so no special handling required
    
    // Account for VelocityTowardsTarget behavior
    if(ProjectileBehavior == PB_VelocityTowardsTarget && ProjectileTarget != None)
    {
        CurrentSpeed = VSize(Velocity);
        
        OrientProjectileTowards(ProjectileTarget.Location);
        
        Velocity = Normal(ProjectileTarget.Location - Location) * CurrentSpeed;
    }
}

/**
*   Destroyed (override)
*   Overridden to destroy effects
*/
simulated event Destroyed()
{
    if(ProjectileTracer != None)
    {
        ProjectileTracer.Destroy();
    }
    
    Super.Destroyed();
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bNetTemporary=True
    ProjectileBehavior=PB_FireAndForget
    ProjectileOrientationAxis=PA_AxisX
    bUseProjectileTracer=True
    ProjectileTracerClass=Class'R_ProjectileTracer'
}