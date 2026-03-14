class R_ArpgSkill_Attack extends R_ArpgSkill;

var private bool bPerformedCollisionCheck;
var private bool bDidLockMovement;

function ActivateSkill()
{
}

auto state SkillNeutral
{
	event BeginState()
	{
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

		RP = GetArpgPawnOwner();
		RP.SetLockDirection(true);

		if(!RP.CanMoveWhileAttacking())
		{
			bDidLockMovement = true;
			RP.LockMovement();
		}

		bPerformedCollisionCheck = false;
	}

	event EndState()
	{
		local R_ArpgPawn RP;

		RP = GetArpgPawnOwner();
		RP.SetLockDirection(false);

		if(bDidLockMovement)
		{
			RP.UnlockMovement();
		}

		if(!bPerformedCollisionCheck)
		{
			PerformCollisionCheck();
		}
	}

	function bool IsValidTarget(R_ArpgPawn TargetPawn)
	{
		local R_ArpgPawn PawnOwner;

		PawnOwner = GetArpgPawnOwner();
		if(PawnOwner == None || TargetPawn == None || PawnOwner == TargetPawn)
		{
			return false;
		}

		if(TargetPawn.GetTeamIndex() != PawnOwner.GetTeamIndex())
		{
			return true;
		}
		return false;
	}

	function PerformCollisionCheck()
	{
		local R_ArpgObserver_Collision Observer;
		local R_ArpgPawn PawnOwner, PawnIt;
		local Vector CollisionOrigin;
		local float CollisionRadius;

		if(bPerformedCollisionCheck)
		{
			return;
		}
		bPerformedCollisionCheck = true;

		PawnOwner = GetArpgPawnOwner();
		if(PawnOwner == None)
		{
			return;
		}

		CollisionOrigin = PawnOwner.Location + Vector(PawnOwner.Rotation) * 32.0;
		CollisionRadius = 16.0;

		foreach RadiusActors(Class'RArpg.R_ArpgPawn', PawnIt, CollisionRadius, CollisionOrigin)
		{
			if(IsValidTarget(PawnIt))
			{
				PawnIt.ArpgTakeDamage(20.0);
				break;
			}
		}

		Observer = GetObserver_Collision();
		if(Observer != None)
		{
			Observer.ClearCollisionSpheres();
			Observer.AddCollisionSphere(CollisionOrigin, CollisionRadius);
		}
	}

	function float GetAttackRate()
	{
		local float BaseValue, AggregateValue;
		local R_ArpgPawn PawnOwner;

		PawnOwner = GetArpgPawnOwner();
		if(PawnOwner != None)
		{
			PawnOwner.GetAttributeValue('AttackRate', BaseValue, AggregateValue);
			return AggregateValue;
		}
		return 1.0;
	}

Begin:
	TryPlayStandardAnim('Attack', 'UpperBody', 1.0, 0.1);
	Sleep(0.5 * (1.0 / GetAttackRate()));
	PerformCollisionCheck();
	Sleep(0.5 * (1.0 / GetAttackRate()));
	GotoState('SkillNeutral');
}