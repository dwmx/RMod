class R_ZoneEventFollower extends Info;

var ZoneInfo OldZone;

event Tick(float DeltaSeconds)
{
	if(Owner == None)
	{
		Destroy();
		return;
	}
	SetLocation(Owner.Location);
}

event ZoneChange(ZoneInfo NewZone)
{
	if(OldZone != None)
	{
		LeavingZone(OldZone);
	}
	OldZone = NewZone;
	
	EnteringZone(NewZone);
}

function LeavingZone(ZoneInfo OldZone)
{
	if(Owner == None
	|| Pawn(Owner) == None
	|| !Pawn(Owner).bIsPlayer
	|| R_GameInfo_Arena(Level.Game) == None)
	{
		return;
	}
	
	// QueueZone
	if(QueueZone(OldZone) != None)
	{
		R_GameInfo_Arena(Level.Game).LeftQueueZone(Pawn(Owner));
	}
}

function EnteringZone(ZoneInfo NewZone)
{
	if(Owner == None
	|| Pawn(Owner) == None
	|| !Pawn(Owner).bIsPlayer
	|| R_GameInfo_Arena(Level.Game) == None)
	{
		return;
	}
	
	// QueueZone
	if(QueueZone(NewZone) != None)
	{
		R_GameInfo_Arena(Level.Game).EnteredQueueZone(Pawn(Owner));
	}
}