//==============================================================================
// R_ATowerWeapon
// Abstract base class for tower's weapons
//==============================================================================
class R_ATowerWeapon extends R_ATowerComponent abstract;

// Current target for this weapon
var private Actor WeaponTarget;

// Current attack range for this weapon
var private float AttackRange;

var float CoolDownDurationSeconds; // The duration in seconds between weapon firings
var float LastFiredTimeStampSeconds; // Time stamp of the last weapon fire

/**
*   SetWeaponTarget / GetWeaponTarget
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

function Actor GetWeaponTarget()
{
    return WeaponTarget;
}

/**
*   UpdateWeaponTarget
*   Finds the best available target for this weapon and updates WeaponTarget
*   if necessary
*/
function UpdateWeaponTarget()
{
    // this is just a test, not final target selection code
    local Pawn P;
    local Vector DeltaVector;
    
    if(OwningTower != None)
    {
        // just grab the first pawn -- should be testing player
        P = OwningTower.Level.PawnList;
        if(P != None)
        {
            DeltaVector = P.Location - OwningTower.Location;
            if(VSize(DeltaVector) <= AttackRange)
            {
                SetWeaponTarget(P);
            }
            else
            {
                SetWeaponTarget(None);
            }
        }
    }
}

/**
*   TryFireWeaponAtTarget
*   Will attempt to fire the weapon at the current target, and apply cooldown
*   logic if successful
*/
function TryFireWeaponAtTarget()
{
    local float CurrentTimeStampSeconds;
    
    if(OwningTower != None)
    {
        CurrentTimeStampSeconds = OwningTower.Level.TimeSeconds;
        if(CurrentTimeStampSeconds - LastFiredTimeStampSeconds >= CoolDownDurationSeconds)
        {
            LastFiredTimeStampSeconds = CurrentTimeStampSeconds;
            ExecuteWeaponFire();
        }
    }
}

/**
*   ExecuteWeaponFire
*   Performs the actual weapon firing
*   No need to apply cool down in this function, that is handled in TryFireWeaponAtTarget
*/
function ExecuteWeaponFire()
{
    
}

/**
*   TickComponent (override)
*   This is overridden to test weapon target selection
*   Target selection should not be performed this way in the long run
*/
function TickComponent(float DeltaSeconds)
{
    UpdateWeaponTarget();
    TryFireWeaponAtTarget();
}

defaultproperties
{
    AttackRange=512.0
    CoolDownDurationSeconds=1.5
}