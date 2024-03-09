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
//class R_CreaturePlayerProxy extends AnimationProxy;
class R_CreaturePlayerProxy extends R_RunePlayerProxy;

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
var Actor PendingPickupActor;

var bool bDoStowExecuted;
var bool bDoThrowExecuted;

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

/**
*   AcquireInventory (override)
*   This is overridden to attach Inventory actors to the AnimProxy instead of to the
*   owner.
*/
function AcquireInventory(Inventory InventoryActor)
{
    InventoryActor.FireEvent(InventoryActor.Event);
    InventoryActor.Event = '';

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

    if(Runes(InventoryActor) != None)
    {
        AcquireRunes(Runes(InventoryActor));
        return;
    }

    if(Pickup(InventoryActor) != None)
    {
        // No original functionality for this
        return;
    }
}

function AcquireWeapon(Weapon WeaponActor)
{
    local R_RunePlayer RPOwner;

    RPOwner = R_RunePlayer(Owner);
    if(RPOwner != None)
    {
        RPOwner.InstantStow();
        RPOwner.SelectWeapon(WeaponActor);
        RPOwner.Weapon = WeaponActor;

        CurWeapon = RPOwner.Weapon;
        NewWeapon = WeaponActor; // k...?

        if(NonStow(WeaponActor) != None)
        {
            StowWeapon = None;
        }
        else
        {
            StowWeapon = RPOwner.GetStowedWeapon(GetStowIndex(NewWeapon));
        }

        // Original two hander vs shield code - this doesn't matter for creatures
        // TODO: Will likely need some other logic here at some point

        //if(CurWeapon != None && CurWeapon.A_Defend == 'None')
        //{ // This weapon just picked up cannot be used with a shield
        //    RunePlayer(Owner).DropShield();
        //}

        if(Owner.IsInState('PlayerSwimming'))
        {
            RPOwner.InstantStow();
        }
    }
}

function AcquireShield(Shield ShieldActor)
{
    local int ShieldJoint;
    local R_RunePlayer RPOwner;

    RPOwner = R_RunePlayer(Owner);
    if(RPOwner != None)
    {
        RPOwner.DropShield();
        RPOwner.Shield = ShieldActor;

        ShieldJoint = JointNamed(RPOwner.ShieldJoint);
        if(ShieldJoint != 0)
        {
            AttachActorToJoint(RPOwner.Shield, ShieldJoint);
        }

    }
}

function AcquireRunes(Runes RunesActor)
{
    RunesActor.GoToState('Activated');
}

/**
*   ProxyPickup (override)
*   Overridden to play the Dwarf pickup animation
*   TODO:
*   Generalize the function to work with all creatures
*/
function ProxyPickup()
{
    local Name AnimToPlay;
    local float AnimRate;

    bDoStowExecuted = false;

    AnimToPlay = 'GetWeapon';
    AnimRate = 1.5;

    BlendAnimSequence = AnimToPlay;
    BlendAnimAlpha = 1.0;
    R_RunePlayer(Owner).BlendAnimSequence = BlendAnimSequence;
    R_RunePlayer(Owner).BlendAnimAlpha = BlendAnimAlpha;

    PlayAnim(AnimToPlay, AnimRate, 0.1);
    R_RunePlayer(Owner).TryPlayTorsoAnim(AnimToPlay, AnimRate, 0.1);
}

/**
*   ProxyStowWeapon (override)
*   Any time this function is called in RunePlayer, it is expected that the triggered animation
*   will fire an event which calls DoStow().
*
*   Because Creatures do not have these events in any of their animations, they will never trigger
*   the call do DoStow.
*
*   Instead, this function now sets the flag bDoStowExecuted to false, which is flipped back in DoStow.
*   Latent state scripts look for this flag and force the call to DoStow if the event was never fired.
*/
function ProxyStowWeapon(int StowIndex)
{
    local R_RunePlayer RPOwner;

    DoStowIndex = StowIndex;
    bDoStowExecuted = false;

    PlayAnim('TOblock', 1.0, 0.1);
}

/**
*   DoStow (override)
*/
function DoStow()
{
    Super.DoStow();
    bDoStowExecuted = true;
}

function bool WantsToPickup(Inventory InventoryActor)
{
    local R_RunePlayer RPOwner;

    RPOwner = R_RunePlayer(Owner);
    if(RPOwner != None)
    {
        // This is specific to dwarves, but always let them pick up shields
        if(Shield(InventoryActor) != None)
        {
            if(RPOwner.Weapon != None && !CanUseWeaponWithShield(RPOwner.Weapon))
            {
                // Can't use current weapon with a shield
                return false;
            }
            if(RPOwner.BodyPartMissing(BODYPART_LARM1))
            {
                // Arm is not available
                return false;
            }
            return true;
        }
    }

    return Super.WantsToPickup(InventoryActor);
}

/**
*   CanUseWeaponWithShield
*   Returns whether or not this AnimProxy can use the given weapon with a shield
*/
function bool CanUseWeaponWithShield(Weapon WeaponActor)
{
    local R_RunePlayer_Creature RPOwner;

    if(WeaponActor == None)
    {
        return true;
    }

    RPOwner = R_RunePlayer_Creature(Owner);
    if(RPOwner != None)
    {
        if(RPOwner.bCanHoldShieldWithTwoHandedWeapons)
        {
            return true;
        }

        if(WeaponActor.A_Defend == 'None')
        { // This weapon is a 2 hander
            return false;
        }
    }
    // RunePlayer normally returns false if the WeaponActor does not have an A_Defend anim set
    return true;
}

/*
function bool CanPickup(Inventory InventoryActor)
{
    return false;
}

function bool WantsToPickup(Inventory InventoryActor)
{
    local Pawn PawnOwner;

    if(InventoryActor == None)
    {
        return false;
    }

    PawnOwner = Pawn(Owner);
    if(PawnOwner != None)
    {
        if(PawnOwner.FindInventoryType(InventoryActor.Class) != None)
        { // Only hold one of each class
            return false;
        }
    }

    if(Weapon(InventoryActor) != None)
    {
        return WantsToPickupWeapon(Weapon(InventoryActor));
    }
    if(Shield(InventoryActor) != None)
    {
        return WantsToPickupShield(Shield(InventoryActor));
    }

    return false;
}

function bool WantsToPickupWeapon(Weapon WeaponActor)
{
    return true;
}

function bool WantsToPickupShield(Shield ShieldActor)
{
    return true;
}
*/

/*
event FrameNotify(int FramePassed)
{
    local Pawn PawnOwner;
    local Weapon WeaponActor;
    local R_AShield ShieldActor;

    PawnOwner = Pawn(Owner);
    if(PawnOwner != None)
    {
        WeaponActor = PawnOwner.Weapon;
        if(WeaponActor != None)
        {
            WeaponActor.FrameNotify(FramePassed);
        }
        
        ShieldActor = R_AShield(PawnOwner.Shield);
        if(ShieldActor != None)
        {
            ShieldActor.FrameNotify(FramePassed);
        }
    }
}
*/

function WeaponActivate()
{
    local Pawn PawnOwner;
    local Weapon WeaponActor;

    PawnOwner = Pawn(Owner);
    if(PawnOwner != None)
    {
        WeaponActor = PawnOwner.Weapon;
        if(WeaponActor != None)
        {
            PawnOwner.WeaponActivate();
            WeaponActor.PlaySwipeSound();

            // I think this just triggers runepower attacks?
            WeaponActor.WeaponFire(0);
        }
    }
}

function WeaponDeactivate()
{
    local Pawn PawnOwner;

    PawnOwner = Pawn(Owner);
    if(PawnOwner != None)
    {
        PawnOwner.WeaponDeactivate();
    }
}

auto state Idle
{
    function bool Use()
    {
        GoToState('PickingUp');
        return true;
    }

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
    event EndState()
    {
        WeaponDeactivate();
    }

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
    TorsoAnim = 'None';
    //Sleep(0.1);
    //WeaponActivate(); // Weapon activate gets called from animation events
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

state PickingUp
{
    function bool ShouldDropShield()
    {
        local R_RunePlayer_Creature RPOwner;

        RPOwner = R_RunePlayer_Creature(Owner);
        if(RPOwner != None)
        {
            return !CanUseWeaponWithShield(RPOwner.Weapon);
        }
    }

begin:
    FindPickupItem();
    RunePlayer(Owner).LastHeldWeapon = None;
    if(PendingItem != None)
    { // Retrieve the current item
        PendingItem.LifeSpan = 0; // This item is about to be picked up, so it shouldn't go away
        PendingItem.Style = Default.Style; // Item could possibly be in fade-out alpha blend mode
            
        RunePlayer(Owner).UninterruptedAnim = 'None';
        RunePlayer(Owner).GotoState('Uninterrupted'); // Don't allow the lower-body to move while picking up		

        if(PendingItem.IsA('Food'))
        { // Save the last weapon in RunePlayer(Owner)'s hand to switch back after eating food
            RunePlayer(Owner).LastHeldWeapon = RunePlayer(Owner).Weapon;
        }

        if(RunePlayer(Owner).Weapon != None && !PendingItem.IsA('Shield') && !PendingItem.IsA('Runes'))
        { // If RunePlayer(Owner) has a weapon in his hand, stow it (or drop a weapon if it's a non-stow)
          // No need to stow the weapon if picking up a shield or rune, which are done left-handed
            if(RunePlayer(Owner).Weapon.IsA('NonStow'))
                RunePlayer(Owner).LastHeldWeapon = None;

            DoStowType = DST_STOW;
            ProxyStowWeapon(GetStowIndex(RunePlayer(Owner).Weapon));
            FinishAnim();
            if(!bDoStowExecuted) // [RMod]: Force call to DoStow if animation event never received
            {
                DoStow();
            }
        }

        // Pickup the new item		
        DoStowType = DST_PICKUP;
        RunePlayer(Owner).PlaySound(RunePlayer(Owner).WeaponPickupSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.08 + 0.96);
        ProxyPickup();
        FinishAnim();
        if(!bDoStowExecuted) // [RMod]: Force call to DoStow if animation event never received
        {
            DoStow();
        }
        ProxyDonePickup();
        if(ShouldDropShield())
        {
            RunePlayer(Owner).DropShield();
        }
        PendingItem = None;
        RunePlayer(Owner).GotoState('PlayerWalking');   
    }

    RunePlayer(Owner).SetMovementMode(); // Set combat or exploration mode

    if(RunePlayer(Owner).LastHeldWeapon == None)
    {
        SyncAnimation(0.4);
        GotoState('Idle');
    }
    else
        RetrieveLastHeldWeapon();
}

/**
*   State: Switching (override)
*   This state is originally set up to work by listening for events in animations which trigger
*   the actual inventory interactions. Because Creatures do not have animations with these events,
*   this state is overridden to force the interaction to happen.
*/
state Switching
{
    function bool ShouldDropShield()
    {
        local R_RunePlayer_Creature RPOwner;

        RPOwner = R_RunePlayer_Creature(Owner);
        if(RPOwner != None)
        {
            return !CanUseWeaponWithShield(RPOwner.Weapon);
        }
    }

begin:
    curWeapon = RunePlayer(Owner).Weapon;
    newWeapon = RunePlayer(Owner).GetStowedWeapon(index);
    nextWeapon = RunePlayer(Owner).GetNextWeapon(curWeapon);
    RunePlayer(Owner).LastHeldWeapon = None;

    if(curWeapon != None && GetStowIndex(curWeapon) == index && nextWeapon != None
        && nextWeapon != curWeapon && newWeapon != None)
    { // Swap between weapons of similar types
        DoStowType = DST_SWAP;
        ProxyStowWeapon(index);
        FinishAnim();
        if(!bDoStowExecuted) // [RMod]: Force call to DoStow if animation event never received
        {
            DoStow();
        }

        // Activate the current weapon	
        RunePlayer(Owner).Weapon.GotoState('Active');

        goto('done');
    }
    else if(curWeapon != None)
    {
        if(index >= 0)
        { // Real weapon (not fists)
            if(newWeapon == None)
            { // No weapon of type was stowed
                goto('done');
            }
        }

        DoStowType = DST_STOW;
        ProxyStowWeapon(GetStowIndex(curWeapon));
        FinishAnim();
        if(!bDoStowExecuted) // [RMod]: Force call to DoStow if animation event never received
        {
            DoStow();
        }
    }       

    if(index == -1)
    { // Fists (no weapon)
        RunePlayer(Owner).Weapon = None;
        goto('done');
    }

    if(newWeapon != None)
    {
        DoStowType = DST_RETRIEVE;
        ProxyStowWeapon(index);
        FinishAnim();
        if(!bDoStowExecuted) // [RMod]: Force call to DoStow if animation event never received
        {
            DoStow();
        }
    }

    // Retrieve the current weapon	
    if(RunePlayer(Owner).Weapon != None)
        RunePlayer(Owner).Weapon.GotoState('Active');

done:
    if(ShouldDropShield())
    {
        RunePlayer(Owner).DropShield();
    }

    if(Owner.Region.Zone.bWaterZone)
        RunePlayer(Owner).InstantStow(); // Disallow switching weapons while jumping into water
    
    RunePlayer(Owner).SetMovementMode(); // Set combat or exploration mode

    SyncAnimation(0.3);
    GotoState('Idle');
}

/**
*   State: Throwing (override)
*   Overridden to play creature-specific animations for throws and force DoThrow call
*   no matter what animation is played.
*/
state Throwing
{
    event BeginState()
    {
        bDoThrowExecuted = false;
    }

    function PlayThrowAnim()
    {
        local R_RunePlayer_Creature RPOwner;
        local Name AnimToPlay;
        local float AnimRate;

        RPOwner = R_RunePlayer_Creature(Owner);
        if(RPOwner != None)
        {
            AnimToPlay = RPOwner.A_Throw;
            AnimRate = RPOwner.A_Throw_Rate;

            if(AnimToPlay != '')
            {
                AnimRate = Clamp(AnimRate, 0.1, 2.0);
                PlayAnim(AnimToPlay, AnimRate, 0.1);
            }
        }
    }

    function DoThrow()
    {
        Super.DoThrow();
        bDoThrowExecuted = true;
    }

Begin:
    PlayThrowAnim();
    FinishAnim();
    if(!bDoThrowExecuted)
    {
        DoThrow();
    }
    RunePlayer(Owner).SetMovementMode();
    SyncAnimation(0.15);
    GoToState('Idle');
}

/*
state PickingUp
{
    function bool CanPickup(Inventory InventoryActor)
    {
        return InventoryActor == PendingPickupActor;
    }

    function UpdatePendingPickupActor()
    {
        local Pawn PawnOwner;

        PawnOwner = Pawn(Owner);
        if(PawnOwner != None && PawnOwner.UseActor != None)
        {
            if(PawnOwner.UseActor.Owner == None)
            {
                PendingPickupActor = PawnOwner.UseActor;
            }
        }
    }

    function AttachToHand()
    {
        local int WeaponJoint;
        
        if(Pawn(Owner) != None)
        {
            if(R_RunePlayer(Owner) != None)
            {
                R_RunePlayer(Owner).InstantStow();
            }
            WeaponJoint = Owner.JointNamed(Pawn(Owner).WeaponJoint);
        }

        AttachActorToJoint(PendingPickupActor, WeaponJoint);
    }

Begin:
    UpdatePendingPickupActor();
    R_RunePlayer(Owner).LastHeldWeapon = None;
    if(PendingPickupActor != None)
    {
        Inventory(PendingPickupActor).LifeSpan = 0;
        PendingPickupActor.Style = Default.Style;

        // No moving while picking up
        R_RunePlayer(Owner).UninterruptedAnim = 'None';
        R_RunePlayer(Owner).GotoState('Uninterrupted');

        if(Food(PendingPickupActor) != None)
        {
            R_RunePlayer(Owner).LastHeldWeapon = R_RunePlayer(Owner).Weapon;
        }

        if(R_RunePlayer(Owner).Weapon != None && Shield(PendingPickupActor) == None && Runes(PendingPickupActor) == None)
        {
            if(NonStow(R_RunePlayer(Owner).Weapon) != None)
            {
                R_RunePlayer(Owner).LastHeldWeapon = None;
            }
        }
    }

    //AttachToHand();
    //Sleep(0.1);
    //GoToState('Idle');
}
*/

defaultproperties
{
    DrawType=DT_SkeletalMesh
    Skeletal=SkelModel'creatures.Dwarf'
    bHidden=False
}