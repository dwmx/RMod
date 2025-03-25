//==============================================================================
// R_Projectile_TreeOneRocket
// The terrifyingly destructive Tree One Rocket
//==============================================================================
class R_Projectile_TreeOneRocket extends R_AProjectile_TD;

defaultproperties
{
    DrawType=DT_SkeletalMesh
    Skeletal=SkelModel'plants.Tree'
    DrawScale=0.5
    MaxSpeed=500.0
    Speed=500.0
    ProjectileBehavior=PB_FireAndForget
    ProjectileOrientationAxis=PA_AxisZ
}