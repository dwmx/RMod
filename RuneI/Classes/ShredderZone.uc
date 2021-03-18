//=============================================================================
// ShredderZone.
//=============================================================================
class ShredderZone expands ZoneInfo;


function ActorEntered( actor Other )
{
	Super.ActorEntered(Other);

	if (!Other.IsA('PlayerPawn'))
		Other.Destroy();
}

defaultproperties
{
}
