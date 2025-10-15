class R_BTTask_SelectInventory extends R_BTTask;

var private Inventory SelectedInventory;

static function String GetNodeClassString() { return "SelectWeapon"; }

function OnActivated()
{
	local R_Bot Bot;
	local PlayerPawn PP;

	SelectedInventory = None;

	Bot = GetBot();
	if(Bot != None)
	{
		PP = Bot.GetOwnedPlayerPawn();
		if(PP != None)
		{
			if(PP.Weapon != None && FRand() > 0.7)
			{
				SelectedInventory = None;
			}
			else
			{
				SelectedInventory = SelectRandomStowedInventory(PP);
			}
		}
	}
}

function Inventory SelectRandomStowedInventory(Pawn P)
{
	local Inventory Inv;
	local Inventory Candidates[12];
	local int NumCandidates;

	NumCandidates = 0;
	for(Inv = P.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if(NumCandidates >= ArrayCount(Candidates))
		{
			break;
		}

		if(Inv == P.Weapon)
		{
			continue;
		}

		if(Weapon(Inv) != None)
		{
			Candidates[NumCandidates] = Inv;
			++NumCandidates;
		}
	}

	if(NumCandidates == 0)
	{
		return None;
	}
	return Candidates[Rand(NumCandidates)];	
}

function TickTask(float DeltaSeconds)
{
	local R_Bot Bot;
	local R_BotPawnController PawnController;
	local Weapon WeaponInventory;
	local PlayerPawn PP;

	PawnController = GetPawnController();
	if(PawnController == None)
	{
		EndTaskFail();
		return;
	}

	Bot = GetBot();
	PP = Bot.GetOwnedPlayerPawn();
	if(PP.Weapon == SelectedInventory)
	{
		EndTaskSuccess();
		return;
	}

	if(PawnController.CanPerformSwitchWeapon())
	{
		if(SelectedInventory != None)
		{
			WeaponInventory = Weapon(SelectedInventory);
			if(WeaponInventory != None)
			{
				switch(WeaponInventory.MeleeType)
				{
					case MELEE_AXE:	PawnController.SwitchWeapon_NextAxe(); break;
					case MELEE_HAMMER: PawnController.SwitchWeapon_NextHammer(); break;
					case MELEE_SWORD: PawnController.SwitchWeapon_NextSword(); break;
				}
			}
		}
		else
		{
			PawnController.StowWeapon();
		}
	}
}