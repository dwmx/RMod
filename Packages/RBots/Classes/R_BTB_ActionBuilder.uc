//==============================================================================
//	R_BTB_ActionBuilder
//	Object for building and configuring BehaviorAction objects within a tree
//==============================================================================
class R_BTB_ActionBuilder extends R_RBotsObject abstract;

var private R_BehaviorActionInstance BehaviorActionInstance;

//------------------------------------------------------------------------------

function R_BehaviorActionInstance GetBehaviorActionInstance()
{
	return BehaviorActionInstance;
}

function SetBehaviorActionInstance(R_BehaviorActionInstance NewBehaviorActionInstance)
{
	BehaviorActionInstance = NewBehaviorActionInstance;
}

function InternalSetParameter(Name ParamName, R_Variant Value)
{
	BehaviorActionInstance.SetParameter(ParamName, Value);
}