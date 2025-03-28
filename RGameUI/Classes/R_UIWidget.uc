//==============================================================================
// R_UIWidget
// Base class for all UI Widgets in the RMod User Interface package
//==============================================================================
class R_UIWidget extends Object;

// Libraries
const CanvasLibrary = Class'RBase.R_ACanvasLibrary';
const UILibrary = Class'RGameUI.R_AUILibrary';

// The owning PlayerPawn
var PlayerPawn OwningPlayer;

// Anchor testing

/**
*   InitializeWidget
*   Called immediately after the owning player has created this widget
*   OwningPlayer is valid by the time this function is called
*/
final function bool InitializeWidget(PlayerPawn NewOwningPlayer)
{
    if(NewOwningPlayer == None)
    {
        Warn(Class @ "InitializeWidget failed, NewOwningPlayer = None");
        return false;
    }
    
    OwningPlayer = NewOwningPlayer;
    Log("Widget initialized for class" @ Class, UILibrary.Static.LogCategory());
    Log("Building widget" @ Self, UILibrary.Static.LogCategory());
    BuildWidget();
    
    return true;
}

/**
*   BuildWidget
*   This function should construct your widget
*/
function BuildWidget()
{
    Log("Building widget" @ Class, UILibrary.Static.LogCategory());
}

/**
*   DrawWidget
*   Main draw function for each widget
*/
function DrawWidget(Canvas C)
{
    local Vector BoxExtent1, BoxExtent2;
    
    BoxExtent1.X = C.ClipX * 0.25;
    BoxExtent2.X = C.ClipX * 0.75;
    
    BoxExtent1.Y = C.ClipY * 0.25;
    BoxExtent2.Y = C.ClipY * 0.75;
    
    CanvasLibrary.Static.DrawBoxSolid(C, BoxExtent1, BoxExtent2, 1.0, 1.0, 0.0, 1.0);
    
    //C.Font = C.SmallFont;
    //DrawTestString(C, -300.0);
    //
    //C.Font = C.MedFont;
    //DrawTestString(C, -200.0);
    //
    //C.Font = C.BigFont;
    //DrawTestString(C, -100.0);
    //
    //C.Font = C.LargeFont;
    //DrawTestString(C, 0.0);
    //
    //C.Font = C.RuneMedFont;
    //DrawTestString(C, 100.0);
    //
    //C.Font = C.CredsFont;
    //DrawTestString(C, 200.0);
    //
    //C.Font = C.ButtonFont;
    //DrawTestString(C, 300.0);
    
}

function DrawTestString(Canvas C, float YOffset)
{
    local float DrawX, DrawY;
    local float StrW, StrH;
    local String DrawString;
    
    DrawString = "My User Interface Is Working!!!!";
    C.SetColor(255.0, 255.0, 255.0);
    C.Style = 1;
    
    //C.Font = C.BigFont;
    C.StrLen(DrawString, StrW, StrH);
    DrawX = C.ClipX * 0.5 - StrW * 0.5;
    DrawY = C.ClipY * 0.5 - StrH * 0.5 + YOffset;
    C.SetPos(DrawX, DrawY);
    C.DrawText(DrawString);
}

function DrawTestBox(Canvas C)
{
    
}