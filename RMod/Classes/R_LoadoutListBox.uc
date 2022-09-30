class R_LoadoutListBox extends UWindowListBox;

var bool bUpdatePending;

/**
*   Paint (override)
*   Draw this loadout list box. Note that it's important to draw background
*   items before calling Super.Paint, because the Super call will also draw all
*   child elements.
*/
event Paint(Canvas C, float MouseX, float MouseY)
{
    C.DrawColor.R = 255;
    C.DrawColor.G = 255;
    C.DrawColor.B = 255;
    DrawStretchedTexture(C,0.00,0.00,WinWidth,WinHeight,Texture'WhiteTexture');

    Super.Paint(C, MouseX, MouseY);
}

function SetSelectedLoadoutItemByClass(Class<Inventory> LoadoutInventoryClass)
{
    local R_LoadoutListBoxItem LoadoutItem;

    LoadoutItem = R_LoadoutListBoxItem(Items);
    while(LoadoutItem != None)
    {
        if(LoadoutItem.LoadoutInventoryClass == LoadoutInventoryClass)
        {
            SetSelectedItem(LoadoutItem);
        }

        LoadoutItem = R_LoadoutListBoxItem(LoadoutItem.Next);
    }
}

event DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
    local R_LoadoutListBoxItem LoadoutItem;
    local String LoadoutDisplayNameString;

    LoadoutItem = R_LoadoutListBoxItem(Item);
    if(LoadoutItem != None)
    {
        if(LoadoutItem.bSelected)
        {
            C.DrawColor.R = 0;
            C.DrawColor.G = 0;
            C.DrawColor.B = 128;
            DrawStretchedTexture(C, X, Y, W, H-1, Texture'WhiteTexture');
            C.DrawColor.R = 255;
            C.DrawColor.G = 255;
            C.DrawColor.B = 255;
        }
        else
        {
            C.DrawColor.R = 0;
            C.DrawColor.G = 0;
            C.DrawColor.B = 0;
        }
        C.Font = Root.Fonts[F_Normal];
        
        //C.Font = Root.Fonts[0];

        LoadoutDisplayNameString = LoadoutItem.LoadoutDisplayNameString;
        ClipText(C, X+2, Y, LoadoutDisplayNameString);
    }
}

event LMouseDown(float MouseX, float MouseY)
{
    local R_LoadoutListBoxItem LoadoutItem;

    Super.LMouseDown(MouseX, MouseY);
    LoadoutItem = R_LoadoutListBoxItem(GetItemAt(MouseX, MouseY));
    if(LoadoutItem != None)
    {
        SetSelectedItem(LoadoutItem);
        bUpdatePending = true;
        //UpdateOwnerLoadout();
    }
}

defaultproperties
{
    ItemHeight=13.0
    ListClass=Class'RMod.R_LoadoutListBoxItem'
    bUpdatePending=False
}