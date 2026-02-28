//==============================================================================
//	R_ArpgItemContainerSet
//	Abstract base class for representing sets of ItemContains held by a given
//	entity in the world
//==============================================================================
class R_ArpgItemContainerSet extends R_ArpgObject abstract;

const ArpgItemGridClass = Class'RArpg.R_ArpgItemGrid';
const ArpgItemSlotClass = Class'RArpg.R_ArpgItemSlot';

//------------------------------------------------------------------------------
//	Inventory events emitted from this class
const EVENT_INVENTORY_SLOT_CHANGED = 'InventorySlotChanged';

//------------------------------------------------------------------------------

var private R_ArpgPawn OwnerPawn;

//------------------------------------------------------------------------------

function R_ArpgItemContainer GetItemContainer(Name ItemContainerIdentifier);

//------------------------------------------------------------------------------

function SetOwnerPawn(R_ArpgPawn NewOwnerPawn)
{
	OwnerPawn = NewOwnerPawn;
}

function R_ArpgPawn GetOwnerPawn()
{
	return OwnerPawn;
}

function FireInventoryEvent(Name EventName, Name InventoryContainerName, optional R_ArpgItem OptionalItem)
{
	if(OwnerPawn == None)
	{
		return;
	}

	OwnerPawn.ReceiveInventoryEvent(EventName, InventoryContainerName, Self, OptionalItem);
}