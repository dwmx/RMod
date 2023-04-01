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
var config bool bOptionShieldHitStun;
var config bool bOptionShieldDamageBoostsStrength;
var config bool bOptionManualBloodlust;

replication
{
    reliable if(Role == ROLE_Authority)
        bOptionShieldHitStun,
        bOptionShieldDamageBoostsStrength,
        bOptionManualBloodlust;
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
}