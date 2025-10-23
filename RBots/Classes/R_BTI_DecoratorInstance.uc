//==============================================================================
//	R_BTI_DecoratorInstance
//	Represents an individual instance of an R_BehaviorDecorate in a BehaviorTree
//==============================================================================
class R_BTI_DecoratorInstance extends R_BehaviorActionInstance;

const LogCategory = 'BehaviorDecoratorInstance';

var private R_BehaviorDecorator BehaviorDecorator;

//------------------------------------------------------------------------------

function R_BehaviorDecorator GetBehaviorDecorator()
{
	if(BehaviorDecorator == None)
	{
		BehaviorDecorator = R_BehaviorDecorator(GetBehaviorAction());
	}
	return BehaviorDecorator;
}

//------------------------------------------------------------------------------

defaultproperties
{
	RequiredBehaviorActionClass=Class'RBots.R_BehaviorDecorator'
}