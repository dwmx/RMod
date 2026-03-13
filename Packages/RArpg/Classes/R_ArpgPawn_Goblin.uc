//==============================================================================
//	R_ArpgPawn_Goblin
//==============================================================================
class R_ArpgPawn_Goblin extends R_ArpgPawn;

var private bool bAnimationPlaying;

event PostBeginPlay()
{
	local R_ArpgAnimationController LocalAnimController;
	
	Super.PostBeginPlay();

	LocalAnimController = GetAnimationController();
	if(LocalAnimController != None)
	{
		LocalAnimController.SetAnimationSetClass(Class'RArpg.R_ArpgAnimationSet_Goblin');
	}

	AddSkill(Class'RArpg.R_ArpgSkill_Attack', 'Attack');
}

event Tick(float DeltaSeconds)
{
	Super.Tick(DeltaSeconds);

	SetRotation(Rotator(Velocity * Vect(1,1,0)));
}

function int GetMovementDirection()
{
	if(VSize(Velocity * Vect(1,1,0)) <= 8.0)
	{
		return MOVEDIR_NEUTRAL;
	}

	return MOVEDIR_FORWARD;
}

function PlayPawnAnim(
	Name AnimSequence,
	optional bool bUpperBody,
	optional bool bLowerBody,
	optional float Rate,
	optional float TweenTime)
{
	// Ignore upper/lower
	PlayAnim(AnimSequence, Rate, TweenTime);
	bAnimationPlaying = true;
}

function LoopPawnAnim(
	Name AnimSequence,
	optional bool bUpperBody,
	optional bool bLowerBody,
	optional float Rate,
	optional float TweenTime,
	optional float MinRate)
{
	if(!bAnimationPlaying)
	{
		LoopAnim(AnimSequence, Rate, TweenTime, MinRate);
	}
}

function AnimEnd()
{
	bAnimationPlaying = false;
}

defaultproperties
{
	Skeletal=SkelModel'creatures.Goblin'
	CollisionRadius=16.000000
    CollisionHeight=32.000000
	GroundSpeed=60.0
	Mass=50.000000
    Buoyancy=35.000000
	AnimationSetDefaultClass=Class'RArpg.R_ArpgAnimationSet_Goblin'
	bAnimationPlaying=false
}