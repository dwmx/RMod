//==============================================================================
//	R_BotBehavior_Fight
//	Try to kill and try not to die
//==============================================================================
class R_BotBehavior_Fight extends R_BotBehavior;

var private float AccumulatedTime;

function BehaviorActivated()
{
	local R_Bot Bot;

	Bot = GetBot();
	if(Bot != None)
	{
		Bot.ClearPath();
	}
}

function BehaviorTick(float DeltaSeconds)
{
	local PlayerPawn P;

	AccumulatedTime += DeltaSeconds;
	if(AccumulatedTime >= 5.0)
	{
		AccumulatedTime = 0.0;
		P = GetPlayerPawn();
		if(P != None)
		{
			P.Fire();
		}
	}
}