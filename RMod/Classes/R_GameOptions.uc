//==============================================================================
//  R_GameOptions
//  Implements RMod-specific configurable game options.
//==============================================================================
class R_GameOptions extends ReplicationInfo;

var Class<R_AUtilities> UtilitiesClass;

var config bool bOptionShieldHitStun;

replication
{
    reliable if(Role == ROLE_Authority)
        bOptionShieldHitStun;
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

        LogGameOption("ShieldHitStun", String(bOptionShieldHitStun));
    }
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
}