//==============================================================================
// R_Tower_DwarfMech
// Dwarf Mech Tower
//==============================================================================
class R_Tower_DwarfMech extends R_ATower;

// This is a test of using a weapon as a component
var R_ATowerWeapon PrimaryWeapon;

// The current target of this tower
var Actor TargetActor;

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
        //ProjectileWeapon.ProjectileClass = Class'R_Projectile_DwarfMechRocket';
        ProjectileWeapon.ProjectileClass = Class'RuneI.MechRocket';
        PrimaryWeapon = ProjectileWeapon;
    }
}

/**
*   CE_TargetChanged (override)
*   Overridden to cause this tower to lock-on to the target
*/
function CE_TargetChanged(R_ATowerComponent CallerComponent, Actor NewTarget)
{
    TargetActor = NewTarget;
}

/**
*   Tick (override)
*   Overridden to test target lock-on
*/
event Tick(float DeltaSeconds)
{
    local Vector DeltaVector;
    local Rotator NewRotation;
    
    Super.Tick(DeltaSeconds);
    
    if(TargetActor != None)
    {
        DeltaVector = TargetActor.Location - Location;
        DeltaVector.Z = 0.0;
        NewRotation = Rotator(DeltaVector);
        SetRotation(NewRotation);
    }
    else
    {
        NewRotation.Yaw = 0;
        NewRotation.Pitch = 0;
        NewRotation.Roll = 0;
        SetRotation(NewRotation);
    }
}

defaultproperties
{
    Skeletal=SkelModel'creatures.MechaDwarf'
}