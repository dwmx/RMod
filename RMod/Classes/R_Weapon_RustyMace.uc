class R_Weapon_RustyMace extends R_AWeapon_Hammer;

var(Sounds) Sound PoweredUpFireSound;
//=============================================================================
//
// PowerupInit
//
//=============================================================================

function PowerupInit()
{
    Super.PowerupInit();

    DesiredColorAdjust.Z = 128;
}

//=============================================================================
//
// PowerupEndingPulseOn
//
//=============================================================================

function PowerupEndingPulseOn()
{
    DesiredFatness = 140;
    DesiredColorAdjust.Z = 0;
    PlaySound(PoweredUpEndingSound, SLOT_None);
}

//=============================================================================
//
// PowerupEndingPulseOff
//
//=============================================================================

function PowerupEndingPulseOff()
{
    DesiredFatness = 128;
    DesiredColorAdjust.Z = 128;
}

//=============================================================================
//
// PowerupEnded
//
//=============================================================================

function PowerupEnded()
{
    Super.PowerupEnded();

    DesiredColorAdjust.Z = 0;
}   

simulated function SpawnPowerupEffect()
{
    local EffectSkeleton ES;

    // Spawn an EffectSkeleton that will display all powered up effects
    ES = Spawn(class'EffectSkelBlast', self);
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

//=============================================================================
//
// Powerup: BlastRadius
//
// This function is called when the weapon is initially powered up
//=============================================================================

function WeaponFire(int SwingCount)
{
    local BlastRadius B;
    local vector loc;

    if (bPoweredUp && (SwingCount == 0 || SwingCount == 2))
    {
        loc = Owner.Location - vect(0, 0, 10);
        B = Spawn(class'BlastRadius',,, loc, rotator(vect(0,0,1)));
        B.Instigator = Pawn(Owner);
        PlaySound(PoweredUpFireSound, SLOT_Interface);
    }
}

defaultproperties
{
     PoweredUpFireSound=Sound'WeaponsSnd.PowerUps.ascifi05'
     StowMesh=1
     Damage=15
     BloodTexture=Texture'weapons.RustyMacerusty_maceblood'
     RunePowerRequired=25
     RunePowerDuration=15.000000
     PowerupMessage="Blast!"
     ThroughAir(0)=Sound'WeaponsSnd.Swings.swing06'
     ThroughAirBerserk(0)=Sound'WeaponsSnd.Swings.bswing06'
     HitFlesh(0)=Sound'WeaponsSnd.ImpFlesh.impfleshclub02'
     HitWood(0)=Sound'WeaponsSnd.ImpWood.impactwood16'
     HitStone(0)=Sound'WeaponsSnd.ImpStone.impactstone18'
     HitMetal(0)=Sound'WeaponsSnd.ImpMetal.impactmetal01'
     HitDirt(0)=Sound'WeaponsSnd.ImpEarth.impactearth02'
     HitIce(0)=Sound'WeaponsSnd.ImpStone.impactstone18'
     HitShield=Sound'WeaponsSnd.Shields.shield06'
     HitWeapon=Sound'WeaponsSnd.Swords.sword06'
     HitBreakableWood=Sound'WeaponsSnd.ImpWood.impactwood12'
     HitBreakableStone=Sound'WeaponsSnd.ImpStone.impactstone11'
     SheathSound=Sound'WeaponsSnd.Stows.xstow01'
     UnsheathSound=Sound'WeaponsSnd.Stows.xunstow01'
     ThrownSoundLOOP=Sound'WeaponsSnd.Throws.throw01L'
     PowerUpSound=Sound'WeaponsSnd.PowerUps.powerstart35'
     PoweredUpSoundLOOP=Sound'WeaponsSnd.PowerUps.power22L'
     PitchDeviation=0.070000
     PowerupIcon=Texture'RuneFX2.rmace'
     PowerupIconAnim=Texture'RuneFX2.rmace1a'
     PoweredUpSwipeClass=Class'RuneI.WeaponSwipeBlue'
     A_Idle=S2_idle
     A_AttackA=H1_attackA
     A_AttackAReturn=H1_attackAReturn
     A_AttackB=H1_attackB
     A_AttackBReturn=H1_AttackBReturn
     A_AttackC=H1_attackC
     A_AttackCReturn=H1_AttackCReturn
     A_AttackStandA=H1_StandingAttackA
     A_AttackStandAReturn=H1_StandingAttackAreturn
     A_AttackStandB=H1_StandingAttackB
     A_AttackStandBReturn=H1_StandingAttackBreturn
     A_AttackBackupB=S1_BackupAttackB
     A_AttackBackupBReturn=S1_BackupAttackBReturn
     A_AttackStrafeRight=H1_StrafeRightAttack
     A_AttackStrafeLeft=H1_StrafeLeftAttack
     A_Throw=S2_Throw
     A_Powerup=s2_powerup
     A_Defend=S2_DefendTo
     A_DefendIdle=S2_DefendIdle
     A_PainFront=S2_painFront
     A_PainRight=S1_painBack
     A_PickupGroundLeft=S2_PickupLeft
     A_PickupHighLeft=S2_PickupLeftHigh
     A_Taunt=H1_Taunt
     A_PumpTrigger=S2_PumpTrigger
     A_LeverTrigger=S2_LeverTrigger
     PickupMessage="You have found a Rusty Mace"
     PickupSound=Sound'OtherSnd.Pickups.grab01'
     DropSound=Sound'WeaponsSnd.Drops.hammerdrop05'
     Skeletal=SkelModel'weapons.RustyMace'
     SkelGroupSkins(0)=Texture'weapons.RustyMacerusty_mace'
     SkelGroupSkins(1)=Texture'weapons.RustyMacerusty_mace'
}