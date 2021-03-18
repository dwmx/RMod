//=============================================================================
// LokiGuard.
//=============================================================================
class LokiGuard expands Viking;

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
			SkelGroupSkins[2] = Texture'players.ragnarlg_bodypain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[10] = Texture'players.ragnarlg_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[8] = Texture'players.ragnarlg_armpain';
			SkelGroupSkins[11] = Texture'players.ragnarlg_armpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[5] = Texture'players.ragnarlg_armpain';
			SkelGroupSkins[4] = Texture'players.ragnarlg_armpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[3] = Texture'players.ragnarlg_legpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[1] = Texture'players.ragnarlg_legpain';
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
		case 10:							return BODYPART_HEAD;
		case 11:							return BODYPART_LARM1;
		case 4: 							return BODYPART_RARM1;
		case 3:								return BODYPART_LLEG1;
		case 1:								return BODYPART_RLEG1;
		case 2: case 5: case 6: case 7:
			case 8: case 9: 				return BODYPART_TORSO;
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
			SkelGroupSkins[12] = Texture'runefx.gore_bone';
			SkelGroupFlags[12] = SkelGroupFlags[12] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[7] = Texture'runefx.gore_bone';
			SkelGroupFlags[7] = SkelGroupFlags[7] & ~POLYFLAG_INVISIBLE;
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
			return class'GuardLArm';
		case BODYPART_RARM1:
			return class'GuardRArm';
		case BODYPART_HEAD:
			return class'GuardHead';
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
		//arms
		SkelGroupSkins[1] = texture'statues.lg_rckleg';
		SkelGroupSkins[3] = texture'statues.lg_rckleg';

		//legs
		SkelGroupSkins[4] = texture'statues.lg_rckarm';
		SkelGroupSkins[11] = texture'statues.lg_rckarm';

		//body
		SkelGroupSkins[2] = texture'statues.lg_rckbody';
		SkelGroupSkins[5] = texture'statues.lg_rckbody';
		SkelGroupSkins[6] = texture'statues.lg_rckbody';
		SkelGroupSkins[7] = texture'statues.lg_rckbody';
		SkelGroupSkins[8] = texture'statues.lg_rckbody';
		SkelGroupSkins[9] = texture'statues.lg_rckbody';

		//head
		SkelGroupSkins[10] = texture'statues.lg_rckhead';
	}
}

defaultproperties
{
     AcquireSound=Sound'CreaturesSnd.Vikings.dark2attack03'
     AmbientWaitSounds(0)=Sound'CreaturesSnd.Vikings.dark2ambient01'
     AmbientWaitSounds(1)=Sound'CreaturesSnd.Vikings.vike1see01'
     AmbientWaitSounds(2)=Sound'CreaturesSnd.Vikings.vike1breath02'
     AmbientFightSounds(0)=Sound'CreaturesSnd.Vikings.dark2attack01'
     AmbientFightSounds(1)=Sound'CreaturesSnd.Vikings.dark2see01'
     AmbientFightSounds(2)=Sound'CreaturesSnd.Vikings.dark2ambient01'
     AmbientWaitSoundDelay=10.000000
     AmbientFightSoundDelay=7.000000
     HitSound1=Sound'CreaturesSnd.Vikings.guardhit01'
     HitSound2=Sound'CreaturesSnd.Vikings.guardhit02'
     HitSound3=Sound'CreaturesSnd.Vikings.guardhit03'
     Die=Sound'CreaturesSnd.Vikings.guarddeath01'
     Die2=Sound'CreaturesSnd.Vikings.guarddeath02'
     Die3=Sound'CreaturesSnd.Vikings.guarddeath03'
     MaxMouthRot=7000
     MaxMouthRotRate=65535
     SkelMesh=5
}
