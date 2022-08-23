//=============================================================================
// SnowBeastChained.
//=============================================================================
class SnowBeastChained expands SnowBeast;


/*	DESCRIPTION:
		This version is chained up until freed by destroying chains.
*/

//var PlayerPawn thePlayer;


//============================================================
//
// PainSkin
//
// returns the pain skin for a given polygroup
//============================================================
function Texture PainSkin(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_HEAD:
			SkelGroupSkins[1] = Texture'creatures.snowbeasttb_bodypain';
			SkelGroupSkins[8] = Texture'creatures.snowbeasttb_bodypain';
			SkelGroupSkins[4] = Texture'creatures.snowbeasttb_bodypain';//teeth
			SkelGroupSkins[5] = Texture'creatures.snowbeasttb_bodypain';
			break;
		case BODYPART_TORSO:
			SkelGroupSkins[3] = Texture'creatures.snowbeasttb_bodypain';
			SkelGroupSkins[6] = Texture'creatures.snowbeasttb_bodypain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[10] = Texture'creatures.snowbeasttb_armlegpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[9] = Texture'creatures.snowbeasttb_armlegpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[7] = Texture'creatures.snowbeasttb_armlegpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[2] = Texture'creatures.snowbeasttb_armlegpain';
			break;
	}
	return None;
}

function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	return false;
}

/*
Scripting now being used
State() ChainedUp
{
ignores KilledBy, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, LongFall, PainTimer, CheckForEnemies;

	function BeginState()
	{
		SetTimer(0.5, false);
		SpeechTime=0.5;
	}

	function EndState()
	{
		SetTimer(0, false);
		SpeechTime=0;
		SetMovementPhysics();
	}

	function WeaponActivate()
	{
		Jaws.StartAttack();
	}

	function WeaponDeactivate()
	{
		Jaws.FinishAttack();
	}

	function SpeechTimer()
	{
		switch(Rand(3))
		{
		case 0:
			LookToward(GetJointPos(JointNamed('lwrist')),true);
			break;
		case 1:	// Can't turn head this far
			LookToward(GetJointPos(JointNamed('rwrist')),true);
			break;
		case 2:
			LookAt(thePlayer, true);
			break;
		}
		SpeechTime = RandRange(0.25, 2);
	}

	function SeePlayer(actor seen)
	{
		if (PlayerPawn(seen)!=None)
			theplayer = PlayerPawn(seen);

		Super.SeePlayer(seen);
	}

	function Timer()
	{
		if (Enemy != None)
		{
			GotoState('ChainedUp', 'Angry');
		}
		SetTimer(RandRange(0.2, 5.0), false);
	}

	function EnemyAcquired()
	{
		LookAt(Enemy);
	}

	function EnemyNotVisible()
	{
		Enemy = None;
	}

	function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
	{
		GotoState('ChainedUp', 'Cower');
		return false;
	}

	function bool DamageBodyPart(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType, int bodypart)
	{
		GotoState('ChainedUp', 'Angry');
		return Super.DamageBodyPart(Damage, EventInstigator, HitLocation, Momentum, DamageType, BodyPart);
	}

Cower:
	LoopAnim('cower', 1.0, 0.1);
	Sleep(2.0);
	FinishAnim();
	Goto('Wait');

Angry:
	if (ActorInSector(Enemy, ANGLE_45))
	{	// Straight ahead
		PlayBite();
		FinishAnim();
	}
	else
	{	// Roar
	}
	Goto('Wait');

Begin:
Wait:
	PlayWaiting(0.2);
}
*/

defaultproperties
{
     bIsBoss=True
     ReducedDamageType=All
     AttitudeToPlayer=ATTITUDE_Ignore
     bRotateTorso=False
     SkelMesh=2
}
