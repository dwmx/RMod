//==============================================================================
//  R_AWeapon_Sword
//  Base RMod Sword weapon class.
//==============================================================================
class R_AWeapon_Sword extends R_AWeapon abstract;

var vector S1, S2;  //temp

//=============================================================================
//
// StickInWall
//
//=============================================================================
function bool StickInWall( EMatterType matter)
{
    local rotator r;
    local vector X,Y,Z;
    local float WeaponLength;

    if (matter!=MATTER_WOOD && matter!=MATTER_ICE &&
        matter!=MATTER_EARTH && matter!=MATTER_SNOW &&
        matter!=MATTER_FLESH && matter!=MATTER_BREAKABLEWOOD)
        return false;

    // Coax any orientation into good range
    r = Rotation;
    r.Roll = Clamp(r.Roll, 27000, 34000);
    //slog("Roll="$R.Roll@"[27000..34000]");

    // Determine if it would be sticking into wall
    GetAxes(r, X,Y,Z);
    WeaponLength = VSize(GetJointPos(SweepJoint2)-GetJointPos(SweepJoint1));
    S1 = Location;
    S2 = Location + Y*WeaponLength;

    if (!FastTrace(Location + Y*WeaponLength, Location))
    {   // Stuck in wall
        SetRotation(r);
        return true;
    }

    return false;
}

simulated function Debug(Canvas canvas, int mode)
{
    Super.Debug(canvas, mode);
    Canvas.DrawLine3D(S1, S2, 155, 155, 0);
    Canvas.DrawText("AttachParent: " @AttachParent);
    Canvas.CurY -= 8;
}

//=============================================================================
//
// Throw
//
// Special CalculateDamage function for thrown swords (to do special stab code)
//=============================================================================

state Throw
{
    function int CalculateDamage(actor Victim)
    {
        local int dam;
        local Pawn P;
        local vector X,Y,Z, HitVec, HitVec2D;
        local float dotp;
        
        dam = Super.CalculateDamage(Victim);
        
        if(Victim.IsA('Pawn'))
        {
            P = Pawn(Victim);
            if(P.CanStabActor() && dam >= P.Health)
            {
                GetAxes(P.Rotation,X,Y,Z);
                X.Z = 0;
                HitVec = Normal(Location - Victim.Location);
                HitVec2D = HitVec;
                HitVec2D.Z = 0;
                dotp = HitVec2D dot X;
                if(dotp > 0.7)          //Only allow skewer from front..
                {
                    StabActor(P);
                    SetOwner(None); //Disallow any other damage to others..
                }
            }
        }
        
        return(dam);
    }
}

defaultproperties
{
    bCanBePoweredUp=True
    DamageType=Sever
    ThrownDamageType=thrownweaponsever
    ThrownSoundLOOP=Sound'WeaponsSnd.Throws.throw02L'
    PowerUpSound=Sound'OtherSnd.Pickups.pickup01'
    PoweredUpEndingSound=Sound'WeaponsSnd.PowerUps.powerend21'
    PoweredUpEndSound=Sound'WeaponsSnd.PowerUps.powerend17'
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
    A_AttackStrafeRight=S1_StrafeRightAttack
    A_AttackStrafeLeft=S1_StrafeLeftAttack
    A_JumpAttack=OneHandJumpAttackB
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
    HitFleshEffectClass=Class'RuneI.BloodMist'
    HitWoodEffectClass=Class'RuneI.HitWood'
    HitStoneEffectClass=Class'RuneI.HitStone'
    HitMetalEffectClass=Class'RuneI.HitMetal'
    HitDirtEffectClass=Class'RuneI.GroundDust'
    HitShieldEffectClass=Class'RuneI.HitWood'
    HitWeaponEffectClass=Class'RuneI.HitMetal'
    HitBreakableWoodEffectClass=Class'RuneI.HitWood'
    HitBreakableStoneEffectClass=Class'RuneI.HitStone'
    HitIceEffectClass=Class'RMod.R_Effect_HitIce'
}