//==============================================================================
//  R_AUILibrary
//  Library class
//
//  Package wide functions for the GameUI RMod package
//==============================================================================
class R_AUILibrary extends R_ALibrary abstract;

static function Name LogCategory() { return 'RGameUI'; }

/**
*   CreateWidget
*   The main function for creating Game UI Widgets
*
*   Users should not instantiate widgets directly via New, they should instead
*   use this function
*
*   The initialization steps are important for widgets to work properly
*
*   Widget creation flow looks like this:
*   - R_AUILibrary.CreateWidget
*   - Call to New()
*   - R_UIWidget.InitializeWidget
*   - R_UIWidget.BuildWidget <--- This is the function your widgets should override
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