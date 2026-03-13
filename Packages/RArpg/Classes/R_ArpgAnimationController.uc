//==============================================================================
//	R_ArpgAnimationController
//==============================================================================
class R_ArpgAnimationController extends R_ArpgObject;

var private Class<R_ArpgAnimationSet> AnimationSetDefaultClass;
var private Class<R_ArpgAnimationSet> AnimationSetClass;

var private Class<R_ArpgAnimationSetSelector> AnimationSetSelectorClass;

var private Actor ActorOwner;

function SetActorOwner(Actor NewActorOwner)
{
	ActorOwner = NewActorOwner;
}

function Tick(float DeltaSeconds)
{}

//------------------------------------------------------------------------------

function UpdateAnimationSetForTag(R_ArpgTag Tag)
{
	if(AnimationSetSelectorClass != None)
	{
		SetAnimationSetClass(AnimationSetSelectorClass.Static.GetAnimationSetClassFromTag(Tag));
	}
}

//------------------------------------------------------------------------------

function PlayStandardAnimation(Name StandardName, optional float Rate, optional float Tween)
{
	local Class<R_ArpgAnimationSet> LocalAnimSetClass;
	local Name LocalAnimName;

	if(ActorOwner == None)
	{
		return;
	}

	LocalAnimSetClass = GetAnimationSetClass();
	if(LocalAnimSetClass != None)
	{
		switch(StandardName)
		{
		case 'Death':	LocalAnimName = LocalAnimSetClass.Static.GetStaticDeathAnimation();		break;
		case 'Attack':	LocalAnimName = LocalAnimSetClass.Static.GetStaticAttackAnimation();	break;
		default:
			LocalAnimName = '';
		}
	}

	ActorOwner.PlayAnim(LocalAnimName, Rate, Tween);
	if(ActorOwner.AnimProxy != None)
	{
		ActorOwner.AnimProxy.PlayAnim(LocalAnimName, Rate, Tween);
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