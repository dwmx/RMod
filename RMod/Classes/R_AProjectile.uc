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

replication
{
    reliable if(Role == ROLE_Authority)
        ProjectileTarget;
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    
    Velocity = Vector(Rotation) * Speed;
}

function SetProjectileTarget(Actor NewProjectileTarget)
{
    ProjectileTarget = NewProjectileTarget;
}

simulated event Tick(float DeltaSeconds)
{
    local Vector TargetDeltaVector;
    local Rotator NewRotation;
    local float CurrentSpeed;
    
    Super.Tick(DeltaSeconds);
    
    // FireAndForget is a projectile's default behavior, so no special handling required
    
    // Account for VelocityTowardsTarget behavior
    if(ProjectileBehavior == PB_VelocityTowardsTarget && ProjectileTarget != None)
    {
        TargetDeltaVector = ProjectileTarget.Location - Location;
        NewRotation = Rotator(TargetDeltaVector);
        CurrentSpeed = VSize(Velocity);
        
        SetRotation(NewRotation);
        Velocity = Vector(NewRotation) * CurrentSpeed;
    }
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bNetTemporary=True
    ProjectileBehavior=PB_FireAndForget
}