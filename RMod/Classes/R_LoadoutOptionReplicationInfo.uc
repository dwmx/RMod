//==============================================================================
//  R_LoadoutOptionReplicationInfo
//  Categorizes collections of loadout options so that clients can display
//  available loadout items per slot, and server can perform client validation.
//  Server can access via:
//      R_GameInfo.LoadoutOptionReplicationInfo
//  Client can access via:
//      R_RunePlayer.LoadoutReplicationInfo.LoadoutOptionReplicationInfo
//==============================================================================
class R_LoadoutOptionReplicationInfo extends ReplicationInfo;

var Class<R_AUtilities> UtilitiesClass;

struct FLoadoutOption
{
    var Class<Inventory> InventoryClass;
};

enum ELoadoutSlot
{
    LS_Primary,
    LS_Secondary,
    LS_Tertiary
};

const MAX_LOADOUT_OPTIONS = 16; // This must match the following array sizes.
var config FLoadoutOption LoadoutOptionsPrimary[16];
var config FLoadoutOption LoadoutOptionsSecondary[16];
var config FLoadoutOption LoadoutOptionsTertiary[16];

replication
{
    reliable if(Role == ROLE_Authority)
        LoadoutOptionsPrimary,
        LoadoutOptionsSecondary,
        LoadoutOptionsTertiary;
}

event BeginPlay()
{
    Super.BeginPlay();

    UtilitiesClass.Static.RModLog("LoadoutOptionsReplicationInfo spawned with class" @ Class);
}

/**
*   VerifyLoadoutSlotContainsInventoryClass
*   Verify that the specified inventory class is valid for the specified loadout
*   slot. This is used for server-side validation of client data.
*/
function bool VerifyLoadoutSlotContainsInventoryClass(ELoadoutSlot LoadoutSlot, Class<Inventory> InventoryClass)
{
    local int i;

    switch(LoadoutSlot)
    {
    case LS_Primary:
        for(i = 0; i < MAX_LOADOUT_OPTIONS; ++i)
        {
            if(LoadoutOptionsPrimary[i].InventoryClass == InventoryClass)
            {
                return true;
            }
        }
        break;
    case LS_Secondary:
        for(i = 0; i < MAX_LOADOUT_OPTIONS; ++i)
        {
            if(LoadoutOptionsSecondary[i].InventoryClass == InventoryClass)
            {
                return true;
            }
        }
        break;
    case LS_Tertiary:
        for(i = 0; i < MAX_LOADOUT_OPTIONS; ++i)
        {
            if(LoadoutOptionsTertiary[i].InventoryClass == InventoryClass)
            {
                return true;
            }
        }
        break;
    }

    return false;
}

defaultproperties
{
    UtilitiesClass=Class'RMod.R_AUtilities'
    LoadoutOptionsPrimary(0)=(InventoryClass=Class'RMod.R_Weapon_DwarfBattleAxe')
    LoadoutOptionsPrimary(1)=(InventoryClass=Class'RMod.R_Weapon_DwarfBattleHammer')
    LoadoutOptionsPrimary(2)=(InventoryClass=Class'RMod.R_Weapon_DwarfBattleSword')
    LoadoutOptionsPrimary(3)=(InventoryClass=Class'RMod.R_Weapon_DwarfWorkSword')
    LoadoutOptionsPrimary(4)=(InventoryClass=Class'RMod.R_Shield_DwarfWoodShield')
    LoadoutOptionsSecondary(0)=(InventoryClass=Class'RMod.R_Weapon_VikingBroadSword')
    LoadoutOptionsSecondary(1)=(InventoryClass=Class'RMod.R_Weapon_SigurdAxe')
    LoadoutOptionsSecondary(2)=(InventoryClass=Class'RMod.R_Weapon_TrialPitMace')
    LoadoutOptionsSecondary(3)=(InventoryClass=Class'RMod.R_Weapon_VikingAxe')
    LoadoutOptionsSecondary(4)=(InventoryClass=Class'RMod.R_Weapon_DwarfWorkHammer')
    LoadoutOptionsSecondary(5)=(InventoryClass=Class'RMod.R_Shield_DarkShield')
    LoadoutOptionsTertiary(0)=(InventoryClass=Class'RMod.R_Weapon_VikingShortSword')
    LoadoutOptionsTertiary(1)=(InventoryClass=Class'RMod.R_Weapon_BoneClub')
    LoadoutOptionsTertiary(2)=(InventoryClass=Class'RMod.R_Weapon_GoblinAxe')
    LoadoutOptionsTertiary(3)=(InventoryClass=Class'RMod.R_Weapon_HandAxe')
    LoadoutOptionsTertiary(4)=(InventoryClass=Class'RMod.R_Weapon_RomanSword')
    LoadoutOptionsTertiary(5)=(InventoryClass=Class'RMod.R_Weapon_RustyMace')
}