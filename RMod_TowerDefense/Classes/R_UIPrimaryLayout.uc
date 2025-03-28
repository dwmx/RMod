//==============================================================================
// R_UIPrimaryLayout
// Primary layout widget for Tower Defense game mode
// This is the RootWidgetClass for R_RunePlayer_TD, and is the main entry point
// for all Game UI Widgets in the Tower Defense game mode
//==============================================================================
class R_UIPrimaryLayout extends R_UIWidget;

function BuildWidget()
{
    Super.BuildWidget();
    
    UILibrary.Static.CreateWidget(Class'RGameUI.R_UIWidget', OwningPlayer);
}