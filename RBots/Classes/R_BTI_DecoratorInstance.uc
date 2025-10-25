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

function DecoratorActivated(R_Bot Bot, R_DecoratorMemory Memory)
{
	local R_BehaviorDecorator LocalDecorator;

	LocalDecorator = GetBehaviorDecorator();
	if(LocalDecorator != None)
	{
		BehaviorDecorator.DecoratorActivated(Self, Bot, Memory);
	}
}

function DecoratorDeactivated(R_Bot Bot, R_DecoratorMemory Memory)
{
	local R_BehaviorDecorator LocalDecorator;

	LocalDecorator = GetBehaviorDecorator();
	if(LocalDecorator != None)
	{
		BehaviorDecorator.DecoratorDeactivated(Self, Bot, Memory);
	}
}

function DecoratorTick(R_Bot Bot, R_DecoratorMemory Memory, float ActiveTime, float DeltaSeconds)
{
	local R_BehaviorDecorator LocalDecorator;

	LocalDecorator = GetBehaviorDecorator();
	if(LocalDecorator != None)
	{
		BehaviorDecorator.DecoratorTick(Self, Bot, Memory, ActiveTime, DeltaSeconds);
	}
}

//------------------------------------------------------------------------------

defaultproperties
{
	RequiredBehaviorActionClass=Class'RBots.R_BehaviorDecorator'
}