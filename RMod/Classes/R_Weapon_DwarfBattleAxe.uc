class R_Weapon_DwarfBattleAxe extends R_AWeapon_Axe;

//=============================================================================
//
// Powerup: Gib Damage
//
//=============================================================================
function PowerupInit()
{   
    SpawnPowerupEffect();
    SwipeClass = PoweredUpSwipeClass;
    DesiredColorAdjust.X = 140;
}

function PowerupEndingPulseOn()
{
    DesiredFatness = 140;
    DesiredColorAdjust.X = 0;
    DesiredColorAdjust.Y = 0;
    DesiredColorAdjust.Z = 0;
    PlaySound(PoweredUpEndingSound, SLOT_None);
}

function PowerupEndingPulseOff()
{
    DesiredFatness = 128;
    DesiredColorAdjust.X = 140;
    DesiredColorAdjust.Y = 80;
    DesiredColorAdjust.Z = 80;
}

function PowerupEnded()
{
    Super.PowerupEnded();
    DesiredColorAdjust.X = 0;
    DesiredColorAdjust.Y = 0;
    DesiredColorAdjust.Z = 0;
}


simulated function SpawnPowerupEffect()
{
    local EffectSkeleton ES;

    // Spawn an EffectSkeleton that will display all powered up effects
    ES = Spawn(class'EffectSkelGibAxe', self);
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
    local int dam;

    dam = Super.CalculateDamage(Victim);

    if(bPoweredUp && dam != 0)
    {
        if (ScriptPawn(Victim)!=None && ScriptPawn(Victim).bIsBoss)
            return dam;

        dam = 1000;
    }

    return(dam);
}

defaultproperties
{
     StowMesh=1
     Damage=40
     BloodTexture=Texture'weapons.BattleAxeD_Battle_axeblood'
     rating=4
     RunePowerRequired=100
     RunePowerDuration=15.000000
     PowerupMessage="Super Damage!"
     ThroughAir(0)=Sound'WeaponsSnd.Swings.swing02'
     ThroughAirBerserk(0)=Sound'WeaponsSnd.Swings.bswing15'
     HitFlesh(0)=Sound'WeaponsSnd.ImpFlesh.impfleshaxe01'
     HitWood(0)=Sound'WeaponsSnd.ImpWood.impactwood06'
     HitStone(0)=Sound'WeaponsSnd.ImpStone.impactstone05'
     HitMetal(0)=Sound'WeaponsSnd.ImpMetal.impactcombo02'
     HitDirt(0)=Sound'WeaponsSnd.ImpEarth.impactearth05'
     HitShield=Sound'WeaponsSnd.Shields.shield15'
     HitWeapon=Sound'WeaponsSnd.Swords.sword15'
     HitBreakableWood=Sound'WeaponsSnd.ImpWood.impactwood12'
     HitBreakableStone=Sound'WeaponsSnd.ImpStone.impactstone13'
     SheathSound=Sound'WeaponsSnd.Stows.xstow06'
     UnsheathSound=Sound'WeaponsSnd.Stows.xunstow06'
     ThrownSoundLOOP=Sound'WeaponsSnd.Throws.throw03L'
     PowerUpSound=Sound'WeaponsSnd.PowerUps.powerstart22'
     PoweredUpSoundLOOP=Sound'WeaponsSnd.PowerUps.power39L'
     PowerupIcon=Texture'RuneFX2.baxe'
     PowerupIconAnim=Texture'RuneFX2.baxe1a'
     PoweredUpSwipeClass=Class'RuneI.WeaponSwipeRed'
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
     A_AttackA=X5_attackA
     A_AttackAReturn=X5_attackAreturn
     A_AttackB=X5_attackB
     A_AttackBReturn=X5_attackBreturn
     A_AttackC=None
     A_AttackCReturn=None
     A_AttackStandA=X5_StandingattackA
     A_AttackStandAReturn=X5_StandingattackAreturn
     A_AttackStandB=X5_StandingattackB
     A_AttackStandBReturn=X5_StandingattackBreturn
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
     A_Taunt=x5_taunt
     A_PumpTrigger=H5_PumpTrigger
     A_LeverTrigger=H5_LeverTrigger
     PickupMessage="You possess a Dwarven Battle Axe"
     PickupSound=Sound'OtherSnd.Pickups.grab05'
     DropSound=Sound'WeaponsSnd.Drops.axedrop01'
     Mass=18.000000
     Skeletal=SkelModel'weapons.BattleAxe'
     SkelGroupSkins(0)=Texture'weapons.BattleAxesigaxe'
     SkelGroupSkins(1)=Texture'weapons.BattleAxesigaxe'
}