//==============================================================================
//	R_BTTask_Delay
//	Simple delay Node
//==============================================================================
class R_BTTask_Delay extends R_BTTask;

var private float TimeAccumulator;

static function String GetNodeClassString() { return "Delay"; }

function OnActivated()
{
	TimeAccumulator = 0.0;
}

function TickTask(float DeltaSeconds)
{
	TimeAccumulator += DeltaSeconds;
	if(TimeAccumulator >= 3.0)
	{
		EndTaskSuccess();
		return;
	}
}