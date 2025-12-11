//==============================================================================
//	R_BTB_DecoratorBuilder
//==============================================================================
class R_BTB_DecoratorBuilder extends R_BTB_ActionBuilder;

var private R_BTI_DecoratorInstance BehaviorDecoratorInstance;

//------------------------------------------------------------------------------

function R_BTI_DecoratorInstance GetBehaviorDecoratorInstance()
{
	if(BehaviorDecoratorInstance == None)
	{
		BehaviorDecoratorInstance = R_BTI_DecoratorInstance(GetBehaviorActionInstance());
	}
	return BehaviorDecoratorInstance;
}

// Only valid on conditional decorators
function R_BTB_DecoratorBuilder SetAbortType(int AbortType)
{
	return Self;
}

function R_BTB_DecoratorBuilder SetParameter(Name ParamName, R_Variant Value)
{
	InternalSetParameter(ParamName, Value);
	return Self;
}