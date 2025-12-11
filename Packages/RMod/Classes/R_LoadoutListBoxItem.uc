class R_LoadoutListBoxItem extends UWindowListBoxItem;

var Class<Inventory> LoadoutInventoryClass;
var String LoadoutDisplayNameString;

event int Compare(UWindowList A, UWindowList B)
{
    local R_LoadoutListBoxItem LA, LB;

    LA = R_LoadoutListBoxItem(A);
    LB = R_LoadoutListBoxItem(B);

    // Null checks
    if(LA == None && LB == None)
    {
        return -1;
    }
    else if(LA == None && LB != None)
    {
        return -1;
    }
    else if(LA != None && LB == None)
    {
        return 1;
    }

    // Return in alphabetical order
    if(Caps(LA.LoadoutDisplayNameString) < Caps(LB.LoadoutDisplayNameString))
    {
        return -1;
    }
    else
    {
        return 1;
    }
}

defaultproperties
{
    bSelected=False
    LoadoutInventoryClass=None
    LoadoutDisplayNameString="None"
}