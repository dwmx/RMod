//=============================================================================
// SarkSword.
//=============================================================================
class SarkSword expands Sark;


//============================================================
//
// PostBeginPlay
//
//============================================================

function PostBeginPlay()
{
	local actor f;

	Super.PostBeginPlay();

	f = Spawn(Class'SarkEyeSword');
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
		case 1: case 12:		return BODYPART_LLEG1;
		case 2: case 13:		return BODYPART_RLEG1;
		case 4: case 11:		return BODYPART_LARM1;
		case 9: case 14:		return BODYPART_RARM1;
		case 3: case 5:	case 6:
		case 7: case 8: case 10:
		case 0:					return BODYPART_TORSO;
		case 15:				return BODYPART_HEAD;
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
			SkelGroupSkins[6] = Texture'runefx.gore_bone';
			SkelGroupFlags[6] = SkelGroupFlags[6] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[8] = Texture'runefx.gore_bone';
			SkelGroupFlags[8] = SkelGroupFlags[8] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[10] = Texture'runefx.gore_bone';
			SkelGroupFlags[10] = SkelGroupFlags[10] & ~POLYFLAG_INVISIBLE;
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
			return class'SarkSwordArm';
		case BODYPART_HEAD:
			return class'SarkSwordHead';
	}
	return None;
}

defaultproperties
{
     JumpSound=Sound'CreaturesSnd.Sark.sark2jump01'
     AcquireSound=Sound'CreaturesSnd.Sark.sark2see'
     AmbientWaitSounds(0)=Sound'CreaturesSnd.Sark.sark2ambient01'
     AmbientWaitSounds(1)=Sound'CreaturesSnd.Sark.sark2ambient02'
     AmbientWaitSounds(2)=Sound'CreaturesSnd.Sark.sark2ambient03'
     AmbientFightSounds(0)=Sound'CreaturesSnd.Sark.sark2attack01'
     AmbientFightSounds(1)=Sound'CreaturesSnd.Sark.sark2attack02'
     AmbientFightSounds(2)=Sound'CreaturesSnd.Sark.sark2attack03'
     AmbientWaitSoundDelay=8.000000
     AmbientFightSoundDelay=7.000000
     StartWeapon=Class'RuneI.DwarfBattleSword'
     Health=300
     HitSound1=Sound'CreaturesSnd.Sark.sark2hit01'
     HitSound2=Sound'CreaturesSnd.Sark.sark2hit02'
     HitSound3=Sound'CreaturesSnd.Sark.sark2hit03'
     Die=Sound'CreaturesSnd.Sark.sark2death01'
     Die2=Sound'CreaturesSnd.Sark.sark2death02'
     Die3=Sound'CreaturesSnd.Sark.sark2death03'
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
     SkelMesh=14
     SkelGroupSkins(0)=Texture'Players.Ragnarsw_armor'
     SkelGroupSkins(1)=Texture'Players.Ragnarsw_armleg'
     SkelGroupSkins(2)=Texture'Players.Ragnarsw_armleg'
     SkelGroupSkins(3)=Texture'Players.Ragnarsw_torso'
     SkelGroupSkins(4)=Texture'Players.Ragnarsw_armleg'
     SkelGroupSkins(5)=Texture'Players.Ragnarsw_armleg'
     SkelGroupSkins(6)=Texture'Players.Ragnarsw_torso'
     SkelGroupSkins(7)=Texture'Players.Ragnarsw_armleg'
     SkelGroupSkins(8)=Texture'Players.Ragnarsw_torso'
     SkelGroupSkins(9)=Texture'Players.Ragnarsw_armleg'
     SkelGroupSkins(10)=Texture'Players.Ragnarsw_torso'
     SkelGroupSkins(11)=Texture'Players.Ragnarsw_armor'
     SkelGroupSkins(12)=Texture'Players.Ragnarsw_armor'
     SkelGroupSkins(13)=Texture'Players.Ragnarsw_armor'
     SkelGroupSkins(14)=Texture'Players.Ragnarsw_armor'
     SkelGroupSkins(15)=Texture'Players.Ragnarsw_head'
}
