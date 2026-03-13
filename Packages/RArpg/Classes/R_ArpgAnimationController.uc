//==============================================================================
//	R_ArpgAnimationController
//==============================================================================
class R_ArpgAnimationController extends R_ArpgAnimationInterface;

var private Class<R_ArpgAnimationSet> AnimationSetDefaultClass;
var private Class<R_ArpgAnimationSet> AnimationSetClass;

var private Class<R_ArpgAnimationSetSelector> AnimationSetSelectorClass;

var private Actor ActorOwner;

var private Name ActiveAnimation;
var private Name ActiveProxyAnim;

//------------------------------------------------------------------------------
// Event name sent to CallbackObject
const ANIM_EVENT_CANCELED = 'AnimCanceled';
const ANIM_EVENT_COMPLETED = 'AnimCompleted';

// Internal animation completion result
const ANIM_RESULT_CANCELED = 'Canceled';
const ANIM_RESULT_COMPLETED = 'Completed';

const ANIM_STATUS_IDLE = 'Idle';
const ANIM_STATUS_PLAYING = 'Playing';
struct R_ArpgPlayAnimState
{
	var Name AnimSequence;
	var Name Slot;
	var R_ArpgObject CallbackObject;
	var Name Status;
};
var private R_ArpgPlayAnimState PlayAnimState;
//------------------------------------------------------------------------------

function InitializeArpgObject()
{
	ActorOwner = Actor(Outer);
	InitializePlayAnimState();
}

function InitializePlayAnimState()
{
	PlayAnimState.AnimSequence = 'None';
	PlayAnimState.Slot = 'None';
	PlayAnimState.CallbackObject = None;
	PlayAnimState.Status = ANIM_STATUS_IDLE;
}

//------------------------------------------------------------------------------

function Tick(float DeltaSeconds)
{
	TickPlayAnimState(DeltaSeconds);
}

//------------------------------------------------------------------------------

function GetPlayAnimState(
	out Name AnimSequence,
	out Name Slot,
	out R_ArpgObject CallbackObject,
	out String StatusString)
{
	AnimSequence = PlayAnimState.AnimSequence;
	Slot = PlayAnimState.Slot;
	CallbackObject = PlayAnimState.CallbackObject;
	StatusString = String(PlayAnimState.Status);
}

function FinishPlayAnimState(Name Result)
{
	local R_ArpgEventPayload Payload;
	local Name EventName;

	if(PlayAnimState.CallbackObject != None)
	{
		EventName = 'None';
		switch(Result)
		{
		case ANIM_RESULT_CANCELED: EventName = ANIM_EVENT_CANCELED; break;
		case ANIM_RESULT_COMPLETED: EventName = ANIM_EVENT_COMPLETED; break;
		}
		if(EventName != 'None')
		{
			Payload.NameArg = PlayAnimState.AnimSequence;
			PlayAnimState.CallbackObject.ReceiveArpgEvent(EventName, Self, Payload);
		}
	}

	InitializePlayAnimState();
	if(ActorOwner != None)
	{
		ActorOwner.AnimSequence = 'None';
		ActorOwner.AnimFrame = 0.0;
		ActorOwner.AnimRate = 0.0;
		if(ActorOwner.AnimProxy != None)
		{
			ActorOwner.AnimProxy.AnimSequence = 'None';
			ActorOwner.AnimProxy.AnimFrame = 0.0;
			ActorOwner.AnimProxy.AnimRate = 0.0;
		}
	}
}

// This function's job is to basically call FinishPlayAnimState with the
// correct result when it notices that the animation is finished playing
function TickPlayAnimState(float DeltaSeconds)
{
	local bool bIsAnimSetAnywhere;
	local bool bIsAnimPlayingAnywhere;

	if(PlayAnimState.Status == ANIM_STATUS_PLAYING)
	{
		if(ActorOwner == None)
		{	// If actor owner was somehow lost, immediately cancel
			FinishPlayAnimState(ANIM_RESULT_CANCELED);
			return;
		}

		bIsAnimSetAnywhere = false;
		bIsAnimPlayingAnywhere = false;

		// Check if animation is set on the Actor
		if(ActorOwner.AnimSequence == PlayAnimState.AnimSequence)
		{
			bIsAnimSetAnywhere = true;
			// Check if the animation is playing on the Actor
			if(ActorOwner.AnimFrame < ActorOwner.AnimLast)
			{
				bIsAnimPlayingAnywhere = true;
			}
		}

		if(ActorOwner.AnimProxy != None)
		{
			// Check if the animation is active on the AnimProxy
			if(ActorOwner.AnimProxy.AnimSequence == PlayAnimState.AnimSequence)
			{
				bIsAnimSetAnywhere = true;
				// Check if the animation is playing on the AnimProxy
				if(ActorOwner.AnimProxy.AnimFrame < ActorOwner.AnimProxy.AnimLast)
				{
					bIsAnimPlayingAnywhere = true;
				}
			}
		}

		// If the animation is playing anywhere, let it go
		if(bIsAnimPlayingAnywhere)
		{
			return;
		}

		// If the anim is set anywhere but is not playing, that means it just finished
		if(bIsAnimSetAnywhere)
		{
			FinishPlayAnimState(ANIM_RESULT_COMPLETED);
			return;
		}

		// If the anim is both not set AND not playing, that means something else
		// modified the actor's animation -- we have to cancel
		FinishPlayAnimState(ANIM_EVENT_CANCELED);
		return;
	}
}

function bool TryPlayAnim(
	Name AnimSequence,
	Name SlotName,
	float Rate,
	float Tween,
	optional R_ArpgObject CallbackObject)
{
	if(ActorOwner == None)
	{
		return false;
	}

	// If anim is already playing, cancel it
	if(PlayAnimState.Status == ANIM_STATUS_PLAYING)
	{
		FinishPlayAnimState(ANIM_RESULT_CANCELED);
	}

	PlayAnimState.AnimSequence = AnimSequence;
	PlayAnimState.Slot = SlotName;
	PlayAnimState.CallbackObject = CallbackObject;
	PlayAnimState.Status = ANIM_STATUS_PLAYING;

	ActorOwner.PlayAnim(AnimSequence);//, Rate, Tween);
	if(ActorOwner.AnimProxy != None)
	{
		ActorOwner.AnimProxy.PlayAnim(AnimSequence);//, Rate, Tween);
	}

	return true;
}

function bool TryPlayStandardAnim(
	Name StandardName,
	Name SlotName,
	float Rate,
	float Tween,
	optional R_ArpgObject CallbackObject)
{
	local Class<R_ArpgAnimationSet> LocalAnimSetClass;
	local Name LocalAnimName;

	if(ActorOwner == None)
	{
		return false;
	}

	LocalAnimSetClass = GetAnimationSetClass();
	LocalAnimName = 'None';
	if(LocalAnimSetClass != None)
	{
		switch(StandardName)
		{
		case 'Death':	LocalAnimName = LocalAnimSetClass.Static.GetStaticDeathAnimation();		break;
		case 'Attack':	LocalAnimName = LocalAnimSetClass.Static.GetStaticAttackAnimation();	break;
		}
	}

	if(LocalAnimName == 'None')
	{	// Failed to find a mapped animation for the name specified
		return false;
	}

	TryPlayAnim(LocalAnimName, SlotName, Rate, Tween, CallbackObject);
}


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------




//------------------------------------------------------------------------------

function UpdateAnimationSetForTag(R_ArpgTag Tag)
{
	if(AnimationSetSelectorClass != None)
	{
		SetAnimationSetClass(AnimationSetSelectorClass.Static.GetAnimationSetClassFromTag(Tag));
	}
}

//------------------------------------------------------------------------------

function SetAnimationSetClass(Class<R_ArpgAnimationSet> NewAnimationSetClass)
{
	if(AnimationSetClass == NewAnimationSetClass)
	{
		return;
	}
	AnimationSetClass = NewAnimationSetClass;
}

function Class<R_ArpgAnimationSet> GetAnimationSetClass()
{
	if(AnimationSetClass != None)
	{
		return AnimationSetClass;
	}
	return AnimationSetDefaultClass;
}

function SetAnimationSetSelectorClass(Class<R_ArpgAnimationSetSelector> NewAnimationSetSelectorClass)
{
	if(AnimationSetSelectorClass == NewAnimationSetSelectorClass)
	{
		return;
	}
	AnimationSetSelectorClass = NewAnimationSetSelectorClass;
	if(AnimationSetSelectorClass != None)
	{
		SetAnimationSetClass(AnimationSetSelectorClass.Static.GetDefaultAnimationSetClass());
	}
}

function Class<R_ArpgAnimationSetSelector> GetAnimationSetSelectorClass()
{
	return AnimationSetSelectorClass;
}

defaultproperties
{
	AnimationSetClass=Class'RArpg.R_ArpgAnimationSet'
	AnimationSetSelectorClass=Class'RArpg.R_ArpgAnimationSetSelector'
}