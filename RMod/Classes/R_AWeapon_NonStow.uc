//==============================================================================
//  R_AWeapon_NonStow
//==============================================================================
class R_AWeapon_NonStow extends R_AWeapon;

//============================================================================
//
// GetUsePriority
//
// Returns the priority of the weapon, lower is better
//============================================================================

function int GetUsePriority()
{
    return(6);
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

    // Create effects
    PlayHitMatterSound(matter);

    SpawnBloodSpray(HitLoc, HitNorm, matter);
}

function SpawnBloodSpray(vector HitLoc, vector HitNorm, EMatterType matter);

defaultproperties
{
     MeleeType=MELEE_NON_STOW
     ThrownSoundLOOP=Sound'WeaponsSnd.Throws.throw02L'
     A_Idle=T_OUTIdle
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
     A_AttackStandA=S1_StandingAttackA
     A_AttackStandAReturn=S1_StandingAttackAReturn
     A_AttackBackupA=H3_BackupAttackA
     A_AttackBackupAReturn=H3_BackupAttackAReturn
     A_AttackStrafeRight=S1_StrafeRightAttack
     A_AttackStrafeLeft=S1_StrafeLeftAttack
     A_JumpAttack=OneHandJumpAttack
     A_Throw=H3_throw
     A_Defend=H3_DefendTO
     A_DefendIdle=H3_DefendIdle
     A_PainFront=Onehand_painRight
     A_PainBack=Onehand_painRight
     A_PainLeft=Onehand_painLeft
     A_PainRight=Onehand_painRight
     A_PickupGroundLeft=PickupGroundLeft
     A_PickupHighLeft=PickupHighLeft
     A_Taunt=S3_taunt
     A_LeverTrigger=T_OUTLeverTrigger
     RespawnTime=30.000000
     PickupSound=Sound'OtherSnd.Pickups.grab02'
     RespawnSound=Sound'OtherSnd.Respawns.respawn01'
     PickupMessageClass=Class'RuneI.PickupMessage'
     Mass=12.000000
}