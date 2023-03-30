class R_LoadoutReplicationInfo extends ReplicationInfo;

var Class<R_AUtilities> UtilitiesClass;
var R_LoadoutOptionReplicationInfo LoadoutOptionReplicationInfo;
var Class<Inventory> PrimaryInventoryClass;
var Class<Inventory> SecondaryInventoryClass;
var Class<Inventory> TertiaryInventoryClass;

replication
{
    reliable if(Role == ROLE_Authority)
        LoadoutOptionReplicationInfo,
        PrimaryInventoryClass,
        SecondaryInventoryClass,
        TertiaryInventoryClass;

    reliable if(Role < ROLE_Authority && bNetOwner)
        ServerUpdateLoadout;
}

event BeginPlay()
{
    local R_GameInfo RGI;

    Super.BeginPlay();

    if(Role == ROLE_Authority)
    {
        RGI = R_GameInfo(Level.Game);
        if(RGI != None)
        {
            LoadoutOptionReplicationInfo = RGI.LoadoutOptionReplicationInfo;
        }
    }
}

/**
*   Tick (override)
*   Overridden to destroy this LRI when it no longer has an owner.
*   This is a hack to avoid overriding the Destroyed event on R_RunePlayer,
*   which is causing client-side crashes.
*/
event Tick(float DeltaSeconds)
{
    if(Owner == None)
    {
        Destroy();
    }
}

function ServerUpdateLoadout(
    Class<Inventory> NewPrimaryInventoryClass,
    Class<Inventory> NewSecondaryInventoryClass,
    Class<Inventory> NewTertiaryInventoryClass)
{
    if(LoadoutOptionReplicationInfo != None)
    {
        if(LoadoutOptionReplicationInfo.VerifyLoadoutSlotContainsInventoryClass(LS_Primary, NewPrimaryInventoryClass)
        && LoadoutOptionReplicationInfo.VerifyLoadoutSlotContainsInventoryClass(LS_Secondary, NewSecondaryInventoryClass)
        && LoadoutOptionReplicationInfo.VerifyLoadoutSlotContainsInventoryClass(LS_Tertiary, NewTertiaryInventoryClass))
        {
            PrimaryInventoryClass = NewPrimaryInventoryClass;
            SecondaryInventoryClass = NewSecondaryInventoryClass;
            TertiaryInventoryClass = NewTertiaryInventoryClass;
        }
        else
        {
            UtilitiesClass.Static.RModWarn("Received invalid inventory loadout options from client" @ Owner);
        }
    }
}

defaultproperties
{
    UtilitiesClass=Class'RMod.R_AUtilities'
    PrimaryInventoryClass=Class'RuneI.Handaxe'
    SecondaryInventoryClass=Class'RuneI.RomanSword'
}