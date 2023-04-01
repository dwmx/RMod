//==============================================================================
//  R_GameOptions
//  Implements RMod-specific configurable game options.
//==============================================================================
class R_GameOptions extends ReplicationInfo config(RMod);

var Class<R_AUtilities> UtilitiesClass;

//==============================================================================
//  Game Options
//  For ease of use throughout the code, whenever a new option is added here,
//  add a corresponding accessor function in R_AGameOptionsChecker.
//==============================================================================
var config bool bOptionShieldHitStun;                   // Players enter pain state when their shield is struck
var config bool bOptionShieldDamageBoostsStrength;      // Striking shield grants strength to attacker
var config bool bOptionManualBloodlust;                 // Allow players to manually activate bloodlust
var config bool bOptionWeaponThrowBlockTier1;           // Tier 1 weapons are throw-blockable
var config bool bOptionWeaponThrowBlockTier2;           // Tier 2 weapons are throw-blockable
var config bool bOptionWeaponThrowBlockTier3;           // Tier 3 weapons are throw-blockable
var config bool bOptionWeaponThrowBlockTier4;           // Tier 4 weapons are throw-blockable
var config bool bOptionWeaponThrowBlockTier5;           // Tier 5 weapons are throw-blockable

replication
{
    reliable if(Role == ROLE_Authority)
        bOptionShieldHitStun,
        bOptionShieldDamageBoostsStrength,
        bOptionManualBloodlust,
        bOptionWeaponThrowBlockTier1,
        bOptionWeaponThrowBlockTier2,
        bOptionWeaponThrowBlockTier3,
        bOptionWeaponThrowBlockTier4,
        bOptionWeaponThrowBlockTier5;
}

/**
*   PostBeginPlay (override)
*   Overridden to log the class of game options spawned for the current gameinfo.
*/
event BeginPlay()
{
    local String LogString;

    Super.BeginPlay();

    if(Role == ROLE_Authority)
    {
        LogString = "GameOptions spawned with class:" @ Self.Class;
        if(UtilitiesClass != None)
        {
            UtilitiesClass.Static.RModLog(LogString);
        }
        else
        {
            Log(LogString);
        }

        LogAllGameOptions();
        
        SaveConfig();
    }
}

/**
*   LogAllGameOptions
*   Perform all desired logging of game options here
*/
function LogAllGameOptions()
{
    LogGameOption("ShieldHitStun", String(bOptionShieldHitStun));
    LogGameOption("ShieldDamageBoostsStrength", String(bOptionShieldDamageBoostsStrength));
    LogGameOption("ManualBloodlust", String(bOptionManualBloodlust));
    LogGameOption("WeaponThrowBlockTier1", String(bOptionWeaponThrowBlockTier1));
    LogGameOption("WeaponThrowBlockTier2", String(bOptionWeaponThrowBlockTier2));
    LogGameOption("WeaponThrowBlockTier3", String(bOptionWeaponThrowBlockTier3));
    LogGameOption("WeaponThrowBlockTier4", String(bOptionWeaponThrowBlockTier4));
    LogGameOption("WeaponThrowBlockTier5", String(bOptionWeaponThrowBlockTier5));
}

function LogGameOption(String GameOptionNameString, String GameOptionValueString)
{
    local String LogString;

    LogString = "Game Option '" $ GameOptionNameString $ "':" @ GameOptionValueString;
    if(UtilitiesClass != None)
    {
        UtilitiesClass.Static.RModLog(LogString);
    }
    else
    {
        Log(LogString);
    }
}

defaultproperties
{
    UtilitiesClass=Class'RMod.R_AUtilities_GameOptions'
    bOptionShieldHitStun=True
    bOptionShieldDamageBoostsStrength=True
    bOptionManualBloodlust=True
    bOptionWeaponThrowBlockTier1=False
    bOptionWeaponThrowBlockTier2=False
    bOptionWeaponThrowBlockTier3=True
    bOptionWeaponThrowBlockTier4=True
    bOptionWeaponThrowBlockTier5=True
}