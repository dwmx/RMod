class R_BehaviorTask_SelectEquipTarget extends R_BehaviorTask;

const TaskParam_EquipTarget = 'EquipTarget';

static function String GetTaskDisplayString() { return "Select Equip Target"; }

function int TickTask(R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds)
{
	local PlayerPawn PP;
	local Inventory NewEquipTarget;

	if(Bot != None)
	{
		PP = Bot.GetOwnedPlayerPawn();
	}

	if(PP == None)
	{
		return TaskFail;
	}

	NewEquipTarget = SelectRandomStowedInventory(PP);
	WriteMappedActor(BlackBoard, TaskParam_EquipTarget, NewEquipTarget);
	return TaskSuccess;
}

function Inventory SelectRandomStowedInventory(Pawn P)
{
	local Inventory Inv;
	local Inventory Candidates[16];
	local int NumCandidates;

	if(P == None)
	{
		return None;
	}

	NumCandidates = 0;
	for(Inv = P.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if(NumCandidates >= ArrayCount(Candidates))
		{
			break;
		}

		if(Weapon(Inv) != None)
		{
			if(P.Weapon != Inv)
			{
				Candidates[NumCandidates] = Inv;
				++NumCandidates;
			}
		}
	}

	return Candidates[Rand(NumCandidates)];
}