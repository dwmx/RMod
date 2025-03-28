//==============================================================================
// R_UIWidget
// Base class for all UI Widgets in the RMod User Interface package
//==============================================================================
class R_UIWidget extends Object;

// Libraries
const UILibrary = Class'R_AUILibrary';

// The owning PlayerPawn
var PlayerPawn OwningPlayer;

/**
*   InitializeWidget
*   Called immediately after the owning player has created this widget
*   OwningPlayer is valid by the time this function is called
*/
function InitializeWidget(PlayerPawn NewOwningPlayer)
{
    OwningPlayer = NewOwningPlayer;
    Log("Widget initialized", UILibrary.Static.LogCategory());
}

/**
*   DrawWidget
*   Main draw function for each widget
*/
function DrawWidget(Canvas C)
{
    C.Font = C.SmallFont;
    DrawTestString(C, -300.0);
    
    C.Font = C.MedFont;
    DrawTestString(C, -200.0);
    
    C.Font = C.BigFont;
    DrawTestString(C, -100.0);
    
    C.Font = C.LargeFont;
    DrawTestString(C, 0.0);
    
    C.Font = C.RuneMedFont;
    DrawTestString(C, 100.0);
    
    C.Font = C.CredsFont;
    DrawTestString(C, 200.0);
    
    C.Font = C.ButtonFont;
    DrawTestString(C, 300.0);
    
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