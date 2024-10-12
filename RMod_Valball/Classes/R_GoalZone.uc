class R_GoalZone extends ZoneInfo;

var R_GameInfo_VB GameInfo_VB;

event PostBeginPlay()
{
	GameInfo_VB = R_GameInfo_VB(Level.Game);
}

event ActorEntered(Actor Other)
{
	Super.ActorEntered(Other);
	
	if(GameInfo_VB != None)
	{
		//GameInfo_VB.ActorEnteredGoalZone(Self, Other);
	}
}

defaultproperties
{
}
