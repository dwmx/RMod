//==============================================================================
//	R_ArpgAnimationController_Pawn
//	Controls the animation for an ArpgPawn
//	Do not make calls to PlayAnim or LoopAnim directly on the pawn, all
//	anim logic should pass through here
//==============================================================================
class R_ArpgAnimationController_Pawn extends R_ArpgAnimationController;

var private R_ArpgPawn PawnOwner;

function SetActorOwner(Actor NewActorOwner)
{
	local R_ArpgPawn LocalPawn;

	Super.SetActorOwner(NewActorOwner);

	LocalPawn = R_ArpgPawn(NewActorOwner);
	if(LocalPawn != None)
	{
		PawnOwner = LocalPawn;
	}
}

function Tick(float DeltaSeconds)
{
	local int MovementDirection;
	local Class<R_ArpgAnimationSet> AnimSetClass;
	local Name LocomotionAnim;

	return;
	if(PawnOwner == None)
	{
		return;
	}

	MovementDirection = PawnOwner.GetMovementDirection();
	AnimSetClass = GetAnimationSetClass();
	if(AnimSetClass != None)
	{
		LocomotionAnim = AnimSetClass.Static.GetStaticAnimationForMovementDirection(MovementDirection);

		PawnOwner.LoopAnim(LocomotionAnim, 1.0, 0.1);
		if(PawnOwner.AnimProxy != None)
		{
			PawnOwner.AnimProxy.LoopAnim(LocomotionAnim, 1.0, 0.1);
		}
	}
}