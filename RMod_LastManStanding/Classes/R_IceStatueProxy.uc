class R_IceStatueProxy extends Pawn;

/* 
*   This class is necessary for team damage, used only during the IceStatue state.
*   Weapon.uc throws out all struck actors if their Team is the same as the weapon's owner's team.
*   Because of this, no call to JointDamaged ever gets made, and there's no way for a pawn to respond to being struck by a teammate.
*   This class uses a dummy team (128) to always take damage from anyone, and then reports it back to the owner.
*/

event PostBeginPlay()
{
    local Inventory I;

    Super.PostBeginPlay();
    CopyParent();
    ApplyStatueFeaturesToActor(Self);
    
    DesiredFatness = 255;
    
    if(Role == ROLE_Authority)
    {
        PlayerReplicationInfo = Spawn(class'RMod_LastManStanding.R_IceStatueProxyPRI', Self);
    }
}

function ApplyStatueFeaturesToActor(Actor A)
{
    local int i;
    for(i = 0; i < 16; ++i)
    {
        A.SkelGroupSkins[i] = Texture'statues.ice1';
    }
}

function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int Joint)
{
    local R_RunePlayer_LastManStanding RP;
    RP = R_RunePlayer_LastManStanding(Owner);
    if(RP != None)
    {
        return RP.ReceiveIceStatueProxyJointDamaged(Damage, EventInstigator, HitLoc, Momentum, DamageType, Joint);
    }
    return true;
}

simulated event Tick(float DeltaSeconds)
{
    if(Role >= ROLE_AutonomousProxy)
    {
        Super.Tick(DeltaSeconds);
    }
    
    CopyParent();
}

simulated function CopyParent()
{
    SetLocation(Owner.Location);
    SetRotation(Owner.Rotation);
    Skeletal = Owner.Skeletal;
    SubstituteMesh = Owner.SubstituteMesh;
    SkelMesh = Owner.SkelMesh;
    AnimSequence = Owner.AnimSequence;
    AnimFrame = Owner.AnimFrame;
    if(AnimProxy != None && Owner.AnimProxy != None)
    {
        AnimProxy.AnimSequence = Owner.AnimProxy.AnimSequence;
        AnimProxy.AnimFrame = Owner.AnimProxy.AnimFrame;
    }
    DesiredColorAdjust = Owner.DesiredColorAdjust;
    ColorAdjust = Owner.ColorAdjust;
}

defaultproperties
{
    RemoteRole=ROLE_AutonomousProxy
    Style=STY_Translucent
    DrawType=DT_SkeletalMesh
    bCollideActors=True
    bBlockActors=False
    bBlockPlayers=False
    bHidden=False
    bSweepable=True
}