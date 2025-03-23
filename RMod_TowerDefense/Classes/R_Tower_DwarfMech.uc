//==============================================================================
// R_Tower_DwarfMech
// Dwarf Mech Tower
//==============================================================================
class R_Tower_DwarfMech extends R_ATower;

// This is a test of using a weapon as a component
var R_ATowerWeapon PrimaryWeapon;

/**
*   InitializeTowerComponents (override)
*   Instantiate all components for dwarf mech tower
*/
function InitializeTowerComponents()
{
    local R_TowerWeapon_ProjectileWeapon ProjectileWeapon;
    
    Super.InitializeTowerComponents();
    
    // Setup primary weapon
    ProjectileWeapon = R_TowerWeapon_ProjectileWeapon(CreateTowerComponent(Class'R_TowerWeapon_ProjectileWeapon'));
    if(ProjectileWeapon == None)
    {
        UtilitiesClass.Static.RModWarn("R_Tower_DwarfMech failed to create primary weapon component");
    }
    else
    {
        ProjectileWeapon.ProjectileClass = Class'R_Projectile_DwarfMechRocket';
        PrimaryWeapon = ProjectileWeapon;
    }
}

defaultproperties
{
    Skeletal=SkelModel'creatures.MechaDwarf'
}