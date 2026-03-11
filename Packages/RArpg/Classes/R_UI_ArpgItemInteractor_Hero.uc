class R_UI_ArpgItemInteractor_Hero extends R_UI_ArpgItemInteractor;

const UIGameLib = Class'RArpg.R_UI_ArpgUIGameLib';

function bool TryHandleLMouseDown()
{
	local R_UI_ArpgRootWindow LocalArpgRoot;
	local R_ArpgItem LocalFloatingItem;
	local R_ArpgPlayerController PlayerController;
	local R_ArpgPawn_Hero HeroPawn;

	if(FloatingItemSlot != None && FloatingItemSlot.GetItem(0, LocalFloatingItem))
	{
		LocalArpgRoot = R_UI_ArpgRootWindow(Root);
		if(LocalArpgRoot != None)
		{
			if(!LocalArpgRoot.IsMouseInGameUI())
			{
				PlayerController = R_ArpgPlayerController(GetPlayerOwner());
				if(PlayerController != None)
				{
					HeroPawn = R_ArpgPawn_Hero(PlayerController.GetControlledPawn());
				}

				if(HeroPawn == None)
				{
					return false;
				}

				return HeroPawn.TryTossFloatingItem();
			}
		}
	}
	
	return Super.TryHandleLMouseDown();
}

function Color GetSpecialNameDisplayColor(R_ArpgItem Item)
{
	local Name ItemRarityType;

	if(Item == None)
	{
		return Super.GetSpecialNameDisplayColor(Item);
	}

	return UIGameLib.Static.GetItemRarityTypeDrawColor(Item.GetItemRarityType());
}