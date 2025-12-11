//==============================================================================
//	R_BTNode_Decorator
//	Behavior Tree node containing a Decorator
//==============================================================================
class R_BTNode_Decorator extends R_BTNode_Action;

var private R_BTI_DecoratorInstance DecoratorInstance;

function String GetNodeDisplayString()
{
	return "Decorator";
}

function R_BTI_DecoratorInstance GetDecoratorInstance()
{
	if(DecoratorInstance == None)
	{
		DecoratorInstance = R_BTI_DecoratorInstance(GetBehaviorActionInstance());
	}
	return DecoratorInstance;
}

function BaseNodeActivated(R_BehaviorTreeContext Context)
{
	local R_BTNode LocalChild;
	local R_BTI_DecoratorInstance LocalDecoratorInstance;

	Super.BaseNodeActivated(Context);

	LocalDecoratorInstance = GetDecoratorInstance();
	if(LocalDecoratorInstance != None)
	{
		LocalDecoratorInstance.DecoratorActivated(
			Context.GetBot(),
			Context.GetDecoratorMemory(GetNodeUID()));
	}

	LocalChild = GetChild();
	if(LocalChild != None)
	{
		LocalChild.BaseNodeActivated(Context);
	}
}

function BaseNodeDeactivated(R_BehaviorTreeContext Context)
{
	local R_BTNode LocalChild;
	local R_BTI_DecoratorInstance LocalDecoratorInstance;

	Super.BaseNodeDeactivated(Context);

	LocalDecoratorInstance = GetDecoratorInstance();
	if(LocalDecoratorInstance != None)
	{
		LocalDecoratorInstance.DecoratorDeactivated(
			Context.GetBot(),
			Context.GetDecoratorMemory(GetNodeUID()));
	}

	LocalChild = GetChild();
	if(LocalChild != None)
	{
		LocalChild.BaseNodeDeactivated(Context);
	}
}

function int Tick(R_BehaviorTreeContext Context, float DeltaSeconds)
{
	local R_BTNode LocalChild;
	local R_BTI_DecoratorInstance LocalDecoratorInstance;

	LocalDecoratorInstance = GetDecoratorInstance();
	if(LocalDecoratorInstance != None)
	{
		LocalDecoratorInstance.DecoratorTick(
			Context.GetBot(),
			Context.GetDecoratorMemory(GetNodeUID()),
			Context.GetNodeActiveTime(GetNodeUID()),
			DeltaSeconds);
	}

	LocalChild = GetChild();
	if(LocalChild == None)
	{
		return NodeFail;
	}

	return LocalChild.Tick(Context, DeltaSeconds);
}

defaultproperties
{
	RequiredBehaviorActionInstanceClass=Class'RBots.R_BTI_DecoratorInstance'
}