//==============================================================================
//  R_AUILibrary
//  Library class
//
//  Package wide functions for the GameUI RMod package
//==============================================================================
class R_AUILibrary extends R_ALibrary abstract;

static function Name LogCategory() { return 'RGameUI'; }

/**
*/
static function R_UIWidget CreateWidget(
    Class<R_UIWidget> WidgetClass,
    PlayerPawn OwningPlayer)
{
    local R_UIWidget Widget;
    
    if(WidgetClass == None)
    {
        Warn("CreateWidget called with WidgetClass = None -- returning None");
        return None;
    }
    if(OwningPlayer == None)
    {
        Warn("CreateWidget called with OwningPlayer = None -- returning None");
        return None;
    }
    
    Log("Creating widget from class" @ WidgetClass, LogCategory());
    Widget = New(None) WidgetClass;
    if(Widget == None)
    {
        Warn("CreateWidget failed, widget failed to create -- returning None");
        return None;
    }
    
    if(!Widget.InitializeWidget(OwningPlayer))
    {
        Warn("CreateWidget failed, widget initialization failed -- returning None");
    }
    
    return Widget;
}