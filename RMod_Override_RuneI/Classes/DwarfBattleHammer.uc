//=============================================================================
// DwarfBattleHammer.
//=============================================================================
class DwarfBattleHammer expands Hammer;

var bool bWasBloody;

//=============================================================================
//
// Powerup: StoneStatue
//
//=============================================================================
function PowerupInit()
{	
	SpawnPowerupEffect();
	SwipeClass = PoweredUpSwipeClass;
	DamageType='stone';
	ThrownDamageType='stone';
	if(SkelGroupSkins[1] == BloodTexture)
		bWasBloody = True;

	BloodTexture = None;	//Stop from placing blood texture while Powered-Up...
	SkelGroupSkins[0]=Texture'weapons.battlehammerBhammerstone';
    SkelGroupSkins[1]=Texture'weapons.battlehammerBhammerstone';
	bUnlit = true;
}

function PowerupEndingPulseOn()
{
	DesiredFatness = 140;
	DesiredColorAdjust.Z = 0;
	PlaySound(PoweredUpEndingSound, SLOT_None);
}

function PowerupEndingPulseOff()
{
	DesiredFatness = 128;
	DesiredColorAdjust.Z = 150;
}

function PowerupEnded()
{
	local int i;
	local debris StoneChunk;
	
	Super.PowerupEnded();
	DesiredColorAdjust.Z = 0;

	DamageType=Default.DamageType;
	ThrownDamageType=Default.ThrownDamageType;
	BloodTexture=Default.BloodTexture;
	SkelGroupSkins[0]=Default.SkelGroupSkins[0];

	if(bWasBloody)
		SkelGroupSkins[1]=BloodTexture;
	else
		SkelGroupSkins[1]=Default.SkelGroupSkins[1];

	bUnlit = false;

	for(i=0; i<15; i++)
	{
		StoneChunk = spawn(class'DebrisStone',,,GetJointPos(Rand(4)));
		StoneChunk.SetSize(0.2);
		StoneChunk.bUnlit = true;
	}
}

simulated function SpawnPowerupEffect()
{
	local EffectSkeleton ES;

	// Spawn an EffectSkeleton that will display all powered up effects
	ES = Spawn(class'EffectSkelStoneHammer', self);
	if (ES != None)
	{
		AttachActorToJoint(ES, 0);
	}
}

simulated function RemovePowerupEffect()
{
	local actor A;
	// Remove Effect skeleton
	A = DetachActorFromJoint(0);
	A.Destroy();
}

function int CalculateDamage(actor Victim)
{
	if (bPoweredUp && Victim.IsA('Pawn') && Pawn(Victim).CanBeStatued()
		&& !Victim.Region.Zone.bNeutralZone)
	{
		Pawn(Victim).PowerupStone(Pawn(Owner));
		return 0;
	}

	return Super.CalculateDamage(Victim);
}

defaultproperties
{
     bCrouchTwoHands=True
     StowMesh=1
     Damage=50
     BloodTexture=Texture'weapons.battlehammerBhammerblood'
     rating=4
     RunePowerRequired=75
     RunePowerDuration=15.000000
     PowerupMessage="Stone!"
     SweepVector=(Y=0.867000,Z=-0.500000)
     ThroughAir(0)=Sound'WeaponsSnd.Swings.swing03'
     ThroughAirBerserk(0)=Sound'WeaponsSnd.Swings.bswing10'
     HitFlesh(0)=Sound'WeaponsSnd.ImpFlesh.impfleshhammer01'
     HitWood(0)=Sound'WeaponsSnd.ImpWood.impactwood07'
     HitStone(0)=Sound'WeaponsSnd.ImpStone.impactstone13'
     HitMetal(0)=Sound'WeaponsSnd.ImpMetal.impactmetal14'
     HitDirt(0)=Sound'WeaponsSnd.ImpEarth.impactearth04'
     HitShield=Sound'WeaponsSnd.Shields.shield10'
     HitWeapon=Sound'WeaponsSnd.Swords.sword10'
     HitBreakableWood=Sound'WeaponsSnd.ImpWood.impactwood12'
     HitBreakableStone=Sound'WeaponsSnd.ImpStone.impactstone13'
     SheathSound=Sound'WeaponsSnd.Stows.xstow02'
     UnsheathSound=Sound'WeaponsSnd.Stows.xunstow02'
     ThrownSoundLOOP=Sound'WeaponsSnd.Throws.throw03L'
     PowerUpSound=Sound'WeaponsSnd.PowerUps.powerstart18'
     PoweredUpSoundLOOP=Sound'WeaponsSnd.PowerUps.power10L'
     PowerupIcon=Texture'RuneFX2.bhammer'
     PowerupIconAnim=Texture'RuneFX2.bhammer1a'
     PoweredUpSwipeClass=Class'RuneI.WeaponSwipeGray'
     A_Idle=H5_Idle
     A_Forward=walkforwardTwohands
     A_Backward=H5_Backup
     A_Forward45Right=H5_Walk45Right
     A_Forward45Left=H5_Walk45Left
     A_Backward45Right=H5_BackupRight
     A_Backward45Left=H5_BackupLeft
     A_StrafeRight=H5_StrafeRight
     A_StrafeLeft=H5_StrafeLeft
     A_Jump=H5_Jump
     A_AttackA=H5_attackA
     A_AttackAReturn=H5_attackAreturn
     A_AttackB=H5_attackB
     A_AttackBReturn=H5_attackBreturn
     A_AttackC=None
     A_AttackCReturn=None
     A_AttackStandA=H5_StandingattackA
     A_AttackStandAReturn=H5_StandingattackAreturn
     A_AttackStandB=H5_StandingattackB
     A_AttackStandBReturn=H5_StandingattackBReturn
     A_AttackBackupA=H5_Backupattack
     A_AttackBackupAReturn=None
     A_AttackStrafeRight=H5_StrafeRightAttack
     A_AttackStrafeLeft=H5_StrafeLeftAttack
     A_JumpAttack=H5_jumpattack
     A_Throw=H5_Throw
     A_Powerup=H5_Powerup
     A_Defend=None
     A_DefendIdle=None
     A_PainFront=H5_painFront
     A_PainBack=H5_painFront
     A_PainLeft=H5_painFront
     A_PainRight=H5_painFront
     A_PickupGroundLeft=H5_PickupLeft
     A_PickupHighLeft=H5_PickupLeftHigh
     A_Taunt=H5_Taunt
     A_PumpTrigger=H5_PumpTrigger
     A_LeverTrigger=H5_LeverTrigger
     PickupMessage="You now wield a Dwarven Battle Hammer"
     PickupSound=Sound'OtherSnd.Pickups.grab05'
     DropSound=Sound'WeaponsSnd.Drops.hammerdrop01'
     Mass=18.000000
     Skeletal=SkelModel'weapons.battlehammer'
     SkelGroupSkins(0)=Texture'weapons.battlehammerBhammer'
     SkelGroupSkins(1)=Texture'weapons.battlehammerBhammer'
     ShieldDamageMultiplier=2.0
}
