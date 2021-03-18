//=============================================================================
// Pump. 
//=============================================================================
class Pump extends Trigger;

/*
	Note: RepeatTriggerTime invalid for pumps
*/

var(Sounds) Sound GoingDown;
var(Sounds) Sound GoingUp;

var bool bUp;

//============================================================================
//
// GetUseAnim
//
// Returns the animation that the player (or a viking) should play when
// this item is 'used'.
//============================================================================

function name GetUseAnim()
{
	return('PumpTrigger');
}

//============================================================================
//
// CanBeUsed
//
// Whether the actor can be used.
//============================================================================

function bool CanBeUsed(Actor Other)
{
	// Can only be used if the player is facing it
	if(!Other.ActorInSector(self, ANGLE_45))
		return(false);

	return(true);
}

//============================================================================
//
// GetUsePriority
//
// Returns the priority of the weapon, lower is better
//============================================================================

function int GetUsePriority()
{
	return(5);
}

//============================================================
//
// MatterForJoint
//
// Returns what kind of material joint is associated with
//============================================================
function EMatterType MatterForJoint(int joint)
{
	return MATTER_METAL;
}


function PreBeginPlay()
{
	Super.PreBeginPlay();

	if (bInitiallyActive)
	{
		bUp = true;
		AnimSequence='up';
	}
	else
	{
		bUp = false;
		AnimSequence='down';
	}
}

// State of trigger changed, query bInitiallyActive to tell state
function ChangedState()
{
	if (bInitiallyActive)
	{
		bUp = true;
		PlaySound(GoingUp, SLOT_Misc,,,, FRand()*0.5 + 0.8);
		PlayAnim('up', 1.0, 0.5);
	}
	else
	{
		bUp = false;
		PlaySound(GoingDown, SLOT_Misc,,,, FRand()*0.5 + 0.8);
		PlayAnim('down', 1.0, 0.5);
	}
}


//--------------------------------------------------------
//
// Timer
//
//--------------------------------------------------------
function Timer()
{
	// ReTriggerDelay has expired, make trigger operable again
	bInitiallyActive = true;
	ChangedState();
}


//--------------------------------------------------------
//
// Fired
//
//--------------------------------------------------------
function Fired(actor Other)
{
	local RunePlayer P;

	// Toggle state of plunger
	if (bUp)
	{
		PlaySound(GoingDown, SLOT_Misc,,,, FRand()*0.5 + 0.8);
		PlayAnim('down', 1.0, 0.5);
		bUp = false;

		if ( ReTriggerDelay > 0 )
		{
			SetTimer(ReTriggerDelay, false);
		}
	}
	else
	{
		PlaySound(GoingUp, SLOT_Misc,,,, FRand()*0.5 + 0.8);
		PlayAnim('up', 1.0, 0.5);
		bUp = true;
	}
}


state Dormant
{
	ignores Touch, UnTouch, Timer, JointDamaged, Trigger, UseTrigger;

	function bool CanBeUsed(Actor Other)
	{
		return(false);
	}

	function BeginState()
	{
		bLookFocusPlayer=false;
	}
}

defaultproperties
{
     GoingDown=Sound'OtherSnd.Switches.switch16'
     GoingUp=Sound'OtherSnd.Switches.switch04'
     TriggerType=TT_Use
     bHidden=False
     bLookFocusPlayer=True
     AnimSequence=up
     DrawType=DT_SkeletalMesh
     LODCurve=LOD_CURVE_ULTRA_CONSERVATIVE
     CollisionRadius=20.000000
     CollisionHeight=17.000000
     bBlockActors=True
     bBlockPlayers=True
     bSweepable=True
     Skeletal=SkelModel'objects.Trigger'
     SkelGroupSkins(0)=Texture'objects.Triggertrigger'
     SkelGroupSkins(1)=Texture'objects.Triggertrigger'
     SkelGroupSkins(2)=Texture'objects.Triggertrigger'
}
