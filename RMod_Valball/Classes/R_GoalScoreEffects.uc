class R_GoalScoreEffects extends Actor;

simulated event Spawned()
{
	local int i;
	if(Owner != None)
	{
		for(i = 0; i < 10; ++i)
		{
			Spawn(class'debriswood',,,Owner.Location);
		}
	}
	
	Destroy();
}

defaultproperties
{
     bNetTemporary=True
     DrawType=DT_None
}
