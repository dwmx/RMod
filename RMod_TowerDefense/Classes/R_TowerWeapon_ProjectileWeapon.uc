//==============================================================================
// R_TowerWeapon_ProjectileWeapon
// Tower component class for tower weapons which are capable of firing
// projectiles at targets
//==============================================================================
class R_TowerWeapon_ProjectileWeapon extends R_ATowerWeapon;

// Projectile class to spawn each time this weapon is fired
var Class<R_AProjectile> ProjectileClass;

function TickComponent(float DeltaSeconds)
{
}