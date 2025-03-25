class R_Projectile_DwarfMechRocket extends R_AProjectile_TD;

simulated function Vector GetProjectileEffectBaseOffset()
{
    local Vector Result;
    
    Result.X = -12.0;
    
    return Result;
}

defaultproperties
{
    DrawType=DT_SkeletalMesh
    Skeletal=SkelModel'objects.Barrel'
    MaxSpeed=300.0
    Speed=300.0
    DrawScale=0.5
    ProjectileBehavior=PB_VelocityTowardsTarget
    //CollisionRadius=20.000000
    //CollisionHeight=20.000000
}