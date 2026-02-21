//==============================================================================
//	R_UIW_InWorldRootWindow
//	Root Window for the InWorldUI user interface
//==============================================================================
class R_UIW_InWorldRootWindow extends RGameUI.R_UIW_RootWindow;

var private R_UI_Item ActiveItem;
var private R_UI_ItemInteractor ItemInteractor;
var private R_ArpgItem HoveredItem;

function Created()
{
	Super.Created();

	ActiveItem = R_UI_Item(CreateWindow(Class'R_UI_Item', 0, 0, 128, 128));
	ActiveItem.bShouldMousePassThrough = true;
	ActiveItem.bAlwaysOnTop = true;
	HideActiveItem();

	ItemInteractor = R_UI_ItemInteractor(CreateWindow(Class'R_UI_ItemInteractor', 0, 0, 256, 256));
	ItemInteractor.bShouldMousePassThrough = true;
	ItemInteractor.bAlwaysOnTop = true;
}

function ShowActiveItem()
{
	ActiveItem.ShowWindow();
}

function HideActiveItem()
{
	ActiveItem.HideWindow();
}