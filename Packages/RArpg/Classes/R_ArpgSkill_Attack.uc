class R_ArpgSkill_Attack extends R_ArpgSkill;

var private bool bCollisionCheckActive;
var private Actor StruckActors[16];
var private int StruckActorsCount;

event PostBeginPlay()
{
	// TODO: The observer should be in the debug package
	SetObserver_Collision(None);
	SetObserver_Collision(R_ArpgObserver_Collision(ArpgLib.Static.CreateArpgObject(Class'RArpgCore.R_ArpgObserver_Collision')));
}

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
	function DrawDebug(Canvas C)
	{
		local R_ArpgObserver_Collision Observer;

		Observer = GetObserver_Collision();
		if(Observer != None)
		{
			Observer.DrawCollisions(C);
		}
	}

	event BeginState()
	{
		local R_ArpgPawn RP;

		RP = GetArpgPawnOwner();
		RP.SetLockDirection(true);

		bCollisionCheckActive = false;
		StruckActorsCount = 0;
	}

	event EndState()
	{
		local R_ArpgPawn RP;

		RP = GetArpgPawnOwner();
		RP.SetLockDirection(false);

		bCollisionCheckActive = false;
		StruckActorsCount = 0;
	}

	function Name GetAttackAnim()
	{
		local R_ArpgPawn RP;
		local R_ArpgAnimationSet AnimSet;

		RP = GetArpgPawnOwner();
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
		local R_ArpgPawn PawnOwner;
		local Vector CollisionOrigin;
		local float CollisionRadius;

		PawnOwner = GetArpgPawnOwner();
		if(PawnOwner == None)
		{
			return;
		}

		CollisionOrigin = PawnOwner.Location + Vector(PawnOwner.Rotation) * 32.0;
		CollisionRadius = 32.0;

		Observer = GetObserver_Collision();
		if(Observer != None)
		{
			Observer.ClearCollisionSpheres();
			Observer.AddCollisionSphere(CollisionOrigin, CollisionRadius);
		}
	}

	event Tick(float DeltaSeconds)
	{
		TickCollisions(DeltaSeconds);
	}

Begin:
	R_ArpgPawn(Owner).PlayPawnAnim(GetAttackAnim(), true, false, 1.0, 0.1);
	Sleep(0.1);
	//WeaponActivate();
	Sleep(1);
	//WeaponDeactivate();
	GotoState('SkillNeutral');
}