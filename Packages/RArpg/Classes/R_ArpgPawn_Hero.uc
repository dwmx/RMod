class R_ArpgPawn_Hero extends R_ArpgPawn;

//var private R_ArpgInventorySet InventorySet;
var private R_ArpgItemContainerSet InventorySet;

//------------------------------------------------------------------------------
//	Inventory identifiers defined by R_ArpgItemContainerSet_HeroInventory
//	These need to match the identifiers defined in that class
const INVENTORY_GRID_PERSONAL_INVENTORY = 'PersonalInventory';
const INVENTORY_SLOT_MAIN_HAND = 'MainHand';
const INVENTORY_SLOT_OFF_HAND = 'OffHand';
const INVENTORY_SLOT_ARMOR = 'Armor';
const INVENTORY_SLOT_HELM = 'Helm';
const INVENTORY_SLOT_GLOVES = 'Gloves';
const INVENTORY_SLOT_BOOTS = 'Boots';
const INVENTORY_SLOT_FLOAT = 'Float';

//------------------------------------------------------------------------------

var private R_ArpgItemActor ItemActor_Weapon;
var private R_ArpgItemActor ItemActor_Shield;

//------------------------------------------------------------------------------

event PostBeginPlay()
{
	local Weapon W;

	Super.PostBeginPlay();

	// Initialize the InventorySet object which holds all of the ItemContainers
	InventorySet = R_ArpgItemContainerSet(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgItemContainerSet_HeroInventory', Self));
	InventorySet.SetOwnerPawn(Self);

	// Create world-representation actors for the items
	ItemActor_Weapon = Spawn(Class'RArpg.R_ArpgItemActor', Self);
	ItemActor_Shield = Spawn(Class'RArpg.R_ArpgItemActor', Self);

	AttachActorToJoint(ItemActor_Weapon, JointNamed(WeaponJoint));
	AttachActorToJoint(ItemActor_Shield, JointNamed(ShieldJoint));

	// Add some test skills
	AddSkill(Class'RArpg.R_ArpgSkill_Whirlwind');
	AddSkill(Class'RArpg.R_ArpgSkill_Orb');
	AddSkill(Class'RArpg.R_ArpgSkill_Attack');
}

function ReceiveInventoryEvent(Name EventName, Name InventoryContainerName, R_ArpgItemContainerSet Sender, optional R_ArpgItem OptionalItem)
{
	if(EventName == EVENT_INVENTORY_SLOT_CHANGED)
	{
		HandleEvent_InventorySlotChanged(InventoryContainerName, OptionalItem);
	}
}

function HandleEvent_InventorySlotChanged(Name InventorySlotName, R_ArpgItem NewItem)
{
	switch(InventorySlotName)
	{
	case INVENTORY_SLOT_MAIN_HAND:	ItemActor_Weapon.SetItem(NewItem);	break;
	case INVENTORY_SLOT_OFF_HAND:	ItemActor_Shield.SetItem(NewItem);	break;
	}
}

function R_ArpgItemContainerSet GetInventorySet()
{
	return InventorySet;
}

function Input_Fire()
{
	ActivateSkill();
}

function ActivateSkill()
{
	if(GetSkill(0) != None)
	{
		GetSkill(0).ActivateSkill();
	}
}

event FrameNotify(int framepassed)
{
	GetSkill(0).OwnerFrameNotify(framepassed);
	Super.FrameNotify(framepassed);
}

defaultproperties
{
	//RemoteRole=ROLE_AutonomousProxy
	Skeletal=SkelModel'Players.Ragnar'
	//SubstituteMesh=SkelModel'VWCreatures.Giant'
	SkelMesh=1
	CollisionRadius=18.000000
	CollisionHeight=42.000000
	WeaponJoint=attach_hand
    ShieldJoint=attach_shielda
	bFrameNotifies=true
}