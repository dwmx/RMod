class R_Weapon_VikingShortSword extends R_AWeapon_Sword;

var Shield StoredShield; // Stores the current shield while the magic shield is out

//=============================================================================
//
// Powerup: Shield
//
// This function is called when the weapon is initially powered up
//=============================================================================
function PowerupInit()
{
    local Pawn PawnOwner;
    local Shield shield;

    Super.PowerupInit();

    StoredShield = None;
    PawnOwner = Pawn(Owner);
    if (PawnOwner!=None)
    {
        if (PawnOwner.Shield != None)
        {   // Powerup up existing shield
            StoredShield = PawnOwner.Shield;
            StoredShield.bHidden = true;
            StoredShield.bSweepable = false;
            PawnOwner.DetachActorFromJoint(PawnOwner.JointNamed(PawnOwner.ShieldJoint));
        }

        // Give a magic shield
        shield = Spawn(class'MagicShield',,,PawnOwner.Location);
        PawnOwner.AddInventory( shield );
        PawnOwner.AttachActorToJoint(shield, PawnOwner.JointNamed(PawnOwner.ShieldJoint));
        PawnOwner.Shield = shield;
        Shield.GotoState('Active');
    }
}

function PowerupEnded()
{
    local Pawn PawnOwner;
    local Shield shield;

    Super.PowerupEnded();

    PawnOwner = Pawn(Owner);
    if (PawnOwner!=None)
    {
        shield = PawnOwner.Shield;
        if (shield.IsA('MagicShield'))
        {
            PawnOwner.DropShield();
            shield.Destroy();
            PawnOwner.Shield = None;
        }

        // Restore stored shield
        if(StoredShield != None)
        {
            PawnOwner.Shield = StoredShield;            
            PawnOwner.Shield.bHidden = false;
            PawnOwner.Shield.bSweepable = true;
            PawnOwner.AttachActorToJoint(PawnOwner.Shield, PawnOwner.JointNamed(PawnOwner.ShieldJoint));
            StoredShield = None;
        }
    }
}

defaultproperties
{
     StowMesh=1
     Damage=10
     BloodTexture=Texture'weapons.shortswordshortswordblood'
     RunePowerRequired=25
     RunePowerDuration=15.000000
     PowerupMessage="Shield!"
     ThroughAir(0)=Sound'WeaponsSnd.Swings.swing13'
     ThroughAirBerserk(0)=Sound'WeaponsSnd.Swings.bswing01'
     HitFlesh(0)=Sound'WeaponsSnd.ImpFlesh.impfleshsword03'
     HitWood(0)=Sound'WeaponsSnd.ImpWood.impactwood10'
     HitStone(0)=Sound'WeaponsSnd.ImpStone.impactstone01'
     HitMetal(0)=Sound'WeaponsSnd.ImpMetal.impactmetal11'
     HitDirt(0)=Sound'WeaponsSnd.ImpEarth.impactearth02'
     HitIce(0)=Sound'WeaponsSnd.ImpStone.impactstone01'
     HitShield=Sound'WeaponsSnd.Shields.shield01'
     HitWeapon=Sound'WeaponsSnd.Swords.sword01'
     HitBreakableWood=Sound'WeaponsSnd.ImpWood.impactwood12'
     HitBreakableStone=Sound'WeaponsSnd.ImpStone.impactstone11'
     SheathSound=Sound'WeaponsSnd.Stows.xstow03'
     UnsheathSound=Sound'WeaponsSnd.Stows.xunstow03'
     ThrownSoundLOOP=Sound'WeaponsSnd.Throws.throw01L'
     PowerUpSound=Sound'WeaponsSnd.PowerUps.powerstart27'
     PoweredUpSoundLOOP=Sound'WeaponsSnd.PowerUps.power36L'
     PitchDeviation=0.070000
     PowerupIcon=Texture'RuneFX2.ssword'
     PowerupIconAnim=Texture'RuneFX2.ssword1a'
     PoweredUpSwipeClass=Class'RuneI.WeaponSwipeRed'
     A_AttackD=S1_attackD
     A_AttackDReturn=S1_attackDreturn
     A_AttackStandA=S1_StandingAttackA
     A_AttackStandAReturn=S1_StandingAttackAReturn
     A_AttackStandB=S1_StandingAttackB
     A_AttackStandBReturn=S1_StandingAttackBReturn
     A_AttackBackupB=S1_BackupAttackB
     A_AttackBackupBReturn=S1_BackupAttackBReturn
     A_Throw=S1_Throw
     A_Powerup=S1_Powerup
     A_Defend=S1_DefendTO
     A_DefendIdle=S1_DefendIdle
     A_PainFront=S1_painFront
     A_PainRight=S1_painBack
     A_PickupGroundLeft=S1_PickupLeft
     A_PickupHighLeft=S1_PickupLeftHigh
     A_Taunt=S1_Taunt
     A_PumpTrigger=S1_PumpTrigger
     A_LeverTrigger=S1_LeverTrigger
     PickupMessage="You bear a Viking Short Sword"
     PickupSound=Sound'OtherSnd.Pickups.grab01'
     DropSound=Sound'WeaponsSnd.Drops.sworddrop05'
     Skeletal=SkelModel'weapons.shortsword'
     SkelGroupSkins(0)=Texture'weapons.shortswordshortsword'
     SkelGroupSkins(1)=Texture'weapons.shortswordshortsword'
     WeaponTier=1
}