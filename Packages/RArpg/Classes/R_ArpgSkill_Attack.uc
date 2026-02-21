class R_ArpgSkill_Attack extends R_ArpgSkill;

function ActivateSkill()
{
}

function WeaponActivate()
{
	local Weapon W;

	W = PlayerPawn(Owner).Weapon;
	if(W == None)
	{
		return;
	}

	PlayerPawn(Owner).WeaponActivate();
	W.PlaySwipeSound();
}

function WeaponDeactivate()
{
	local Weapon W;

	W = PlayerPawn(Owner).Weapon;
	if(W == None)
	{
		return;
	}

	PlayerPawn(Owner).WeaponDeactivate();
}

auto state SkillNeutral
{
	event BeginState()
	{
		Log("In state SkillNeutral");
	}

	function ActivateSkill()
	{
		GotoState('SkillActive');
	}
}

state SkillActive
{
	event BeginState()
	{
		local R_ArpgPawn RP;

		RP = R_ArpgPawn(Owner);
		RP.SetLockDirection(true);
	}

	event EndState()
	{
		local R_ArpgPawn RP;

		RP = R_ArpgPawn(Owner);
		RP.SetLockDirection(false);
	}

	function OwnerFrameNotify(int framepassed)
	{
		local Weapon W;

		W = Pawn(Owner).Weapon;
		W.FrameNotify(framepassed);
	}

	function Name GetAttackAnim()
	{
		local R_ArpgPawn RP;
		local R_ArpgAnimationSet AnimSet;

		RP = R_ArpgPawn(Owner);
		if(RP != None)
		{
			AnimSet = RP.GetAnimationSet();
		}

		if(AnimSet == None)
		{
			return '';
		}

		return AnimSet.AttackMoving;
	}

Begin:
	Owner.PlayAnim(GetAttackAnim(), 1.0, 0.1);
	Sleep(0.1);
	WeaponActivate();
	Sleep(1);
	WeaponDeactivate();
	GotoState('SkillNeutral');
}