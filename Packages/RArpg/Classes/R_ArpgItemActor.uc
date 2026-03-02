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

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
    DrawType=DT_SkeletalMesh
    CollisionRadius=24.000000
    CollisionHeight=46.000000
}