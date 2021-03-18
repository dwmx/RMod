//=============================================================================
// RunePlayerProxy.
//=============================================================================
class RunePlayerProxy expands AnimationProxy;

var enum DoStowType_e
{
	DST_NONE,
	DST_STOW,
	DST_RETRIEVE,
	DST_PICKUP,
	DST_SWAP
} DoStowType;

var int DoStowIndex;

var Weapon curWeapon;
var Weapon newWeapon;
var Weapon nextWeapon;
var Weapon stowWeapon;
var int index;
var byte PendingSwitchWeapon;

var Inventory PendingItem;

var Name TorsoAnim;
var Name TorsoIntroAnim;
var Name TorsoLoop; // Used for special attack types

//var Actor PowerEffect;


//=============================================================================
//
// PostBeginPlay
//
//=============================================================================

function PostBeginPlay()
{
	Super.PostBeginPlay();
	PendingSwitchWeapon = 0;
	
//	SetTimer(0.1, true);
}


// Pass frame notifies to weapon
simulated event FrameNotify(int framepassed)
{
	if (Owner != None && RunePlayer(Owner).Weapon != None)
		RunePlayer(Owner).Weapon.FrameNotify(framepassed);
}

//=============================================================================
//
// GetGroup
//
//=============================================================================

function name GetGroup(name sequence)
{
	if(RunePlayer(Owner).Weapon != None)
	{ // This only returns MoveAttack for forward and backward motions (which override the lower-body)
		if(sequence == RunePlayer(Owner).Weapon.A_AttackA)						return('MoveAttack');
		else if(sequence == RunePlayer(Owner).Weapon.A_AttackB)					return('MoveAttack');
		else if(sequence == RunePlayer(Owner).Weapon.A_AttackC)					return('MoveAttack');
		else if(sequence == RunePlayer(Owner).Weapon.A_AttackD)					return('MoveAttack');
		else if(sequence == RunePlayer(Owner).Weapon.A_AttackAReturn)			return('MoveAttack');
		else if(sequence == RunePlayer(Owner).Weapon.A_AttackBReturn)			return('MoveAttack');
		else if(sequence == RunePlayer(Owner).Weapon.A_AttackCReturn)			return('MoveAttack');
		else if(sequence == RunePlayer(Owner).Weapon.A_AttackDReturn)			return('MoveAttack');
		else if(sequence == RunePlayer(Owner).Weapon.A_AttackBackupA)			return('MoveAttack');
		else if(sequence == RunePlayer(Owner).Weapon.A_AttackBackupAReturn)		return('MoveAttack');
		else if(sequence == RunePlayer(Owner).Weapon.A_AttackBackupB)			return('MoveAttack');
		else if(sequence == RunePlayer(Owner).Weapon.A_AttackBackupBReturn)		return('MoveAttack');
	}
	else
		return(sequence);
}

//=========================================================================
//
// AcquireInventory
//
//=========================================================================

function AcquireInventory(Inventory item)
{
	local int joint;

	// Trigger any events when the item is picked up
	item.FireEvent(item.Event);
	item.Event = ''; // Clear out the event on this item 
	
	// Attach the item to the appropriate joint
	if(item.IsA('Weapon'))
	{
		RunePlayer(Owner).InstantStow();
		RunePlayer(Owner).SelectWeapon(Weapon(item));
		RunePlayer(Owner).Weapon = Weapon(item);

		curWeapon = RunePlayer(Owner).Weapon;		
		newWeapon = Weapon(item);

		if(item.IsA('NonStow'))
		{
			stowWeapon = None;
		}
		else
		{
			stowWeapon = RunePlayer(Owner).GetStowedWeapon(GetStowIndex(newWeapon));
		}

		if(curWeapon != None && curWeapon.A_Defend == 'None')
		{ // This weapon just picked up cannot be used with a shield
			RunePlayer(Owner).DropShield();
		}

		// Picked up a weapon underwater, instantly stow it
		if(Owner.IsInState('PlayerSwimming'))
		{
			RunePlayer(Owner).InstantStow();
		}
	}
	else if(item.IsA('Shield'))
	{
		RunePlayer(Owner).DropShield();
		RunePlayer(Owner).Shield = Shield(item);
	
		joint = RunePlayer(Owner).JointNamed(RunePlayer(Owner).ShieldJoint);
		if(joint != 0)
		{
			RunePlayer(Owner).AttachActorToJoint(RunePlayer(Owner).Shield, joint);
		}
	}
	else if(item.IsA('Runes'))
	{
		item.GotoState('Activated'); // TODO:  Finish Pickup functionality	
	}
	else if(item.IsA('Pickup'))
	{
//		Pickup(item).PickupFunction(Pawn(Owner));	// The pickup function is called by AcquireInventory
	}
}

//=============================================================================
//
// SyncAnimation
//
// Tries to sync the current proxy anim to the master anim
//=============================================================================

function SyncAnimation(float tween)
{
	local Name UpperName;

	if(!RunePlayer(Owner).bIsCrouching)
	{
		if(RunePlayer(Owner).Velocity.X * RunePlayer(Owner).Velocity.X + RunePlayer(Owner).Velocity.Y * RunePlayer(Owner).Velocity.Y < 1000)
		{ // Waiting
			if(RunePlayer(Owner).Weapon==None)
			{ // Exploration mode
				UpperName = 'neutral_idle';
			}
			else
			{ // Combat Mode
				UpperName = RunePlayer(Owner).Weapon.A_Idle;
			}
/*
			if(RunePlayer(Owner).Shield == None)
			{
				if(RunePlayer(Owner).Weapon == None)
				{ // Idle, no shield, no weapon
					UpperName = 'IDL_ALL_breathe1_AN0N';		
				}
				else
				{ // Idle, no shield, with a weapon
					UpperName = 'IDL_ALL_breathe1_AA0N';
				}
			}
			else
			{
				if(RunePlayer(Owner).Weapon == None)
				{ // Idle, with a shield, no weapon
					UpperName = 'IDL_ALL_breathe1_AN0S';		
				}
				else
				{ // Idle with both a shield and a weapon
					UpperName = 'IDL_ALL_breathe1_AA0S';
				}
			}
*/
		}
		else
		{ // Running	
			if(RunePlayer(Owner).Shield == None)
			{
				if(RunePlayer(Owner).Weapon == None)
				{ // Run, no shield, no weapon
					UpperName = 'MOV_ALL_run1_AN0N';
				}
				else
				{ // Run, no shield, with a weapon
					UpperName = 'MOV_ALL_run1_AA0N';
				}
			}
			else
			{
				if(RunePlayer(Owner).Weapon == None)
				{ // Run, with a shield, no weapon
					UpperName = 'MOV_ALL_run1_AN0S';
				}
				else
				{ // Run, with both a shield and a weapon
					UpperName = 'MOV_ALL_run1_AA0S';
				}
			}
		}
	}
	else
	{ // Crouching
		if(RunePlayer(Owner).Velocity.X * RunePlayer(Owner).Velocity.X + RunePlayer(Owner).Velocity.Y * RunePlayer(Owner).Velocity.Y < 1000)
		{ // Waiting
			if(RunePlayer(Owner).Shield == None)
			{
				if(RunePlayer(Owner).Weapon == None)
				{ // Idle, no shield, no weapon
					UpperName = 'IDL_ALL_crbreathe1_AN0N';		
				}
				else
				{ // Idle, no shield, with a weapon
					UpperName = 'IDL_ALL_crbreathe1_AA0N';
				}
			}
			else
			{
				if(RunePlayer(Owner).Weapon == None)
				{ // Idle, with a shield, no weapon
					UpperName = 'IDL_ALL_crbreathe1_AN0S';		
				}
				else
				{ // Idle with both a shield and a weapon
					UpperName = 'IDL_ALL_crbreathe1_AA0S';
				}
			}
		}
		else
		{ // Running	
			if(RunePlayer(Owner).Shield == None)
			{
				if(RunePlayer(Owner).Weapon == None)
				{ // Run, no shield, no weapon
					UpperName = 'MOV_ALL_crrun1_AN0N';
				}
				else
				{ // Run, no shield, with a weapon
					UpperName = 'MOV_ALL_crrun1_AA0N';
				}
			}
			else
			{
				if(RunePlayer(Owner).Weapon == None)
				{ // Run, with a shield, no weapon
					UpperName = 'MOV_ALL_crrun1_AN0S';
				}
				else
				{ // Run, with both a shield and a weapon
					UpperName = 'MOV_ALL_crrun1_AA0S';
				}
			}
		}
	}

	PlayAnim(UpperName, 1.0, tween);
}

//----- Animation Playing Functions -----

//=============================================================================
//
// ProxyStowWeapon
//
//=============================================================================

function ProxyStowWeapon(int type)
{
	DoStowIndex = type;

	if(!RunePlayer(Owner).bIsCrouching)
	{
		if(type == 0)
		{
			PlayAnim('IDL_ALL_sstow1_AA0S', 1.0, 0.1);
		}
		else if(type == 1)
		{
			PlayAnim('IDL_ALL_hstow1_AA0S', 1.0, 0.1);
		}
		else if(type == 2)
		{
			PlayAnim('IDL_ALL_xstow1_AA0S', 1.0, 0.1);
		}
		else
		{
			PlayAnim('IDL_ALL_drop1_AA0S', 1.0, 0.1);		
		}
	}
	else
	{
		if(type == 0)
		{
			PlayAnim('IDL_ALL_crsstow1_AA0N', 1.0, 0.1);
		}
		else if(type == 1)
		{
			PlayAnim('IDL_ALL_crhstow1_AA0N', 1.0, 0.1);
		}
		else if(type == 2)
		{
			PlayAnim('IDL_ALL_crxstow1_AA0N', 1.0, 0.1);
		}
		else
		{
			PlayAnim('IDL_ALL_crdrop1_AA0N', 1.0, 0.1);		
		}
	}
}

//=============================================================================
//
// ProxyDropWeapon
//
//=============================================================================

function ProxyDropWeapon()
{
	if(!RunePlayer(Owner).bIsCrouching)
	{
		PlayAnim('IDL_ALL_drop1_AA0S', 1.0, 0.1);		
	}
	else
	{
		PlayAnim('IDL_ALL_crdrop1_AA0S', 1.0, 0.1);		
	}
}

//=============================================================================
//
// ProxyPickup
//
//=============================================================================

function ProxyPickup()
{
	local float deltaZ;
	local name anim;

	deltaZ = (PendingItem.GetJointPos(0).Z - RunePlayer(Owner).Location.Z);

	if(PendingItem.IsA('Stein'))
	{ // FOOD TEST
		anim = 'DrinkLow';
		BlendAnimSequence = 'DrinkHigh';

		BlendAnimAlpha = (deltaZ + 40) / 85;
		if(BlendAnimAlpha < 0)
			BlendAnimAlpha = 0;
		else if(BlendAnimAlpha < 0)
			BlendAnimAlpha = 0;

		RunePlayer(Owner).BlendAnimSequence = BlendAnimSequence;
		RunePlayer(Owner).BlendAnimAlpha = BlendAnimAlpha;
	}
	else if(PendingItem.IsA('Food'))
	{
		anim = 'EatLow';
		BlendAnimSequence = 'EatHigh';

		BlendAnimAlpha = (deltaZ + 40) / 85;
		if(BlendAnimAlpha < 0)
			BlendAnimAlpha = 0;
		else if(BlendAnimAlpha < 0)
			BlendAnimAlpha = 0;

		RunePlayer(Owner).BlendAnimSequence = BlendAnimSequence;
		RunePlayer(Owner).BlendAnimAlpha = BlendAnimAlpha;
	}
	else if(PendingItem.IsA('Sword') 
		&& (PendingItem.Rotation.Roll & 65535) > 12000 && (PendingItem.Rotation.Roll & 65535) < 20000)
	{ // Pickup a sword that is pointing downward (stuck in something... such as a body)
		if(deltaZ <= -14)
		{ // Low, no blend
			anim = 'SwordPullOutLow';
		}
		else if(deltaZ >= 14)
		{ // Overhead, no blend
			anim = 'SwordPullOutHigh';
		}
		else
		{ // Blend to fit the desired pickup location
			anim = 'SwordPullOutLow';
			
			BlendAnimSequence = 'SwordPullOutLow';
			BlendAnimAlpha = (deltaZ + 14) / 28;
			RunePlayer(Owner).BlendAnimSequence = BlendAnimSequence;
			RunePlayer(Owner).BlendAnimAlpha = BlendAnimAlpha;
		}
	}
	else if(PendingItem.IsA('Shield') || PendingItem.IsA('Runes'))
	{ // Shields and Runes are picked up with the left hand
		// Blend to fit the desired pickup location (-40, 45)
		if(RunePlayer(Owner).Weapon == None)
		{ // Neutral
			anim = 'PickupGroundLeft'; 
			BlendAnimSequence = 'PickupHighLeft';
		}
		else
		{
			anim = RunePlayer(Owner).Weapon.A_PickupGroundLeft;
			BlendAnimSequence = RunePlayer(Owner).Weapon.A_PickupHighLeft;
		}

		BlendAnimAlpha = (deltaZ + 40) / 85;
		RunePlayer(Owner).BlendAnimSequence = BlendAnimSequence;
		RunePlayer(Owner).BlendAnimAlpha = BlendAnimAlpha;
	}
	else if(PendingItem.IsA('Weapon'))
	{
		if(deltaZ <= -40)
		{ // On the ground, no blend
			anim = 'PickupGround';
		}
		else if(deltaZ >= 45)
		{ // Overhead, no blend
			anim = 'PickupOverhead';
		}
		else
		{ // Blend to fit the desired pickup location
			anim = 'PickupWaist';
			
			if(deltaZ < 0)
			{
				BlendAnimSequence = 'PickupGround';
				BlendAnimAlpha = (-deltaZ) / 40;
				RunePlayer(Owner).BlendAnimSequence = 'PickupGround';
				RunePlayer(Owner).BlendAnimAlpha = (-deltaZ) / 40;
			}
			else
			{
				BlendAnimSequence = 'PickupOverhead';
				BlendAnimAlpha = deltaZ / 45;
				RunePlayer(Owner).BlendAnimSequence = 'PickupOverhead';
				RunePlayer(Owner).BlendAnimAlpha = deltaZ / 45;
			}
		}
	}

	PlayAnim(anim, 1.0, 0.1);		
	RunePlayer(Owner).TryPlayTorsoAnim(anim, 1.0, 0.1);
}

//=============================================================================
//
// ProxyDonePickup
//
//=============================================================================

function ProxyDonePickup()
{
	// Destroy blend info
	BlendAnimSequence = '';
	BlendAnimAlpha = 0;
	RunePlayer(Owner).BlendAnimSequence = '';
	RunePlayer(Owner).BlendAnimAlpha = 0;
}

//=============================================================================
//
// ProxyThrowWeapon
//
//=============================================================================

function ProxyThrowWeapon()
{
}

//=============================================================================
//
// ThrowGhost
//
// Notify for Throw powerup
//=============================================================================
function ThrowGhost()
{
	if (!RunePlayer(Owner).IsAnimating() || RunePlayer(Owner).AnimSequence != 'ghostthrow')
		RunePlayer(Owner).ThrowGhost();
}

//=============================================================================
//
// SwitchWeapon
//
// The player wants to switch to a given weapon number
//
// 1 - Fists
// 2 - Sword
// 3 - Hammer
// 4 - Axe
//=============================================================================

function SwitchWeapon(byte F)
{
	PendingSwitchWeapon = F;
}


//=============================================================================
//
// WeaponActivate
//
//=============================================================================

function WeaponActivate()
{
	local Weapon Weapon;

	Weapon = RunePlayer(Owner).Weapon;
	if(Weapon != None)
	{
		RunePlayer(Owner).WeaponActivate();
		RunePlayer(Owner).Weapon.PlaySwipeSound();

		// Call WeaponFire based upon the attack
		if(AnimSequence == Weapon.A_AttackA || AnimSequence == Weapon.A_AttackStandA 
			|| AnimSequence == Weapon.A_AttackBackupA || AnimSequence == Weapon.A_AttackStrafeRight
			|| AnimSequence == Weapon.A_AttackStrafeLeft)
		{
			RunePlayer(Owner).Weapon.WeaponFire(0);
		}
		else if(AnimSequence == Weapon.A_AttackB || AnimSequence == Weapon.A_AttackStandB || AnimSequence == Weapon.A_AttackBackupB)
			RunePlayer(Owner).Weapon.WeaponFire(1);
		else if(AnimSequence == Weapon.A_AttackC)
			RunePlayer(Owner).Weapon.WeaponFire(2);
		else if(AnimSequence == Weapon.A_AttackD)
			RunePlayer(Owner).Weapon.WeaponFire(3);
	}
}

//=============================================================================
//
// WeaponDeactivate
//
// Swipe Effect Notify
//=============================================================================

function WeaponDeactivate()
{
	if(RunePlayer(Owner).Weapon != None)
	{
		RunePlayer(Owner).WeaponDeactivate();
//		RunePlayer(Owner).Weapon.FinishAttack();
	}
}

//=============================================================================
//
// SwipeEffectStart
//
// Swipe Effect Notify
//=============================================================================

function SwipeEffectStart()
{
	if(RunePlayer(Owner).Weapon != None)
	{
		RunePlayer(Owner).Weapon.EnableSwipeTrail();
	}
}

//=============================================================================
//
// SwipeEffectEnd
//
// Swipe Effect Notify
//=============================================================================

function SwipeEffectEnd()
{
	if(RunePlayer(Owner).Weapon != None)
	{
		RunePlayer(Owner).Weapon.DisableSwipeTrail();
	}
}


//=============================================================================
//
// SwipeEffectCombo
//
// Swipe Effect Notify
//=============================================================================

function SwipeEffectCombo()
{
}

//=============================================================================
//
// ClearSwipeArray
//
// ClearSwipeArray Notify
//=============================================================================

function ClearSwipeArray()
{
	WeaponActivate();
}

//=============================================================================
//
// RopeClimb
//
// RopeClimb Notify
//=============================================================================

function RopeClimb()
{
	Owner.PlaySound(RunePlayer(Owner).RopeClimbSound[Rand(3)], SLOT_Interact, 
		1.0, false, 1200, FRand() * 0.08 + 0.96);
}

//=============================================================================
//
// SwimSplash
//
// Splash notify
//=============================================================================

function SwimSplash()
{
	local vector loc;

	if(RunePlayer(Owner).bSurfaceSwimming)
	{
		loc = Owner.GetJointPos(Owner.JointNamed('rwrist')) + vect(0, 0, 4);
		Spawn(class'Ripple2',,, loc);
		loc = Owner.GetJointPos(Owner.JointNamed('lwrist')) + vect(0, 0, 4);
		Spawn(class'Ripple2',,, loc);
	}
	else
	{
	}
}

//=============================================================================
//
// DoStow
//
//=============================================================================

function DoStow()
{
	local vector v;

	if(DoStowType == DST_NONE)
	{
		return;
	}
	else if(DoStowType == DST_STOW)
	{ // Stow
		if(RunePlayer(Owner).Weapon != None)
		{
			if(RunePlayer(Owner).Weapon.IsA('NonStow'))
			{
				// Play Weapon Drop Sound
				RunePlayer(Owner).PlaySound(RunePlayer(Owner).WeaponDropSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.08 + 0.96);
				RunePlayer(Owner).DropWeapon();
			}
			else
			{
				RunePlayer(Owner).StowWeapon(None);
			}
		}
	}
	else if(DoStowType == DST_RETRIEVE)
	{ // Retrieve
		RunePlayer(Owner).RetrieveWeapon(DoStowIndex);
	}	
	else if(DoStowType == DST_PICKUP && PendingItem != None)
	{ // Pickup		
		if(PendingItem.IsA('Weapon') || PendingItem.IsA('Shield') || PendingItem.IsA('Runes'))
		{ // Send a touch message to the object we are about to pick up,
		  // The actual pickup and attaching is handled in AcquireInventory
			PendingItem.Touch(RunePlayer(Owner));
		}
		else if(PendingItem.IsA('Food'))
		{
			PendingItem = PendingItem.SpawnCopy(RunePlayer(Owner));

			// NOTE:  Touch for food is handled in the notify (when they are actually activated)
			RunePlayer(Owner).AttachActorToJoint(PendingItem, RunePlayer(Owner).JointNamed(RunePlayer(Owner).WeaponJoint));
			PendingItem.SetOwner(RunePlayer(Owner));
			PendingItem.PlaySound(Food(PendingItem).UseSound);
		}
	}		
	else if(DoStowType == DST_SWAP)
	{ // Swap current weapon with the next available weapon of type
		if(RunePlayer(Owner).Weapon != None)
		{ // Stow the current weapon, swap it with the next weapon, and then retrieve the next weapon
			RunePlayer(Owner).StowWeapon(None);
			RunePlayer(Owner).SwapStowToNext(DoStowIndex);
			RunePlayer(Owner).RetrieveWeapon(DoStowIndex);
		}
	}
}

//=============================================================================
//
// InventorySpecial1
//
// Generic inventory notify, passes it onto the inventory item in Ragnar's hand
//=============================================================================

function InventorySpecial1()
{
	local actor A;

	if(RunePlayer(Owner).Weapon != None)
		RunePlayer(Owner).Weapon.InventorySpecial1();
	else
	{
		A = Owner.ActorAttachedTo(Owner.JointNamed(RunePlayer(Owner).WeaponJoint));

		if(A != None)
		{
			if(A.IsA('Inventory'))
				Inventory(A).InventorySpecial1();
			else if(A.IsA('DiscardedHealth'))
				DiscardedHealth(A).InventorySpecial1();
		}
	}
}

//=============================================================================
//
// InventorySpecial2
//
// Generic inventory notify, passes it onto the inventory item in Ragnar's hand
//=============================================================================

function InventorySpecial2()
{
	local actor A;

	if(RunePlayer(Owner).Weapon != None)
		RunePlayer(Owner).Weapon.InventorySpecial2();
	else
	{
		A = Owner.ActorAttachedTo(Owner.JointNamed(RunePlayer(Owner).WeaponJoint));

		if(A != None)
		{
			if(A.IsA('Inventory'))
				Inventory(A).InventorySpecial2();
			else if(A.IsA('DiscardedHealth'))
				DiscardedHealth(A).InventorySpecial2();
		}
	}
}

//=============================================================================
//
// InventorySpecial3
//
// Generic inventory notify, passes it onto the inventory item in Ragnar's hand
//=============================================================================

function InventorySpecial3()
{
	local actor A;

	if(RunePlayer(Owner).Weapon != None)
		RunePlayer(Owner).Weapon.InventorySpecial3();
	else
	{
		A = Owner.ActorAttachedTo(Owner.JointNamed(RunePlayer(Owner).WeaponJoint));

		if(A != None)
		{
			if(A.IsA('Inventory'))
				Inventory(A).InventorySpecial3();
			else if(A.IsA('DiscardedHealth'))
				DiscardedHealth(A).InventorySpecial3();
		}
	}
}

//=============================================================================
//
// UseNotify
//
// Notify used by animations to specify when the use should occur
//=============================================================================

function UseNotify()
{
	if(RunePlayer(Owner).UseActor != None)
		RunePlayer(Owner).UseActor.UseTrigger(RunePlayer(Owner));

	RunePlayer(Owner).UseActor = None;
}

// ----- Utility Functions -----

//=============================================================================
//
// GetStowIndex
//
//=============================================================================

function int GetStowIndex(Weapon weapon)
{
	return(Weapon.MeleeType);
}

//=============================================================================
//
// Use
//
//=============================================================================

function bool Use()
{
	return(false);
}

//=============================================================================
//
// CanPickUp
//
//=============================================================================

function bool CanPickup(Inventory item)
{
	return(false);
}

//=============================================================================
//
// WantsToPickup
//
//=============================================================================

function bool WantsToPickup(Inventory item)
{
	local Weapon cur, next, stow;

/*		
	if(RunePlayer(Owner).Physics != PHYS_Walking 
		|| (RunePlayer(Owner).Velocity.X * RunePlayer(Owner).Velocity.X + RunePlayer(Owner).Velocity.Y * RunePlayer(Owner).Velocity.Y >= 1000))
	{ // Test:  Only allow RunePlayer(Owner) to pick things up if he's standing still and on the ground
		return(false);
	}
*/
	if(item.IsA('Weapon') && !item.IsA('InvisibleWeapon'))
	{
		cur = RunePlayer(Owner).Weapon;		
		next = Weapon(item);

		if (RunePlayer(Owner).BodyPartMissing(BODYPART_RARM1))
			return false;

		// Disallow if item already held
		if (RunePlayer(Owner).FindInventoryType(item.Class) != None)
			return false;

		stow = RunePlayer(Owner).GetStowedWeapon(GetStowIndex(next));

		if(stow != None)
		{
			if(stow.IsA(next.Class.Name))
			{ // Don't pick up a weapon if it's identical to a stowed weapon
				return(false);
			}
		}

		if(cur == None)
		{
			return(true);
		}

		if(cur.IsA(next.Class.Name))
		{ // Don't pick up a weapon if it's identical to the current weapon
			return(false);
		}
		
		return(true);
	}
	else if(item.IsA('Shield'))
	{
		if (RunePlayer(Owner).BodyPartMissing(BODYPART_LARM1))
			return false;

		if(RunePlayer(Owner).Weapon != None && RunePlayer(Owner).Weapon.A_Defend == 'None')
		{ // Current weapon held cannot be used with a shield
			return(false);
		}

		if(RunePlayer(Owner).Shield != None && RunePlayer(Owner).Shield.IsA('MagicShield'))
			return(false); // Cannot swap magic shields for other shields

		return(RunePlayer(Owner).Shield == None || Shield(item).Health > RunePlayer(Owner).Shield.Health);
	}	
	else if(item.IsA('Runes'))
	{
		return(Runes(item).PawnWantsRune(Pawn(Owner)));
	}
	else if(item.IsA('Food'))
	{
		if(RunePlayer(Owner).Health < RunePlayer(Owner).MaxHealth ||
			RunePlayer(Owner).BodyPartMissing(BODYPART_LARM1) ||
			RunePlayer(Owner).BodyPartMissing(BODYPART_RARM1))
			return(true);
	}
		
	return(false);
}

//=============================================================================
//
// RetrieveLastHeldWeapon
//
//=============================================================================

function RetrieveLastHeldWeapon()
{
	if(RunePlayer(Owner).LastHeldWeapon == None)
		return;

	if(RunePlayer(Owner).LastHeldWeapon.IsA('NonStow'))
		return;

	PendingSwitchWeapon = 0;
	index = GetStowIndex(RunePlayer(Owner).LastHeldWeapon);

	RunePlayer(Owner).LastHeldWeapon = None;

	GotoState('Switching');
}

// ----- Proxy States -----

//-----------------------------------------------------------------------------
//
// Idle
//
//-----------------------------------------------------------------------------

auto state Idle
{
	//=========================================================================
	//
	// SwitchWeapon
	//
	// The player wants to switch to a given weapon number
	//
	// 1 - Fists
	// 2 - Sword
	// 3 - Hammer
	// 4 - Axe
	//=========================================================================
	
	function SwitchWeapon(byte F)
	{
		PendingSwitchWeapon = 0;
		if(F <= 4)
		{
			index = F - 2; // Subtract 2 because FISTS are weapon #1

			GotoState('Switching');
		}
	}

	//=========================================================================
	//
	// CanPickUp
	//
	// This CanPickUp is called when RunePlayer(Owner) touches a pickupable object,
	// so bAutoPickup is checked first
	//=========================================================================

	function bool CanPickup(Inventory item)
	{
		local Weapon cur, next, stow;

		if(!Level.Game.bAutoPickup && !Owner.IsInState('PlayerSwimming'))
		{ // Auto weapon pickup if autopickup is set, or if swimming
			return(false);	
		}

		if(item.IsA('Weapon') && !item.IsA('InvisibleWeapon'))
		{
			cur = RunePlayer(Owner).Weapon;
			next = Weapon(item);

			stow = RunePlayer(Owner).GetStowedWeapon(GetStowIndex(next));

			// Disallow if item already held
			if (RunePlayer(Owner).FindInventoryType(item.Class) != None)
				return false;

			// Don't allow picking up non-stow items while swimming
			if(Owner.IsInState('PlayerSwimming') && item.IsA('NonStow'))
				return(false);

			if(cur == None)
			{
				return(true);
			}
			else if(cur != None && item.IsA('NonStow'))
			{
				return(false);
			}

			return(true);
		}
		else if(item.IsA('Shield'))
		{
			if(RunePlayer(Owner).Weapon != None && RunePlayer(Owner).Weapon.A_Defend == 'None')
			{ // Current weapon held cannot be used with a shield
				return(false);
			}

			if(RunePlayer(Owner).Shield != None && RunePlayer(Owner).Shield.IsA('MagicShield'))
				return(false); // Cannot swap magic shields

			return(RunePlayer(Owner).Shield == None || Shield(item).Health > RunePlayer(Owner).Shield.Health);
		}	
		else if(item.IsA('Runes'))
		{
			return(Runes(item).PawnWantsRune(Pawn(Owner)));
		}
		else if(item.IsA('Food'))
		{
			return(RunePlayer(Owner).Health < RunePlayer(Owner).MaxHealth);
		}

		return(false);
	}

	//=========================================================================
	//
	// Use
	//
	//=========================================================================

	function bool Use()
	{
		GotoState('PickingUp');
		return(true);
	}
	
	//=========================================================================
	//
	// Attack
	//
	// Normal Attack (Double click attack is handled inside the attack state)
	// TODO:  Move this out of the idle and make it univeral (??)
	//=========================================================================
	
	function bool Attack()
	{
		local float dp;
		local vector X, Y, Z;
		local bool bRight;
		local int i;

		TorsoIntroAnim = 'None';
		TorsoLoop = 'None';

		if(RunePlayer(Owner).Weapon == None || RunePlayer(Owner).Weapon.A_AttackA == 'None')
			return(false);

		// Determine the direction the player is attempting to move
		GetAxes(RunePlayer(Owner).Rotation, X, Y, Z);
		dp = vector(RunePlayer(Owner).Rotation) dot Normal(RunePlayer(Owner).Acceleration);

		if(Normal(RunePlayer(Owner).Acceleration) dot Y >= 0)
		{
			bRight = true;
		}
		else
		{
			bRight = false;
		}

		if(RunePlayer(Owner).bIsCrouching)
		{ // Crouch attack
			if(dp < 0.9 && dp > -0.9)
			{ // Strafing
				if(bRight)
				{ // Strafe right
				TorsoAnim = RunePlayer(Owner).Weapon.A_AttackStrafeRight;
				}
				else
				{ // Strafe left
				TorsoAnim = RunePlayer(Owner).Weapon.A_AttackStrafeLeft;
				}
			}
			else
				TorsoAnim = RunePlayer(Owner).Weapon.A_AttackStrafeRight;

			GotoState('Attacking');
			return(true);
		}

		if(RunePlayer(Owner).Velocity.X * RunePlayer(Owner).Velocity.X + RunePlayer(Owner).Velocity.Y * RunePlayer(Owner).Velocity.Y < 1000)
		{ // Standing Still
			TorsoAnim = RunePlayer(Owner).Weapon.A_AttackStandA;		
		}
		else if(dp > 0.9)
		{ // Distinctly forward
			if(RunePlayer(Owner).AnimSequence == RunePlayer(Owner).Weapon.A_Jump)
			{ // Jump Attack and moving forward results in a special spin attack
				TorsoAnim = RunePlayer(Owner).Weapon.A_JumpAttack;
				
				GotoState('Attacking');
				return(true);			
			}
			else
			{
				TorsoAnim = RunePlayer(Owner).Weapon.A_AttackA;		
			}
		}
		else if(dp < -0.9)
		{ // Distinctly backward
			TorsoAnim = RunePlayer(Owner).Weapon.A_AttackBackupA;
		}
		else if(bRight)
		{ // Strafe right
			TorsoAnim = RunePlayer(Owner).Weapon.A_AttackStrafeRight;
		}
		else
		{ // Strafe left
			TorsoAnim = RunePlayer(Owner).Weapon.A_AttackStrafeLeft;
		}
		
		// If berserking, play a random berserk yell (if an enemy is nearby)
		if(RunePlayer(Owner).bBloodLust && RunePlayer(Owner).LookTarget != None
			&& RunePlayer(Owner).LookTarget.IsA('Pawn'))
		{
			i = Rand(6);
			RunePlayer(Owner).PlaySound(RunePlayer(Owner).BerserkYellSound[i], 
				SLOT_Talk, 1.0, false, 1200, FRand() * 0.08 + 0.96);			
		}	

		GotoState('Attacking');

		return(true);
	}
	
	//=========================================================================
	//
	// Defend
	// 
	//=========================================================================
	
	function bool Defend()
	{
		if(RunePlayer(Owner).Shield != None)
		{
			GotoState('Defending');
			return(true);
		}
		else
			return(false);
	}

	//=========================================================================
	//
	// Throw
	//
	//=========================================================================
	
	function bool Throw()
	{
		GotoState('Throwing');
		return(true);
	}

begin:
	if(RunePlayer(Owner).bAltFire == 1 && RunePlayer(Owner).Shield != None)
	{
		GotoState('Defending');
	}
	else if(PendingSwitchWeapon != 0)
	{
		SwitchWeapon(PendingSwitchWeapon);
	}
}

//-----------------------------------------------------------------------------
//
// Switching
//
//-----------------------------------------------------------------------------

state Switching
{
	function TryPlayAnim(Name anim, optional float rate, optional float tween) {}
	function TryLoopAnim(Name anim, optional float rate, optional float tween) {}
	function TryTweenAnim(Name anim, optional float tween) {}

	function bool CanGotoPainState()
	{
		return(false);
	}

	//==========================================================================
	//
	// CanPickUp
	//
	//==========================================================================

	function bool CanPickup(Inventory item)
	{
		return(false);
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
	}

	// Retrieve the current weapon	
	if(RunePlayer(Owner).Weapon != None)
		RunePlayer(Owner).Weapon.GotoState('Active');

done:		
	if(RunePlayer(Owner).Weapon != None && RunePlayer(Owner).Weapon.A_Defend == 'None')
	{ // This weapon just switched to cannot be used with a shield
		RunePlayer(Owner).DropShield();
	}

	if(Owner.Region.Zone.bWaterZone)
		RunePlayer(Owner).InstantStow(); // Disallow switching weapons while jumping into water
	
	RunePlayer(Owner).SetMovementMode(); // Set combat or exploration mode

	SyncAnimation(0.3);
	GotoState('Idle');
}

//-----------------------------------------------------------------------------
//
// PickingUp
//
//-----------------------------------------------------------------------------

state PickingUp
{
	function TryPlayAnim(Name anim, optional float rate, optional float tween) {}
	function TryLoopAnim(Name anim, optional float rate, optional float tween) {}
	function TryTweenAnim(Name anim, optional float tween) {}

	function EndState()
	{
	}

	function bool CanGotoPainState()
	{
		return(false);
	}
	
	//=========================================================================
	//
	// CanPickUp
	//
	//=========================================================================

	function bool CanPickup(Inventory item)
	{
		return(item == PendingItem);
	}

	//=========================================================================
	//
	// FindPickupItem
	// 
	//=========================================================================

	function FindPickupItem()
	{
		PendingItem = None;
		
		if(RunePlayer(Owner).UseActor.Owner != None)
		{
			return;
		}

		PendingItem = Inventory(RunePlayer(Owner).UseActor);
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
		}

		// Pickup the new item		
		DoStowType = DST_PICKUP;
		RunePlayer(Owner).PlaySound(RunePlayer(Owner).WeaponPickupSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.08 + 0.96);
		ProxyPickup();
		FinishAnim();
		ProxyDonePickup();
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


//-----------------------------------------------------------------------------
//
// Attacking
//
//-----------------------------------------------------------------------------

state Attacking
{
	function TryPlayAnim(Name anim, optional float rate, optional float tween) {}
	function TryLoopAnim(Name anim, optional float rate, optional float tween) {}
	function TryTweenAnim(Name anim, optional float tween) {}

	//==========================================================================
	//
	// CanPickUp
	//
	//==========================================================================

	function bool CanPickup(Inventory item)
	{
		return(false);
	}

	//=========================================================================
	//
	// BeginState
	//
	//=========================================================================

	function BeginState()
	{
		SwipeEffectStart(); // Guarantee that the swipe effect is turned on
	}

	//=========================================================================
	//
	// EndState
	//
	//=========================================================================

	function EndState()
	{
		WeaponDeactivate(); // Guarantee that the weapon is cold
		SwipeEffectEnd(); // Guarantee that the swipe effect is turned off
	}

	//=========================================================================
	//
	// StopAttack
	//
	//=========================================================================
	
	function StopAttack()
	{		
		WeaponDeactivate();
		SyncAnimation(0.3);
		SwipeEffectEnd(); // Guarantee that the swipe effect is turned off
		
		GotoState('Idle');
	}

	//=========================================================================
	//
	// Attack
	//
	// In the middle of an attack.  Can only combo if the attack allows it
	// Also controls taking over the player control for certain attacks
	//=========================================================================

	function bool Attack()
	{			
		if(RunePlayer(Owner).bIsCrouching)
			return(false); // No combos when crouching

		if(RunePlayer(Owner).Weapon == None)
			return(false);

		if(AnimSequence == RunePlayer(Owner).Weapon.A_AttackStandA && RunePlayer(Owner).Weapon.A_AttackStandB != 'None')
			TorsoAnim = RunePlayer(Owner).Weapon.A_AttackStandB;
		else if(AnimSequence == RunePlayer(Owner).Weapon.A_AttackA && RunePlayer(Owner).Weapon.A_AttackB != 'None')
			TorsoAnim = RunePlayer(Owner).Weapon.A_AttackB;
		else if(AnimSequence == RunePlayer(Owner).Weapon.A_AttackB && RunePlayer(Owner).Weapon.A_AttackC != 'None')
			TorsoAnim = RunePlayer(Owner).Weapon.A_AttackC;
		else if(AnimSequence == RunePlayer(Owner).Weapon.A_AttackC && RunePlayer(Owner).Weapon.A_AttackD != 'None')
			TorsoAnim = RunePlayer(Owner).Weapon.A_AttackD;
		else if(AnimSequence == RunePlayer(Owner).Weapon.A_AttackBackupA && RunePlayer(Owner).Weapon.A_AttackBackupB != 'None')
			TorsoAnim = RunePlayer(Owner).Weapon.A_AttackBackupB;


		return(true);
	}

	//=========================================================================
	//
	// Defend
	// 
	// Defending is not allowed in the middle of an attack
	//=========================================================================

	function bool Defend()
	{
		return(true);
	}

	//=========================================================================
	//
	// PlayAttack
	// 
	//=========================================================================

	function PlayAttack(float tween)
	{
		PlayAnim(TorsoAnim, 1.0, tween);
		RunePlayer(Owner).TryPlayTorsoAnim(TorsoAnim, 1.0, tween);
	}

begin:
doattack:
	if(RunePlayer(Owner).Weapon != None)
	{
//CJR		if(TorsoAnim != RunePlayer(Owner).Weapon.A_JumpAttack)
//CJR			RunePlayer(Owner).SpeedScale = SS_Other;

		PlayAttack(0.1); // Attack A
		Sleep(0.1); // Time to tween to the attack
		WeaponActivate(); // Activate the weapon for the attack (AFTER the tween)
		TorsoAnim = 'None';
		FinishAnim();
		WeaponDeactivate();

		if(TorsoAnim != 'None')
		{ // Combo B
			PlayAttack(0.0); // Attack B
			TorsoAnim = 'None';
			FinishAnim();
			WeaponDeactivate();

			if(TorsoAnim != 'None')
			{ // Combo C
				PlayAttack(0.0); // Attack C
				TorsoAnim = 'None';
				FinishAnim();
				WeaponDeactivate();

				if(TorsoAnim != 'None')
				{ // Combo D
					PlayAttack(0.0); // Attack D
					TorsoAnim = 'None';
					FinishAnim();
					WeaponDeactivate();

					if(RunePlayer(Owner).Weapon.A_AttackDReturn != 'None')
					{ // Return C
						TorsoAnim = RunePlayer(Owner).Weapon.A_AttackDReturn;
						PlayAttack(0.0);
						TorsoAnim = 'None';
						FinishAnim();
					}
				}
				else if(RunePlayer(Owner).Weapon.A_AttackCReturn != 'None')
				{ // Return C
					TorsoAnim = RunePlayer(Owner).Weapon.A_AttackCReturn;
					PlayAttack(0.0);
					TorsoAnim = 'None';
					FinishAnim();
				}
			}
			else if(AnimSequence == RunePlayer(Owner).Weapon.A_AttackB && RunePlayer(Owner).Weapon.A_AttackBReturn != 'None')
			{ // Return B
				TorsoAnim = RunePlayer(Owner).Weapon.A_AttackBReturn;
				PlayAttack(0.0);
				TorsoAnim = 'None';
				FinishAnim();
			}
			else if(AnimSequence == RunePlayer(Owner).Weapon.A_AttackBackupB && RunePlayer(Owner).Weapon.A_AttackBackupBReturn != 'None')
			{ // Backup Return B
				TorsoAnim = RunePlayer(Owner).Weapon.A_AttackBackupBReturn;
				PlayAttack(0.0);
				TorsoAnim = 'None';
				FinishAnim();
			}
			else if(AnimSequence == RunePlayer(Owner).Weapon.A_AttackStandB && RunePlayer(Owner).Weapon.A_AttackStandBReturn != 'None')
			{ // Stand Return B
				TorsoAnim = RunePlayer(Owner).Weapon.A_AttackStandBReturn;
				PlayAttack(0.0);
				TorsoAnim = 'None';
				FinishAnim();
			}
		}
		else if(AnimSequence == RunePlayer(Owner).Weapon.A_AttackA && RunePlayer(Owner).Weapon.A_AttackAReturn != 'None')
		{ // Return A
			TorsoAnim = RunePlayer(Owner).Weapon.A_AttackAReturn;
			PlayAttack(0.0);
			TorsoAnim = 'None';
			FinishAnim();
		}
		else if(AnimSequence == RunePlayer(Owner).Weapon.A_AttackBackupA && RunePlayer(Owner).Weapon.A_AttackBackupAReturn != 'None')
		{ // Backup Return A
			TorsoAnim = RunePlayer(Owner).Weapon.A_AttackBackupAReturn;
			PlayAttack(0.0);
			TorsoAnim = 'None';
			FinishAnim();
		}
		else if(AnimSequence == RunePlayer(Owner).Weapon.A_AttackStandA && RunePlayer(Owner).Weapon.A_AttackStandAReturn != 'None')
		{ // Stand Return A
			TorsoAnim = RunePlayer(Owner).Weapon.A_AttackStandAReturn;
			PlayAttack(0.0);
			TorsoAnim = 'None';
			FinishAnim();
		}
		
		WeaponDeactivate();
		RunePlayer(Owner).SetMovementMode();
	}

done:
	SyncAnimation(0.01);
	GotoState('Idle');
}

//-----------------------------------------------------------------------------
//
// Defending
//
//-----------------------------------------------------------------------------

state Defending
{
	function TryPlayAnim(Name anim, optional float rate, optional float tween) {}
	function TryLoopAnim(Name anim, optional float rate, optional float tween) {}
	function TryTweenAnim(Name anim, optional float tween) {}

	//==========================================================================
	//
	// CanPickUp
	//
	//==========================================================================

	function bool CanPickup(Inventory item)
	{
		return(false);
	}

	//=========================================================================
	//
	// BeginState
	// 
	//=========================================================================

	function BeginState()
	{
		PlayDefend();
		RunePlayer(Owner).ActivateShield(true);
	}

	function AnimEnd()
	{	
		local name anim;

		if(RunePlayer(Owner).Weapon == None)
		{ // Neutral
			anim = 'neutral_defendTo';
		}
		else
		{ // Weapon-specific
			anim = RunePlayer(Owner).Weapon.A_Defend;
		}

		if(AnimSequence == anim)
			PlayDefendIdle();
	}

	//=========================================================================
	//
	// EndState
	// 
	//=========================================================================

	function EndState()
	{
		RunePlayer(Owner).ActivateShield(false);
	}

	//=========================================================================
	//
	// PlayDefend
	//
	//=========================================================================

	function PlayDefend()
	{
		local name anim;

		if(RunePlayer(Owner).Weapon == None)
		{ // Neutral
			anim = 'h3_defendTO';
		}
		else
		{ // Weapon-specific
			anim = RunePlayer(Owner).Weapon.A_Defend;
		}

		PlayAnim(anim, 1.5, 0.01);

		// Only play the anim on the legs if Ragnar isn't crouching
		if(!RunePlayer(Owner).bIsCrouching)
			RunePlayer(Owner).TryPlayTorsoAnim(anim, 1.0, 0.08); 
	}

	//=========================================================================
	//
	// PlayDefendIdle
	//
	//=========================================================================

	function PlayDefendIdle()
	{
		if(RunePlayer(Owner).Weapon == None)
		{
			if(RunePlayer(Owner).bIsCrouching)
				LoopAnim('crouch_defendidle', 1.0, 0.1);
			else
				LoopAnim('h3_defendIdle', 1.0, 0.1);
		}
		else
		{
			LoopAnim(RunePlayer(Owner).Weapon.A_DefendIdle, 1.0, 0.1);
		}
	}

	//=========================================================================
	//
	// SwitchWeapon
	// 
	//=========================================================================

	function SwitchWeapon(byte F)
	{
		PendingSwitchWeapon = 0;
		if(F <= 4)
		{
			index = F - 2; // Subtract 2 because FISTS are weapon #1
			
			GotoState('Switching');
		}
	}
	
begin:
	if(RunePlayer(Owner).bAltFire == 1 && RunePlayer(Owner).Shield != None)
	{
		Sleep(0.01);
		goto('begin');
	}

	RunePlayer(Owner).ActivateShield(false);
	SyncAnimation(0.15);	
	GotoState('Idle');
}

//-----------------------------------------------------------------------------
//
// Throwing
//
//-----------------------------------------------------------------------------

state Throwing
{
	function TryPlayAnim(Name anim, optional float rate, optional float tween) {}
	function TryLoopAnim(Name anim, optional float rate, optional float tween) {}
	function TryTweenAnim(Name anim, optional float tween) {}

	//==========================================================================
	//
	// CanPickUp
	//
	//==========================================================================

	function bool CanPickup(Inventory item)
	{
		return(false);
	}

	//=========================================================================
	//
	// PlayThrowAnim
	// 
	//=========================================================================

	function PlayThrowAnim()
	{
		PlayAnim(RunePlayer(Owner).Weapon.A_Throw, 1.0, 0.1);		
		RunePlayer(Owner).TryPlayTorsoAnim(RunePlayer(Owner).Weapon.A_Throw, 1.0, 0.1);
	}

	//=========================================================================
	//
	// DoThrow
	// 
	//=========================================================================
	
	function DoThrow()
	{
		RunePlayer(Owner).ThrowWeapon();
	}

begin:
	PlayThrowAnim();
	FinishAnim();

	RunePlayer(Owner).SetMovementMode(); // Set combat or exploration mode

	SyncAnimation(0.15);
	
	GotoState('Idle');
}

//=============================================================================
//
// Pain
//
//=============================================================================

state Pain
{
	function TryPlayAnim(Name anim, optional float rate, optional float tween) {}
	function TryLoopAnim(Name anim, optional float rate, optional float tween) {}
	function TryTweenAnim(Name anim, optional float tween) {}

	function bool CanGotoPainState()
	{
		return(false);
	}

	//==========================================================================
	//
	// CanPickUp
	//
	//==========================================================================

	function bool CanPickup(Inventory item)
	{
		return(false);
	}

Begin:
	Sleep(RunePlayer(Owner).PainDelay);

	// Make certain that RunePlayer(Owner)'s movement type is proper, because painstate is
	// pre-emptive and the movement type could be in a bizarre state when pain is inflicted
	RunePlayer(Owner).SetMovementMode();
	SyncAnimation(0.08);
	GotoState('Idle');
}

//=============================================================================
//
// Uninterrupted
//
//=============================================================================

state Uninterrupted
{
	function TryPlayAnim(Name anim, optional float rate, optional float tween) {}
	function TryLoopAnim(Name anim, optional float rate, optional float tween) {}
	function TryTweenAnim(Name anim, optional float tween) {}

	//==========================================================================
	//
	// CanPickUp
	//
	//==========================================================================

	function bool CanPickup(Inventory item)
	{
		return(false);
	}

	function bool CanGotoPainState()
	{
		return(false);
	}

	simulated function AnimEnd()
	{
		GotoState('Idle');
	}

begin:
}

//=============================================================================
//
// PlayerRopeClimbing
//
//=============================================================================

state PlayerRopeClimbing
{
	ignores TryPlayAnim, TryLoopAnim, TryTweenAnim, SwitchWeapon;

begin:
}

//=============================================================================
//
// EdgeHanging
//
//=============================================================================

state EdgeHanging
{
	ignores SwitchWeapon, Attack, Defend, Use, Throw;

begin:
}

//=============================================================================
//
// Debug
//
//=============================================================================

simulated function Debug(Canvas canvas, int mode)
{
	local vector pos1, pos2;	// testing sweep
	local vector offset;
	local actor A,BestActor;
	local float score,BestScore;
	local int X,Y;

	Super.Debug(canvas, mode);

	Canvas.DrawText("RunePlayerProxy:");
	Canvas.CurY -= 8;
}

defaultproperties
{
}
