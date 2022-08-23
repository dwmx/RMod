//=============================================================================
// HelTorch.
//=============================================================================
class HelTorch expands Torch;


//=============================================================================
//
// Ignite
//
//=============================================================================
function Ignite()
{
	if (Region.Zone.bWaterZone)
		return;

	// Spawn fire on the torch
	TorchFire = Spawn(class'torchfire',,, GetJointPos(JointNamed('offset')),);
	PlaySound(IgniteSound, SLOT_Interface);
	
	AttachActorToJoint(TorchFire, JointNamed('offset'));
	
	DamageType = 'fire';
	bUnlit = true;
	ScaleGlow = 2.0;
	HitCount = 3.0;
	DouseTime = 0.0;

	// Reset weapon anims
	A_Idle = Default.A_Idle;
    A_Forward = Default.A_Forward;
    A_Backward = Default.A_Backward;
    A_Backward45Right = Default.A_Backward45Right;
    A_Backward45Left = Default.A_Backward45Left;
    A_StrafeRight = Default.A_StrafeRight;
    A_StrafeLeft = Default.A_StrafeLeft;
	A_Forward45Right = Default.A_Forward45Right;
	A_Forward45Left = Default.A_Forward45Left;
	A_AttackA = Default.A_AttackA;
	A_AttackStrafeRight = Default.A_AttackStrafeRight;
	A_AttackStrafeLeft = Default.A_AttackStrafeLeft;
	A_AttackStandA = Default.A_AttackStandA;
	A_AttackStandAReturn = Default.A_AttackStandAReturn;
	A_AttackStandB = Default.A_AttackStandB;
	A_AttackStandBReturn = Default.A_AttackStandBReturn;

    LightType=LT_Steady;
    LightEffect=LE_None;
    LightBrightness=230;
    LightHue=20;
    LightSaturation=20;
    LightRadius=16;
}

defaultproperties
{
     Style=STY_Masked
     CollisionHeight=5.000000
     Skeletal=SkelModel'objects.HelTorch'
}
