//==============================================================================
//  R_CreaturePlayerProxy
//  Animation proxy class for creature players, supports upper/lower body
//  independent animations.
//==============================================================================

//==============================================================================
//  IMPORTANT NOTES:
//  Rune's SCM model format includes "JointGroup" data which the original
//  AnimationProxy class uses to separate upper and lower body animations.
//
//  The meshes created for creatures, like goblin and dwarf, were never set up
//  with this JointGroup data. Since there does not appear to be a way to
//  set the JointGroups from UnrealScript, those meshes will not work with the
//  original AnimationProxy.
//
//  However, a significant portion of game code is still routed to the
//  AnimationProxy (Use, Attack, Defend, Taunt, etc), so in order to avoid
//  rewriting all of that, this class is still used.
//
//  It's very important to note that the animation proxy attaches all actors
//  to itself, and NOT to the ownining RunePlayer the way AnimationProxy
//  normally does.
//==============================================================================
class R_CreaturePlayerProxy extends AnimationProxy;

// Enumerator for the different directional attacks
enum EAttackDirection
{
    AD_Forward,
    AD_Backward,
    AD_Left,
    AD_Right,
    AD_Neutral
};

var Name TorsoAnim;

event BeginPlay()
{
    Super.BeginPlay();
    Skeletal = Owner.Skeletal;
}

event Tick(float DeltaSeconds)
{
    LockSelfMeshToOwnerMesh();
}

function LockSelfMeshToOwnerMesh()
{
    local Vector OwnerMeshOffset;
    local Vector ProxyMeshOffset;
    local Vector ProxyMeshLocation;

    OwnerMeshOffset = Owner.GetJointPos(JointNamed('pelvis')) - Owner.Location;
    ProxyMeshOffset = Self.GetJointPos(JointNamed('pelvis')) - Self.Location;

    ProxyMeshLocation = Owner.Location + (OwnerMeshOffset - ProxyMeshOffset);

    SetLocation(ProxyMeshLocation);
    SetRotation(Owner.Rotation);
}

function AcquireInventory(Inventory InventoryActor)
{
    if(Weapon(InventoryActor) != None)
    {
        AcquireWeapon(Weapon(InventoryActor));
        return;
    }

    if(Shield(InventoryActor) != None)
    {
        AcquireShield(Shield(InventoryActor));
        return;
    }
}

function AcquireWeapon(Weapon WeaponActor)
{
    local Name WeaponJoint;
    if(Pawn(Owner) != None)
    {
        WeaponJoint = Pawn(Owner).WeaponJoint;
        AttachActorToJoint(WeaponActor, JointNamed(WeaponJoint));
    }
}

function AcquireShield(Shield ShieldActor)
{
    local Name ShieldJoint;
    if(Pawn(Owner) != None)
    {
        ShieldJoint = Pawn(Owner).ShieldJoint;
        AttachActorToJoint(ShieldActor, JointNamed(ShieldJoint));
    }
}

auto state Idle
{
    function EAttackDirection DetermineInitialAttackDirection()
    {
        local Vector X, Y, Z;
        local Vector AccelNormalized;
        local float ForwardDotAccel;
        local float RightDotAccel;

        if(Owner.Acceleration.X * Owner.Acceleration.X + Owner.Acceleration.Y * Owner.Acceleration.Y < 1000)
        {
            // Standing still
            return AD_Neutral;
        }

        GetAxes(Owner.Rotation, X, Y, Z);
        AccelNormalized = Normal(Owner.Acceleration);

        ForwardDotAccel = AccelNormalized Dot X;
        if(ForwardDotAccel > 0.9)
        { // Distinctly forward
            return AD_Forward;
        }
        else if(ForwardDotAccel < -0.9)
        { // Distinctly backward
            return AD_Backward;
        }

        RightDotAccel = AccelNormalized Dot Y;
        if(RightDotAccel > 0.0)
        {
            return AD_Right;
        }
        else if(RightDotAccel < 0.0)
        {
            return AD_Left;
        }

        return AD_Neutral;
    }

    function bool Attack()
    {
        local EAttackDirection AttackDirection;
        local Name InitialAttackAnim;

        AttackDirection = DetermineInitialAttackDirection();
        switch(AttackDirection)
        {
        case AD_Forward:
        case AD_Backward:
        case AD_Neutral:
            InitialAttackAnim = 'AttackA';
            break;
        case AD_Left:
            InitialAttackAnim = 'AttackB';
            break;
        case AD_Right:
            InitialAttackAnim = 'AttackC';
            break;
        }

        TorsoAnim = InitialAttackAnim;
        GotoState('Attacking');

        return true;
    }
}

state Attacking
{
    function bool CanPickup(Inventory InventoryActor)
    {
        return false;
    }

    function bool Defend()
    {
        return true;
    }

    function bool Attack()
    {
        return true;
    }

Begin:
    PlayAnim(TorsoAnim, 1.5, 0.1);
    Sleep(0.1);
    WeaponActivate();
    TorsoAnim = 'None';
    FinishAnim();
    WeaponDeactivate();
    if(TorsoAnim != 'None')
    {
        GoTo('Begin');
    }

    SyncAnimation(0.01);
    GoToState('Idle');
}

state Defending
{
    event BeginState()
    {
        PlayDefend();
    }

    function PlayDefend()
    {
        PlayAnim('block', 1.0, 0.1);
    }

Begin:
    if(RunePlayer(Owner).bAltFire == 1)
    {
        Sleep(0.01);
        GoTo('Begin');
    }
    SyncAnimation(0.15);
    GoToState('Idle');
}

defaultproperties
{
    DrawType=DT_SkeletalMesh
    Skeletal=SkelModel'creatures.Dwarf'
    bHidden=False
}