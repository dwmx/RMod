//==============================================================================
//	R_ArpgItemContainerSet
//	Abstract base class for representing sets of ItemContains held by a given
//	entity in the world
//==============================================================================
class R_ArpgItemContainerSet extends R_ArpgObject abstract;

const ArpgItemGridClass = Class'RArpg.R_ArpgItemGrid';
const ArpgItemSlotClass = Class'RArpg.R_ArpgItemSlot';

function R_ArpgItemContainer GetItemContainer(Name ItemContainerIdentifier);