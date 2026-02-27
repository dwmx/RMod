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
	ItemGrid_PersonalInventory.SetGridSize(12, 4);

	ItemSlot_MainHand 	= R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(ArpgItemSlotClass, Self));
	ItemSlot_OffHand 	= R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(ArpgItemSlotClass, Self));
	ItemSlot_Armor 		= R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(ArpgItemSlotClass, Self));
	ItemSlot_Helm 		= R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(ArpgItemSlotClass, Self));
	ItemSlot_Gloves 	= R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(ArpgItemSlotClass, Self));
	ItemSlot_Boots 		= R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(ArpgItemSlotClass, Self));

	ItemSlot_Float 		= R_ArpgItemSlot(ArpgLib.Static.CreateArpgObject(ArpgItemSlotClass, Self));

	// Add some test items
	AddSomeTestItems();
}

function AddSomeTestItems()
{
	local R_ArpgItem TestItem;

	TestItem = R_ArpgItem(ArpgLib.Static.CreateArpgObject(Class'RArpgCore.R_ArpgItem', Self));
	TestItem.SetItemGridSize(2,2);
	TestItem.SetItemUITexture(Texture'RuneFX.loading1');
	ItemGrid_PersonalInventory.AddItem(TestItem);

	TestItem = R_ArpgItem(ArpgLib.Static.CreateArpgObject(Class'RArpgCore.R_ArpgItem', Self));
	TestItem.SetItemGridSize(3,3);
	TestItem.SetItemUITexture(Texture'RuneFX.saving1');
	ItemGrid_PersonalInventory.AddItem(TestItem);
}

function R_ArpgItemContainer GetItemContainer(Name ItemContainerIdentifier)
{
	switch(ItemContainerIdentifier)
	{
	case 'PersonalInventory':	return ItemGrid_PersonalInventory;
	case 'MainHand':			return ItemSlot_MainHand;
	case 'OffHand':				return ItemSlot_OffHand;
	case 'Armor':				return ItemSlot_Armor;
	case 'Helm':				return ItemSlot_Helm;
	case 'Gloves':				return ItemSlot_Gloves;
	case 'Boots':				return ItemSlot_Boots;
	case 'Float':				return ItemSlot_Float;
	}

	return None;
}