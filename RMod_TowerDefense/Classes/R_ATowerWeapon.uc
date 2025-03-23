//==============================================================================
// R_ATowerWeapon
// Abstract base class for tower's weapons
//==============================================================================
class R_ATowerWeapon extends R_ATowerComponent abstract;

// Current target for this weapon
var private Actor WeaponTarget;

// Current attack range for this weapon
var private float AttackRange;

/**
*   SetWeaponTarget
*   Updates the current WeaponTarget Actor and calls the associated event
*   function on owning Tower if changed
*/
function SetWeaponTarget(Actor NewWeaponTarget)
{
    if(WeaponTarget == NewWeaponTarget)
    {
        return;
    }
    WeaponTarget = NewWeaponTarget;
    
    if(OwningTower != None)
    {
        OwningTower.CE_TargetChanged(Self, WeaponTarget);
    }
}

/**
*   UpdateWeaponTarget
*   Finds the best available target for this weapon and updates WeaponTarget
*   if necessary
*/
function UpdateWeaponTarget()
{}

defaultproperties
{
    AttackRange=512.0
}