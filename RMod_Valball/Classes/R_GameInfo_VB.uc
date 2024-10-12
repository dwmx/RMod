class R_GameInfo_VB extends R_GameInfo_TDM;

var class<Actor> BallClass;
var Actor Ball;

var class<Actor> GoalScoreEffectsClass;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	//SpawnBall();
}

function SpawnBall()
{
	local R_BallStart BallStart;
	
	if(Ball != None)
	{
		Ball.Destroy();
	}
	
	foreach AllActors(class'RMod_ValBall.R_BallStart', BallStart)
	{
		break;
	}
	if(BallStart == None)
	{
		return;
	}
	Ball = Spawn(BallClass,,, BallStart.Location, BallStart.Rotation);
	FireEvent('BallSpawned');
}

function ActorEnteredGoalZone(R_GoalZone Zone, Actor A)
{
	if(A == Ball)
	{
		Spawn(GoalScoreEffectsClass, Ball);
		A.Destroy();
		SpawnBall();
	}
}

defaultproperties
{
     BallClass=Class'RMod_Valball.R_Ball'
     GoalScoreEffectsClass=Class'RMod_Valball.R_GoalScoreEffects'
}