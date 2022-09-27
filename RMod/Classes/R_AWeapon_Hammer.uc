//==============================================================================
//  R_AWeapon_Hammer
//  Base RMod Hammer weapon class.
//==============================================================================
class R_AWeapon_Hammer extends R_AWeapon abstract;

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
            {   // Joint j was hit
                matter = HitActor.MatterForJoint(j);
                break;
            }
        }
    }
    else if(HitActor.IsA('LevelInfo'))
    {   
        matter = HitActor.MatterTrace(HitLoc, Owner.Location, WeaponSweepExtent);
    }
    else
    {
        matter = HitActor.MatterForJoint(0);
    }

    PlayHitMatterSound(matter);

    // Create effects
    switch(matter)
    {
        case MATTER_FLESH:
            if(HitActor.IsA('Sark') || HitActor.IsA('SarkRagnar'))
                Spawn(class'SarkBloodMist',,, HitLoc, rotator(HitNorm)); // Sark blood
            else
                Spawn(class'BloodMist',,, HitLoc, rotator(HitNorm));

            if(BloodTexture != None && !Region.Zone.bWaterZone && !class'GameInfo'.Default.bVeryLowGore)
            {
                SkelGroupSkins[1] = BloodTexture;
            }
            break;
        case MATTER_WOOD:
            break;
        case MATTER_STONE:
            Spawn(class'HitStone',,, HitLoc, rotator(HitNorm));
            break;
        case MATTER_METAL:
            break;
        case MATTER_EARTH:
            Spawn(class'GroundDust',,, HitLoc, rotator(HitNorm));
            break;
        case MATTER_BREAKABLEWOOD:
            break;
        case MATTER_BREAKABLESTONE:
            break;
        case MATTER_WEAPON:
            break;
        case MATTER_SHIELD:
            break;
        case MATTER_ICE:
            break;
        case MATTER_WATER:
            break;
    }
}

defaultproperties
{
     MeleeType=MELEE_HAMMER
     bCanBePoweredUp=True
     DamageType=Blunt
     ThrownSoundLOOP=Sound'WeaponsSnd.Throws.throw02L'
     PowerUpSound=Sound'OtherSnd.Pickups.pickup01'
     PoweredUpEndingSound=Sound'WeaponsSnd.PowerUps.powerend22'
     PoweredUpEndSound=Sound'WeaponsSnd.PowerUps.powerend20'
     SwipeClass=Class'RuneI.WeaponSwipeBlue'
     A_Idle=weapon1_idle
     A_Forward=S1_Walk
     A_Backward=weapon1_backup
     A_Forward45Right=S1_Walk45Right
     A_Forward45Left=S1_Walk45Left
     A_Backward45Right=weapon1_backup45Right
     A_Backward45Left=weapon1_backup45Left
     A_StrafeRight=StrafeRight
     A_StrafeLeft=StrafeLeft
     A_Jump=MOV_ALL_jump1_AA0S
     A_ForwardAttack=LegsTest
     A_AttackA=S1_attackA
     A_AttackAReturn=S1_attackAreturn
     A_AttackB=S1_attackB
     A_AttackC=S1_attackC
     A_AttackCReturn=S1_attackCReturn
     A_AttackStandA=S1_attackA
     A_AttackStandAReturn=S1_attackAreturn
     A_AttackStandB=S1_attackB
     A_AttackStandBReturn=S1_attackBreturn
     A_AttackBackupA=S1_BackupAttackA
     A_AttackBackupAReturn=S1_BackupAttackAReturn
     A_AttackStrafeRight=S3_StrafeRightAttack
     A_AttackStrafeLeft=S3_StrafeLeftAttack
     A_JumpAttack=OneHandJumpAttack
     A_Throw=S3_throw
     A_Defend=H3_DefendTO
     A_DefendIdle=H3_DefendIdle
     A_PainFront=Onehand_painRight
     A_PainBack=Onehand_painRight
     A_PainLeft=Onehand_painLeft
     A_PainRight=Onehand_painRight
     A_PickupGroundLeft=H3_PickupLeft
     A_PickupHighLeft=H3_PickupLeftHigh
     A_Taunt=S3_taunt
     RespawnTime=30.000000
     RespawnSound=Sound'OtherSnd.Respawns.respawn01'
     PickupMessageClass=Class'RuneI.PickupMessage'
}