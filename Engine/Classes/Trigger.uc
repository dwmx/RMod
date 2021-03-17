//=============================================================================
// Trigger: senses things happening in its proximity and generates 
// sends Trigger/UnTrigger to actors whose names match 'EventName'.
//=============================================================================
class Trigger extends Triggers
	native;

#exec Texture Import File=Textures\Trigger.pcx Name=S_Trigger Mips=Off Flags=2

//-----------------------------------------------------------------------------
// Trigger variables.

// Trigger type.
var() enum ETriggerType
{
	TT_PlayerProximity,	// Trigger is activated by player proximity.
	TT_PawnProximity,	// Trigger is activated by any pawn's proximity
	TT_ClassProximity,	// Trigger is activated by actor of that class only
	TT_AnyProximity,    // Trigger is activated by any actor in proximity.
	TT_Shoot,		    // Trigger is activated by player shooting it.
	TT_Damage,			// Trigger is activated by taking damage
	TT_Use,				// Trigger is activated by being used
	TT_Sight,			// RUNE: Trigger is activated when the player sees it (rendered)
} TriggerType;

// Human readable triggering message.
var() localized string Message;

// Only trigger once and then go dormant.
var() bool bTriggerOnceOnly;

// For triggers that are activated/deactivated by other triggers.
var() bool bInitiallyActive;

var() class<actor> ClassProximityType;

var() float	RepeatTriggerTime; //if > 0, repeat trigger message at this interval is still touching other
var() float ReTriggerDelay; //minimum time before trigger can be triggered again
var	  float TriggerTime;
var() float DamageThreshold; //minimum damage to trigger if TT_Shoot, TT_Damage

var() float	SightDistance;	// RUNE: for TT_Sight, the distance before it is triggered (<=0 denotes infinite)
var() float SightAngle;		// RUNE: for TT_Sight, the angle on-screen before it is triggered

// AI vars
var	actor TriggerActor;	// actor that triggers this trigger
var actor TriggerActor2;

//=============================================================================
// AI related functions

function PostBeginPlay()
{
	if ( !bInitiallyActive )
		FindTriggerActor();
	if ( TriggerType == TT_Shoot )
	{
		bHidden = false;
		bProjTarget = true;
		DrawType = DT_None;
	}
	
	if(TriggerType == TT_Damage)
	{
		 bSweepable = True;
	}
		
	Super.PostBeginPlay();
}

function FindTriggerActor()
{
	local Actor A;

	TriggerActor = None;
	TriggerActor2 = None;
	ForEach AllActors(class 'Actor', A)
		if ( A.Event == Tag)
		{
			if ( Counter(A) != None )
				return; //FIXME - handle counters
			if (TriggerActor == None)
				TriggerActor = A;
			else
			{
				TriggerActor2 = A;
				return;
			}
		}
}

function Actor SpecialHandling(Pawn Other)
{
	local int i;

	if ( bTriggerOnceOnly && !bCollideActors )
		return None;

	if ( (TriggerType == TT_PlayerProximity) && !Other.bIsPlayer )
		return None;

	if ( !bInitiallyActive )
	{
		if ( TriggerActor == None )
			FindTriggerActor();
		if ( TriggerActor == None )
			return None;
		if ( (TriggerActor2 != None) 
			&& (VSize(TriggerActor2.Location - Other.Location) < VSize(TriggerActor.Location - Other.Location)) )
			return TriggerActor2;
		else
			return TriggerActor;
	}

	// is this a shootable trigger?
	if ( TriggerType == TT_Shoot || TriggerType == TT_Damage)
	{
		if ( !Other.bCanDoSpecial || (Other.Weapon == None) )
			return None;

		Other.Target = self;
		Other.bShootSpecial = true;
//		Other.FireWeapon();
		Other.bFire = 0;
		Other.bAltFire = 0;
		return Other;
	}

	// can other trigger it right away?
	if ( IsRelevant(Other) )
	{
		for (i=0;i<4;i++)
			if (Touching[i] == Other)
				Touch(Other);
		return self;
	}

	return self;
}

// when trigger gets turned on, check its touch list

function CheckTouchList()
{
	local int i;

	for (i=0;i<4;i++)
		if ( Touching[i] != None )
			Touch(Touching[i]);
}

// State of trigger changed, query bInitiallyActive to tell state
function ChangedState()
{
}


//=============================================================================
// Trigger states.

// Trigger is always active.
state() NormalTrigger
{
}

// Other trigger toggles this trigger's activity.
state() OtherTriggerToggles
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		bInitiallyActive = !bInitiallyActive;
		ChangedState();
		if ( bInitiallyActive )
			CheckTouchList();
	}
}

// Other trigger turns this on.
state() OtherTriggerTurnsOn
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		local bool bWasActive;

		bWasActive = bInitiallyActive;
		bInitiallyActive = true;
		ChangedState();
		if ( !bWasActive )
			CheckTouchList();
	}
}

// Other trigger turns this off.
state() OtherTriggerTurnsOff
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		bInitiallyActive = false;
		ChangedState();
	}
}

state Dormant
{
	ignores Touch, UnTouch, Timer, JointDamaged, Trigger, UseTrigger;
}


//=============================================================================
// Trigger logic.


//--------------------------------------------------------
//
// Fired
//
// Happens when fired by any means (happens once per triggering)
//--------------------------------------------------------
function Fired(actor Other)
{
}


//--------------------------------------------------------
//
// TriggerAction
//
// This is the action that happens to each receiver when I am triggered
// Override this for different trigger types
//--------------------------------------------------------
function TriggerAction(actor Receiver, actor Cause, Pawn EventInstigator)
{
	Receiver.Trigger(Cause, EventInstigator);
}


//--------------------------------------------------------
//
// UnTriggerAction
//
// This is the action that happens to each receiver when I am un-triggered
// Override this for different trigger types
//--------------------------------------------------------
function UnTriggerAction(actor Receiver, actor Cause, Pawn EventInstigator)
{
	Receiver.UnTrigger( Cause, EventInstigator );
}


//
// See whether the other actor is relevant to this trigger.
//
function bool IsRelevant( actor Other )
{
	if( !bInitiallyActive )
		return false;
	switch( TriggerType )
	{
		case TT_PlayerProximity:
			return Pawn(Other)!=None && Pawn(Other).bIsPlayer;
		case TT_PawnProximity:
			return Pawn(Other)!=None && ( Pawn(Other).Intelligence > BRAINS_None );
		case TT_ClassProximity:
			return ClassIsChildOf(Other.Class, ClassProximityType);
		case TT_AnyProximity:
			return true;
		case TT_Shoot:
			return ( (Projectile(Other) != None) && (Projectile(Other).Damage >= DamageThreshold) );
		case TT_Damage:
			return false;
		case TT_Use:
			return false;
		case TT_Sight:
			return Pawn(Other)!=None && Pawn(Other).bIsPlayer;
	}
}



//=============================================================================
// Stimuli

// Used for RepeatTrigger (only valid for TT_Touch)
function Timer()
{
	local bool bKeepTiming;
	local int i;

	bKeepTiming = false;

	for (i=0;i<4;i++)
		if ( (Touching[i] != None) && IsRelevant(Touching[i]) )
		{
			bKeepTiming = true;
			Touch(Touching[i]);
		}

	if ( bKeepTiming )
		SetTimer(RepeatTriggerTime, false);
}


//
// Called when something touches the trigger.
//
function Touch( actor Other )
{
	local actor A;
	if( IsRelevant( Other ) )
	{
		if ( ReTriggerDelay > 0 )
		{
			if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
				return;
			TriggerTime = Level.TimeSeconds;
		}
		Fired(Other);
		// Broadcast the Trigger message to all matching actors.
		if( Event != '' )
			foreach AllActors( class 'Actor', A, Event )
				TriggerAction(A, Other, Other.Instigator);

		if ( Other.IsA('Pawn') && (Pawn(Other).SpecialGoal == self) )
			Pawn(Other).SpecialGoal = None;
				
		if( Message != "" )
			// Send a string message to the toucher.
			Other.Instigator.ClientMessage( Message );

		if( bTriggerOnceOnly )
			// Ignore future touches.
			SetCollision(False);
		else if ( RepeatTriggerTime > 0 )
			SetTimer(RepeatTriggerTime, false);
	}
}

//
// Called when something damages the trigger
//
function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
{
	local actor A;

	if ( bInitiallyActive && (TriggerType==TT_Shoot || TriggerType==TT_Damage) && (Damage >= DamageThreshold) && (EventInstigator != None) )
	{
		if ( ReTriggerDelay > 0 )
		{
			if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
				return true;
			TriggerTime = Level.TimeSeconds;
		}
		Fired(EventInstigator);
		// Broadcast the Trigger message to all matching actors.
		if( Event != '' )
			foreach AllActors( class 'Actor', A, Event )
				TriggerAction(A, EventInstigator, EventInstigator);

		if( Message != "" )
			// Send a string message to the toucher.
			EventInstigator.Instigator.ClientMessage( Message );

		if( bTriggerOnceOnly )
			// Ignore future touches.
			SetCollision(False);
	}
	return true;
}


//
// Called when somethings uses trigger
//
function bool UseTrigger(actor Other)
{
	local actor A;
	
	if(Other == None)
		return(false);

	if (bInitiallyActive && TriggerType == TT_Use)
	{
		if ( ReTriggerDelay > 0 )
		{
			if ( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
				return false;
			TriggerTime = Level.TimeSeconds;
		}
		Fired(Other);
		// Broadcast the Trigger message to all matching actors.
		if( Event != '' )
			foreach AllActors( class 'Actor', A, Event )
				TriggerAction(A, Other, Other.Instigator);

		if ( Other.IsA('Pawn') && (Pawn(Other).SpecialGoal == self) )
			Pawn(Other).SpecialGoal = None;
				
		if( Message != "" && Other.Instigator != None)
			// Send a string message to the toucher.
			Other.Instigator.ClientMessage( Message );

		if( bTriggerOnceOnly )	// Ignore future stimuli
			GotoState('Dormant');

		return true;
	}
	return false;
}


//
// When something untouches the trigger.
//
function UnTouch( actor Other )
{
	local actor A;
	if( IsRelevant( Other ) )
	{
		// Untrigger all matching actors.
		if( Event != '' )
			foreach AllActors( class 'Actor', A, Event )
				UntriggerAction(A, Other, Other.Instigator);
	}
}

defaultproperties
{
     bInitiallyActive=True
     InitialState=NormalTrigger
     Texture=Texture'Engine.S_Trigger'
}
