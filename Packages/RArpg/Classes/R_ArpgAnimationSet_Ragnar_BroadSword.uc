class R_ArpgAnimationSet_Ragnar_BroadSword extends R_ArpgAnimationSet_Ragnar;

static function Name GetStaticAttackAnimation(optional int Parameters)
{
	local Name AttackAnimations[3];

	AttackAnimations[0] = 'S3_StandingAttackA';
	AttackAnimations[1] = 'S3_StrafeRightAttack';
	AttackAnimations[2] = 'S3_StrafeLeftAttack';
	
	return AttackAnimations[Rand(ArrayCount(AttackAnimations))];
}

static function Name GetStaticPainAnimation(optional int Parameters)
{
	local Name PainAnimations[4];
	PainAnimations[0] = 'S3_painFront';
	PainAnimations[1] = 'S3_painBack';
	PainAnimations[2] = 'S3_painLeft';
	PainAnimations[3] = 'S3_painRight';
	return PainAnimations[Rand(ArrayCount(PainAnimations))];
}

defaultproperties
{
    Idle=S3_idle
    Forward=S3_Walk
    Backward=S3_Backup
    Forward45Right=S3_Walk45Right
    Forward45Left=S3_Walk45Left
    Backward45Right=S3_Backup45Right
    Backward45Left=S3_Backup45Left
    StrafeRight=S3_StrafeRight
    StrafeLeft=S3_StrafeLeft
    AttackMoving=S3_attackA
    AttackStanding=S3_attackA
}