//=============================================================================
// AnimationProxy.
//=============================================================================
class AnimationProxy expands Keypoint
	native;


/*	Description:
	This actor controls any secondary animation on characters including
	the animation of skeletal joint groups other than 0
*/

var Weapon			curWeapon;		// Current weapon
var Weapon			newWeapon;		// Weapon being acquired
var Shield			curShield;		// Current shield
var Shield			newShield;		// Shield being acquired



//=============================================================================
//
// PostBeginPlay
//
//=============================================================================
function PostBeginPlay()
{
	Enable('Tick');
}

//=============================================================================
//
// AnimEnd
//
// Proxy animation has ended, inform the proxy owner
//=============================================================================
event AnimEnd()
{
	Owner.AnimProxyEnd();
}


//----- Animation Playing Functions -----

//=============================================================================
//
// Animation functions to be overrideen in child classes
//
//=============================================================================
function PlayPickupWeapon(){}
function PlayDropWeapon(){}
function PlayThrowWeapon(){}
function PlayPickupShield(){}
function PlayDropShield(){}
function PlayAttackLow(){}
function PlayAttackHigh(){}
function PlayAttackVertical(){}
function PlayIdle(){}
function PlayDefendLow(){}
function PlayDefendHigh(){}
function PlayDeath(){}

//=============================================================================
//
// GetGroup
//
//=============================================================================

function name GetGroup(name sequence)
{
	return('');
}

//=============================================================================
//
// TryPlayAnim
//
// The Owner has entered an animation state, inform the proxy of the
// new animation
//=============================================================================
function TryPlayAnim(Name anim, optional float rate, optional float tween)
{
	if(rate == 0.0)
	{ // Handle optional case
		rate = 1.0;
	}
	if(tween == 0.0)
	{ // Handle optional case
		tween = 0.1;
	}

	PlayAnim(anim, rate, tween);
}

//=============================================================================
//
// TryLoopAnim
//
//=============================================================================
function TryLoopAnim(Name anim, optional float rate, optional float tween)
{
	if(rate == 0.0)
	{ // Handle optional case
		rate = 1.0;
	}
	if(tween == 0.0)
	{ // Handle optional case
		tween = 0.1;
	}

	LoopAnim(anim, rate, tween);
}

//=============================================================================
//
// TryTweenAnim
//
//=============================================================================
function TryTweenAnim(Name anim, optional float tween)
{
	if(tween == 0.0)
	{ // Handle optional case
		tween = 0.1;
	}

	TweenAnim(anim, tween);
}

//=============================================================================
//
// SyncAnimation
//
// Tries to sync the current proxy anim to the master anim
//=============================================================================
function SyncAnimation(float tween)
{
	PlayAnim(Owner.AnimSequence, 1.0, tween);
}

//=============================================================================
//
// WeaponActivate
//
// WeaponActivate Notify
//=============================================================================
function WeaponActivate()
{
	Pawn(Owner).bSwingingHigh = true;
	Pawn(Owner).bSwingingLow  = false;
}

//=============================================================================
//
// WeaponDeactivate
//
//=============================================================================
function WeaponDeactivate()
{
	Pawn(Owner).bSwingingHigh = false;
	Pawn(Owner).bSwingingLow  = false;
}


//=============================================================================
//
// CanGotoPainState
//
//=============================================================================

function bool CanGotoPainState()
{
	return(true);
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
	return(false);
}

//=============================================================================
//
// State specific functions
//
//=============================================================================
function		AcquireInventory(Inventory item)	{					}
function bool	Attack()							{	return(false);	}
function		StopAttack()						{					}
function bool	Defend()							{	return(false);	}
function bool	Throw()								{	return(false);	}
function bool	Pickup()							{	return(false);	}
function bool	Use()								{	return(false);	}


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
	// Attack
	//
	//=========================================================================
	function bool Attack()
	{
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
		GotoState('Defending');
		return(true);
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
	
	//=========================================================================
	// not tested
	// use to auto-sync proxy with parent each time anim ends
	//=========================================================================
	/*
	function AnimEnd()
	{
		// Sync up animation with owner
		if (AnimSequence != Owner.AnimSequence)
		{
			SyncAnimation(0.1);
		}
	}
	*/
}



//-----------------------------------------------------------------------------
//
// Acquiring
//
//-----------------------------------------------------------------------------
state Acquiring
{
	ignores TryPlayAnim, TryLoopAnim, TryTweenAnim;

begin:
	if (newWeapon != None)
	{	// Acquiring weapon
	
		// Drop current weapon if any
		if (curWeapon != None)
		{
			PlayDropWeapon();
			FinishAnim();
			//Goblin.DropWeapon();
		}

		// attach new weapon
		Pawn(Owner).Weapon.GotoState('Active');
		newWeapon = None;
	}
	else
	{	// Acquiring shield
		if (curShield != None)
		{
			PlayDropShield();
			FinishAnim();
			//Goblin.DropShield();
		}

		Pawn(Owner).Shield.GotoState('Active');
	}

done:
	SyncAnimation(0.4);
	GotoState('Idle');
}


//-----------------------------------------------------------------------------
//
// Attacking
//
//-----------------------------------------------------------------------------
state Attacking
{
	ignores TryPlayAnim, TryLoopAnim, TryTweenAnim;

	function EndState()
	{
		WeaponDeactivate();
	}
	
	//=========================================================================
	//
	// StopAttack
	//
	//=========================================================================
	function StopAttack()
	{		
		SyncAnimation(0.3);
		GotoState('Idle');
	}

	//=========================================================================
	//
	// Defend
	// 
	//=========================================================================
	function bool Defend()
	{
		GotoState('Defending');
		return(true);
	}

	//=========================================================================
	//
	// PlayAttackAnim
	// 
	//=========================================================================
	function PlayAttackAnim()
	{
		PlayAnim('AttackA', 1.0, 0.1);
	}

begin:
	PlayAttackHigh();
	FinishAnim();

	SyncAnimation(0.3);
	GotoState('Idle');
}



//-----------------------------------------------------------------------------
//
// Defending
//
//-----------------------------------------------------------------------------
state Defending
{
	ignores TryPlayAnim, TryLoopAnim, TryTweenAnim;

	function StopDefending()
	{
		GotoState('Defending', 'end');
	}

end:
	SyncAnimation(0.3);	
	GotoState('Idle');

begin:
	PlayDefendHigh();
}



//-----------------------------------------------------------------------------
//
// Throwing
//
//-----------------------------------------------------------------------------
state Throwing
{
	ignores TryPlayAnim, TryLoopAnim, TryTweenAnim;

	//=========================================================================
	//
	// DoThrow
	// 
	//=========================================================================
	function DoThrow()
	{
		Pawn(Owner).TossWeapon();
	}

begin:
	PlayThrowWeapon();
	FinishAnim();

	SyncAnimation(0.3);
	GotoState('Idle');
}

//-----------------------------------------------------------------------------
//
// Dying
//
//-----------------------------------------------------------------------------

state Dying
{
	ignores TryPlayAnim, TryLoopAnim, TryTweenAnim;

begin:
}

defaultproperties
{
     bStatic=False
     bFrameNotifies=True
     NetPriority=3.000000
}
