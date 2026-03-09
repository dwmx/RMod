//==============================================================================
//	R_ArpgPawn_Hero
//==============================================================================
class R_ArpgPawn_Hero extends R_ArpgPawn;

var private Class<R_ArpgAnimationSetSelector> AnimationSetSelectorClass;
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
//	Interaction query responses
//	The UI will ask the pawn, "what would happen if you tried to interact with X"
//	UI then uses that information to draw more helpful visuals for proxies
const INTERACTION_QUERY_SUCCESS = 1;		// Can perform interaction
const INTERACTION_QUERY_FAIL_ACTOR = 4;		// Can't interact with this actor
const INTERACTION_QUERY_FAIL_DISTANCE = 5;	// Too far away to perform interaction

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

function ReceiveInventoryEvent(Name EventName, Name InventoryContainerName, R_ArpgItemContainerSet Sender, R_ArpgItem Items[2])
{
	if(EventName == EVENT_INVENTORY_SLOT_CHANGED)
	{
		HandleEvent_InventorySlotChanged(InventoryContainerName, Items[0], Items[1]);
	}
}

function bool IsEquipmentSlot(Name InventorySlot)
{
	switch(InventorySlot)
	{
	case INVENTORY_SLOT_MAIN_HAND:
	case INVENTORY_SLOT_OFF_HAND:
	case INVENTORY_SLOT_ARMOR:
	case INVENTORY_SLOT_HELM:
	case INVENTORY_SLOT_GLOVES:
	case INVENTORY_SLOT_BOOTS:
		return true;
	}
	return false;
}

function HandleEvent_InventorySlotChanged(Name InventorySlotName, R_ArpgItem OldItem, R_ArpgItem NewItem)
{
	// Update the current animation set
	if(InventorySlotName == INVENTORY_SLOT_MAIN_HAND)
	{
		if(NewItem == None)	SetAnimationSetClass(AnimationSetSelectorClass.Static.GetDefaultAnimationSetClass());
		else				SetAnimationSetClass(AnimationSetSelectorClass.Static.GetAnimationSetClassFromTag(NewItem.GetItemTag()));
	}

	// Update the item actor if there is one
	switch(InventorySlotName)
	{
	case INVENTORY_SLOT_MAIN_HAND:	ItemActor_Weapon.SetItem(NewItem);	break;
	case INVENTORY_SLOT_OFF_HAND:	ItemActor_Shield.SetItem(NewItem);	break;
	}

	// If this is an equipment slot, remove old and apply new affixes
	if(IsEquipmentSlot(InventorySlotName))
	{
		RemoveItemAffixes(OldItem);
		ApplyItemAffixes(NewItem);
	}
}

function ApplyItemAffixes(R_ArpgItem Item)
{
	local R_ArpgEntity Entity;
	local R_ArpgAttributeSet AttributeSet;
	local int AffixCount;
	local Class<R_ArpgAffix> AffixClass;
	local int AffixParameters;
	local Name ModifierAttributeNames[8];
	local float ModifierMagnitudes[8];
	local int ModifierOperators[8];
	local int ModifierCount;
	local int i, j;

	if(Item == None)
	{
		return;
	}

	Entity = GetEntity();
	if(Entity != None)
	{
		AttributeSet = Entity.GetEntityAttributeSet();
	}
	if(AttributeSet == None)
	{
		return;
	}

	AffixCount = Item.GetAffixCount();
	for(i = 0; i < AffixCount; ++i)
	{
		if(!Item.GetAffix(i, AffixClass, AffixParameters))
		{
			continue;
		}

		AffixClass.Static.GetAttributeModifiers(
			AffixParameters,
			ModifierAttributeNames,
			ModifierMagnitudes,
			ModifierOperators,
			ModifierCount);
		
		for(j = 0; j < ModifierCount; ++j)
		{
			AttributeSet.AddAttributeModifier(
				ModifierAttributeNames[j],
				ModifierMagnitudes[j],
				ModifierOperators[j],
				Item.GetItemUID());
		}
	}
}

function RemoveItemAffixes(R_ArpgItem Item)
{
	local R_ArpgEntity Entity;
	local R_ArpgAttributeSet AttributeSet;

	if(Item == None)
	{
		return;
	}

	Entity = GetEntity();
	if(Entity != None)
	{
		AttributeSet = Entity.GetEntityAttributeSet();
	}
	if(AttributeSet == None)
	{
		return;
	}

	AttributeSet.RemoveAttributeModifiersBySource(Item.GetItemUID());
}

function R_ArpgItemContainerSet GetInventorySet()
{
	return InventorySet;
}

function bool TryTossFloatingItem()
{
	local R_ArpgItemContainer FloatingSlot;
	local R_ArpgItem FloatingItem;
	local R_ArpgItemActor_Pickup PickupActor;

	if(InventorySet != None)
	{
		FloatingSlot = InventorySet.GetItemContainer(INVENTORY_SLOT_FLOAT);
		if(FloatingSlot == None)
		{
			return false;
		}

		FloatingSlot.GetItem(0, FloatingItem);
		if(FloatingItem == None)
		{
			return false;
		}

		PickupActor = Spawn(Class'RArpg.R_ArpgItemActor_Pickup', None,, Location);
		if(PickupActor == None)
		{
			return false;
		}

		FloatingSlot.RemoveItem(FloatingItem);
		PickupActor.SetItem(FloatingItem);
		return true;
	}

	return false;
}

function int QueryInteraction(R_ArpgInteractionProxy InteractionProxy)
{
	local Actor A;
	local Vector DeltaLocation;
	local float Distance;

	A = InteractionProxy.GetProxyOwner();
	if(A == None)
	{
		return INTERACTION_QUERY_FAIL_ACTOR;
	}

	DeltaLocation = A.Location - Self.Location;
	Distance = VSize(DeltaLocation) - A.CollisionRadius - Self.CollisionRadius;
	if(Distance >= 128.0)
	{
		return INTERACTION_QUERY_FAIL_DISTANCE;
	}

	return INTERACTION_QUERY_SUCCESS;
}

function bool TryInteract(R_ArpgInteractionProxy InteractionProxy)
{
	local R_ArpgItemActor_Pickup Pickup;

	if(InteractionProxy != None)
	{
		Pickup = R_ArpgItemActor_Pickup(InteractionProxy.GetProxyOwner());
		if(Pickup == None)
		{
			return false;
		}
	}

	if(TryAddItem(Pickup.GetItem()))
	{
		Pickup.Destroy();
		return true;
	}

	return false;
}

function bool TryAddItem(R_ArpgItem Item)
{
	if(InventorySet != None)
	{
		return InventorySet.TryAddItem(Item);
	}
	return false;
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
	AnimationSetDefaultClass=Class'RArpg.R_ArpgAnimationSet_Ragnar_Default'
	AnimationSetSelectorClass=Class'R_ArpgAnimationSetSelector_Ragnar'
}