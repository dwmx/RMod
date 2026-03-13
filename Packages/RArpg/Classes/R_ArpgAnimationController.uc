//==============================================================================
//	R_ArpgAnimationController
//==============================================================================
class R_ArpgAnimationController extends R_ArpgObject;

var private Class<R_ArpgAnimationSet> AnimationSetDefaultClass;
var private Class<R_ArpgAnimationSet> AnimationSetClass;

var private Class<R_ArpgAnimationSetSelector> AnimationSetSelectorClass;

var private Actor ActorOwner;

var private Name ActiveAnimation;
var private Name ActiveProxyAnim;

function InitializeArpgObject()
{
	ActorOwner = Actor(Outer);
}

function Tick(float DeltaSeconds)
{
	TickActiveAnimation(DeltaSeconds);
}

//------------------------------------------------------------------------------

function PlayAnimation(Name AnimSequence, optional float Rate, optional float Tween)
{
	if(ActorOwner == None)
	{
		return;
	}

	if(ActiveAnimation != '')
	{
		Log("ANIMATION CANCELED");
	}

	ActiveAnimation = AnimSequence;
	//ActorOwner.PlayAnim(AnimSequence, Rate, Tween);
	ActorOwner.LoopAnim(AnimSequence, Rate, Tween);
	if(ActorOwner.AnimProxy != None)
	{
		ActiveProxyAnim = AnimSequence;
		//ActorOwner.AnimProxy.PlayAnim(AnimSequence, Rate, Tween);
		ActorOwner.AnimProxy.LoopAnim(AnimSequence, Rate, Tween);
	}
}

function TickActiveAnimation(float DeltaSeconds)
{
	if(ActorOwner != None)
	{
		if(ActiveAnimation != '')
		{
			if(ActorOwner.AnimSequence != ActiveAnimation)
			{
				ActiveAnimation = '';
				Log("ANIMATION ENDED BECAUSE OWNERS ANIM CHANGED");
			}

			if(ActorOwner.AnimFrame >= ActorOwner.AnimLast)
			{
				ActiveAnimation = '';
				Log("ANIMATION ENDED BECAUSE IT TIMED OUT");
			}
		}


		if(ActorOwner.AnimProxy != None && ActiveProxyAnim != '')
		{
			if(ActorOwner.AnimProxy.AnimSequence != ActiveProxyAnim)
			{
				ActiveProxyAnim = '';
				Log("anim proxy anim ended because anim chagned");
			}

			if(ActorOwner.AnimProxy.AnimFrame >= ActorOwner.AnimProxy.AnimLast)
			{
				ActiveProxyAnim = '';
				Log("anim proxy anim ended because it timed out");
			}
		}
	}
}

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

	PlayAnimation(LocalAnimName, Rate, Tween);
	//ActorOwner.PlayAnim(LocalAnimName, Rate, Tween);
	//if(ActorOwner.AnimProxy != None)
	//{
	//	ActorOwner.AnimProxy.PlayAnim(LocalAnimName, Rate, Tween);
	//}
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