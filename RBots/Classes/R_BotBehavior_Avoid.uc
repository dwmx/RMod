//==============================================================================
//	R_BotBehavior_Avoid
//	Avoid enemy players at all costs
//==============================================================================
class R_BotBehavior_Avoid extends R_BotBehavior;

function BehaviorActivated()
{
}


function BehaviorTick(float DeltaSeconds)
{
	local R_Bot Bot;
	local R_BotPerception BotPerception;
	local R_BotPawnController BotController;
	local Vector ActorAvoidanceDir, BorderAvoidanceDir;
	local float ActorAvoidanceInfluence, BorderAvoidanceInfluence;
	local Actor PerceivedActor;
	local Vector NewMovementInput;

	Bot = GetBot();
	if(Bot == None)
		return;

	BotPerception = GetBotPerception();
	if(BotPerception == None)
		return;

	BotController = GetBotPawnController();
	if(BotController == None)
		return;

	// Calc actor avoidance
	ActorAvoidanceDir = Vect(0.0, 0.0, 0.0);
	ActorAvoidanceInfluence = 0.0;
	PerceivedActor = BotPerception.GetPerceivedActor();
	if(PerceivedActor != None)
	{
		CalcAvoidanceForLocation2D(
			PerceivedActor.Location,
			32.0, 256.0,
			ActorAvoidanceDir, ActorAvoidanceInfluence);
	}
	
	// Calc border avoidance
	BorderAvoidanceDir = BotPerception.GetBorderAvoidanceDir(BorderAvoidanceInfluence);

	// Calc overall movement input
	NewMovementInput = (ActorAvoidanceDir * ActorAvoidanceInfluence) + (BorderAvoidanceDir * BorderAvoidanceInfluence);
	NewMovementInput = Normal(NewMovementInput);

	BotController.AddMovementInput_WorldSpace(NewMovementInput);
}

function CalcAvoidanceForLocation2D(
	Vector Location,
	float DesiredDistanceMin,
	float DesiredDistanceMax,
	out Vector OutAvoidanceDir,
	out float OutAvoidanceInfluence)
{
	local PlayerPawn P;
	local Vector Delta;
	local float Distance;
	local float Temp;
	local float t;

	P = GetPlayerPawn();
	if(P == None)
	{
		OutAvoidanceDir = Vect(0.0, 0.0, 0.0);
		OutAvoidanceInfluence = 0.0;
		return;
	}

	Temp = FMin(DesiredDistanceMin, DesiredDistanceMax);
	DesiredDistanceMax = FMax(DesiredDistanceMin, DesiredDistanceMax);
	DesiredDistanceMin = Temp;

	Delta = P.Location - Location;
	Distance = VSize(Delta);
	t = (Distance - DesiredDistanceMin) / (DesiredDistanceMax - DesiredDistanceMin);
	t = 1.0 - FClamp(t, 0.0, 1.0);

	OutAvoidanceDir = Normal(Delta);
	OutAvoidanceInfluence = t;
}