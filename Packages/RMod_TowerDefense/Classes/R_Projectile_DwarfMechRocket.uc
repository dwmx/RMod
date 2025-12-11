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
    MaxSpeed=500.0
    Speed=500.0
    DrawScale=0.5
    ProjectileBehavior=PB_VelocityTowardsTarget
}