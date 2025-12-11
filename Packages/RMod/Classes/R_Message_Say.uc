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
		if(RelatedPRI_1.bIsSpectator)
		{
			C = Default.ColorsClass.Static.GetSpectatorColor();
		}
		else
		{
			C = Default.ColorsClass.Static.GetTeamColor(RelatedPRI_1.Team);
		}
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

static function String GenerateConsoleStringForMessage(String Msg, optional PlayerReplicationInfo PRI)
{
	local String Result;

	Result = Msg;

	if(PRI != None)
	{
		Result = PRI.PlayerName $ ":" @ Result;
	}
	
	Result = "-" @ Result;

	return Result;
}

// Handle beeps and console entry for normal text message types
static function ClientReceiveMessage(
    PlayerPawn P,
    String Msg,
    optional PlayerReplicationInfo PRI)
{
	if(Msg == "")
	{
		return;
	}

    if ( Default.bBeep && P.bMessageBeep )
	{
        P.PlayBeepSound();
	}

    if ( Default.bIsConsoleMessage )
    {
        if ((P.Player != None) && (P.Player.Console != None))
		{
            //P.Player.Console.AddString(Msg);
			P.Player.Console.AddString(GenerateConsoleStringForMessage(Msg, PRI));
		}
    }

    if ( P.myHUD != None )
	{
        P.myHUD.LocalizedMessage( Default.Class, 0, PRI, None, None, Msg );
	}
}

defaultproperties
{
     ColorsClass=Class'RMod.R_AColors'
}
