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
//	The original player model, Ragnar, was set up with this JointGroup data,
//	but the original creature meshes, like goblin and dwarf, were NOT set up
//	with this data.
//
//	To get AnimProxy to work with creature meshes, you can use the custom
//	HTK editor engine to export meshes as SCM, and then reimport with modified
//	jointgroup data. Thanks to "nah" for creating the HTK editor tools.
//==============================================================================
class R_CreaturePlayerProxy extends R_RunePlayerProxy;

// Attack directions -- These need to match those in R_CreaturePlayer
const AD_Neutral 	= 0;
const AD_Forward 	= 1;
const AD_Backward 	= 2;
const AD_Left 		= 3;
const AD_Right 		= 4;
const AD_Invalid 	= -1;

var Name TorsoAnim;
var Actor PendingPickupActor;

var bool bDoStowExecuted;
var bool bDoThrowExecuted;

event BeginPlay()
{
    Super.BeginPlay();
    Skeletal = Owner.Skeletal;
    SkelMesh = Owner.SkelMesh;
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
    local R_CreaturePlayer RPOwner;
    local Name AnimToPlay;
    local float AnimRate;

    bDoStowExecuted = false;

    RPOwner = R_CreaturePlayer(Owner);
    if(RPOwner != None)
    {
        RPOwner.SelectPickupAnim(AnimToPlay, AnimRate);
    }

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
    local R_CreaturePlayer RPOwner;

    if(WeaponActor == None)
    {
        return true;
    }

    RPOwner = R_CreaturePlayer(Owner);
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

	function int DetermineInitialAttackDirection()
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
		local int AttackDirection;
        local Name InitialAttackAnim;
		local R_CreaturePlayer CreatureOwner;

		InitialAttackAnim = 'None';
		CreatureOwner = R_CreaturePlayer(Owner);
		if(CreatureOwner != None)
		{
			AttackDirection = DetermineInitialAttackDirection();
			InitialAttackAnim = CreatureOwner.SelectDirectionalAttackAnimation(AttackDirection, 0);
		}

		if(InitialAttackAnim != 'None')
		{
			TorsoAnim = InitialAttackAnim;
        	GotoState('Attacking');
			return true;
		}
		else
		{
			TorsoAnim = 'None';
			return false;
		}
        
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
		local R_CreaturePlayer CreatureOwner;
		local Name AnimToPlay;

		AnimToPlay = 'None';
		CreatureOwner = R_CreaturePlayer(Owner);
		if(CreatureOwner != None)
		{
			AnimToPlay = CreatureOwner.SelectDefendAnimation();
		}

		if(AnimToPlay != 'None')
		{
			PlayAnim(AnimToPlay, 1.0, 0.1);
			TorsoAnim = AnimToPlay;
		}
		else
		{
			TorsoAnim = 'None';
		}
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
        local R_CreaturePlayer RPOwner;

        RPOwner = R_CreaturePlayer(Owner);
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
        local R_CreaturePlayer RPOwner;

        RPOwner = R_CreaturePlayer(Owner);
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
        local R_CreaturePlayer RPOwner;
        local Name AnimToPlay;

        RPOwner = R_CreaturePlayer(Owner);
        if(RPOwner != None)
        {
            AnimToPlay = RPOwner.SelectThrowAnim();
        }
        PlayAnim(AnimToPlay, 1.0, 0.1);
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

defaultproperties
{
}