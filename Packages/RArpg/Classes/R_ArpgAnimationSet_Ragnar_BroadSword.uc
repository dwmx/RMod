class R_ArpgAnimationSet_Ragnar_BroadSword extends R_ArpgAnimationSet;

function Name GetAttackAnimation()
{
	local Name AttackAnimations[3];

	AttackAnimations[0] = 'S3_StandingAttackA';
	AttackAnimations[1] = 'S3_StrafeRightAttack';
	AttackAnimations[2] = 'S3_StrafeLeftAttack';
	
	return AttackAnimations[Rand(ArrayCount(AttackAnimations))];
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