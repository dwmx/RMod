class R_Message_Say extends SayMessage;

var class<R_AColors> ColorsClass;

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	local Color C;
	
	if(RelatedPRI_1 != None)
	{
		C = Default.ColorsClass.Static.GetTeamColor(RelatedPRI_1.Team);
	}
	else
	{
		C = Default.ColorsClass.Static.ColorWhite();
	}
	
	return C;
}

static function MangleString(out string MessageText,
	optional PlayerReplicationInfo PRI1,
	optional PlayerReplicationInfo PRI2,
	optional Object obj)
{
	// HUD will apply the player's name
	//if (PRI1 != None)
	//	MessageText = PRI1.PlayerName $ ":" @ MessageText;
}

defaultproperties
{
     ColorsClass=Class'RMod.R_AColors'
}
