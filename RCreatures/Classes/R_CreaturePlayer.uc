//==============================================================================
//  R_CreaturePlayer
//	Base class for all playable creatures
//	The bulk of the creature functionality is split between this class and
//	R_CreaturePlayerProxy
//
//	If you are not familiar with original RunePlayer/RunePlayerProxy setup:
//
//	RunePlayerProxy is an invisible actor which controls the upper body
//	animations along with functionality associated with those animations
//		i.e. Use, Attack, Throw, Defend
//
//	RunePlayer is the actual controlled Pawn class, plays looping animations
//	(like Run, Falling, Crouch) on the lower body and tells the AnimProxy
//	what animations to play
//
//	CreaturePlayer/CreaturePlayerProxy is set up the same way
//==============================================================================
class R_CreaturePlayer extends R_RunePlayer config;

// Attack directions -- These need to match those in R_CreaturePlayerProxy
const AD_Neutral 	= 0;
const AD_Forward 	= 1;
const AD_Backward 	= 2;
const AD_Left 		= 3;
const AD_Right 		= 4;
const AD_Invalid 	= -1;

var float ThrowStrengthMultiplier;

// Relevant skeletal joints
var Name AttachAxeJoint;
var Name AttachSwordJoint;
var Name AttachHammerJoint;

// If true, this creature can hold shields with 2 handers
var bool bCanHoldShieldWithTwoHandedWeapons;

state EdgeHanging
{
    function PlayPullUp(optional float Tween)
    {
        PlayStepUp(Tween);
    }

    function PlayStepUp(optional float Tween)
    {
        // play sound
        PlayAnim('pullupB', 1.0, tween);
        if(AnimProxy != None)
        {
            AnimProxy.TryPlayAnim('pullupB', 1.0, tween);
        }
    }

    function AnimEnd()
    {
        PlayWaiting(0.2);

        // Done climbing
        if(AnimProxy != None)
        {
            AnimProxy.GoToState('Idle');
        }

        GoToState('PlayerWalking');
    }
}

exec function AltFire( optional float F )
{
    PlayAltFiring();
}

function PlayAltFiring()
{
    if(AnimProxy != None)
    {
        AnimProxy.Defend();
    }
}

/**
*	Fire (override)
*	Overridden to call PlayFiring even when there is no Weapon
*/
exec function Fire( optional float F )
{
	bJustFired = true;
	if( bShowMenu || (Level.Pauser!="") || (Role < ROLE_Authority) )
		return;

	//if(Weapon != None)
		PlayFiring();
}

function PlayThrow()
{
    // TODO: Optionally play animation here
}

/**
*	CalcThrowMagnitudeForWeapon
*	Called from ThrowWeapon to determine how far this creature can throw a given weapon
*/
function CalcThrowMagnitudeForWeapon(Weapon ThrownWeapon, out float ThrowXMagnitude, out float ThrowZMagnitude)
{
    ThrowXMagnitude = ThrowStrengthMultiplier * 7500.0 / ThrownWeapon.Mass;
    ThrowXMagnitude = Clamp(ThrowXMagnitude, 0.0, 750.0);

    ThrowZMagnitude = ThrowStrengthMultiplier * 2000.0 / ThrownWeapon.Mass;
    ThrowZMagnitude = Clamp(ThrowZMagnitude, 0.0, 200.0); 
}

/**
*   ThrowWeapon (override)
*   Allows creatures to throw farther than other Players via CalcThrowMagnitudeForWeapon
*/
function ThrowWeapon()
{
    local Actor ParentActor;
    local int AttachJoint;
    local Vector X, Y, Z;
    local Vector Extent;
    local Vector WeaponLocation;
    local Vector HitLocation, HitNormal;
    local Weapon ThrownWeapon;
    local float ThrowXMagnitude, ThrowZMagnitude;

    if(Weapon == None)
    {
        return;
    }

    ParentActor = GetAttachmentParentActor();
    AttachJoint = ParentActor.JointNamed(WeaponJoint);
    ParentActor.DetachActorFromJoint(AttachJoint);

    GetAxes(ViewRotation, X, Y, Z);

    Extent.X = Weapon.CollisionRadius;
    Extent.Y = Weapon.CollisionRadius;
    Extent.Z = Weapon.CollisionRadius;

    WeaponLocation = GetJointPos(AttachJoint);

    if(Trace(HitLocation, HitNormal, WeaponLocation, Location, true, Extent) != None)
    {
        WeaponLocation = Location;
    }

    Weapon.SetLocation(WeaponLocation);

    ThrownWeapon = Weapon;
    DeleteInventory(Weapon);
    ThrownWeapon.SetOwner(Self);

    CalcThrowMagnitudeForWeapon(ThrownWeapon, ThrowXMagnitude, ThrowZMagnitude);

    ThrownWeapon.Velocity = X * ThrowXMagnitude + Z * ThrowZMagnitude;
    ThrownWeapon.GoToState('Throw');
}

//==============================================================================
//	Animation related functions
//==============================================================================
/**
*	LoopAnimWithProxy
*	Loop an animation on CreaturePlayer and attempt to loop that same animation
*	on the CreaturePlayerProxy
*/
function LoopAnimWithProxy(Name AnimName, float Rate, float Tween)
{
    LoopAnim(AnimName, Rate, Tween);
    if(AnimProxy != None)
    {
        AnimProxy.TryLoopAnim(AnimName, Rate, Tween);
    }
}

/**
*	PlayAnimWithProxy
*	Play an animation on CreaturePlayer and attempt to play that same animation
*	on the CreaturePlayerProxy
*/
function PlayAnimWithProxy(Name AnimName, float Rate, float Tween)
{
    PlayAnim(AnimName, Rate, Tween);
    if(AnimProxy != None)
    {
        AnimProxy.TryPlayAnim(AnimName, Rate, Tween);
    }
}

/**
*	Falling (override)
*	Overridden to correctly route animation calls to PlayInAir and PlayFalling
*
*	- PlayInAir: Plays when the Creature is falling and the ground is near
*	- PlayFalling: Plays when the Creature is falling with no ground in sight
*/
function Falling()
{
    local Vector TraceStart,TraceEnd;

    TraceStart = Location;
    TraceEnd = TraceStart + Vect(0,0,-1) * CollisionHeight * 2.5;

    if(FastTrace(TraceEnd, TraceStart))
    {
        PlayInAir(0.1);
    }
    else
    {
        PlayFalling(0.1);
    }
}

/**
*	LongFall (override)
*	Overridden to route call to new function PlayLongFalling
*	Original game code doesn't appear to implement this in any of the main player classes,
*	so it's probably not very useful, but still copied from some creature class scripts
*/
function LongFall()
{
	PlayLongFalling(0.1);
}

/**
*   PlayDying (override)
*   Overridden to catch DamageTypes 'fell' and 'fire' and pass animation control to appropriate functions
*	Super.PlayDying routes PlayAnimation call to the rest of the dying functions
*/
function PlayDying(Name DamageType, vector HitLoc)
{
    if(DamageType == 'fell')
    {
        PlayFellDeath(DamageType);
    }
    else if(DamageType == 'fire')
    {
        PlayFireDeath(DamageType);
    }
    else
    {
        Super.PlayDying(DamageType, HitLoc);
    }
}

/**
*	SelectDirectionalAttackAnimation
*	Called from CreaturePlayerProxy when determining what attack to play
*/
function Name SelectDirectionalAttackAnimation(int AttackDirection, int AttackChainIndex)
{ return 'None'; }

/**
*	SelectDefendAnimation
*	Called from CreaturePlayerProxy when determining what defend animation to play
*/
function Name SelectDefendAnimation()
{ return 'None'; }

/**
*   SelectTauntAnim (Override)
*   Select the taunt animation to play when triggered
*/
function Name SelectTauntAnim()
{ return 'None'; }

/**
*   SelectThrowAnim
*   Called by CreaturePlayerProxy to select the throw animation to play
*   when throwing the current weapon.
*/
function Name SelectThrowAnim()
{ return 'None'; }

/**
*	SelectPickupAnim
*	Called by CreaturePlayerProxy to select the pickup animation to play
*	when grabbing Inventorys
*/
function SelectPickupAnim(out Name OutAnimToPlay, out float OutAnimRate) {}

//==============================================================================
//	PlayAnimation functions
//	All of these are overridden to avoid playing R_RunePlayer animation
//
//	All creatures are different enough that there's no base code for these here,
//	they should be implemented individually per creature
//
//	These are most likely the only animation functions you will need to override
//==============================================================================
// Movement animations
function PlayWaiting(optional float Tween)		{}
function PlayMoving(optional float Tween)		{}
function PlayJump()								{}
function PlayDuck(optional float Tween)			{}
function PlayInAir(optional float Tween)		{}	// In air
function PlayFalling(optional float Tween)		{}	// In air, ground is near
function PlayLongFalling(optional float Tween)	{}	// In air for a long time
function PlayLanding(optional float Tween)		{}

// Pain animations
function PlayFrontHit(optional float Tween)		{}
function PlayBackHit(optional float Tween)  	{ PlayFrontHit(Tween);  }
function PlayLeftHit(optional float Tween)  	{ PlayFrontHit(Tween);  }
function PlayRightHit(optional float Tween)		{ PlayFrontHit(Tween);  }
function PlayHeadHit(optional float Tween)  	{ PlayFrontHit(Tween);  }
function PlayDrowning(optional float Tween)		{}

// Death animations
function PlayFellDeath(Name DamageType)			{}
function PlayDeath(Name DamageType)				{}
function PlayBackDeath(name DamageType)     	{ PlayDeath(DamageType); }
function PlayLeftDeath(name DamageType)     	{ PlayDeath(DamageType); }
function PlayRightDeath(name DamageType)    	{ PlayDeath(DamageType); }
function PlayHeadDeath(name DamageType)     	{ PlayDeath(DamageType); }
function PlaySkewerDeath(name DamageType)   	{ PlayDeath(DamageType); }
function PlayFireDeath(Name DamageType)     	{ PlayDeath(DamageType); }
function PlayDrownDeath(name DamageType)    	{}
//==============================================================================

/**
*   GetAttachmentParentActor
*   Return the actor that Inventory actors should attach to
*/
function Actor GetAttachmentParentActor()
{
    return Self;
}

/**
*   DropWeapon (override)
*   Overridden to detach weapon from AnimProxy instead of Self
*   See R_CreaturePlayerProxy for more details
*/
function DropWeapon()
{
    local Actor ParentActor;
    local int AttachedJoint;
    local Vector X, Y, Z;

    if(Weapon == None)
    {
        return;
    }

    if(Weapon.bPoweredUp)
    {
        Weapon.PowerupEnd();
    }

    ParentActor = GetAttachmentParentActor();
    AttachedJoint = ParentActor.JointNamed(WeaponJoint);

    if(AttachedJoint != 0)
    {
        ParentActor.DetachActorFromJoint(AttachedJoint);

        GetAxes(Rotation, X, Y, Z);
        Weapon.DropFrom(GetJointPos(AttachedJoint));

        if(Weapon != None)
        {
            Weapon.SetPhysics(PHYS_Falling);
            Weapon.Velocity = Y * 100 + X * 75;
            Weapon.Velocity.Z = 50;
            Weapon.GotoState('Drop');
            Weapon.DisableSwipeTrail();

            DeleteInventory(Weapon);
        }
    }
}

/**
*   DropShield (override)
*   Overridden to detach shield from AnimProxy instead of Self
*   See R_CreaturePlayerProxy for more details
*/
function DropShield()
{
    local Actor ParentActor;
    local int AttachedJoint;
    local Vector X, Y, Z;

    if(Shield == None)
    {
        return;
    }

    ParentActor = GetAttachmentParentActor();
    AttachedJoint = ParentActor.JointNamed(ShieldJoint);

    if(AttachedJoint != 0)
    {
        ParentActor.DetachActorFromJoint(AttachedJoint);

        GetAxes(Rotation, X, Y, Z);

        Shield.DropFrom(GetJointPos(AttachedJoint));
        Shield.SetPhysics(PHYS_Falling);
        Shield.Velocity = Y * 100 + X * 75;
        Shield.Velocity.Z = 50;
        Shield.GoToState('Drop');

        DeleteInventory(Shield);
    }
}

/**
*   SelectWeapon (override)
*   Overridden to attach selected weapons to the AnimProxy instead of Self
*   See R_CreaturePlayerProxy for more details
*/
function SelectWeapon(Weapon NewWeapon)
{
    local Actor ParentActor;
    local int AttachJoint;

    Weapon = NewWeapon;

    ParentActor = GetAttachmentParentActor();

    AttachJoint = ParentActor.JointNamed(WeaponJoint);
    if(AttachJoint != 0)
    {
        ParentActor.AttachActorToJoint(Weapon, AttachJoint);
    }
}

/**
*   GetStowAttachJointForMeleeType
*   Returns the joint index for attaching weapon categories (axes, hammers, swords)
*/
function int GetStowAttachJointForMeleeType(Actor ParentActor, Weapon WeaponActor)
{
    switch(WeaponActor.MeleeType)
    {
    case MELEE_SWORD:   return ParentActor.JointNamed(AttachSwordJoint);
    case MELEE_AXE:     return ParentActor.JointNamed(AttachAxeJoint);
    case MELEE_HAMMER:  return ParentActor.JointNamed(AttachHammerJoint);
    default:            return 0;
    }
}

/**
*   StowWeapon (override)
*   Overridden to attach stowed weapons to the AnimProxy instead of Self
*   See R_CreaturePlayerProxy for more details
*/
function StowWeapon(Weapon OldWeapon)
{
    local Actor ParentActor;
    local int StowAttachJoint;
    local int EquipAttachJoint;
    local int StowIndex;

    if(Weapon == None)
    {
        return;
    }

    ParentActor = GetAttachmentParentActor();

    StowAttachJoint = GetStowAttachJointForMeleeType(ParentActor, Weapon);

    EquipAttachJoint = ParentActor.JointNamed(WeaponJoint);

    if(StowAttachJoint != 0 && EquipAttachJoint != 0)
    {
        ParentActor.DetachActorFromJoint(EquipAttachJoint);
        ParentActor.AttachActorToJoint(Weapon, StowAttachJoint);

        if(R_RunePlayerProxy(AnimProxy) != None)
        {
            StowIndex = R_RunePlayerProxy(AnimProxy).GetStowIndex(Weapon);
        }
        SetStowedWeapon(StowIndex, Weapon);
        Weapon.GoToState('Stow');
        Weapon = None;
    }
}

/**
*   GetAttachJointForStowIndex
*   Return the joint index associated with the given ParentActor for the specified StowIndex.
*   Determines which joint to stow a weapon at based on type.
*/
function int GetAttachJointForStowIndex(Actor ParentActor, int StowIndex)
{
    switch(StowIndex)
    {
    case 0:     return ParentActor.JointNamed(AttachSwordJoint);// MELEE_SWORD
    case 1:     return ParentActor.JointNamed(AttachHammerJoint);// MELEE_HAMMER
    case 2:     return ParentActor.JointNamed(AttachAxeJoint);// MELEE_AXE
    default:    return 0;
    }
}

/**
*   RetrieveWeapon (override)
*   Overridden to attach retrieved weapons to the AnimProxy instead of Self
*   See R_CreaturePlayerProxy for more details
*/
function RetrieveWeapon(int StowIndex)
{
    local Actor ParentActor;
    local int StowAttachJoint;
    local Weapon CurrentWeapon;
    local Weapon NextWeapon;

    ParentActor = GetAttachmentParentActor();

    StowAttachJoint = GetAttachJointForStowIndex(ParentActor, StowIndex);

    CurrentWeapon = GetStowedWeapon(StowIndex);
    if(StowAttachJoint != 0 && CurrentWeapon != None)
    {
        ParentActor.DetachActorFromJoint(StowAttachJoint);
        SelectWeapon(CurrentWeapon);

        SetStowedWeapon(StowIndex, None);
        NextWeapon = GetNextWeapon(CurrentWeapon);
        if(NextWeapon != None && NextWeapon != CurrentWeapon)
        {
            ParentActor.AttachActorToJoint(NextWeapon, StowAttachJoint);
            NextWeapon.bHidden = false;
            SetStowedWeapon(StowIndex, NextWeapon);
        }
    }
}

/**
*   SwapStowToNext (override)
*   Overridden to attach stowed weapons to the AnimProxy instead of Self
*   See R_CreaturePlayerProxy for more details
*/
function SwapStowToNext(int StowIndex)
{
    local Actor ParentActor;
    local int StowAttachJoint;
    local Weapon StowedWeapon;
    local Weapon NextWeapon;

    ParentActor = GetAttachmentParentActor();

    StowedWeapon = GetStowedWeapon(StowIndex);
    if(StowedWeapon != None)
    {
        NextWeapon = GetNextWeapon(StowedWeapon);
        if(NextWeapon != None && NextWeapon != StowedWeapon)
        {
            StowedWeapon.bHidden = true;
            NextWeapon.bHidden = false;

            StowAttachJoint = GetAttachJointForStowIndex(ParentActor, StowIndex);

            if(StowAttachJoint != 0)
            {
                ParentActor.DetachActorFromJoint(StowAttachJoint);
                ParentActor.AttachActorToJoint(NextWeapon, StowAttachJoint);
                SetStowedWeapon(StowIndex, NextWeapon);
            }
        }
    }
}

defaultproperties
{
    GroundSpeed=240.000000
    AccelRate=1000.000000
    JumpZ=400.000000
    MaxStepHeight=30.000000
    WalkingSpeed=160.000000
    HitSound1=Sound'CreaturesSnd.Dwarves.hit02'
    HitSound2=Sound'CreaturesSnd.Dwarves.word26'
    HitSound3=Sound'CreaturesSnd.Dwarves.hit07'
    Die=Sound'CreaturesSnd.Dwarves.death09'
    Die2=Sound'CreaturesSnd.Dwarves.death10'
    Die3=Sound'CreaturesSnd.Dwarves.death12'
    FootStepWood(0)=None
    FootStepWood(1)=None
    FootStepWood(2)=None
    FootStepMetal(0)=Sound'FootstepsSnd.Metal.footmetal10'
    FootStepMetal(1)=Sound'FootstepsSnd.Metal.footmetal11'
    FootStepMetal(2)=Sound'FootstepsSnd.Metal.footmetal12'
    FootStepStone(0)=Sound'FootstepsSnd.Earth.footgravel13'
    FootStepStone(1)=Sound'FootstepsSnd.Earth.footgravel12'
    FootStepStone(2)=Sound'FootstepsSnd.Earth.footgravel13'
    FootStepIce(0)=Sound'FootstepsSnd.Ice.footice04'
    FootStepIce(1)=Sound'FootstepsSnd.Ice.footice05'
    FootStepIce(2)=Sound'FootstepsSnd.Ice.footice06'
    FootStepEarth(0)=Sound'FootstepsSnd.Earth.footgravel03'
    FootStepEarth(1)=Sound'FootstepsSnd.Earth.footgravel05'
    FootStepEarth(2)=Sound'FootstepsSnd.Earth.footgravel06'
    FootStepSnow(0)=Sound'FootstepsSnd.Snow.footsnow10'
    FootStepSnow(1)=Sound'FootstepsSnd.Snow.footsnow11'
    FootStepSnow(2)=Sound'FootstepsSnd.Snow.footsnow12'
    WeaponJoint=attach_hand
    ShieldJoint=attach_shielda
    CollisionRadius=24.000000
    CollisionHeight=33.000000
    Skeletal=SkelModel'creatures.Dwarf'
    SkelMesh=0
    SpawnableAnimationProxyClass=Class'RCreatures.R_CreaturePlayerProxy'
    bFrameNotifies=true
    AttachAxeJoint=attach_axe
    AttachSwordJoint=attatch_sword
    AttachHammerJoint=attach_hammer
    bCanHoldShieldWithTwoHandedWeapons=true
    ThrowStrengthMultiplier=1.0
}