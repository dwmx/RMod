//=============================================================================
// DarkViking.
//=============================================================================
class DarkViking expands Viking;

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
			SkelGroupSkins[2] = Texture'players.ragnardv_bodypain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[3] = Texture'players.ragnardv_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[10] = Texture'players.ragnardv_armlegpain';
			SkelGroupSkins[12] = Texture'players.ragnardv_armlegpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[7] = Texture'players.ragnardv_armlegpain';
			SkelGroupSkins[11] = Texture'players.ragnardv_armlegpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[1] = Texture'players.ragnardv_armlegpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[4] = Texture'players.ragnardv_armlegpain';
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
		case 3: case 5:						return BODYPART_HEAD;
		case 12:							return BODYPART_LARM1;
		case 11:							return BODYPART_RARM1;
		case 1:								return BODYPART_LLEG1;
		case 4:								return BODYPART_RLEG1;
		case 2: case 6: case 7: case 8: 
			case 9:	case 10: 				return BODYPART_TORSO;
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
			SkelGroupSkins[6] = Texture'runefx.gore_bone';
			SkelGroupFlags[6] = SkelGroupFlags[6] & ~POLYFLAG_INVISIBLE;
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
			return class'DarkVikingLArm';
		case BODYPART_RARM1:
			return class'DarkVikingRArm';
		case BODYPART_HEAD:
			return class'DarkVikingHead';
			break;
	}

	return None;
}


//================================================
//
// Statue
//
//================================================
State() Statue
{
ignores HearNoise, EnemyAcquired, Bump;

	function CreatureStatue()
	{
		//armleg
		SkelGroupSkins[1] = texture'statues.dv_rockarmleg';
		SkelGroupSkins[4] = texture'statues.dv_rockarmleg';
		SkelGroupSkins[11] = texture'statues.dv_rockarmleg';
		SkelGroupSkins[12] = texture'statues.dv_rockarmleg';

		//body
		SkelGroupSkins[2] = texture'statues.dv_rockbody';
		SkelGroupSkins[6] = texture'statues.dv_rockbody';
		SkelGroupSkins[7] = texture'statues.dv_rockbody';		//?? (arm?)
		SkelGroupSkins[8] = texture'statues.dv_rockbody';
		SkelGroupSkins[9] = texture'statues.dv_rockbody';
		SkelGroupSkins[10] = texture'statues.dv_rockbody';		//?? (arm?)

		//head
		SkelGroupSkins[3] = texture'statues.dv_rockhead';
		SkelGroupSkins[5] = texture'statues.dv_rockhead';
	}
}

defaultproperties
{
     StartStowWeapon=None
     FightOrDefend=0.000000
     LatOrVertDodge=0.500000
     LungeRange=0.000000
     AcquireSound=Sound'CreaturesSnd.Vikings.dark2see01'
     AmbientWaitSounds(0)=Sound'CreaturesSnd.Vikings.dark2ambient01'
     AmbientWaitSounds(1)=Sound'CreaturesSnd.Vikings.vike1breath01'
     AmbientWaitSounds(2)=Sound'CreaturesSnd.Vikings.vike1breath02'
     AmbientFightSounds(0)=Sound'CreaturesSnd.Vikings.vike1attack01'
     AmbientFightSounds(1)=Sound'CreaturesSnd.Vikings.vike1attack02'
     AmbientFightSounds(2)=Sound'CreaturesSnd.Vikings.vike1attack03'
     AmbientWaitSoundDelay=11.000000
     AmbientFightSoundDelay=8.000000
     StartWeapon=Class'RuneI.VikingAxe'
     StartShield=Class'RuneI.VikingShield'
     CombatRange=200.000000
     MaxStepHeight=25.000000
     HitSound1=Sound'CreaturesSnd.Vikings.vike1hit01'
     HitSound2=Sound'CreaturesSnd.Vikings.vike1hit02'
     HitSound3=Sound'CreaturesSnd.Vikings.vike1hit03'
     Die=Sound'CreaturesSnd.Vikings.guarddeath01'
     Die2=Sound'CreaturesSnd.Vikings.guarddeath02'
     Die3=Sound'CreaturesSnd.Vikings.guarddeath03'
     SkelMesh=1
}
