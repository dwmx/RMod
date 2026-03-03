//==============================================================================
//	R_ArpgItemContainerSet_HeroInventory
//	This class defines the main inventory containers for a hero
//==============================================================================
class R_ArpgItemContainerSet_HeroInventory extends R_ArpgItemContainerSet;

const INVENTORY_GRID_PERSONAL_INVENTORY = 'PersonalInventory';
const INVENTORY_SLOT_MAIN_HAND = 'MainHand';
const INVENTORY_SLOT_OFF_HAND = 'OffHand';
const INVENTORY_SLOT_ARMOR = 'Armor';
const INVENTORY_SLOT_HELM = 'Helm';
const INVENTORY_SLOT_GLOVES = 'Gloves';
const INVENTORY_SLOT_BOOTS = 'Boots';
const INVENTORY_SLOT_FLOAT = 'Float';

var private R_ArpgItemGrid ItemGrid_PersonalInventory;

var private R_ArpgItemSlot ItemSlot_MainHand;
var private R_ArpgItemSlot ItemSlot_OffHand;
var private R_ArpgItemSlot ItemSlot_Armor;
var private R_ArpgItemSlot ItemSlot_Helm;
var private R_ArpgItemSlot ItemSlot_Gloves;
var private R_ArpgItemSlot ItemSlot_Boots;

var private R_ArpgItemSlot ItemSlot_Float;

//------------------------------------------------------------------------------
// 	Events received from ItemSlots -- These need to match R_ArpgItemSlot.uc
const EVENT_ITEM_CHANGED = 'ItemChanged';

//------------------------------------------------------------------------------

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

	// Set up event listeners
	ItemSlot_MainHand.SetEventListener(Self);
	ItemSlot_OffHand.SetEventListener(Self);
	ItemSlot_Armor.SetEventListener(Self);
	ItemSlot_Helm.SetEventListener(Self);
	ItemSlot_Gloves.SetEventListener(Self);
	ItemSlot_Boots.SetEventListener(Self);

	//// Add some test items
	//AddSomeTestItems();
}

// TODO:
// GET RID OF THIS
// This is being implemented by ArpgItemFactory, which is stored on ArpgGameInfo
function AddSomeTestItems()
{
	//local R_ArpgItem TestItem;

	// TODO: This was moved to R_ArpgGameInfo.SpawnForPlayer
	// Still need to implement the WorldPresence DataStore and set up actors, animations, etc

	//TestItem = ItemFactory.CreateItemFromTag(TagLib.Static.MakeTag('Item','Shield','WoodShield'));

	//TestItem = R_ArpgItem(ArpgLib.Static.CreateArpgObject(Class'RArpgCore.R_ArpgItem', Self));
	//TestItem.SetItemTag(TagLib.Static.MakeTag('Item','Shield','WoodShield'));
	//TestItem.SetItemGridSize(2,3);
	//TestItem.SetItemSkelModel(SkelModel'weapons.woodshield');
	//TestItem.AddItemModifier(Class'RArpg.R_ArpgItemModifier_AllSkills', 3);
	//TestItem.AddItemModifier(Class'RArpg.R_ArpgItemModifier_AttackSpeed', 50);
	//ItemGrid_PersonalInventory.AddItem(TestItem);

	//TestItem = R_ArpgItem(ArpgLib.Static.CreateArpgObject(Class'RArpgCore.R_ArpgItem', Self));
	//TestItem.SetItemTag(TagLib.Static.MakeTag('Item','Weapon','Sword','BroadSword'));
	//TestItem.SetItemGridSize(1,3);
	//TestItem.SetItemSkelModel(SkelModel'weapons.broadsword');
	//TestItem.AddItemModifier(Class'RArpg.R_ArpgItemModifier_AttackSpeed', 100);
	//TestItem.AddItemModifier(Class'RArpg.R_ArpgItemModifier_Damage', 300);
	//ItemGrid_PersonalInventory.AddItem(TestItem);
}

function R_ArpgItemContainer GetItemContainer(Name ItemContainerIdentifier)
{
	if(ItemContainerIdentifier == INVENTORY_GRID_PERSONAL_INVENTORY)	return ItemGrid_PersonalInventory;
	if(ItemContainerIdentifier == INVENTORY_SLOT_MAIN_HAND)				return ItemSlot_MainHand;
	if(ItemContainerIdentifier == INVENTORY_SLOT_OFF_HAND)				return ItemSlot_OffHand;
	if(ItemContainerIdentifier == INVENTORY_SLOT_ARMOR)					return ItemSlot_Armor;
	if(ItemContainerIdentifier == INVENTORY_SLOT_HELM)					return ItemSlot_Helm;
	if(ItemContainerIdentifier == INVENTORY_SLOT_GLOVES)				return ItemSlot_Gloves;
	if(ItemContainerIdentifier == INVENTORY_SLOT_BOOTS)					return ItemSlot_Boots;
	if(ItemContainerIdentifier == INVENTORY_SLOT_FLOAT)					return ItemSlot_Float;

	return None;
}

function Name GetItemContainerIdentifier(R_ArpgItemContainer ItemContainer)
{
	if(ItemContainer == ItemGrid_PersonalInventory)	return INVENTORY_GRID_PERSONAL_INVENTORY;
	if(ItemContainer == ItemSlot_MainHand)			return INVENTORY_SLOT_MAIN_HAND;
	if(ItemContainer == ItemSlot_OffHand)			return INVENTORY_SLOT_OFF_HAND;
	if(ItemContainer == ItemSlot_Armor)				return INVENTORY_SLOT_ARMOR;
	if(ItemContainer == ItemSlot_Helm)				return INVENTORY_SLOT_HELM;
	if(ItemContainer == ItemSlot_Gloves)			return INVENTORY_SLOT_GLOVES;
	if(ItemContainer == ItemSlot_Boots)				return INVENTORY_SLOT_BOOTS;
	if(ItemContainer == ItemSlot_Float)				return INVENTORY_SLOT_FLOAT;

	return '';
}

function ReceiveArpgEvent(Name EventName, Object Sender, R_ArpgEventPayload Payload)
{
	local R_ArpgItemSlot LocalItemSlot;
	local R_ArpgItem LocalItem;

	if(EventName == EVENT_ITEM_CHANGED)
	{
		LocalItemSlot = R_ArpgItemSlot(Sender);
		LocalItem = R_ArpgItem(Payload.OptionalObject);
		HandleEvent_ItemSlotChanged(LocalItemSlot, LocalItem);
	}
}

function HandleEvent_ItemSlotChanged(R_ArpgItemSlot ItemSlot, R_ArpgItem NewItem)
{
	local Name InventorySlotName;

	InventorySlotName = GetItemContainerIdentifier(ItemSlot);
	FireInventoryEvent(EVENT_INVENTORY_SLOT_CHANGED, InventorySlotName, NewItem);
}

function bool TryAddItem(R_ArpgItem Item)
{
	if(ItemGrid_PersonalInventory != None)
	{
		return ItemGrid_PersonalInventory.AddItem(Item);
	}
	return false;
}