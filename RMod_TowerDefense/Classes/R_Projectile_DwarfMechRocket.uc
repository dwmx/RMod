class R_Projectile_DwarfMechRocket extends R_AProjectile_TD;

defaultproperties
{
    DrawType=DT_SkeletalMesh
    Skeletal=SkelModel'objects.Barrel'
    MaxSpeed=100.0
    Speed=100.0
    ProjectileBehavior=PB_VelocityTowardsTarget
    //CollisionRadius=20.000000
    //CollisionHeight=20.000000
}