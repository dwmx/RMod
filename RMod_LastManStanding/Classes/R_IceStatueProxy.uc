class R_IceStatueProxy extends Pawn;

/* 
*   This class is necessary for team damage, used only during the IceStatue state.
*   Weapon.uc throws out all struck actors if their Team is the same as the weapon's owner's team.
*   Because of this, no call to JointDamaged ever gets made, and there's no way for a pawn to respond to being struck by a teammate.
*   This class uses a dummy team (128) to always take damage from anyone, and then reports it back to the owner.
*/

event PostBeginPlay()
{
    Super.PostBeginPlay();
    SetLocation(Owner.Location);
    PlayerReplicationInfo = Spawn(class'RMod_LastManStanding.R_IceStatueProxyPRI', Self);
}

function ApplyProxy(Actor InActor)
{
    Skeletal = InActor.Skeletal;
    SubstituteMesh = InActor.SubstituteMesh;
    SkelMesh = InActor.SkelMesh;
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

defaultproperties
{
    RemoteRole=ROLE_None
    DrawType=DT_SkeletalMesh
    bCollideActors=True
    bBlockActors=False
    bBlockPlayers=False
    bHidden=True
    bSweepable=True
}