//=============================================================================
// Berserker.
//=============================================================================
class Berserker expands Viking;

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
			SkelGroupSkins[4] = Texture'players.ragnarb_bodypain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[1] = Texture'players.ragnarb_headpain';
			SkelGroupSkins[2] = Texture'players.ragnarb_headpain';
			SkelGroupSkins[3] = Texture'players.ragnarb_headpain';
			SkelGroupSkins[7] = Texture'players.ragnarb_headpain';
			SkelGroupSkins[14] = Texture'players.ragnarb_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[11] = Texture'players.ragnarb_armspain';
			SkelGroupSkins[13] = Texture'players.ragnarb_armspain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[10] = Texture'players.ragnarb_armspain';
			SkelGroupSkins[12] = Texture'players.ragnarb_armspain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[6] = Texture'players.ragnarb_legpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[5] = Texture'players.ragnarb_legpain';
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
		case 1: case 2: case 3: case 14:	return BODYPART_HEAD;
		case 13:							return BODYPART_LARM1;
		case 12:							return BODYPART_RARM1;
		case 6:								return BODYPART_LLEG1;
		case 5:								return BODYPART_RLEG1;
		case 4: case 7: case 8: case 9:
		case 10: case 11: case 15:			return BODYPART_TORSO;
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
	{
		case BODYPART_LARM1:
			SkelGroupSkins[9] = Texture'runefx.gore_bone';
			SkelGroupFlags[9] = SkelGroupFlags[9] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[8] = Texture'runefx.gore_bone';
			SkelGroupFlags[8] = SkelGroupFlags[8] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[15] = Texture'players.ragnarb_neckgore';
			SkelGroupFlags[15] = SkelGroupFlags[15] & ~POLYFLAG_INVISIBLE;
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
			return class'BerserkerLArm';
		case BODYPART_RARM1:
			return class'BerserkerRArm';
		case BODYPART_HEAD:
			return class'BerserkerHead';
			break;
	}

	return None;
}

//============================================================
//
// CanPickup
//
// Let's pawn dictate what it can pick up
//============================================================
function bool CanPickup(Inventory item)
{
	if (Health <= 0)
		return false;

	if (item.IsA('Weapon') && (BodyPartHealth[BODYPART_RARM1] > 0) && (Weapon == None))
	{
		return (item.IsA('axe') || item.IsA('hammer') || item.IsA('Sword') || item.IsA('Torch'));
	}
	else if (item.IsA('Shield') && (BodyPartHealth[BODYPART_LARM1] > 0) && (Shield == None))
	{
		return false;
	}
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
	}

Fight:
	if ( !ValidEnemy() )
		Goto('BackFromSubState');

	GetEnemyProximity();
	
	// Attack if close enough
	if(Weapon != None && InMeleeRange(Enemy) || (EnemyMovement == MOVE_CLOSER && EnemyDist < MeleeRange * 2.5))
	{
		WeaponActivate();
		Weapon.EnableSwipeTrail();

		PlayAnim(Weapon.A_AttackA, 1.0, 0.1);
		FinishAnim();

		if(Weapon.A_AttackB != 'None' && FRand() < 0.75)
		{
			ClearSwipeArray();
			PlayAnim(Weapon.A_AttackB, 1.0, 0.01);
			FinishAnim();

			if(Weapon.A_AttackC != 'None' && FRand() < 0.5)
			{
				ClearSwipeArray();
				PlayAnim(Weapon.A_AttackC, 1.0, 0.01);
				FinishAnim();
				
				WeaponDeactivate();

				if(Weapon.A_AttackCReturn != 'None')
				{
					PlayAnim(Weapon.A_AttackCReturn, 1.0, 0.1);
					FinishAnim();
				}
			}
			else
			{ // B-Return
				WeaponDeactivate();

				if(Weapon.A_AttackBReturn != 'None')
				{
					PlayAnim(Weapon.A_AttackBReturn, 1.0, 0.1);
					FinishAnim();
				}
			}
		}
		else
		{ // A-Return
			WeaponDeactivate();

			if(Weapon.A_AttackAReturn != 'None')
			{
				PlayAnim(Weapon.A_AttackAReturn, 1.0, 0.1);
				FinishAnim();
			}
		}

		Weapon.DisableSwipeTrail();		
		Sleep(TimeBetweenAttacks);
	}
	if(InCombatRange(Enemy))
	{
		Sleep(0.05);
		Goto('Begin');
	}

}

defaultproperties
{
     AcquireSound=Sound'CreaturesSnd.Vikings.berzerksee01'
     AmbientWaitSounds(0)=Sound'CreaturesSnd.Vikings.berzerkambient01'
     AmbientWaitSounds(1)=Sound'CreaturesSnd.Vikings.berzerkambient02'
     AmbientWaitSounds(2)=Sound'CreaturesSnd.Vikings.berzerkambient03'
     AmbientFightSounds(0)=Sound'CreaturesSnd.Vikings.berzerkattack01'
     AmbientFightSounds(1)=Sound'CreaturesSnd.Vikings.berzerkattack02'
     AmbientFightSounds(2)=Sound'CreaturesSnd.Vikings.berzerkattack03'
     AmbientWaitSoundDelay=10.000000
     AmbientFightSoundDelay=6.000000
     StartShield=None
     CombatRange=1.000000
     GroundSpeed=300.000000
     WalkingSpeed=150.000000
     Health=150
     BodyPartHealth(1)=125
     BodyPartHealth(3)=125
     BodyPartHealth(5)=100
     HitSound1=Sound'CreaturesSnd.Vikings.berzerkhit01'
     HitSound2=Sound'CreaturesSnd.Vikings.berzerkhit02'
     HitSound3=Sound'CreaturesSnd.Vikings.berzerkhit03'
     Die=Sound'CreaturesSnd.Vikings.berzerkdeath01'
     Die2=Sound'CreaturesSnd.Vikings.berzerkdeath02'
     Die3=Sound'CreaturesSnd.Vikings.berzerkdeath03'
     LandGrunt=Sound'CreaturesSnd.Vikings.berzerkhit01'
}
