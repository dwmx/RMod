//=============================================================================
// PickupMessage.
//=============================================================================
class PickupMessage extends LocalMessage;


static function string AssembleString(
	HUD myHUD,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional String MessageString
	)
{
	return "";
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (OptionalObject != None)
		return Class<Inventory>(OptionalObject).Default.PickupMessage;
}

defaultproperties
{
     bIsUnique=True
     bIsConsoleMessage=True
     bFadeMessage=True
     DrawColor=(R=0,B=0)
     bCenter=True
}
