class R_Weapon_VikingAxe extends R_AWeapon_Axe;

//=============================================================================
//
// Powerup: Friendly
//
//=============================================================================
function PowerupInit()
{   
    SpawnPowerupEffect();
    SwipeClass = PoweredUpSwipeClass;
    DesiredColorAdjust.Z = 140;
}

function PowerupEndingPulseOn()
{
    DesiredFatness = 140;
    DesiredColorAdjust.Y = 0;
    DesiredColorAdjust.Z = 0;
    PlaySound(PoweredUpEndingSound, SLOT_None);
}

function PowerupEndingPulseOff()
{
    DesiredFatness = 128;
    DesiredColorAdjust.Y = 80;
    DesiredColorAdjust.Z = 80;
}

function PowerupEnded()
{
    Super.PowerupEnded();
    DesiredColorAdjust.Y = 0;
    DesiredColorAdjust.Z = 0;
}


simulated function SpawnPowerupEffect()
{
    local EffectSkeleton ES;

    // Spawn an EffectSkeleton that will display all powered up effects
    ES = Spawn(class'EffectSkelEmpathyAxe', self);
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
    if(bPoweredUp && Pawn(Victim) != None && Level.NetMode == NM_StandAlone)
    {   // Make non-boss scriptpawns friendly towards you (only in Single-player)
        Pawn(Victim).PowerupFriend(Pawn(Owner));
        Spawn(class'EmpathyFlash',,,Location,);
        return 0;
    }

    return(Super.CalculateDamage(Victim));
}

defaultproperties
{
     StowMesh=1
     Damage=20
     BloodTexture=Texture'weapons.VikingAxeAxeskinblood'
     rating=2
     RunePowerRequired=50
     RunePowerDuration=15.000000
     PowerupMessage="Ally!"
     ThroughAir(0)=Sound'WeaponsSnd.Swings.swing11'
     ThroughAirBerserk(0)=Sound'WeaponsSnd.Swings.bswing13'
     HitFlesh(0)=Sound'WeaponsSnd.ImpFlesh.impfleshaxe05'
     HitWood(0)=Sound'WeaponsSnd.ImpWood.impactwood05'
     HitStone(0)=Sound'WeaponsSnd.ImpIce.impactice02'
     HitMetal(0)=Sound'WeaponsSnd.ImpMetal.impactmetal04'
     HitDirt(0)=Sound'WeaponsSnd.ImpEarth.impactearth01'
     HitIce(0)=Sound'WeaponsSnd.ImpIce.impactice02'
     HitShield=Sound'WeaponsSnd.Shields.shield13'
     HitWeapon=Sound'WeaponsSnd.Swords.sword13'
     HitBreakableWood=Sound'WeaponsSnd.ImpWood.impactwood12'
     HitBreakableStone=Sound'WeaponsSnd.ImpStone.impactstone11'
     SheathSound=Sound'WeaponsSnd.Stows.xstow05'
     UnsheathSound=Sound'WeaponsSnd.Stows.xunstow05'
     PowerUpSound=Sound'WeaponsSnd.PowerUps.powerstart12'
     PoweredUpSoundLOOP=Sound'WeaponsSnd.PowerUps.power44L'
     PitchDeviation=0.080000
     PowerupIcon=Texture'RuneFX2.vaxe'
     PowerupIconAnim=Texture'RuneFX2.vaxe1a'
     PoweredUpSwipeClass=Class'RuneI.WeaponSwipeGray'
     A_Idle=S2_idle
     A_AttackA=X3_attackA
     A_AttackAReturn=X3_attackAreturn
     A_AttackB=X3_attackB
     A_AttackBReturn=X3_attackBreturn
     A_AttackC=X3_attackC
     A_AttackCReturn=X3_attackCreturn
     A_AttackStandA=X3_StandingAttackA
     A_AttackStandAReturn=X3_StandingAttackAReturn
     A_AttackStandB=X3_StandingAttackB
     A_AttackStandBReturn=X3_StandingAttackBReturn
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
     A_Taunt=X3_Taunt
     A_PumpTrigger=S2_PumpTrigger
     A_LeverTrigger=S2_LeverTrigger
     PickupMessage="You are armed with a Viking Axe"
     PickupSound=Sound'OtherSnd.Pickups.grab03'
     DropSound=Sound'WeaponsSnd.Drops.axedrop03'
     CollisionRadius=22.000000
     Mass=14.000000
     Skeletal=SkelModel'weapons.VikingAxe'
     SkelGroupSkins(0)=Texture'weapons.VikingAxeAxeskin'
     SkelGroupSkins(1)=Texture'weapons.VikingAxeAxeskin'
}