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
	TestItem.SetItemGridSize(2,3);
	TestItem.SetItemUITexture(Texture'RArpg.UIWoodShield');
	TestItem.ItemUITextureTX = 0.0;
	TestItem.ItemUITextureTY = 0.0;
	TestItem.ItemUITextureTW = 256.0;
	TestItem.ItemUITextureTH = 256.0;
	TestItem.AddItemModifier(Class'RArpg.R_ArpgItemModifier_AllSkills', 3);
	TestItem.AddItemModifier(Class'RArpg.R_ArpgItemModifier_AttackSpeed', 50);
	ItemGrid_PersonalInventory.AddItem(TestItem);

	TestItem = R_ArpgItem(ArpgLib.Static.CreateArpgObject(Class'RArpgCore.R_ArpgItem', Self));
	TestItem.SetItemGridSize(1,3);
	TestItem.SetItemUITexture(Texture'RArpg.UIBroadSword');
	TestItem.ItemUITextureTX = 86.0;
	TestItem.ItemUITextureTY = 0.0;
	TestItem.ItemUITextureTW = 86.0;
	TestItem.ItemUITextureTH = 256.0;
	TestItem.AddItemModifier(Class'RArpg.R_ArpgItemModifier_AttackSpeed', 100);
	TestItem.AddItemModifier(Class'RArpg.R_ArpgItemModifier_Damage', 300);
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