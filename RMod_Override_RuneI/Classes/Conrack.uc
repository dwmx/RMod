//=============================================================================
// Conrack.
//=============================================================================
class Conrack expands Viking;


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
			SkelGroupSkins[1] = Texture'players.ragnarcon_chestpain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[11] = Texture'players.ragnarcon_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[10] = Texture'players.ragnarcon_armlegpain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[5] = Texture'players.ragnarcon_armlegpain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[2] = Texture'players.ragnarcon_armlegpain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[3] = Texture'players.ragnarcon_armlegpain';
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
		case 11:					return BODYPART_HEAD;
		case 10:					return BODYPART_LARM1;
		case 5:						return BODYPART_RARM1;
		case 2:						return BODYPART_LLEG1;
		case 3:						return BODYPART_RLEG1;
		case 4: case 7: case 8:	// Gore caps
		case 6: case 9:			// Arm stubs
		case 1:						return BODYPART_TORSO;
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
			SkelGroupSkins[8] = Texture'runefx.gore_bone';
			SkelGroupFlags[8] = SkelGroupFlags[8] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[7] = Texture'runefx.gore_bone';
			SkelGroupFlags[7] = SkelGroupFlags[7] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[4] = Texture'runefx.gore_bone';
			SkelGroupFlags[4] = SkelGroupFlags[4] & ~POLYFLAG_INVISIBLE;
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
			return class'ConrackLArm';
		case BODYPART_RARM1:
			return class'ConrackRArm';
		case BODYPART_HEAD:
			return class'ConrackHead';
			break;
	}

	return None;
}

//===================================================================
//
// PlayDeath
//
// Conrack is a special character who is fought only once in the game
// and he should NOT play a death animation, instead he plays a pain anim
// (the actual death sequence is handled in a cinematic)
//===================================================================
function PlaySkewerDeath(name DamageType) { PlayDeath(DamageType); }

function PlayDeath(name DamageType)           
{ 
	PlayFrontHit(0.1);
}

defaultproperties
{
     AcquireSound=Sound'CreaturesSnd.Vikings.conrakambient02'
     AmbientWaitSounds(0)=Sound'CreaturesSnd.Vikings.conrakambient01'
     AmbientWaitSounds(1)=Sound'CreaturesSnd.Vikings.conrakambient02'
     AmbientWaitSounds(2)=Sound'CreaturesSnd.Vikings.conrakambient03'
     AmbientFightSounds(0)=Sound'CreaturesSnd.Vikings.conrakattack01'
     AmbientFightSounds(1)=Sound'CreaturesSnd.Vikings.conrakattack02'
     AmbientFightSounds(2)=Sound'CreaturesSnd.Vikings.conrakattack03'
     AmbientWaitSoundDelay=9.000000
     AmbientFightSoundDelay=6.000000
     bIsBoss=True
     CarcassType=None
     Health=400
     BodyPartHealth(1)=9999
     BodyPartHealth(3)=9999
     BodyPartHealth(5)=9999
     bGibbable=False
     HitSound1=Sound'CreaturesSnd.Vikings.conrakhit01'
     HitSound2=Sound'CreaturesSnd.Vikings.conrakhit02'
     HitSound3=Sound'CreaturesSnd.Vikings.conrakhit03'
     Die=Sound'CreaturesSnd.Vikings.conrakdeath01'
     Die2=Sound'CreaturesSnd.Vikings.conrakdeath02'
     Die3=Sound'CreaturesSnd.Vikings.conrakdeath03'
     MaxMouthRot=7000
     MaxMouthRotRate=65535
     SkelMesh=3
     SkelGroupSkins(0)=Texture'Players.Ragnarcon_armleg'
     SkelGroupSkins(1)=Texture'Players.Ragnarcon_chest'
     SkelGroupSkins(2)=Texture'Players.Ragnarcon_armleg'
     SkelGroupSkins(3)=Texture'Players.Ragnarcon_armleg'
     SkelGroupSkins(4)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(5)=Texture'Players.Ragnarcon_armleg'
     SkelGroupSkins(6)=Texture'Players.Ragnarcon_armleg'
     SkelGroupSkins(7)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(8)=Texture'Players.Ragnarragd_arms'
     SkelGroupSkins(9)=Texture'Players.Ragnarcon_armleg'
     SkelGroupSkins(10)=Texture'Players.Ragnarcon_armleg'
     SkelGroupSkins(11)=Texture'Players.Ragnarcon_head'
}
