class R_Weapon_VikingBroadSword extends R_AWeapon_Sword;

function PowerupInit()
{
    Super.PowerupInit();
}   

function PowerupEnded()
{
    Super.PowerupEnded();
}   

simulated function SpawnPowerupEffect()
{
    local EffectSkeleton ES;

    // Spawn an EffectSkeleton that will display all powered up effects
    ES = Spawn(class'EffectSkelVampire', self);
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
// Powerup: Vampiric
//
//=============================================================================

function int CalculateDamage(actor Victim)
{
    local int i;
    local VampireTrail vamp;
    local rotator r;
    local int dam;
    local int actualDam;

    dam = Super.CalculateDamage(Victim);

    if(Pawn(Victim)!=None && Pawn(Victim).Health < dam)
        actualDam = Pawn(Victim).Health;
    else
        actualDam = dam;

    if (ScriptPawn(Victim)!=None && ScriptPawn(Victim).bIsBoss)
        return dam;

    if(bPoweredUp && Victim.IsA('Pawn') && actualDam > 0)
    {
        for(i = 0; i < 5; i++)
        {
            vamp = Spawn(Class'VampireTrail',owner,, Victim.Location, Owner.Rotation);
            r = rotator(Victim.Location - Owner.Location);
            r.Yaw += -12000 + 4800 * i + (FRand() - 0.5) * 1000;
            vamp.Velocity = (350 + 100 * FRand()) * vector(r);
            vamp.Velocity.Z += 150 + 100 * FRand();

            r = rotator(vamp.Velocity);             
            
            // Compute acceleration for a smooth arch
            if(i < 2)
            {
                r.Yaw -= 8000 + FRand() * 2000;
            }
            else if(i > 2)
            {
                r.Yaw += 8000 + FRand() * 2000;
            }
            
            vamp.Acceleration = vector(r) * 1000;
            vamp.VampireDest = Pawn(Owner);
            vamp.HealthBoost = dam / 5;
            SetRotation(rotator(vamp.Velocity));
        }
    }

    return(dam);
}

defaultproperties
{
     StowMesh=1
     Damage=20
     BloodTexture=Texture'weapons.broadswordv_broadblood'
     rating=2
     SweepJoint2=6
     RunePowerRequired=50
     RunePowerDuration=15.000000
     PowerupMessage="Vampiric Attack!"
     StabMesh=2
     ThroughAir(0)=Sound'WeaponsSnd.Swings.swing15'
     ThroughAirBerserk(0)=Sound'WeaponsSnd.Swings.bswing03'
     HitFlesh(0)=Sound'WeaponsSnd.ImpFlesh.impfleshsword07'
     HitWood(0)=Sound'WeaponsSnd.ImpWood.impactwood15'
     HitStone(0)=Sound'WeaponsSnd.ImpStone.impactstone07'
     HitMetal(0)=Sound'WeaponsSnd.ImpMetal.impactmetal17'
     HitDirt(0)=Sound'WeaponsSnd.ImpEarth.impactearth03'
     HitIce(0)=Sound'WeaponsSnd.ImpStone.impactstone07'
     HitShield=Sound'WeaponsSnd.Shields.shield03'
     HitWeapon=Sound'WeaponsSnd.Swords.sword03'
     HitBreakableWood=Sound'WeaponsSnd.ImpWood.impactwood12'
     HitBreakableStone=Sound'WeaponsSnd.ImpStone.impactstone11'
     SheathSound=Sound'WeaponsSnd.Stows.xstow03'
     UnsheathSound=Sound'WeaponsSnd.Stows.xunstow03'
     PowerUpSound=Sound'WeaponsSnd.PowerUps.powerstart41'
     PoweredUpSoundLOOP=Sound'WeaponsSnd.PowerUps.power33L'
     PitchDeviation=0.080000
     PowerupIcon=Texture'RuneFX2.bsword'
     PowerupIconAnim=Texture'RuneFX2.bsword1a'
     PoweredUpSwipeClass=Class'RuneI.WeaponSwipeVamp'
     A_Idle=S3_idle
     A_Forward=S3_Walk
     A_Backward=S3_Backup
     A_Forward45Right=S3_Walk45Right
     A_Forward45Left=S3_Walk45Left
     A_Backward45Right=S3_Backup45Right
     A_Backward45Left=S3_Backup45Left
     A_StrafeRight=S3_StrafeRight
     A_StrafeLeft=S3_StrafeLeft
     A_Jump=S3_Jump
     A_AttackA=S3_attackA
     A_AttackAReturn=S3_AttackAreturn
     A_AttackB=S3_attackB
     A_AttackC=S3_attackC
     A_AttackCReturn=S3_attackCreturn
     A_AttackStandA=S3_StandingattackA
     A_AttackStandAReturn=S3_StandingattackAReturn
     A_AttackStandB=S3_StandingattackB
     A_AttackStandBReturn=S3_StandingattackBReturn
     A_AttackBackupA=S3_BackupAttackA
     A_AttackBackupAReturn=S3_BackupAttackAreturn
     A_AttackBackupB=S3_BackupAttackB
     A_AttackBackupBReturn=S3_BackupAttackBreturn
     A_AttackStrafeRight=S3_StrafeRightAttack
     A_AttackStrafeLeft=S3_StrafeLeftAttack
     A_Powerup=S3_Powerup
     A_Defend=S3_DefendTO
     A_DefendIdle=S3_Defendidle
     A_PainFront=S3_painFront
     A_PainBack=S3_painBack
     A_PainLeft=S3_painLeft
     A_PainRight=S3_painRight
     A_PickupGroundLeft=S3_PickupLeft
     A_PickupHighLeft=S3_PickupLeftHigh
     A_PumpTrigger=S3_PumpTrigger
     A_LeverTrigger=S3_LeverTrigger
     PickupMessage="You are armed with a Viking BroadSword"
     PickupSound=Sound'OtherSnd.Pickups.grab03'
     DropSound=Sound'WeaponsSnd.Drops.sworddrop03'
     Mass=14.000000
     Skeletal=SkelModel'weapons.broadsword'
     SkelGroupSkins(0)=Texture'weapons.broadswordv_broad'
     SkelGroupSkins(1)=Texture'weapons.broadswordv_broad'
     WeaponTier=3
}