//==============================================================================
//	R_ArpgCarcass
//==============================================================================
class R_ArpgCarcass extends Actor;

const UtilityLib = Class'RBase.R_AUtilityLibrary';

var Class<R_ArpgInteractionProxy> InteractionProxyClass;

function PostBeginPlay()
{
	Spawn(InteractionProxyClass, Self);
}

function InitCarcassFromPawn(R_ArpgPawn OtherPawn)
{
	local int i;

	if(OtherPawn == None)
	{
		return;
	}

	UtilityLib.Static.CopyActorVisualFeatures(OtherPawn, Self);

	Velocity  = OtherPawn.Velocity;
	SimAnim.X = 10000 * AnimFrame;
	SimAnim.Y = 5000 * AnimRate;
	SimAnim.Z = 1000 * TweenRate;
	SimAnim.W = 10000 * AnimLast;

	SetPhysics(OtherPawn.Physics);

	SetCollisionSize(OtherPawn.CollisionRadius, OtherPawn.CollisionHeight);
}

defaultproperties
{
	bStatic=false
	bStasis=false
	Physics=PHYS_Falling
	LifeSpan=20.0
	DrawType=DT_SkeletalMesh
	InteractionProxyClass=Class'RArpg.R_ArpgInteractionProxy'
}