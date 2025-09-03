//==============================================================================
//	R_BotBehavior_Wander
//	Wander around, aimlessly
//==============================================================================
class R_BotBehavior_Wander extends R_BotBehavior;

function String GetDescriptiveString()
{
	return "Wander";
}

function BehaviorTick(float DeltaSeconds)
{
	local R_Bot Bot;

	Bot = GetBot();
	if(Bot != None)
	{
		Bot.AddMovementInput(Vect(1,0,0) * Cos(Bot.Level.TimeSeconds) + Vect(0,1,0) * Sin(Bot.Level.TimeSeconds));
	}
}