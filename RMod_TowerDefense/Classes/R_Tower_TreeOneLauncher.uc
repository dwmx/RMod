//==============================================================================
// R_Tower_TreeOneLauncher
// The mighty Tree1 Launcher tower
//==============================================================================
class R_Tower_TreeOneLauncher extends R_ATower;

/**
*   InitializeTowerComponent (override)
*/
function InitializeTowerComponents()
{
    local R_TowerWeapon_ProjectileWeapon ProjectileWeapon;
    
    Super.InitializeTowerComponents();
    
    ProjectileWeapon = R_TowerWeapon_ProjectileWeapon(CreateTowerComponent(Class'R_TowerWeapon_ProjectileWeapon'));
    if(ProjectileWeapon != None)
    {
        ProjectileWeapon.ProjectileClass = Class'R_Projectile_TreeOneRocket';
    }
}

defaultproperties
{
    Skeletal=SkelModel'plants.Tree'
    DrawScale=2.0
}