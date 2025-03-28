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
    local R_Mob MobActor;
    local Vector DeltaVector;
    local float CurrentDistance;
    local float BestDistance;
    local Actor BestTarget;
    
    if(OwningTower != None)
    {
        // Find the Mob actor nearest to this tower
        // This may be an inefficient way of doing this, especially if this function is being called rapidly
        // Consider some caching system in GameInfo to hold a list of mobs that this can quickly iterate
        BestDistance = AttackRange + 256.0; // Initialize to some value outside of the attack range
        BestTarget = None;
        
        foreach OwningTower.RadiusActors(Class'R_Mob', MobActor, AttackRange)
        {
            DeltaVector = MobActor.Location - OwningTower.Location;
            CurrentDistance = VSize(DeltaVector);
            
            if(CurrentDistance <= AttackRange)
            {
                if(CurrentDistance < BestDistance)
                {
                    BestDistance = CurrentDistance;
                    BestTarget = MobActor;
                }
            }
        }
        
        SetWeaponTarget(BestTarget);
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