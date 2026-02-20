//==============================================================================
//	R_ArpgItemContainer
//	Abstract base class for ItemContainers
//==============================================================================
class R_ArpgItemContainer extends R_ArpgObject abstract;

function bool IsValidIndex(int Index);
function bool ContainsItem(R_ArpgItem Item);

function bool AddItem(R_ArpgItem Item);
function bool RemoveItem(R_ArpgItem Item);

function int GetItemCount();
function bool GetItem(int Index, out R_ArpgItem OutItem);
function bool GetItemIndex(R_ArpgItem Item, out int OutIndex);