//=============================================================================
// GenericMessage.
//=============================================================================
class GenericMessage extends LocalMessage;


static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return "";
}

defaultproperties
{
     bIsConsoleMessage=True
     bFadeMessage=True
     LifeTime=10
     DrawColor=(G=25,B=25)
     bCenter=True
}
