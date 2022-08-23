class CloudZone extends ZoneInfo;


event ActorEntered( actor Other )
{
	if (Other.IsA('Pawn'))
		Pawn(Other).Died(Pawn(Other).Enemy, 'fell', Location);
	else
		Other.Destroy();
}

defaultproperties
{
}
