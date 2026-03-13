//==============================================================================
//	R_ArpgAnimationController_Pawn
//	Controls the animation for an ArpgPawn
//	Do not make calls to PlayAnim or LoopAnim directly on the pawn, all
//	anim logic should pass through here
//==============================================================================
class R_ArpgAnimationController_Pawn extends R_ArpgAnimationController;

var private R_ArpgPawn PawnOwner;

function InitializeArpgObject()
{
	Super.InitializeArpgObject();
	PawnOwner = R_ArpgPawn(Outer);
}

function Tick(float DeltaSeconds)
{
	if(!GetControllerEnabled())
	{
		return;
	}

	Super.Tick(DeltaSeconds);
	TickLocomotion(DeltaSeconds);
}

function TickLocomotion(float DeltaSeconds)
{
	local Name ActiveAnimSlot;
	local int MovementDirection;
	local Class<R_ArpgAnimationSet> AnimSetClass;
	local Name LocomotionAnim;

	if(PawnOwner == None)
	{
		return;
	}

	ActiveAnimSlot = GetActiveAnimSlot();
	if(ActiveAnimSlot == 'FullBody')
	{	// No locomotion anim plays when full body slot is active
		return;
	}

	if(ActiveAnimSlot == 'UpperBody' && PawnOwner.AnimProxy == None)
	{	// If UpperBody slot is active but there's no proxy, don't play locomotion
		return;
	}

	MovementDirection = PawnOwner.GetMovementDirection();
	AnimSetClass = GetAnimationSetClass();
	if(AnimSetClass != None)
	{
		LocomotionAnim = AnimSetClass.Static.GetStaticAnimationForMovementDirection(MovementDirection);
	}

	if(ActiveAnimSlot == 'UpperBody')
	{	// If UpperBody is active, only play locomotion on the lower body if owner has an AnimProxy
		if(PawnOwner.AnimProxy != None)
		{
			PawnOwner.LoopAnim(LocomotionAnim, 1.0, 0.1);
		}
	}
	else
	{	// All other cases, play full-body locomotion
		PawnOwner.LoopAnim(LocomotionAnim, 1.0, 0.1);
		if(PawnOwner.AnimProxy != None)
		{
			// Nothing playing on the upper body slot, so AnimProxy plays it too
			PawnOwner.AnimProxy.LoopAnim(LocomotionAnim, 1.0, 0.1);
		}
	}
}