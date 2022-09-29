class R_LoadoutReplicationInfo extends ReplicationInfo;

var Class<Inventory> PrimaryInventoryClass;
var Class<Inventory> SecondaryInventoryClass;
var Class<Inventory> TertiaryInventoryClass;

replication
{
    reliable if(Role == ROLE_Authority)
        PrimaryInventoryClass,
        SecondaryInventoryClass,
        TertiaryInventoryClass;

    reliable if(Role < ROLE_Authority && bNetOwner)
        ServerUpdateLoadout;
}

function ServerUpdateLoadout(
    Class<Inventory> NewPrimaryInventoryClass,
    Class<Inventory> NewSecondaryInventoryClass,
    Class<Inventory> NewTertiaryInventoryClass)
{
    Log("Server updating loadout");
    // TODO:
    // It will be important to perform validity checking here
    PrimaryInventoryClass = NewPrimaryInventoryClass;
    SecondaryInventoryClass = NewSecondaryInventoryClass;
    TertiaryInventoryClass = NewTertiaryInventoryClass;
}

defaultproperties
{
    PrimaryInventoryClass=Class'RuneI.DwarfBattleSword'
}