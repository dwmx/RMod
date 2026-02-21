//==============================================================================
//	R_ArpgItemActor
//	World representation of an Item
//==============================================================================
class R_ArpgItemActor extends Actor;

var private R_ArpgItem Item;

event BeginPlay()
{
	local R_ArpgItem LocalItem;

	Super.BeginPlay();
	// This is just a test and should not be here

	LocalItem = new(Self) Class'RArpg.R_ArpgItem';
	SetItem(LocalItem);
}

function SetItem(R_ArpgItem NewItem)
{
	Item = NewItem;
	if(Item == None)
	{
		ClearItemVisualFeatures();
	}
	else
	{
		ApplyItemVisualFeatures(Item);
	}
}

function ClearItemVisualFeatures()
{
	Skeletal = None;
}

function ApplyItemVisualFeatures(R_ArpgItem NewItem)
{
	if(NewItem == None)
	{
		return;
	}

	NewItem.GetItemSkelModel(Skeletal);
}

defaultproperties
{
	RemoteRole=ROLE_DumbProxy
	DrawType=DT_SkeletalMesh
}