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

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bNetTemporary=True
    ProjectileBehavior=PB_FireAndForget
    ProjectileOrientationAxis=PA_AxisX
}