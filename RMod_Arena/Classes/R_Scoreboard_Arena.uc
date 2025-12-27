class R_Scoreboard_Arena extends RMod.R_Scoreboard;

var localized string ChampionString;
var localized string CurrentMatch;
var localized string QueueText;
var localized string VsString;
var localized string InMatchMsg;
var localized string ServerText;
var localized string XOnXText;
var localized string ChampionsText;
var localized string ChallengersText;
var localized string MatchText;

var float RelPosX_Queue;

function DrawTableHeadings(canvas Canvas)
{
	local float XL, YL;
	local float YOffset;
	local float recordString;
	local string CurMatchString;
	local String SpectatorsString;

	//YOffset = Canvas.CurY;

	Canvas.DrawColor = GoldColor;
	Canvas.StrLen("00", XL, YL);
	YOffset = Canvas.CurY;

	// Draw seperator
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.DrawColor = WhiteColor;
	Canvas.SetPos(Canvas.ClipX*0.1, YOffset);
	Canvas.DrawTile(Seperator, Canvas.ClipX*0.8, YL*0.5, 0, 0, Seperator.USize, Seperator.VSize);
	YOffset += YL*0.75;
	Canvas.SetPos(Canvas.ClipX*0.1, YOffset);

	// Scrolling message
	DrawTextScrolling(
		Canvas, Canvas.ClipX * 0.1, YOffset, Canvas.ClipX * 0.8, 24.0, GetMOTDString());

	// Scrolling spectators list
	YOffset += 24.0;
	SpectatorsString = GetSpectatorsString();
	DrawTextScrolling(
		Canvas, Canvas.ClipX * 0.1, YOffset, Canvas.ClipX * 0.8, 24.0, SpectatorsString);

	Canvas.DrawColor = GoldColor;
	YOffset += 24.0;

	// Draw seperator
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.DrawColor = WhiteColor;
	Canvas.SetPos(Canvas.ClipX*0.1, YOffset);
	Canvas.DrawTile(Seperator, Canvas.ClipX*0.8, YL*0.5, 0, 0, Seperator.USize, Seperator.VSize);
	YOffset += YL*0.40;
	Canvas.SetPos(Canvas.ClipX*0.1, YOffset);

	Canvas.DrawColor = GoldColor;
	Canvas.StrLen("00", XL, YL);
	YOffset = Canvas.CurY + YL;

	// Name
	Canvas.SetPos(Canvas.ClipX*RelPosX_Name, YOffset);
	Canvas.DrawText(NameText, false);

	// Score
	Canvas.SetPos(Canvas.ClipX*RelPosX_Score, YOffset);
	Canvas.DrawText(FragsText, false);

	// Draw Deaths
	Canvas.SetPos(Canvas.ClipX*RelPosX_Deaths, YOffset);
	Canvas.DrawText(DeathsText, false);

	// Draw Damage Dealt
	Canvas.SetPos(Canvas.ClipX*RelPosX_DamageDealt, YOffset);
	Canvas.DrawText(DamageDealtText, false);

	//Draw Queue Number - replaced Awards
	Canvas.SetPos(Canvas.ClipX * RelPosX_Queue, YOffset);
	Canvas.DrawText(QueueText, false);

	if (Canvas.ClipX > 512)
	{
		// Ping
		Canvas.SetPos(Canvas.ClipX*RelPosX_Ping, YOffset);
		Canvas.DrawText(PingText, false);
	}

	// Draw seperator
	Canvas.Style = ERenderStyle.STY_Normal;
	YOffset += YL*2.00;
	Canvas.DrawColor = WhiteColor;
	Canvas.SetPos(Canvas.ClipX*0.1, YOffset);
	Canvas.DrawTile(Seperator, Canvas.ClipX*0.8, YL*0.5, 0, 0, Seperator.USize, Seperator.VSize);
	YOffset += YL*0.25;
	Canvas.SetPos(Canvas.ClipX*0.1, YOffset);

}

function color GetTeamColor(int team)
{
	switch(team)
	{
		case 0:
			return ColorsClass.Static.ColorRed();
		case 1:
			return ColorsClass.Static.ColorBlue();

	}
	return ColorsClass.Static.ColorWhite();
}

function DrawPlayerBackground(Canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YOffset, int PRIIndex)
{
	local Color PlayerBackgroundColor;
	local PlayerPawn POwner;

	PlayerBackgroundColor = GetTeamColor(PRI.Team);

	// Draw a background tile
	Canvas.DrawColor = PlayerBackgroundColor;
	Canvas.Style = ERenderStyle.STY_AlphaBlend;

	if(PRIIndex % 2 == 0)
	{
		Canvas.AlphaScale = 0.225;
	}
	else
	{
		Canvas.AlphaScale = 0.15;
	}

	Canvas.SetPos(Canvas.ClipX * 0.1, YOffset - 2);
	Canvas.DrawTile(Background, Canvas.ClipX * 0.8, 18, 0, 0, Background.USize, Background.VSize);
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.AlphaScale = 1.0;
}

function DrawPlayerInfo( canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YOffset)
{

	local bool bLocalPlayer;
	local PlayerPawn PlayerOwner;
	local float XL,YL;
	local ArenaGameReplicationInfo GRI;
	local int i;
	local R_PlayerReplicationInfo RPRI;
	local Color DrawColor, ColorT0, ColorT1;
	local float InterpTime;

	PlayerOwner = PlayerPawn(Owner);
	bLocalPlayer = (PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName);
	GRI = ArenaGameReplicationInfo(PlayerOwner.GameReplicationInfo);

	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticMedFont();
	else
		Canvas.Font = RegFont;

	// Draw Ready
	if (PRI.bReadyToPlay)
	{
		Canvas.StrLen("R ", XL, YL);
		Canvas.SetPos(Canvas.ClipX*0.1-XL, YOffset);
		Canvas.DrawText(ReadyText, false);
	}

	if (bLocalPlayer)
		Canvas.DrawColor = VioletColor;
	else
	{
		if(PRI.Team != 255 && GRI.matchSize != 1)
			Canvas.DrawColor = GetTeamColor(GRI.TeamColor[PRI.Team]);
		else
			Canvas.DrawColor = WhiteColor;
	}

	// Draw Name
	if (PRI.bAdmin)
	{
		if(MyFonts != None)
			Canvas.Font = MyFonts.GetStaticSmallFont();
		else
			Canvas.Font = Font'SmallFont';
	}
	else
	{
		if(MyFonts != None)
			Canvas.Font = MyFonts.GetStaticMedFont();
		else
			Canvas.Font = RegFont;
	}

	Canvas.SetPos(Canvas.ClipX*RelPosX_Name, YOffset);
	//Canvas.DrawText(PRI.PlayerName, false);

	// If spectating this player, draw an indicator
	if(Owner != None
	&& Owner.GetStateName() == 'PlayerSpectating'
	&& R_RunePlayer(Owner) != None
	&& R_RunePlayer(Owner).Camera != None
	&& R_RunePlayer(Owner).Camera.ViewTarget != None
	&& PlayerPawn(R_RunePlayer(Owner).Camera.ViewTarget) != None
	&& PlayerPawn(R_RunePlayer(Owner).Camera.ViewTarget).PlayerReplicationInfo != None
	&& PlayerPawn(R_RunePlayer(Owner).Camera.ViewTarget).PlayerReplicationInfo == PRI)
	{
		Canvas.DrawText(PRI.PlayerName @ " [SPECTATING]", false);
	}
	else
	{
		Canvas.DrawText(PRI.PlayerName, false);
	}

	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticMedFont();
	else
		Canvas.Font = RegFont;

	// Draw Score
	Canvas.SetPos(Canvas.ClipX*RelPosX_Score, YOffset);
	Canvas.DrawText(GetValueForScoreField(PRI), false);

	// Draw Deaths
	Canvas.SetPos(Canvas.ClipX*RelPosX_Deaths, YOffset);
	Canvas.DrawText(GetValueForDeathsField(PRI), false);

	// RMod stuff
	RPRI = R_PlayerReplicationInfo(PRI);
	if(RPRI != None)
	{
		// Draw Damage Dealt
		Canvas.SetPos(Canvas.ClipX*RelPosX_DamageDealt, YOffset);
		Canvas.DrawText(GetValueForDamageDealtField(PRI), false);
	}

	if (Canvas.ClipX > 512 && Level.Netmode != NM_Standalone)
	{
		// Draw Ping
		Canvas.SetPos(Canvas.ClipX*0.7, YOffset);
		if(RPRI != None)
		{
			InterpTime = float(PRI.Ping);
			ColorT0 = ColorsClass.Static.ColorGreen();
			ColorT1 = ColorsClass.Static.ColorRed() * 0.75;
			DrawColor = Canvas.DrawColor;
			Canvas.DrawColor = UtilitiesClass.Static.InterpLinear_Color(float(PRI.Ping), ColorT0, ColorT1, 160.0);
			Canvas.DrawText(PRI.Ping, false);
			Canvas.DrawColor = DrawColor;
		}
		else
		{
			Canvas.DrawText(PRI.Ping, false);
		}

		// Packetloss

		//FONT ALTER
	//	Canvas.Font = RegFont;
		if(MyFonts != None)
			Canvas.Font = MyFonts.GetStaticMedFont();
		else
			Canvas.Font = RegFont;

		Canvas.DrawColor = WhiteColor;
	}

	if(PRI.TeamID <= 16)
	{
		Canvas.SetPos(Canvas.ClipX * RelPosX_Queue, YOffset);
		Canvas.DrawText(TwoDigitString(PRI.TeamID), false);
	}
}

function int GetValueForScoreField(PlayerReplicationInfo PRI)
{
	return int(PRI.Score);
}

function int GetValueForDeathsField(PlayerReplicationInfo PRI)
{
	return int(PRI.Deaths);
}

function int GetValueForDamageDealtField(PlayerReplicationInfo PRI)
{
	if(R_PlayerReplicationInfo(PRI) != None)
	{
		return R_PlayerReplicationInfo(PRI).DamageDealt;
	}
}

function int GetValueForPingField(PlayerReplicationInfo PRI)
{
	return PRI.Ping;
}

function DrawHeader( canvas Canvas )
{
	local GameReplicationInfo GRI;
	local ArenaGameReplicationInfo ArenaGRI;
	local float XL, YL, YL2;
	local float YOffset;
	local PlayerPawn PlayerOwner;
	local string matchType;


	PlayerOwner = PlayerPawn(Owner);

	Canvas.StrLen("TEST", XL, YL);
	YOffset = 5*YL;

	if (Canvas.ClipX > 500)
	{
		GRI = PlayerOwner.GameReplicationInfo;

		if (Level.Netmode != NM_StandAlone)
		{
			Canvas.DrawColor = WhiteColor;
			Canvas.StrLen(GRI.ServerName, XL, YL2);
			Canvas.SetPos((Canvas.ClipX * 0.5) - (XL * 0.5), YOffset);
			Canvas.DrawText(GRI.ServerName, false);

		}

		YOffset += YL;

		ArenaGRI = ArenaGameReplicationInfo(GRI);

		matchType = ArenaGRI.matchSize $ XOnXText $ArenaGRI.matchSize $ ServerText;
		Canvas.StrLen(matchType, XL, YL2);
		Canvas.SetPos((Canvas.ClipX * 0.5) - (XL * 0.5), YOffset);
		Canvas.DrawText(matchType, false);

		YOffset = 7*YL;

		Canvas.DrawColor = GreenColor;
		// Left Column
		Canvas.SetPos(0.1*Canvas.ClipX, YOffset);
		Canvas.DrawText(MapTitleMsg$Level.Title, true);
		YOffset += YL;

		Canvas.SetPos(0.1*Canvas.ClipX, YOffset);
		Canvas.DrawText("Author: "$Level.Author, true);
		YOffset += YL;

		// Right Column
		YOffset = 7*YL;

		Canvas.DrawTextRightJustify(GameTypeMsg$GRI.GameName, 0.9*Canvas.ClipX, YOffset);
		YOffset += YL;

		Canvas.DrawTextRightJustify(GRI.NumPlayers$NumPlayersMsg, 0.9*Canvas.ClipX, YOffset);
		YOffset += 2*YL;

		Canvas.SetPos(0.0, YOffset);
	}
}

function DrawMatchInfo(canvas Canvas, PlayerReplicationInfo PRI_1, PlayerReplicationInfo PRI_2, float XOffset, float YStart)
{
	local float XL, YL;
	local float curY;
	local string MatchString;

	curY = YStart;

	Canvas.StrLen(CurrentMatch, XL, YL);
	curY += YL;

	Canvas.DrawColor = LightCyanColor;
	Canvas.SetPos((Canvas.ClipX * 0.5) - (XL * 0.5), curY);
	Canvas.DrawText(CurrentMatch);
	curY += YL;

	if(PRI_1 != None && PRI_2 != None)
	{
		Canvas.DrawColor = LightGreenColor;
		MatchString = PRI_1.PlayerName $ VsString $ PRI_2.PlayerName;
		Canvas.StrLen(MatchString, XL, YL);
		Canvas.SetPos((Canvas.ClipX * 0.5) - (XL * 0.5), curY);
		Canvas.DrawText(MatchString, false);
	}

	Canvas.SetPos(0.0, curY += YL);
}

function DrawTeamMatchInfo(canvas Canvas, float XOffset, float YStart)
{
	local float XL, YL;
	local float curY, curX, startingX;
	local ArenaGameReplicationInfo GRI;

	GRI = ArenaGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);

	curY = YStart;

	curY += YL;
	Canvas.StrLen(CurrentMatch, XL, YL);
	Canvas.DrawColor = LightCyanColor;
	Canvas.SetPos((Canvas.ClipX * 0.5) - (XL * 0.5), curY);
	Canvas.DrawText(CurrentMatch);
	curY += YL;

	//Canvas.StrLen(GetTeamString(GRI.TeamColor[0]) $ VsString $ GetTeamString(GRI.TeamColor[1]), XL, YL);
	Canvas.StrLen(ChampionsText $ VsString $ ChallengersText, XL, YL);
	startingX = (Canvas.ClipX * 0.5) - (XL * 0.5);
	curX = startingX;

	Canvas.DrawColor = GetTeamColor(GRI.TeamColor[0]);
	Canvas.SetPos(curX, curY);
	Canvas.DrawText(ChampionsText, false);//GetTeamString(GRI.TeamColor[0]), false);
	Canvas.StrLen(ChampionsText, XL, YL);//GetTeamString(GRI.TeamColor[0]), XL, YL);
	curX += XL;

	Canvas.DrawColor = LightGreenColor;
	Canvas.SetPos(curX, curY);
	Canvas.DrawText(VsString, false);
	Canvas.StrLen(VsString, XL, YL);
	curX += XL;

	Canvas.DrawColor = GetTeamColor(GRI.TeamColor[1]);
	Canvas.SetPos(curX, curY);
	Canvas.DrawText(ChallengersText, false);//GetTeamString(GRI.TeamColor[1]), false);

	Canvas.SetPos(0.0, curY += YL);
}

function DrawArenaChampion(canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YStart)
{
	local float XL, YL;
	local float curY;

	curY = YStart;

	Canvas.StrLen(ChampionString, XL, YL);
	curY += YL;

	Canvas.DrawColor = LightCyanColor;
	Canvas.SetPos((Canvas.ClipX * 0.5) - (XL * 0.5), curY);
	Canvas.DrawText(ChampionString);

	if(PRI != None)
	{
		Canvas.DrawColor = LightGreenColor;
		Canvas.StrLen(PRI.PlayerName, XL, YL);
		curY += YL;
		Canvas.SetPos((Canvas.ClipX * 0.5) - (XL * 0.5), curY);
		Canvas.DrawText(PRI.PlayerName, false);
	}

	Canvas.SetPos(0.0, curY += YL);
}

function ShowScores( canvas Canvas )
{
	local PlayerReplicationInfo PRI;
	local PlayerReplicationInfo ChampionPRI, ChallengerPRI;
	local ArenaGameReplicationInfo ArenaGRI;
	local int PlayerCount, I;
	local float XL, YL;
	local float YOffset, YStart;

	// Sort the PRIs
	for (i=0; i<ArrayCount(Ordered); i++)
		Ordered[i] = None;
	for (i=0; i<32; i++)
	{
		if (PlayerPawn(Owner).GameReplicationInfo.PRIArray[i] != None)
		{
			PRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];
			if ( !PRI.bIsSpectator || PRI.bWaitingPlayer )
			{
				Ordered[PlayerCount] = PRI;
				PlayerCount++;
				if (PlayerCount == ArrayCount(Ordered))
					break;
			}
		}
	}
	SortScores(PlayerCount);

	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticMedFont();
	else
		Canvas.Font = RegFont;

	Canvas.DrawColor = WhiteColor;

	// Calculate vertical spacing
	Canvas.StrLen("TEST", XL, YL);

	// Header

	ArenaGRI = ArenaGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo);
	DrawHeader(Canvas);
	DrawArenaChampion(Canvas, Ordered[0], 0, Canvas.CurY + YL);

	if(ArenaGRI != None && ArenaGRI.matchSize > 1)
		DrawTeamMatchInfo(Canvas, 0, Canvas.CurY);
	else
	{
		for(i = 0; i < 32; i++)
		{
			if(PlayerPawn(Owner).GameReplicationInfo.PRIArray[i] != None)
			{
				if(PlayerPawn(Owner).GameReplicationInfo.PRIArray[i].Team == 0)
					ChampionPRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];
				else if(PlayerPawn(Owner).GameReplicationInfo.PRIArray[i].Team == 1)
					ChallengerPRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];
			}

			if(ChallengerPRI != None && ChampionPRI != None)
			{
				DrawMatchInfo(Canvas, ChampionPRI, ChallengerPRI, 0, Canvas.CurY);
				break;
			}

		}
	}

	DrawTableHeadings(Canvas);

	Canvas.StrLen("TEST", XL, YL);
	YStart = Canvas.CurY + YL;

	//TODO: Calculate continuous spacing based on screensize available

	if (PlayerCount < 15)
		YL *= 2;
	else if (PlayerCount < 20)
		YL *= 1.5;
	if (PlayerCount > 15)
		PlayerCount = FMin(PlayerCount, (Canvas.ClipY - YStart)/YL - 1);

	DrawBackground(Canvas, 0.1*Canvas.ClipX, YStart-YL*0.25+2, 0.8*Canvas.ClipX, PlayerCount*YL);

	//YStart += YL;
	YOffset = YStart;

	for ( I=0; I<PlayerCount; I++ )
	{
		YOffset = YStart + I*YL;
		DrawPlayerBackground(Canvas, Ordered[i], 0, YOffset, i);
		DrawPlayerInfo(Canvas, Ordered[I], 0, YOffset);
	}

	// Draw bottom seperator
	Canvas.StrLen("TEST", XL, YL);
	YOffset += YL;
	Canvas.SetPos(0, YOffset);

	// Trailer
	DrawTrailer(Canvas);

	Canvas.DrawColor = WhiteColor;
	Canvas.SetPos(0, YOffset);
}

function DrawTrailer( canvas Canvas )
{
	local int Hours, Minutes, Seconds;
	local string HourString, MinuteString, SecondString;
	local float XL, YL;
	local int curMatch, maxMatch;
	local PlayerPawn PlayerOwner;
	local int YOffset;
	local ArenaGameReplicationInfo ArenaGRI;
	local string text;

	PlayerOwner = PlayerPawn(Owner);
	Canvas.bCenter = true;
	Canvas.DrawColor = WhiteColor;
	Canvas.StrLen("Test", XL, YL);

	// Bottom seperator
	YOffset = Canvas.CurY;
	YOffset += YL*0.75;
	Canvas.SetPos(Canvas.ClipX*0.1, YOffset);
	Canvas.DrawTile(Seperator, Canvas.ClipX*0.8, YL*0.5, 0, 0, Seperator.USize, Seperator.VSize);

	if (Canvas.ClipX > 500)
	{
		// Now start from bottom
		Canvas.SetPos(0, Canvas.ClipY - YL);

		if ( bTimeDown || (PlayerOwner.GameReplicationInfo.RemainingTime > 0) )
		{
			bTimeDown = true;
			if ( PlayerOwner.GameReplicationInfo.RemainingTime <= 0 )
				Canvas.DrawText(RemainingTimeMsg@"00:00", true);
			else
			{
				Minutes = PlayerOwner.GameReplicationInfo.RemainingTime/60;
				Seconds = PlayerOwner.GameReplicationInfo.RemainingTime % 60;
				Canvas.DrawText(RemainingTimeMsg@TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), true);
			}
		}
		else
		{
			Seconds = int(Level.TimeSeconds);
			Minutes = Seconds / 60;
			Hours   = Minutes / 60;
			Seconds = Seconds - (Minutes * 60);
			Minutes = Minutes - (Hours * 60);

			if (Seconds < 10)
				SecondString = "0"$Seconds;
			else
				SecondString = string(Seconds);

			if (Minutes < 10)
				MinuteString = "0"$Minutes;
			else
				MinuteString = string(Minutes);

			if (Hours < 10)
				HourString = "0"$Hours;
			else
				HourString = string(Hours);

			Canvas.DrawText(ElapsedTimeMsg$HourString$":"$MinuteString$":"$SecondString, true);
		}
	}

	// Hit fire to continue message
	Canvas.bCenter = true;
	Canvas.StrLen("Test", XL, YL);
	Canvas.SetPos(0, Canvas.ClipY - YL*4);
	Canvas.DrawColor = RedColor;
	if ( PlayerOwner.GameReplicationInfo.GameEndedComments != "" )
		Canvas.DrawText(ContinueMsg@PlayerOwner.GameReplicationInfo.GameEndedComments@ContinueTrailer, true);
	else if ((PlayerOwner != None) && (PlayerOwner.Health <= 0) )
	{
		ArenaGRI = ArenaGameReplicationInfo(PlayerOwner.GameReplicationInfo);
		if(ArenaGRI != None && ArenaGRI.bInMatch)
		{
			if(PlayerOwner.PlayerReplicationInfo.Team == 0 ||  PlayerOwner.PlayerReplicationInfo.Team == 1)
			{
				Canvas.DrawText(InMatchMsg, true);
				Canvas.bCenter = false;
				return;
			}
		}

		Canvas.DrawText(RestartMsg, true);
	}
	else
	{
		curMatch = ArenaGameReplicationInfo(PlayerOwner.GameReplicationInfo).CurMatch;
		MaxMatch = ArenaGameReplicationInfo(PlayerOwner.GameReplicationInfo).FragLimit;

		if(MaxMatch > 0)
		{
			text = MatchText $ string(curMatch) $ "/" $ MaxMatch;
			Canvas.DrawText(text, true);
		}
	}

	Canvas.bCenter = false;
}

defaultproperties
{
     ChampionString="Arena Champion"
     CurrentMatch="Current Match"
     QueueText="Position"
     VsString=" vs. "
     InMatchMsg="PLEASE WAIT UNTIL MATCH IS FINISHED"
     ServerText=" Server"
     XOnXText=" on "
     ChampionsText="Champions"
     ChallengersText="Challengers"
     MatchText="Match "
     FragsText="Victories"
     DeathsText="Losses"
     RelPosX_Queue=0.8
}
