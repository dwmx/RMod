//=============================================================================
// Torch.
//=============================================================================
class Torch expands NonStow;


var Actor TorchFire;
var() bool bIgnitedAtStartup;
var float DouseTime;
var() int HitCount; // Number of hits before the torch goes out
var(Sounds) sound IgniteSound;
var(Sounds) sound ExtinguishSound;

//=============================================================================
//
// Ignite
//
//=============================================================================
function Ignite()
{
	if (Region.Zone.bWaterZone)
		return;

	// Spawn fire on the torch
	TorchFire = Spawn(class'torchfire',,, GetJointPos(JointNamed('offset')),);
	PlaySound(IgniteSound, SLOT_Interface);

	// If Torches are stasis, the player can smack a wall and cause the particles to
	// "freeze" in space
	if(GetStateName() == 'Active')
		TorchFire.bStasis = false;
	
	AttachActorToJoint(TorchFire, JointNamed('offset'));
	
	SkelGroupSkins[1] = texture'torchtorchburn'; // Flaming torch

	DamageType = 'fire';
	bUnlit = true;
	ScaleGlow = 2.0;
	HitCount = 3.0;
	DouseTime = 0.0;

	// Reset weapon anims
	A_Idle = Default.A_Idle;
    A_Forward = Default.A_Forward;
    A_Backward = Default.A_Backward;
    A_Backward45Right = Default.A_Backward45Right;
    A_Backward45Left = Default.A_Backward45Left;
    A_StrafeRight = Default.A_StrafeRight;
    A_StrafeLeft = Default.A_StrafeLeft;
	A_Forward45Right = Default.A_Forward45Right;
	A_Forward45Left = Default.A_Forward45Left;
	A_AttackA = Default.A_AttackA;
	A_AttackStrafeRight = Default.A_AttackStrafeRight;
	A_AttackStrafeLeft = Default.A_AttackStrafeLeft;
	A_AttackStandA = Default.A_AttackStandA;
	A_AttackStandAReturn = Default.A_AttackStandAReturn;
	A_AttackStandB = Default.A_AttackStandB;
	A_AttackStandBReturn = Default.A_AttackStandBReturn;
	A_AttackBackupA = Default.A_AttackBackupA;
	A_AttackBackupAReturn = Default.A_AttackBackupAReturn;
	A_Defend = Default.A_Defend;
	A_DefendIdle= Default.A_DefendIdle;
	A_LeverTrigger = Default.A_LeverTrigger;
	A_Taunt = Default.A_Taunt;

    LightType=LT_Steady;
    LightEffect=LE_None;
    LightBrightness=240;
    LightHue=20;
    LightSaturation=20;
    LightRadius=16;

	// Put light on the torchfire as well, to 2x brighten the torch
    TorchFire.LightType=LT_Steady;
    TorchFire.LightEffect=LE_None;
    TorchFire.LightBrightness=240;
    TorchFire.LightHue=20;
    TorchFire.LightSaturation=20;
    TorchFire.LightRadius=16;
}


//=============================================================================
//
// Douse
//
//=============================================================================

function Tick(float DeltaSeconds)
{
	local float adjust;

	if(DouseTime > 0)
	{
		DouseTime -= DeltaSeconds;
		if(DouseTime <= 0)
		{
			PlaySound(ExtinguishSound, SLOT_Interface);

//			SkelGroupSkins[1] = None; // Normal torch
			bUnlit = false;
			ScaleGlow = 0.1; // Burned out torch look
			Disable('Tick');
			LightType=LT_None;
			LightEffect=LE_None;
			LightBrightness=0;
			LightRadius=0;
			A_Idle = 't_outidle';
			A_Forward = 'S1_Walk';
			A_Backward = 'weapon1_backup';
			A_Forward45Right = 'S1_walk45Right';
			A_Forward45Left = 'S1_walk45Left';
			A_Backward45Right = 'weapon1_backup45Right';
			A_Backward45Left = 'weapon1_backup45Left';
			A_StrafeRight = 'StrafeRight';
			A_StrafeLeft = 'StrafeLeft';
			A_Jump = 'MOV_ALL_jump1_AA0S';
			A_AttackA = 'weapon1_attackA';
			A_AttackStrafeRight = 'S3_StrafeRightAttack';
			A_AttackStrafeLeft = 'S3_StrafeLeftAttack';
			A_AttackStandA = 'T_OUTStandingAttackA';
			A_AttackStandAReturn = 'T_OUTStandingAttackAReturn';
			A_AttackStandB = 'None';
			A_AttackStandBReturn = 'None';
			A_AttackBackupA = 'H3_BackupAttackA';
			A_AttackBackupAReturn = 'H3_BackupAttackAReturn';
			A_Defend = 'T_OUTDefendTO';
			A_DefendIdle= 'T_OUTDefendIdle';
			A_LeverTrigger = 'T_OutLeverTrigger';
			A_Taunt = 'T_OUTTaunt';
		}
		else
		{
			adjust = DouseTime / 4.0; // div by default dousetime
			ScaleGlow = 0.5 + 1.5 * adjust; 
			LightRadius = 16 * adjust;
		}
	}
}

function Douse()
{
	local actor fire;

	if (ActorAttachedTo(JointNamed('offset')) != None)
	{
		DetachActorFromJoint(JointNamed('offset'));
		TorchFire.Destroy();
		TorchFire = None;
		DamageType = 'blunt';
//		SkelGroupSkins[1] = None; // Normal torch
//		bUnlit = false;
//		ScaleGlow = 1.0;
		DouseTime = 4.0;
		Enable('Tick');
	}
}


//=============================================================================
//
// PostBeginPlay
//
//=============================================================================
function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (bIgnitedAtStartup)
		Ignite();
}

//=============================================================================
//
// FindFire
//
// Locates the nearest source of fire for relighting the torch
//
// Checks for particle fire directly in front of the player
//=============================================================================

function bool FindFire(out vector fireLoc)
{
	local Fire F;
	local vector v1, v2;
	local float dp;

	foreach Owner.RadiusActors(class'fire', F, 100, Owner.Location)
	{
		fireLoc = F.Location;
		return(true);
	}
	
	return(false);
}

//=============================================================================
//
// GetLightAnim
//
// Returns the necessary animation (and sets anim blend) for Torch relighting
//=============================================================================

function name GetLightAnim(Actor Other, vector fireLoc)
{
	local float deltaZ;
	local name anim;

	if(Owner == None)
		return('T_Lite');
	
	deltaZ = (fireLoc.Z - Owner.Location.Z);

	if(deltaZ <= -35)
	{ // On the ground, no blend
		return('T_LightLow');
	}
	else if(deltaZ >= 65)
	{ // Overhead, no blend
		return('T_Lite');
	}
	else
	{ // Blend to fit the desired pickup location
		if(deltaZ < 35)
		{
			Owner.BlendAnimSequence = 'T_LightLow';
			Owner.BlendAnimAlpha = -(deltaZ - 35) / 70;
		}
		else
		{
			Owner.BlendAnimSequence = 'T_Lite';
			Owner.BlendAnimAlpha = (deltaZ - 35) / 30;
		}

		if(Owner.AnimProxy != None)
		{
			Owner.AnimProxy.BlendAnimSequence = Owner.BlendAnimSequence;
			Owner.AnimProxy.BlendAnimAlpha = Owner.BlendAnimAlpha;
		}
		
		return('T_LightMed'); // return medium, mid ranges are blended
	}
}

//=============================================================================
//
// UseTrigger
//
//=============================================================================

function bool UseTrigger(Actor Other)
{
	local RunePlayer p;
	local vector v;
	local vector fireLoc;
	
	if(Other == Owner && TorchFire == None)
	{
		if(Owner.IsA('RunePlayer') && Owner.Physics == PHYS_Walking
			&& (Owner.Velocity.X * Owner.Velocity.X + Owner.Velocity.Y * Owner.Velocity.Y < 1000)
			&& FindFire(fireLoc))
		{ // Only allow the ignite if standing still
			p = RunePlayer(Owner);
			p.PlayUninterruptedAnim(GetLightAnim(Other, fireLoc));		
			return true;
		}
		else
		{
			return false;
		}
	}
	return false;
}

//=============================================================================
//
// InventorySpecial1
//
// Generic Inventory function (called from an animation notify)
//
// For the torch, this notify ignites the torch
//=============================================================================

function InventorySpecial1()
{
	Ignite();
}

//=============================================================================
//
// ZoneChange
//
//=============================================================================
function ZoneChange(ZoneInfo newZone)
{
	if ( newZone.bWaterZone )
	{
		Douse();
	}
}


//=============================================================================
//
// SpawnHitEffect
//
// Spawns an effect based upon what was struck
//=============================================================================
function SpawnHitEffect(vector HitLoc, vector HitNorm, int LowMask, int HighMask, Actor HitActor)
{	
	local int i,j;
	local EMatterType matter;

	// Determine what kind of matter was hit
	if ((HitActor.Skeletal != None) && (LowMask!=0 || HighMask!=0))
	{
		for (j=0; j<HitActor.NumJoints(); j++)
		{
			if (((j <  32) && ((LowMask  & (1 <<  j      )) != 0)) ||
				((j >= 32) && (j < 64) && ((HighMask & (1 << (j - 32))) != 0)) )
			{	// Joint j was hit
				matter = HitActor.MatterForJoint(j);
				break;
			}
		}
	}
	else if(HitActor.IsA('LevelInfo') && TorchFire != None)
	{ // Leave a char mark on the wall if the torch is lit
		matter = HitActor.MatterTrace(HitLoc, Owner.Location, WeaponSweepExtent);
		Spawn(class'DecalChar',,,, rotator(HitNorm));
	}
	else
	{
		matter = HitActor.MatterForJoint(0);
	}

	// Create effects
	PlayHitMatterSound(matter);

	if (matter != MATTER_NONE)
	{
		HitNorm.Z += 0.65;
		Spawn(class'Sparks',,, HitLoc, rotator(HitNorm));
	}

	if(TorchFire != None)
	{
		HitCount--;
		if(HitCount <= 0)
		{
			Douse();
		}
	}	
}

state Active
{
	function BeginState()
	{
		Super.BeginState();

		// If Torches are stasis, the player can smack a wall and cause the particles to
		// "freeze" in space
		if(TorchFire != None)
			TorchFire.bStasis = false;
	}
}

defaultproperties
{
     bIgnitedAtStartup=True
     HitCount=3
     IgniteSound=Sound'EnvironmentalSnd.Fire.fireignite01'
     ExtinguishSound=Sound'EnvironmentalSnd.Fire.fireignite07'
     Damage=10
     DamageType=Blunt
     rating=1
     ThroughAir(0)=Sound'EnvironmentalSnd.Fire.fireignite09'
     ThroughAir(1)=Sound'EnvironmentalSnd.Fire.fireignite03'
     ThroughAir(2)=Sound'EnvironmentalSnd.Fire.fireignite09'
     HitFlesh(0)=Sound'EnvironmentalSnd.Fire.fireignite04'
     HitWood(0)=Sound'EnvironmentalSnd.Fire.fireignite04'
     HitStone(0)=Sound'EnvironmentalSnd.Fire.fireignite04'
     HitMetal(0)=Sound'EnvironmentalSnd.Fire.fireignite04'
     HitDirt(0)=Sound'EnvironmentalSnd.Fire.fireignite04'
     HitShield=Sound'EnvironmentalSnd.Fire.fireignite04'
     HitWeapon=Sound'EnvironmentalSnd.Fire.fireignite04'
     HitBreakableWood=Sound'EnvironmentalSnd.Fire.fireignite04'
     HitBreakableStone=Sound'EnvironmentalSnd.Fire.fireignite04'
     A_Idle=T_Idle
     A_Forward=T_Walk
     A_Backward=T_backup
     A_Forward45Right=T_walk45right
     A_Forward45Left=T_walk45left
     A_Backward45Right=T_backup45Right
     A_Backward45Left=T_backup45Left
     A_StrafeRight=T_StrafeRight
     A_StrafeLeft=T_StrafeLeft
     A_AttackA=T_AttackA
     A_AttackAReturn=T_AttackAreturn
     A_AttackB=T_AttackB
     A_AttackBReturn=T_AttackBreturn
     A_AttackStandA=T_Standingattack
     A_AttackStandAReturn=None
     A_AttackBackupA=T_BackupAttack
     A_AttackBackupAReturn=None
     A_AttackStrafeRight=T_Standingattack
     A_AttackStrafeLeft=T_Standingattack
     A_Defend=T_DefendTo
     A_DefendIdle=T_Defendidle
     A_Taunt=T_Taunt
     A_LeverTrigger=T_LeverTrigger
     bExpireWhenTossed=False
     PickupMessage="You wield a torch"
     DropSound=Sound'EnvironmentalSnd.Fire.torchdrop'
     SoundRadius=11
     CollisionHeight=3.000000
     Buoyancy=2.500000
     Skeletal=SkelModel'objects.Torch'
}
