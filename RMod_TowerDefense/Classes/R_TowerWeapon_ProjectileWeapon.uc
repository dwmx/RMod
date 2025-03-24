//==============================================================================
// R_TowerWeapon_ProjectileWeapon
// Tower component class for tower weapons which are capable of firing
// projectiles at targets
//==============================================================================
class R_TowerWeapon_ProjectileWeapon extends R_ATowerWeapon;

// Projectile class to spawn each time this weapon is fired
//var Class<R_AProjectile> ProjectileClass;
var Class<R_AProjectile> ProjectileClass;

/**
*   ExecuteWeaponFire (override)
*   Overridden to fire a projectile at the target
*/
function ExecuteWeaponFire()
{
    local Vector DeltaVector;
    local Rotator ProjectileRotation;
    local Actor LocalWeaponTarget;
    local R_AProjectile SpawnedProjectile;
    
    if(ProjectileClass == None)
    {
        UtilitiesClass.Static.RModWarn("Attempted to fire projectile weapon but ProjectileClass has not been configured");
        return;
    }
    
    LocalWeaponTarget = GetWeaponTarget();
    if(LocalWeaponTarget != None && OwningTower != None)
    {
        DeltaVector = LocalWeaponTarget.Location - OwningTower.Location;
        ProjectileRotation = Rotator(DeltaVector);
        SpawnedProjectile = OwningTower.Spawn(ProjectileClass, OwningTower, /*Spawn Tag*/, OwningTower.Location, ProjectileRotation);
        if(SpawnedProjectile != None)
        {
            SpawnedProjectile.SetProjectileTarget(LocalWeaponTarget);
            //SpawnedProjectile.Velocity = Normal(DeltaVector) * 1000.0;
        }
    }
}