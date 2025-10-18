class R_BehaviorTask_Equip extends R_BehaviorTask;

const TaskParam_EquipTarget = 'EquipTarget';

static function String GetTaskDisplayString() { return "Equip"; }

function int TickTask(R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds)
{
	local R_BotPawnController PawnController;
	local PlayerPawn PP;
	local Actor EquipTarget;
	local Weapon EquipTargetWeapon;

	PawnController = GetPawnController(Bot);
	if(PawnController == None)
	{
		return TaskFail;
	}

	PP = GetPlayerPawn(Bot);
	if(PP == None)
	{
		return TaskFail;
	}

	if(!ReadMappedActor(BlackBoard, TaskParam_EquipTarget, EquipTarget))
	{
		return TaskFail;
	}

	EquipTargetWeapon = Weapon(EquipTarget);
	if(EquipTargetWeapon == None && EquipTarget != None)
	{	// Tried to equip a non-weapon
		return TaskFail;
	}

	if(PP.Weapon == EquipTarget)
	{
		return TaskSuccess;
	}

	if(PawnController.CanPerformSwitchWeapon())
	{
		if(EquipTarget == None)
		{
			PawnController.StowWeapon();
		}
		else
		{
			switch(EquipTargetWeapon.MeleeType)
			{
				case MELEE_AXE:	PawnController.SwitchWeapon_NextAxe(); break;
				case MELEE_HAMMER: PawnController.SwitchWeapon_NextHammer(); break;
				case MELEE_SWORD: PawnController.SwitchWeapon_NextSword(); break;
			}
		}
	}

	return TaskInProgress;
}