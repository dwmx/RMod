class R_IceStatueProxy extends Pawn;

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

function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
    if(EventInstigator.PlayerReplicationInfo.Team == Pawn(Owner).PlayerReplicationInfo.Team)
    {
        Log("My teammate hit me! for " $ Damage $ " damage");
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