//==============================================================================
//	R_ArpgItemActor
//	World representation of an Item
//==============================================================================
class R_ArpgItemActor extends Actor;

var private R_ArpgItem Item;

event BeginPlay()
{
	local R_ArpgItem LocalItem;
	local Rotator Rot;

	Super.BeginPlay();
	// This is just a test and should not be here

	LocalItem = new(Self) Class'RArpg.R_ArpgItem';
	SetItem(LocalItem);

	Rot.Roll = -65535 / 4;
	SetRotation(Rot);
}

function R_ArpgItem GetItem()
{
	return Item;
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
	local R_ArpgGameInfo GI;
	local R_ArpgData_WorldPresenceDataStore DataStore;
	local R_ArpgData_WorldPresence Data;

	if(NewItem == None)
	{
		return;
	}

	if(Role == ROLE_Authority)
	{
		GI = R_ArpgGameInfo(Level.Game);
		if(GI != None)
		{
			DataStore = GI.GetWorldPresenceDataStore();
			if(DataStore != None)
			{
				if(DataStore.GetWorldPresence(NewItem, Data))
				{
					Skeletal = Data.Skeletal;
				}
			}
		}
	}
}

function String GetItemDisplayString()
{
	local String Result;

	if(Item != None)
	{
		Result = Item.GetItemSpecialNameString();
		if(Result == "")
		{
			Result = Item.GetItemTypeString();
		}
	}
	else
	{
		Result = "Invalid Item";
	}
	return Result;
}

function Name GetItemRarityType()
{
	if(Item == None)
	{
		return '';
	}

	return Item.GetItemRarityType();
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
    DrawType=DT_SkeletalMesh
    CollisionRadius=32.000000
    CollisionHeight=32.000000
}