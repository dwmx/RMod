//=============================================================================
// SarkRagnar.
//=============================================================================
class SarkRagnar extends RunePlayer;

//============================================================
//
// PostBeginPlay
//
//============================================================

function PostBeginPlay()
{
	local actor f;

	Super.PostBeginPlay();

		f = Spawn(Class'SarkEyeRagnar');
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
			SkelGroupSkins[1] = Texture'players.RagnarRagsrk_bodypain';
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[13] = Texture'players.RagnarRagsrk_headpain';
			break;
		case BODYPART_LARM1:
			SkelGroupSkins[10] = Texture'players.RagnarRagsrk_armspain';
			SkelGroupSkins[11] = Texture'players.RagnarRagsrk_armspain';
			break;
		case BODYPART_RARM1:
			SkelGroupSkins[6] = Texture'players.RagnarRagsrk_armspain';
			SkelGroupSkins[7] = Texture'players.RagnarRagsrk_armspain';
			break;
		case BODYPART_LLEG1:
			SkelGroupSkins[3] = Texture'players.RagnarRagsrk_legspain';
			SkelGroupSkins[8] = Texture'players.RagnarRagsrk_legspain';
			break;
		case BODYPART_RLEG1:
			SkelGroupSkins[2] = Texture'players.RagnarRagsrk_legspain';
			SkelGroupSkins[4] = Texture'players.RagnarRagsrk_legspain';
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
		case 13:							return BODYPART_HEAD;
		case 10: 							return BODYPART_LARM1;
		case 6: case 14: case 15:			return BODYPART_RARM1;
		case 8:								return BODYPART_LLEG1;
		case 4:								return BODYPART_RLEG1;
		case 1: case 2: case 3: case 5: case 7: case 9: case 11:
		case 12:							return BODYPART_TORSO;
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
			SkelGroupSkins[5] = Texture'runefx.gore_bone';
			SkelGroupFlags[5] = SkelGroupFlags[5] & ~POLYFLAG_INVISIBLE;
			break;
		case BODYPART_HEAD:
			SkelGroupSkins[12] = Texture'runefx.gore_bone';
			SkelGroupFlags[12] = SkelGroupFlags[12] & ~POLYFLAG_INVISIBLE;
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
			return class'SarkRagnarArm';
		case BODYPART_HEAD:
			return class'SarkRagnarHead';
	}
	return None;
}


//===================================================================
//
// PainTimer
//
// SarkRagnar overrides PainTimer to control gaining health from
// LokiBlood pools
//===================================================================

function PainTimer()
{
	local int i;
	local int newHealth;
	local float depth;
	local vector loc;
	local LokiHealthTrail t;

	// Pain timer just expired:
	//  Check what zone I'm in (and which parts are)
	//  based on that cause damage, and reset PainTime

	if((Health < 0) || (Level.NetMode == NM_Client))
		return;
		
	if(FootRegion.Zone.bPainZone && FootRegion.Zone.bLokiBloodZone)
	{ // SarkRagnar is standing in a LokiBlood pool, try and give him health from it
		if(Health < MaxHealth)
		{
			newHealth = LokiBloodZone(FootRegion.Zone).ExtractHealth();
			if(newHealth > 0)
			{
				Health += newHealth;
				if(Health > MaxHealth)
					Health = MaxHealth;

				for(i = 0; i < 4; i++)
				{
					loc = vect(0, 0, 20);
					loc.Z += FRand() * 10;
					t = spawn(class'LokiHealthTrail', self,, Location - loc);			
					
					t.amplitude = 25;
					t.Velocity.X = 4 + i * 2.5;
					t.Velocity.Z = 60 + i * 10;
					t.LifeSpan = (5 - i) * 0.35;

					if(i == 0 || i == 2)
					{
						t.Velocity.X *= -1;
					}				
				}
			}
		}

		PainTime = 1.0;
		return;
	}

	Super.PainTimer();
}

//=============================================================================
//
// PlayTakeHit
//
//=============================================================================

function PlayTakeHit(float tweentime, int damage, vector HitLoc, name damageType, vector Momentum, int BodyPart)
{
	local float rnd;
	local float time;

	rnd = FClamp(Damage, 10, 40);
	if ( damageType == 'burned' )
		ClientFlash( -0.009375 * rnd, rnd * vect(16.41, 11.719, 4.6875));
	else if ( damageType == 'corroded' )
		ClientFlash( -0.01171875 * rnd, rnd * vect(9.375, 14.0625, 4.6875));
	else if ( damageType == 'drowned' )
		ClientFlash(-0.390, vect(312.5,468.75,468.75));
	else 
		ClientFlash( -0.017 * rnd, rnd * vect(20, 4, 20)); // Purplish flash

	time = 0.15 + 0.005 * Damage;
	ShakeView(time, Damage * 10, time * 0.5);

	Super.PlayTakeHit(tweentime, damage, HitLoc, damageType, Momentum, BodyPart);
}

defaultproperties
{
     ExploreSpeed=472.000000
     CombatSpeed=337.000000
     Die4=Sound'CreaturesSnd.Ragnar.ragsarkdeath04'
     JumpGruntSound(1)=Sound'CreaturesSnd.Ragnar.ragsarkjump02'
     FallingDeathSound=Sound'CreaturesSnd.Ragnar.ragsarkland02'
     FallingScreamSound=Sound'CreaturesSnd.Ragnar.ragsarkfall01'
     HitSoundLow(0)=Sound'CreaturesSnd.Ragnar.ragsarkhit01'
     HitSoundLow(1)=Sound'CreaturesSnd.Ragnar.ragsarkhit02'
     HitSoundLow(2)=Sound'CreaturesSnd.Ragnar.ragsarkhit03'
     HitSoundMed(0)=Sound'CreaturesSnd.Ragnar.ragsarkhit04'
     HitSoundMed(1)=Sound'CreaturesSnd.Ragnar.ragsarkhit05'
     HitSoundMed(2)=Sound'CreaturesSnd.Ragnar.ragsarkhit06'
     HitSoundHigh(0)=Sound'CreaturesSnd.Ragnar.ragsarkhit07'
     HitSoundHigh(1)=Sound'CreaturesSnd.Ragnar.ragsarkhit08'
     HitSoundHigh(2)=Sound'CreaturesSnd.Ragnar.ragsarkhit09'
     BerserkSoundStart=Sound'CreaturesSnd.Ragnar.ragsarkberstart'
     BerserkSoundEnd=Sound'CreaturesSnd.Ragnar.ragsarkberend'
     BerserkSoundLoop=Sound'CreaturesSnd.Ragnar.ragsarkberzerkL'
     BerserkYellSound(0)=Sound'CreaturesSnd.Ragnar.ragsarkattack01'
     BerserkYellSound(1)=Sound'CreaturesSnd.Ragnar.ragsarkattack02'
     BerserkYellSound(2)=Sound'CreaturesSnd.Ragnar.ragsarkattack03'
     BerserkYellSound(3)=Sound'CreaturesSnd.Ragnar.ragsarkattack04'
     BerserkYellSound(4)=Sound'CreaturesSnd.Ragnar.ragsarkattack05'
     BerserkYellSound(5)=Sound'CreaturesSnd.Ragnar.ragsarkattack06'
     GroundSpeed=384.000000
     JumpZ=650.000000
     BaseEyeHeight=45.000000
     EyeHeight=45.000000
     Health=50
     Die=Sound'CreaturesSnd.Ragnar.ragsarkdeath01'
     Die2=Sound'CreaturesSnd.Ragnar.ragsarkdeath02'
     Die3=Sound'CreaturesSnd.Ragnar.ragsarkdeath03'
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
     bNet=False
     DrawScale=1.500000
     CollisionRadius=27.000000
     CollisionHeight=63.000000
     SkelMesh=24
     SkelGroupSkins(0)=Texture'Players.RagnarRagsrk_arms'
     SkelGroupSkins(1)=Texture'Players.RagnarRagsrk_body'
     SkelGroupSkins(2)=Texture'Players.RagnarRagsrk_legs'
     SkelGroupSkins(3)=Texture'Players.RagnarRagsrk_legs'
     SkelGroupSkins(4)=Texture'Players.RagnarRagsrk_legs'
     SkelGroupSkins(5)=Texture'Players.RagnarRagsrk_arms'
     SkelGroupSkins(6)=Texture'Players.RagnarRagsrk_arms'
     SkelGroupSkins(7)=Texture'Players.RagnarRagsrk_arms'
     SkelGroupSkins(8)=Texture'Players.RagnarRagsrk_legs'
     SkelGroupSkins(9)=Texture'Players.RagnarRagsrk_arms'
     SkelGroupSkins(10)=Texture'Players.RagnarRagsrk_arms'
     SkelGroupSkins(11)=Texture'Players.RagnarRagsrk_arms'
     SkelGroupSkins(12)=Texture'Players.RagnarRagsrk_arms'
     SkelGroupSkins(13)=Texture'Players.RagnarRagsrk_head'
     SkelGroupSkins(14)=Texture'Players.RagnarRagsrk_arms'
     SkelGroupSkins(15)=Texture'Players.RagnarRagsrk_arms'
}
