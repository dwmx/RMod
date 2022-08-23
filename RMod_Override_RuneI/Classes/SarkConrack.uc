//=============================================================================
// SarkConrack.
//=============================================================================
class SarkConrack expands Sark;


//============================================================
//
// PostBeginPlay
//
//============================================================

function PostBeginPlay()
{
	local actor f;

	Super.PostBeginPlay();

	f = Spawn(Class'SarkEyeConrack');
	AttachActorToJoint(f, JointNamed('head'));
}

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
		case BODYPART_TORSO:
			SkelGroupSkins[3] = Texture'players.Ragnarsc_torsopain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[2] = Texture'players.Ragnarsc_head';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[6] = Texture'players.ragnarsc_armlegpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[7] = Texture'players.ragnarsc_armlegpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[1] = Texture'players.ragnarsc_armlegpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[1] = Texture'players.ragnarsc_armlegpain';
			break;
	}
	return None;
}

//============================================================
//
// BodyPartForPolyGroup
//
//============================================================
function int BodyPartForPolyGroup(int polygroup)
{
	switch(polygroup)
	{
		case 2:						return BODYPART_HEAD;
		case 8:						return BODYPART_LARM1;
		case 9:						return BODYPART_RARM1;
		case 1:						return BODYPART_LLEG1;
		case 1:						return BODYPART_RLEG1;
		case 4: case 5: case 10:	// Gore caps
		case 8: case 9:			// Arm stubs
		case 3:						return BODYPART_TORSO;
	}
	return BODYPART_BODY;
}

//============================================================
//
// ApplyGoreCap
//
//============================================================
function ApplyGoreCap(int BodyPart)
{
	switch(BodyPart)
	{	// no gore caps exist
		case BODYPART_LARM1:
			SkelGroupSkins[4] = Texture'runefx.gore_bone';
			SkelGroupFlags[4] = SkelGroupFlags[8] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[5] = Texture'runefx.gore_bone';
			SkelGroupFlags[5] = SkelGroupFlags[7] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[10] = Texture'runefx.gore_bone';
			SkelGroupFlags[10] = SkelGroupFlags[4] & ~POLYFLAG_INVISIBLE;
			break;
	}
}

//================================================
//
// SeveredLimbClass
//
//================================================
function class<Actor> SeveredLimbClass(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_LARM1:
		case BODYPART_RARM1:
			return class'SarkConArm';
		case BODYPART_HEAD:
			return class'SarkConHead';
	}

	return None;
}

//===================================================================
//
// PlayDeath
//
// SarkConrack is a special character who is fought only once in the game
// and he should NOT play a death animation, instead he plays a pain anim
//===================================================================
function PlaySkewerDeath(name DamageType) { PlayDeath(DamageType); }

function PlayDeath(name DamageType)           
{ 
	PlayAnim('cine_Loki_kneelonhands', 1.0, 0.1);
}

//------------------------------------------------------------
//
// CanGotoPainState
//
//------------------------------------------------------------

function bool CanGotoPainState()
{
	return(false);
}

//================================================
//
// Fighting
//
//================================================
State Fighting
{
ignores EnemyAcquired;

	// Determine AttackAction based upon enemy movement and position
	function Timer()
	{
		GetEnemyProximity();

		LastAction = AttackAction;
				
		if(EnemyMovement == MOVE_STRAFE_LEFT && FRand() < 0.65 && CheckStrafeLeft())
		{
			AttackAction = AA_STRAFE_LEFT;
		}
		else if(EnemyMovement == MOVE_STRAFE_RIGHT && FRand() < 0.65 && CheckStrafeRight())
		{
			AttackAction = AA_STRAFE_RIGHT;
		}
		else if(FRand() < 0.08 && Physics == PHYS_Walking && CheckJumpLocation())
		{ // Sark jump
			AttackAction = AA_JUMP;
		}
		else if(EnemyMovement == MOVE_STANDING && FRand() < 0.9 || FRand() < 0.35)
		{
			AttackAction = AA_LUNGE;
		}		
	 	else if(FRand() < 0.9)
	 	{
	 		if(FRand() < 0.5 && LastAction != AA_STRAFE_RIGHT || LastAction == AA_STRAFE_LEFT
				&& CheckStrafeLeft())
	 		{
	 			AttackAction = AA_STRAFE_LEFT;
	 		}
	 		else if(LastAction != AA_STRAFE_LEFT || LastAction == AA_STRAFE_RIGHT && CheckStrafeRight())
	 		{
	 			AttackAction = AA_STRAFE_RIGHT;
	 		}
			else
			{
				AttackAction = AA_WAIT;
			}
	 	}
		else
		{
			AttackAction = AA_WAIT;
		}
		
/*	
		if (ShouldDefend())
		{
			GotoState('Fighting', 'Defend');
		}
*/		
	}
		
Fight:
	if(!ValidEnemy())
		Goto('BackFromSubState');

	GetEnemyProximity();
	
	// Attack if close enough
	if(Weapon != None && InMeleeRange(Enemy) || (EnemyMovement == MOVE_CLOSER && EnemyDist < MeleeRange * 2.5))
	{
		PlayAnim(Weapon.A_AttackA, 1.5, 0.1);
		Sleep(0.1);
		WeaponActivate();
		Weapon.EnableSwipeTrail();
		FinishAnim();

		if(Weapon.A_AttackB != 'None' && FRand() < 0.7)
		{
			PlayAnim(Weapon.A_AttackB, 1.5, 0.01);
			if(Enemy != None)
				TurnToward(Enemy);
			FinishAnim();

			// B-Return
			WeaponDeactivate();

			if(Weapon.A_AttackBReturn != 'None')
			{
				PlayAnim(Weapon.A_AttackBReturn, 1.5, 0.1);
				FinishAnim();
			}
		}
		else
		{ // A-Return
			WeaponDeactivate();

			if(Weapon.A_AttackAReturn != 'None')
			{
				PlayAnim(Weapon.A_AttackAReturn, 1.5, 0.1);
				FinishAnim();
			}
		}

		Weapon.DisableSwipeTrail();

		Sleep(TimeBetweenAttacks);
	}
	else if(AttackAction == AA_LUNGE)
	{ // Random lunge
		PlayMoving();
		bStopMoveIfCombatRange = false;
		MoveTo(Enemy.Location - VecToEnemy * MeleeRange, MovementSpeed);
		bStopMoveIfCombatRange = true;
	}
	else if(AttackAction == AA_STRAFE_LEFT)
	{ // Strafe - Position is calculated in Timer, when the strafe is chosen
		PlayStrafeLeft();
		bStopMoveIfCombatRange = false;
		StrafeFacing(Destination, Enemy);
		bStopMoveIfCombatRange = true;
	}
	else if(AttackAction == AA_STRAFE_RIGHT)
	{ // Strafe - Position is calculated in Timer, when the strafe is chosen
		PlayStrafeRight();
		bStopMoveIfCombatRange = false;
		StrafeFacing(Destination, Enemy);
		bStopMoveIfCombatRange = true;
	}
	else if(AttackAction == AA_JUMP)
	{
		PlayFlip(0.1);
		Sleep(0.4); // Sleep for a bit before making the leap
		PlaySound(JumpSound);
		CalcJumpVelocity();
		WaitForLanding();

		RotateSark();
		PlayAnim('sark_land', 1.0, 0.0);
		if(Enemy != None)
			TurnToward(Enemy);
		FinishAnim();
	}
	else
	{
		PlayWaiting();
	}

	if(InCombatRange(Enemy))
	{
		Sleep(0.05);
		Goto('Begin');
	}
	
BackFromSubState:
	GotoState('Charging', 'ResumeFromFighting');
}

//------------------------------------------------
//
// JointDamaged
//
//------------------------------------------------
function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	local bool rtn;
	local int healthBefore, healthAfter;
	local ParticleSystem S;

	healthBefore = Health;
	rtn = Super.JointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, joint);
	healthAfter = Health;

	if(healthBefore >= 500 && healthAfter < 500 && Weapon != None)
	{ // Change his sword and up the damage it does
		Weapon.Damage = Weapon.Damage * 2;

		for(i = 2; i < 6; i++)
		{
			S = Spawn(class'RespawnFire');
			if(S != None)
			{
				S.bSystemOneShot = false;
				S.bOneShot = false;
				S.ScaleMax = 0.8;
				S.ScaleMin = 0.6;
				S.LifeSpanMax = 0.5;
				S.LifeSpanMin = 0.3;
				S.ShapeVector = vect(6, 6, 6);

				Weapon.AttachActorToJoint(S, i);			
			}
		}
	}

	return(rtn);
}

//===================================================================
//
// Scripting
//
//===================================================================

state Scripting
{
	function AmbientSoundTimer()
	{ // Don't play any ambient sounds while scripting
	}
}

function Died(pawn Killer, name damagetype, vector HitLocation)
{
	local int joint;
	local actor S;

	if(Weapon != None)
	{
		for(joint = 2; joint < 6; joint++)
		{
			S = Weapon.DetachActorFromJoint(joint);
			if(S != None)
				S.Destroy();
		}				
	}

	Super.Died(Killer, damageType, HitLocation);
}

//================================================
//
// Dying
//
//================================================

state Dying
{
	function BeginState()
	{
		local int joint;
		local vector X, Y, Z;

		// Drop any stowed weapons
		if(StowWeapon != None)
		{		
			switch(StowWeapon.MeleeType)
			{
			case MELEE_SWORD:
				joint = JointNamed('attatch_sword');
				break;
			case MELEE_AXE:
				joint = JointNamed('attach_axe');
				break;
			case MELEE_AXE:
				joint = JointNamed('attach_hammer');
				break;
			default:
				// Unknown or non-stow item
				return;
			}

			DetachActorFromJoint(joint);
				
			GetAxes(Rotation, X, Y, Z);
			StowWeapon.DropFrom(GetJointPos(joint));
		
			StowWeapon.SetPhysics(PHYS_Falling);
			StowWeapon.Velocity = Y * 100 + X * 75;
			StowWeapon.Velocity.Z = 50;
			
			StowWeapon.GotoState('Drop');
			StowWeapon.DisableSwipeTrail();

			StowWeapon = None; // Remove the StowWeapon from the actor
		}		
	}
		
begin:
	PlayDeath('');
}

defaultproperties
{
     JumpSound=Sound'CreaturesSnd.Sark.sark3jump01'
     AcquireSound=Sound'CreaturesSnd.Sark.sark1see'
     AmbientWaitSounds(0)=Sound'CreaturesSnd.Vikings.conrak2ambient01'
     AmbientWaitSounds(1)=Sound'CreaturesSnd.Vikings.conrak2ambient02'
     AmbientWaitSounds(2)=Sound'CreaturesSnd.Vikings.conrak2ambient03'
     AmbientFightSounds(0)=Sound'CreaturesSnd.Vikings.conrak2attack01'
     AmbientFightSounds(1)=Sound'CreaturesSnd.Vikings.conrak2attack02'
     AmbientFightSounds(2)=Sound'CreaturesSnd.Vikings.conrak2attack03'
     AmbientWaitSoundDelay=8.000000
     AmbientFightSoundDelay=5.000000
     bIsBoss=True
     StartWeapon=Class'RuneI.DwarfWorkSword'
     StartShield=Class'RuneI.DwarfBattleShield'
     MeleeRange=70.000000
     GroundSpeed=400.000000
     HitSound1=Sound'CreaturesSnd.Vikings.conrak2hit01'
     HitSound2=Sound'CreaturesSnd.Vikings.conrak2hit02'
     HitSound3=Sound'CreaturesSnd.Vikings.conrak2hit03'
     Die=Sound'CreaturesSnd.Vikings.conrak2death01'
     Die2=Sound'CreaturesSnd.Vikings.conrak2death02'
     Die3=Sound'CreaturesSnd.Vikings.conrak2death03'
     LandSoundWood=Sound'CreaturesSnd.Sark.sarkland02'
     LandSoundMetal=Sound'CreaturesSnd.Sark.sarkland02'
     LandSoundStone=Sound'CreaturesSnd.Sark.sarkland02'
     LandSoundFlesh=Sound'CreaturesSnd.Sark.sarkland02'
     LandSoundIce=Sound'CreaturesSnd.Sark.sarkland02'
     LandSoundSnow=Sound'CreaturesSnd.Sark.sarkland02'
     LandSoundEarth=Sound'CreaturesSnd.Sark.sarkland02'
     LandSoundWater=Sound'CreaturesSnd.Sark.sarkland02'
     LandSoundMud=Sound'CreaturesSnd.Sark.sarkland02'
     LandSoundLava=Sound'CreaturesSnd.Sark.sarkland02'
     MaxMouthRot=7000
     MaxMouthRotRate=65535
     DrawScale=1.750000
     CollisionRadius=36.000000
     CollisionHeight=69.000000
     SkelMesh=16
     SkelGroupSkins(0)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(1)=Texture'Players.Ragnarsc_armleg'
     SkelGroupSkins(2)=Texture'Players.Ragnarsc_head'
     SkelGroupSkins(3)=Texture'Players.Ragnarsc_torso'
     SkelGroupSkins(4)=Texture'Players.Ragnarsc_armleg'
     SkelGroupSkins(5)=Texture'Players.Ragnarsc_armleg'
     SkelGroupSkins(6)=Texture'Players.Ragnarsc_armleg'
     SkelGroupSkins(7)=Texture'Players.Ragnarsc_armleg'
     SkelGroupSkins(8)=Texture'Players.Ragnarsc_armleg'
     SkelGroupSkins(9)=Texture'Players.Ragnarsc_armleg'
     SkelGroupSkins(10)=Texture'Players.Ragnarsc_torso'
}
