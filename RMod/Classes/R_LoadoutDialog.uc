class R_LoadoutDialog extends UWindowDialogClientWindow;

var Class<R_AUtilities> UtilitiesClass;
var R_LoadoutListBox LoadoutListBoxPrimary;
var R_LoadoutListBox LoadoutListBoxSecondary;
var R_LoadoutListBox LoadoutListBoxTertiary;

function R_LoadoutReplicationInfo GetLoadoutReplicationInfo()
{
    local R_RunePlayer RRP;

    RRP = R_RunePlayer(GetPlayerOwner());
    if(RRP != None)
    {
        return RRP.LoadoutReplicationInfo;
    }

    return None;
}

function R_LoadoutOptionReplicationInfo GetLoadoutOptionReplicationInfo()
{
    local R_RunePlayer RRP;
    local R_LoadoutReplicationInfo LRI;

    RRP = R_RunePlayer(GetPlayerOwner());
    if(RRP != None)
    {
        LRI = RRP.LoadoutReplicationInfo;
        if(LRI != None)
        {
            return LRI.LoadoutOptionReplicationInfo;
        }
    }

    return None;
}

event Created()
{
    Super.Created();

    CreatePrimaryInventoryListBox();
    CreateSecondaryInventoryListBox();
    CreateTertiaryInventoryListBox();
}

function CreatePrimaryInventoryListBox()
{
    local R_LoadoutReplicationInfo LRI;
    local R_LoadoutOptionReplicationInfo LORI;
    local Class<Inventory> LoadoutSlotInventoryArray[16];
    local int i;

    LRI = GetLoadoutReplicationInfo();
    LORI = GetLoadoutOptionReplicationInfo();

    if(LORI != None)
    {
        for(i = 0; i < 16; ++i)
        {
            LoadoutSlotInventoryArray[i] = LORI.LoadoutOptionsPrimary[i].InventoryClass;
        }
    }
    
    LoadoutListBoxPrimary = CreateLoadoutListBoxFromInventoryArray(LoadoutSlotInventoryArray, 0, 0);

    if(LRI != None)
    {
        LoadoutListBoxPrimary.SetSelectedLoadoutItemByClass(LRI.PrimaryInventoryClass);
    }
}

function CreateSecondaryInventoryListBox()
{
    local R_LoadoutReplicationInfo LRI;
    local R_LoadoutOptionReplicationInfo LORI;
    local Class<Inventory> LoadoutSlotInventoryArray[16];
    local int i;

    LRI = GetLoadoutReplicationInfo();
    LORI = GetLoadoutOptionReplicationInfo();

    if(LORI != None)
    {
        for(i = 0; i < 16; ++i)
        {
            LoadoutSlotInventoryArray[i] = LORI.LoadoutOptionsSecondary[i].InventoryClass;
        }
    }
    
    LoadoutListBoxSecondary = CreateLoadoutListBoxFromInventoryArray(LoadoutSlotInventoryArray, 136, 0);

    if(LRI != None)
    {
        LoadoutListBoxSecondary.SetSelectedLoadoutItemByClass(LRI.SecondaryInventoryClass);
    }
}

function CreateTertiaryInventoryListBox()
{
    local R_LoadoutReplicationInfo LRI;
    local R_LoadoutOptionReplicationInfo LORI;
    local Class<Inventory> LoadoutSlotInventoryArray[16];
    local int i;

    LRI = GetLoadoutReplicationInfo();
    LORI = GetLoadoutOptionReplicationInfo();

    if(LORI != None)
    {
        for(i = 0; i < 16; ++i)
        {
            LoadoutSlotInventoryArray[i] = LORI.LoadoutOptionsTertiary[i].InventoryClass;
        }
    }
    
    LoadoutListBoxTertiary = CreateLoadoutListBoxFromInventoryArray(LoadoutSlotInventoryArray, 272, 0);

    if(LRI != None)
    {
        LoadoutListBoxTertiary.SetSelectedLoadoutItemByClass(LRI.TertiaryInventoryClass);
    }
}

function R_LoadoutListBox CreateLoadoutListBoxFromInventoryArray(
    Class<Inventory> InventoryArray[16],
    int LocationX, int LocationY)
{
    local R_LoadoutListBox Result;
    local int i;
    local R_LoadoutListBoxItem LoadoutItem;
    local Class<Inventory> InventoryOption;

    Result = R_LoadoutListBox(CreateControl(Class'RMod.R_LoadoutListBox', LocationX, LocationY, 128, 64));
    Result.bAcceptsFocus = false;
    Result.Items.Clear();

    for(i = 0; i < 16; ++i)
    {
        InventoryOption = InventoryArray[i];

        if(InventoryOption != None)
        {
            LoadoutItem = R_LoadoutListBoxItem(Result.Items.Append(Class'RMod.R_LoadoutListBoxItem'));
            LoadoutItem.LoadoutInventoryClass = InventoryArray[i];
            if(UtilitiesClass != None)
            {
                LoadoutItem.LoadoutDisplayNameString = UtilitiesClass.Static.GetMenuNameForInventoryClass(InventoryOption);
            }
            else
            {
                LoadoutItem.LoadoutDisplayNameString = String(InventoryOption);
            }
        }
    }

    return Result;
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

event WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key)
{
    Super.WindowEvent(Msg, C, X, Y, Key);
    if(Msg == WM_KeyDown && Key == 121)
    {
        Close();
    }
}

event Close(optional bool bByParent)
{
    Root.Console.bQuickKeyEnable = false;
    Root.Console.CloseUWindow();
    Super.Close(bByParent);
}

defaultproperties
{
    UtilitiesClass=Class'RMod.R_AUtilities'
}