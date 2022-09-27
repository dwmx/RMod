class R_Weapon_RomanSword extends R_AWeapon_Sword;

//=============================================================================
//
// Powerup: FireSword
//
// This function is called when the weapon is initially powered up
//=============================================================================

function PowerupInit()
{
    SpawnPowerupEffect();
    SwipeClass = PoweredUpSwipeClass;
    DamageType='fire';
    ThrownDamageType='fire';
}

function PowerupEndingPulseOn()
{
    PlaySound(PoweredUpEndingSound, SLOT_None);
}

function PowerupEndingPulseOff()
{
}

function PowerupEnded()
{
    local int i;
    local actor fire;
    
    Super.PowerupEnded();

    DamageType=Default.DamageType;
    ThrownDamageType=Default.ThrownDamageType;
}

simulated function SpawnPowerupEffect()
{
    local EffectSkeleton ES;

    // Spawn an EffectSkeleton that will display all powered up effects
    ES = Spawn(class'EffectSkelFlameSword', self);
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
    local bool bCollisionJoints;
    local int i;

    dam = Super.CalculateDamage(Victim);

    if(bPoweredUp)
    {
        if (Pawn(Victim)!=None)
        {
            if(Victim.IsA('ScriptPawn') && !ScriptPawn(Victim).bIsBoss)
            {
                Pawn(Victim).PowerupFire(Pawn(Owner));
                dam *= 2;
            }
        }
        else
        {
            for (i=0; i<Victim.NumJoints(); i++)
            {
                if ((Victim.JointFlags[i] & JOINT_FLAG_COLLISION)!=0)
                {
                    bCollisionJoints = true;
                    Victim.SetOnFire(Pawn(Owner), i);
                }
            }
            if (bCollisionJoints)
                return 0;
        }
    }

    return(dam);
}

defaultproperties
{
     StowMesh=1
     Damage=15
     BloodTexture=Texture'weapons.romanswordroman_blood'
     rating=1
     SweepJoint2=6
     RunePowerRequired=50
     RunePowerDuration=15.000000
     PowerupMessage="FlameSword!"
     ThroughAir(0)=Sound'WeaponsSnd.Swings.swing14'
     ThroughAirBerserk(0)=Sound'WeaponsSnd.Swings.bswing02'
     HitFlesh(0)=Sound'WeaponsSnd.ImpFlesh.impfleshsword05'
     HitWood(0)=Sound'WeaponsSnd.ImpWood.impactwood02'
     HitStone(0)=Sound'WeaponsSnd.ImpStone.impactstone16'
     HitMetal(0)=Sound'WeaponsSnd.ImpMetal.impactmetal05'
     HitDirt(0)=Sound'WeaponsSnd.ImpEarth.impactearth01'
     HitIce(0)=Sound'WeaponsSnd.ImpStone.impactstone16'
     HitShield=Sound'WeaponsSnd.Shields.shield02'
     HitWeapon=Sound'WeaponsSnd.Swords.sword02'
     HitBreakableWood=Sound'WeaponsSnd.ImpWood.impactwood12'
     HitBreakableStone=Sound'WeaponsSnd.ImpStone.impactstone11'
     SheathSound=Sound'WeaponsSnd.Stows.xstow03'
     UnsheathSound=Sound'WeaponsSnd.Stows.xunstow03'
     ThrownSoundLOOP=Sound'WeaponsSnd.Throws.throw01L'
     PowerUpSound=Sound'WeaponsSnd.PowerUps.powerstart26'
     PoweredUpSoundLOOP=Sound'WeaponsSnd.PowerUps.power03L'
     PitchDeviation=0.075000
     PowerupIcon=Texture'RuneFX2.rsword'
     PowerupIconAnim=Texture'RuneFX2.rsword1a'
     PoweredUpSwipeClass=Class'RuneI.WeaponSwipeFire'
     A_Idle=S2_idle
     A_AttackA=S2_attackA
     A_AttackAReturn=S2_attackAReturn
     A_AttackB=S2_attackB
     A_AttackBReturn=S2_attackBReturn
     A_AttackC=S2_attackC
     A_AttackCReturn=S2_attackCReturn
     A_AttackStandA=S2_StandingAttackA
     A_AttackStandAReturn=S2_StandingattackAreturn
     A_AttackStandB=S2_StandingAttackB
     A_AttackStandBReturn=S2_StandingAttackBReturn
     A_AttackBackupB=S1_BackupAttackB
     A_AttackBackupBReturn=S1_BackupAttackBReturn
     A_Throw=S2_Throw
     A_Powerup=s2_powerup
     A_Defend=S2_DefendTo
     A_DefendIdle=S2_DefendIdle
     A_PainFront=S2_painFront
     A_PainRight=S1_painBack
     A_PickupGroundLeft=S2_PickupLeft
     A_PickupHighLeft=S2_PickupLeftHigh
     A_Taunt=s2_taunt
     A_PumpTrigger=S2_PumpTrigger
     A_LeverTrigger=S2_LeverTrigger
     PickupMessage="You now carry a Roman Sword"
     PickupSound=Sound'OtherSnd.Pickups.grab02'
     DropSound=Sound'WeaponsSnd.Drops.sworddrop04'
     Mass=12.000000
     Skeletal=SkelModel'weapons.romansword'
     SkelGroupSkins(0)=Texture'weapons.romanswordroman_sword'
     SkelGroupSkins(1)=Texture'weapons.romanswordroman_sword'
}