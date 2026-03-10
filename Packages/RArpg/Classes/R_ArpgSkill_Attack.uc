class R_ArpgSkill_Attack extends R_ArpgSkill;

var private bool bCollisionCheckActive;
var private Actor StruckActors[16];
var private int StruckActorsCount;

var private Name RecoverAnim;

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
		//RP.SetBlockMovementInput(true);
		//RP.Velocity = Vect(0,0,0);
		//RP.Acceleration = Vect(0,0,0);

		bCollisionCheckActive = false;
		StruckActorsCount = 0;
	}

	event EndState()
	{
		local R_ArpgPawn RP;

		RP = GetArpgPawnOwner();
		RP.SetLockDirection(false);
		//RP.SetBlockMovementInput(false);

		bCollisionCheckActive = false;
		StruckActorsCount = 0;
	}

	function Name GetAttackAnim()
	{
		local R_ArpgPawn RP;
		local R_ArpgAnimationSet AnimSet;
		local Name AttackSequence, RecoverSequence;

		RP = GetArpgPawnOwner();
		if(RP != None)
		{
			AnimSet = RP.GetAnimationSet();
		}

		if(AnimSet == None)
		{
			return '';
		}

		//AnimSet.GetRandomAttackAnimation(AttackSequence, RecoverSequence);
		//RecoverAnim = RecoverSequence;
		//return AttackSequence;
		return AnimSet.GetAttackAnimation();
	}

	function AddStruckActor(Actor A)
	{
		if(A == None)
		{
			return;
		}

		if(StruckActorsCount >= ArrayCount(StruckActors))
		{
			return;
		}

		StruckActors[StruckActorsCount] = A;
		++StruckActorsCount;
	}

	function bool HasStruckActor(Actor A)
	{
		local int i;

		if(A == None)
		{
			return false;
		}

		for(i = 0; i < StruckActorsCount; ++i)
		{
			if(StruckActors[i] == A)
			{
				return true;
			}
		}
		return false;
	}

	function EnableCollisionCheck()
	{
		bCollisionCheckActive = true;
	}

	function DisableCollisionCheck()
	{
		bCollisionCheckActive = false;
	}

	function TickCollisions(float DeltaSeconds)
	{
		local R_ArpgObserver_Collision Observer;
		local R_ArpgPawn PawnOwner, PawnIt;
		local Vector CollisionOrigin;
		local float CollisionRadius;

		PawnOwner = GetArpgPawnOwner();
		if(PawnOwner == None)
		{
			return;
		}

		CollisionOrigin = PawnOwner.Location + Vector(PawnOwner.Rotation) * 32.0;
		CollisionRadius = 32.0;

		foreach RadiusActors(Class'RArpg.R_ArpgPawn', PawnIt, CollisionRadius, CollisionOrigin)
		{
			if(HasStruckActor(PawnIt) || PawnIt == PawnOwner)
			{
				continue;
			}

			AddStruckActor(PawnIt);
			PawnIt.ArpgTakeDamage(20.0);
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

	event Tick(float DeltaSeconds)
	{
		TickCollisions(DeltaSeconds);
	}

Begin:
	R_ArpgPawn(Owner).PlayPawnAnim(GetAttackAnim(), true, false, GetAttackRate(), 0.1);
	//R_ArpgPawn(Owner).AnimProxy.FinishAnim();
	//R_ArpgPawn(Owner).FinishAnim();
	//Log("FINISHED ANIM");
	//R_ArpgPawn(Owner).PlayPawnAnim(RecoverAnim, true, false, 1.0, 0.1);
	//R_ArpgPawn(Owner).AnimProxy.FinishAnim();
	//Sleep(0.1);
	//WeaponActivate();
	Sleep(0.8 * (1.0 / GetAttackRate()));
	//WeaponDeactivate();
	GotoState('SkillNeutral');
}