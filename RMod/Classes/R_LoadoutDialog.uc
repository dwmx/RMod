class R_LoadoutDialog extends UWindowDialogClientWindow;

var R_LoadoutListBox LoadoutListBoxPrimary;
var R_LoadoutListBox LoadoutListBoxSecondary;
var R_LoadoutListBox LoadoutListBoxTertiary;

event Created()
{
    Super.Created();
    CreatePrimaryInventoryListBox();
    CreateSecondaryInventoryListBox();
    CreateTertiaryInventoryListBox();
}

function CreatePrimaryInventoryListBox()
{
    local R_LoadoutListBoxItem LoadoutItem;

    // Create Primary inventory list box
    LoadoutListBoxPrimary = R_LoadoutListBox(CreateControl(Class'RMod.R_LoadoutListBox', 0, 0, 128, 64));
    LoadoutListBoxPrimary.bAcceptsFocus = false;
    LoadoutListBoxPrimary.Items.Clear();

    LoadoutItem = R_LoadoutListBoxItem(LoadoutListBoxPrimary.Items.Append(Class'RMod.R_LoadoutListBoxItem'));
    LoadoutItem.LoadoutInventoryClass = Class'RMod.R_Weapon_DwarfBattleAxe';
    LoadoutItem.LoadoutDisplayNameString = "Battle Axe";

    LoadoutItem = R_LoadoutListBoxItem(LoadoutListBoxPrimary.Items.Append(Class'RMod.R_LoadoutListBoxItem'));
    LoadoutItem.LoadoutInventoryClass = Class'RMod.R_Weapon_DwarfBattleHammer';
    LoadoutItem.LoadoutDisplayNameString = "Battle Hammer";

    LoadoutItem = R_LoadoutListBoxItem(LoadoutListBoxPrimary.Items.Append(Class'RMod.R_LoadoutListBoxItem'));
    LoadoutItem.LoadoutInventoryClass = Class'RMod.R_Weapon_DwarfBattleSword';
    LoadoutItem.LoadoutDisplayNameString = "Battle Sword";

    LoadoutItem = R_LoadoutListBoxItem(LoadoutListBoxPrimary.Items.Append(Class'RMod.R_LoadoutListBoxItem'));
    LoadoutItem.LoadoutInventoryClass = Class'RMod.R_Weapon_DwarfWorkSword';
    LoadoutItem.LoadoutDisplayNameString = "Work Sword";

    LoadoutItem = R_LoadoutListBoxItem(LoadoutListBoxPrimary.Items.Append(Class'RMod.R_LoadoutListBoxItem'));
    LoadoutItem.LoadoutInventoryClass = Class'RMod.R_Shield_DwarfWoodShield';
    LoadoutItem.LoadoutDisplayNameString = "Work Shield";
}

function CreateSecondaryInventoryListBox()
{
    local R_LoadoutListBoxItem LoadoutItem;

    // Create Primary inventory list box
    LoadoutListBoxSecondary = R_LoadoutListBox(CreateControl(Class'RMod.R_LoadoutListBox', 128, 0, 128, 64));
    LoadoutListBoxSecondary.bAcceptsFocus = false;
    LoadoutListBoxSecondary.Items.Clear();

    LoadoutItem = R_LoadoutListBoxItem(LoadoutListBoxSecondary.Items.Append(Class'RMod.R_LoadoutListBoxItem'));
    LoadoutItem.LoadoutInventoryClass = Class'RMod.R_Weapon_VikingBroadSword';
    LoadoutItem.LoadoutDisplayNameString = "Broad Sword";

    LoadoutItem = R_LoadoutListBoxItem(LoadoutListBoxSecondary.Items.Append(Class'RMod.R_LoadoutListBoxItem'));
    LoadoutItem.LoadoutInventoryClass = Class'RMod.R_Weapon_SigurdAxe';
    LoadoutItem.LoadoutDisplayNameString = "Sigurd Axe";

    LoadoutItem = R_LoadoutListBoxItem(LoadoutListBoxSecondary.Items.Append(Class'RMod.R_LoadoutListBoxItem'));
    LoadoutItem.LoadoutInventoryClass = Class'RMod.R_Weapon_TrialPitMace';
    LoadoutItem.LoadoutDisplayNameString = "Pit Mace";

    LoadoutItem = R_LoadoutListBoxItem(LoadoutListBoxSecondary.Items.Append(Class'RMod.R_LoadoutListBoxItem'));
    LoadoutItem.LoadoutInventoryClass = Class'RMod.R_Weapon_VikingAxe';
    LoadoutItem.LoadoutDisplayNameString = "Viking Axe";

    LoadoutItem = R_LoadoutListBoxItem(LoadoutListBoxSecondary.Items.Append(Class'RMod.R_LoadoutListBoxItem'));
    LoadoutItem.LoadoutInventoryClass = Class'RMod.R_Weapon_DwarfWorkHammer';
    LoadoutItem.LoadoutDisplayNameString = "Work Hammer";
}

function CreateTertiaryInventoryListBox()
{
    local R_LoadoutListBoxItem LoadoutItem;

    // Create Primary inventory list box
    LoadoutListBoxTertiary = R_LoadoutListBox(CreateControl(Class'RMod.R_LoadoutListBox', 256, 0, 128, 64));
    LoadoutListBoxTertiary.bAcceptsFocus = false;
    LoadoutListBoxTertiary.Items.Clear();

    LoadoutItem = R_LoadoutListBoxItem(LoadoutListBoxTertiary.Items.Append(Class'RMod.R_LoadoutListBoxItem'));
    LoadoutItem.LoadoutInventoryClass = Class'RMod.R_Weapon_VikingShortSword';
    LoadoutItem.LoadoutDisplayNameString = "Short Sword";

    LoadoutItem = R_LoadoutListBoxItem(LoadoutListBoxTertiary.Items.Append(Class'RMod.R_LoadoutListBoxItem'));
    LoadoutItem.LoadoutInventoryClass = Class'RMod.R_Weapon_RomanSword';
    LoadoutItem.LoadoutDisplayNameString = "Roman Sword";

    LoadoutItem = R_LoadoutListBoxItem(LoadoutListBoxTertiary.Items.Append(Class'RMod.R_LoadoutListBoxItem'));
    LoadoutItem.LoadoutInventoryClass = Class'RMod.R_Weapon_BoneClub';
    LoadoutItem.LoadoutDisplayNameString = "Bone Club";

    LoadoutItem = R_LoadoutListBoxItem(LoadoutListBoxTertiary.Items.Append(Class'RMod.R_LoadoutListBoxItem'));
    LoadoutItem.LoadoutInventoryClass = Class'RMod.R_Weapon_GoblinAxe';
    LoadoutItem.LoadoutDisplayNameString = "Goblin Axe";

    LoadoutItem = R_LoadoutListBoxItem(LoadoutListBoxTertiary.Items.Append(Class'RMod.R_LoadoutListBoxItem'));
    LoadoutItem.LoadoutInventoryClass = Class'RMod.R_Weapon_HandAxe';
    LoadoutItem.LoadoutDisplayNameString = "Hand Axe";
}

event Tick(float DeltaSeconds)
{
    Super.Tick(DeltaSeconds);

    UpdateLoadout();
}

function UpdateLoadout()
{
    local R_RunePlayer RP;
    local R_LoadoutReplicationInfo LRI;
    local R_LoadoutListBoxItem LoadoutItem;
    local Class<Inventory> PrimaryInventoryClass;
    local Class<Inventory> SecondaryInventoryClass;
    local Class<Inventory> TertiaryInventoryClass;
    local bool bUpdateRequired;

    bUpdateRequired = false;
    PrimaryInventoryClass = None;
    SecondaryInventoryClass = None;
    TertiaryInventoryClass = None;

    if(LoadoutListBoxPrimary != None)
    {
        LoadoutItem = R_LoadoutListBoxItem(LoadoutListBoxPrimary.SelectedItem);
        if(LoadoutItem != None)
        {
            PrimaryInventoryClass = LoadoutItem.LoadoutInventoryClass;
        }

        if(LoadoutListBoxPrimary.bUpdatePending)
        {
            bUpdateRequired = true;
            LoadoutListBoxPrimary.bUpdatePending = false;
        }
    }

    if(LoadoutListBoxSecondary != None)
    {
        LoadoutItem = R_LoadoutListBoxItem(LoadoutListBoxSecondary.SelectedItem);
        if(LoadoutItem != None)
        {
            SecondaryInventoryClass = LoadoutItem.LoadoutInventoryClass;
        }

        if(LoadoutListBoxSecondary.bUpdatePending)
        {
            bUpdateRequired = true;
            LoadoutListBoxSecondary.bUpdatePending = false;
        }
    }

    if(LoadoutListBoxTertiary != None)
    {
        LoadoutItem = R_LoadoutListBoxItem(LoadoutListBoxTertiary.SelectedItem);
        if(LoadoutItem != None)
        {
            TertiaryInventoryClass = LoadoutItem.LoadoutInventoryClass;
        }

        if(LoadoutListBoxTertiary.bUpdatePending)
        {
            bUpdateRequired = true;
            LoadoutListBoxTertiary.bUpdatePending = false;
        }
    }

    // Update if loadout has changed
    if(bUpdateRequired)
    {
        RP = R_RunePlayer(GetPlayerOwner());
        if(RP != None)
        {
            LRI = RP.LoadoutReplicationInfo;
            if(LRI == None) Log("No LRI");
            LRI.ServerUpdateLoadout(PrimaryInventoryClass, SecondaryInventoryClass, TertiaryInventoryClass);
        }
    }
}