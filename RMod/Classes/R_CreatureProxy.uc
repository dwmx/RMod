class R_CreatureProxy extends Actor;

var Name AnimToPlay;

var Weapon W;
var Shield S;

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();
    Enable('Tick');
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    //SpawnEquipment();
}

simulated event Tick(float DeltaSeconds)
{
    if(W != None)
        AttachActorToJoint(W, JointNamed('attach_hand'));
    if(S != None)
        AttachActorToJoint(S, JointNamed('attach_shielda'));
}

simulated function SpawnEquipment()
{
    W = Spawn(Class'DwarfWorkHammer', Self);
    S = Spawn(Class'DwarfBattleShield', Self);
}

simulated function PlayProxyAnim(Name Anim, float Rate, float Tween)
{
    PlayAnim(Anim, Rate, Tween);
}

simulated function LoopProxyAnim(Name Anim, float Rate, float Tween)
{
    LoopAnim(Anim, Rate, Tween);
}

simulated function SyncAnimFrameWithOwner()
{
    if(Owner != None)
    {
        AnimFrame = Owner.AnimFrame;
    }
}

simulated function Attack()
{
    GotoState('Attacking');
}

simulated function Defend()
{
    GotoState('Defend');
}

auto state Idle
{
    simulated function Attack()
    {
        GotoState('Attack');
    }

    simulated function Defend()
    {
        GotoState('Defending');
    }
}

state Attacking
{
    simulated function PlayProxyAnim(Name Anim, float Rate, float Tween) {}
    simulated function LoopProxyAnim(Name Anim, float Rate, float Tween) {}

Begin:
    PlayAnim('attackA', 1.0, 0.1);
    FinishAnim();
    SyncAnimFrameWithOwner();
    GotoState('Idle');
}

state Defending
{
    simulated function PlayProxyAnim(Name Anim, float Rate, float Tween) {}
    simulated function LoopProxyAnim(Name Anim, float Rate, float Tween) {}

    simulated event BeginState()
    {
        PlayAnim('block', 1.0, 0.1);
    }

Begin:
    if(RunePlayer(Owner).bAltFire == 1)
        Sleep(1.0);
        //goto('Begin');
    GotoState('Idle');
}

defaultproperties
{
    InitialState='Idle'
    RemoteRole=ROLE_AutonomousProxy
    DrawType=DT_SkeletalMesh
}

/*
var Name AnimToPlay;

event PreBeginPlay()
{
    local Vector NewLocation;
    local Rotator NewRotation;

    Enable('Tick');


    NewLocation.X = 0.0;
    NewLocation.Y = 0.0;
    NewLocation.Z = 0.0;

    NewRotation.Yaw = 0;
    NewRotation.Pitch = 0;
    NewRotation.Roll = 0;

    SetLocation(NewLocation);
    SetRotation(NewRotation);

}

simulated event Tick(float DeltaSeconds)
{
    LoopAnim(AnimToPlay, 1.0, 0.1);
}

defaultproperties
{
    RemoteRole=ROLE_AutonomousProxy
    DrawType=DT_SkeletalMesh
}
*/