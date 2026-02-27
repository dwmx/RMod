//==============================================================================
//	R_ArpgItemContainerSet_HeroInventory
//	This class defines the main inventory containers for a hero
//==============================================================================
class R_ArpgItemContainerSet_HeroInventory extends R_ArpgItemContainerSet;

var private R_ArpgItemGrid ItemGrid_PersonalInventory;

var private R_ArpgItemSlot ItemSlot_MainHand;
var private R_ArpgItemSlot ItemSlot_OffHand;
var private R_ArpgItemSlot ItemSlot_Armor;
var private R_ArpgItemSlot ItemSlot_Helm;
var private R_ArpgItemSlot ItemSlot_Gloves;
var private R_ArpgItemSlot ItemSlot_Boots;

var private R_ArpgItemSlot ItemSlot_Float;

function InitializeArpgObject()
{
	ItemGrid_PersonalInventory = R_ArpgItemGrid(ArpgLib.Static.CreateArpgObject(ArpgItemGridClass, Self));

	ItemSlot_MainHand 	= R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(ArpgItemSlotClass, Self));
	ItemSlot_OffHand 	= R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(ArpgItemSlotClass, Self));
	ItemSlot_Armor 		= R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(ArpgItemSlotClass, Self));
	ItemSlot_Helm 		= R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(ArpgItemSlotClass, Self));
	ItemSlot_Gloves 	= R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(ArpgItemSlotClass, Self));
	ItemSlot_Boots 		= R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(ArpgItemSlotClass, Self));

	ItemSlot_Float 		= R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(ArpgItemSlotClass, Self));
}

function R_ArpgItemContainer GetItemContainer(Name ItemContainerIdentifier)
{
	return None;
}