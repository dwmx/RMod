//=============================================================================
// TeleporterZone
//=============================================================================
class TeleporterZone extends ZoneInfo;


// Anything entering this zone automatically touches the associated teleporter

var() name TeleporterTag;
var Teleporter myTeleporter;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( TeleporterTag != '' )
		ForEach AllActors(class'Teleporter', myTeleporter, TeleporterTag)
			break;
}

event ActorEntered( actor Other )
{
	if ( myTeleporter != None )
		myTeleporter.Touch(Other);
}

defaultproperties
{
}
