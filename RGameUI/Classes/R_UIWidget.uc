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
var Vector AnchorMin;
var Vector AnchorMax;

// Test child widget
var R_UIWidget ChildWidget;

var float ColorR, ColorG, ColorB, ColorA;

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
    local Vector SavedOrigin;
    local Vector SavedClip;
    local Vector Extent1, Extent2;
    local float OrgX, OrgY;
    local float Width, Height;

    // Push canvas state
    SavedOrigin.X = C.OrgX;
    SavedOrigin.Y = C.OrgY;
    SavedClip.X = C.ClipX;
    SavedClip.Y = C.ClipY;
    
    // Calc draw space
    CanvasLibrary.Static.ConstrainExtentsInPlace(C, AnchorMin, AnchorMax);
    Extent1.X = C.ClipX * AnchorMin.X;
    Extent1.Y = C.ClipY * AnchorMin.Y;
    Extent2.X = C.ClipX * AnchorMax.X;
    Extent2.Y = C.ClipY * AnchorMax.Y;
    
    OrgX = C.OrgX + C.ClipX * AnchorMin.X;
    OrgY = C.OrgY + C.ClipY * AnchorMin.Y;
    Width = Extent2.X - Extent1.X;
    Height = Extent2.Y - Extent1.Y;
    
    // Draw Self and children
    C.SetOrigin(OrgX, OrgY);
    C.SetClip(Width, Height);
    
    DrawSelfAsBox(C);
    
    if(ChildWidget != None)
    {
        ChildWidget.DrawWidget(C);
    }
    
    // Restore canvas state
    C.SetClip(SavedClip.X, SavedClip.Y);
    C.SetOrigin(SavedOrigin.X, SavedOrigin.Y);
    
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

function DrawSelfAsBox(Canvas C)
{
    local Vector Extent1, Extent2;
    
    Extent1.X = 0.0;
    Extent1.Y = 0.0;
    Extent2.X = 1.0 * C.ClipX;
    Extent2.Y = 1.0 * C.ClipY;
    
    CanvasLibrary.Static.DrawBoxOutline(C, Extent1, Extent2, 4.0, ColorR, ColorG, ColorB, ColorA);
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

defaultproperties
{
    AnchorMin=(X=0.25,Y=0.25)
    AnchorMax=(X=0.75,Y=0.75})
    ColorR=1.0
    ColorG=1.0
    ColorB=0.0
    ColorA=0.5
}