class R_BTTask_MoveInDirection extends R_BTTask;

var private float TimeAccumulator;

static function String GetNodeClassString() { return "MoveInDirection"; }

function OnActivated()
{
	TimeAccumulator = 0.0;
}

function TickTask(float DeltaSeconds)
{
	local R_BotPawnController PawnController;
	local Vector Input;

	TimeAccumulator += DeltaSeconds;

	PawnController = GetPawnController();
	if(PawnController != None)
	{
		Input.X = Cos(TimeAccumulator);
		Input.Y = Sin(TimeAccumulator);
		Input *= 0.5;
		PawnController.AddMovementInput_WorldSpace(Input);
	}

	if(TimeAccumulator >= 10.0)
	{
		EndTaskSuccess();
	}
}