class R_Scoreboard_TDM extends R_Scoreboard_DM;

var class<R_AColors> ColorsClass;
var TeamInfo OrderedTeams[4];


function color GetTeamColor(int team)
{
	return ColorsClass.Static.GetTeamColor(Team);
	//switch(team)
	//{
	//	case 0:
	//		return RedColor;
	//	case 1:
	//		return BlueColor;
	//	case 2:
	//		return GreenColor;
	//	case 3:
	//		return GoldColor;
	//}
	//return WhiteColor;
}

function DrawBackground( canvas Canvas, int X, int Y, int W, int H)
{
	local PlayerReplicationInfo PRI;
	PRI = PlayerPawn(Owner).PlayerReplicationInfo;
	BackgroundColor=GetTeamColor(PRI.Team);
	Super.DrawBackground( Canvas, X, Y, W, H);
}

function SortTeams(int N)
{
	local int i,j,Max;
	local TeamInfo TempTI;

	// Determine team standings
	for (i=0; i<N-1; i++)
	{
		Max = i;
		for (j=i+1; j<N; j++)
		{
			if (OrderedTeams[j].Score > OrderedTeams[Max].Score)
				Max=j;
			else if (OrderedTeams[j].Score == OrderedTeams[Max].Score &&
				OrderedTeams[j].Size < OrderedTeams[Max].Size)
				Max=j;
			//TODO: Add deaths to teaminfo
			else if (OrderedTeams[j].Score == OrderedTeams[Max].Score &&
				OrderedTeams[j].Size == OrderedTeams[Max].Size &&
				OrderedTeams[j].TeamIndex < OrderedTeams[Max].TeamIndex)
				Max=j;
		}

		TempTI = OrderedTeams[Max];
		OrderedTeams[Max] = OrderedTeams[i];
		OrderedTeams[i] = TempTI;
	}
}

function SortScores(int N)
{
	local int i,j,Max;
	local PlayerReplicationInfo TempPRI;

	// Determine team standings
	for (i=0; i<N-1; i++)
	{
		Max = i;
		for (j=i+1; j<N; j++)
		{
			if (Ordered[j].Score > Ordered[Max].Score)
				Max=j;
			else if ((Ordered[j].Score == Ordered[Max].Score) && (Ordered[j].Deaths < Ordered[Max].Deaths))
				Max=j;
			else if ((Ordered[j].Score == Ordered[Max].Score) && (Ordered[j].Deaths == Ordered[Max].Deaths) &&
				(Ordered[j].PlayerID < Ordered[Max].Score))
				Max=j;
		}

		TempPRI = Ordered[Max];
		Ordered[Max] = Ordered[i];
		Ordered[i] = TempPRI;
	}
}

function DrawTeamInfo( canvas Canvas, TeamInfo TI, float XOffset, float YOffset)
{
	local Color TeamBackgroundColor;
	local float XL1, YL1, XL2, YL2;

	// Draw backdrop
	Canvas.AlphaScale = 0.1;
	Canvas.Style = ERenderStyle.STY_AlphaBlend;
	Canvas.DrawColor = GetTeamColor(TI.TeamIndex);
	Canvas.SetPos(Canvas.ClipX * 0.1, YOffset);
	Canvas.DrawTile(Background, Canvas.ClipX * 0.8, 18, 0, 0, Background.USize, Background.VSize);

	Canvas.StrLen("00", XL1, YL1);
		//FONT ALTER
	//Canvas.Font = Canvas.BigFont;
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticBigFont();
	else
		Canvas.Font = Canvas.BigFont;

	Canvas.StrLen("00", XL2, YL2);

	Canvas.DrawColor = ColorsClass.Static.ColorWhite();
	Canvas.Style = ERenderStyle.STY_Normal;

	// Draw Name
	Canvas.Font = Canvas.BigFont;
	Canvas.SetPos(Canvas.ClipX*RelPosX_Name, YOffset);//-((YL2-YL1)*0.5));
	Canvas.DrawText(TI.TeamName);

	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticMedFont();
	else
		Canvas.Font = RegFont;

	// Draw Score
	Canvas.SetPos(Canvas.ClipX*RelPosX_Score, YOffset + 2);//-((YL2-YL1)*0.5));
	Canvas.DrawText(int(TI.Score), false);

		//FONT ALTER
	//Canvas.Font = RegFont;
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticMedFont();
	else
		Canvas.Font = RegFont;
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
	local int AwardPos;
	local float TeamScore;
	local R_PlayerReplicationInfo RPRI;
	local Color DrawColor, ColorT0, ColorT1;
	local float InterpTime;

	PlayerOwner = PlayerPawn(Owner);
	bLocalPlayer = (PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName);
		//FONT ALTER
//	Canvas.Font = RegFont;
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticMedFont();
	else
		Canvas.Font = RegFont;

	if (PRI.Team < 4)
		TeamScore = RuneGameReplicationInfo(PlayerOwner.GameReplicationInfo).Teams[PRI.Team].Score;
	else
		TeamScore = 0;

	// Draw Ready
	if (PRI.bReadyToPlay)
	{
		Canvas.StrLen("R ", XL, YL);
		Canvas.SetPos(Canvas.ClipX*0.1-XL, YOffset);
		Canvas.DrawText(ReadyText, false);
	}

	Canvas.DrawColor = GetTeamColor(PRI.Team);
	if (!bLocalPlayer)
	{
		Canvas.DrawColor.R = byte(float(Canvas.DrawColor.R) * 0.9);
		Canvas.DrawColor.G = byte(float(Canvas.DrawColor.G) * 0.9);
		Canvas.DrawColor.B = byte(float(Canvas.DrawColor.B) * 0.9);
	}

	// Draw Name
	if (PRI.bAdmin)	
	{	//FONT ALTER
		//Canvas.Font = Font'SmallFont';
		if(MyFonts != None)
			Canvas.Font = MyFonts.GetStaticSmallFont();
		else
			Canvas.Font = Font'SmallFont';
	}
	else
	{	//FONT ALTER
		//Canvas.Font = RegFont;
		if(MyFonts != None)
			Canvas.Font = MyFonts.GetStaticMedFont();
		else
			Canvas.Font = RegFont;
	}

	Canvas.SetPos(Canvas.ClipX*(RelPosX_Name+0.03), YOffset);
	Canvas.DrawColor = ColorsClass.Static.ColorWhite();

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

			//FONT ALTER
	//Canvas.Font = RegFont;
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticMedFont();
	else
		Canvas.Font = RegFont;

	// RPRI
	RPRI = R_PlayerReplicationInfo(PRI);

	// Draw Score
	Canvas.SetPos(Canvas.ClipX*RelPosX_Score, YOffset);
	if(RPRI != None)
	{
		InterpTime = Level.TimeSeconds - RPRI.ScoreTracker.TimeSeconds;
		ColorT0 = ColorsClass.Static.ColorGreen();
		ColorT1 = ColorsClass.Static.ColorWhite();
		DrawColor = Canvas.DrawColor;
		Canvas.DrawColor = UtilitiesClass.Static.InterpQuadratic_Color(InterpTime, ColorT0, ColorT1, 2.0);
		Canvas.DrawText(int(PRI.Score), false);
		Canvas.DrawColor = DrawColor;
	}
	else
	{
		Canvas.DrawText(int(PRI.Score), false);
	}

	// Draw Deaths
	Canvas.SetPos(Canvas.ClipX*RelPosX_Deaths, YOffset);
	if(RPRI != None)
	{
		InterpTime = Level.TimeSeconds - RPRI.DeathsTracker.TimeSeconds;
		ColorT0 = ColorsClass.Static.ColorRed();
		ColorT1 = ColorsClass.Static.ColorWhite();
		DrawColor = Canvas.DrawColor;
		Canvas.DrawColor = UtilitiesClass.Static.InterpQuadratic_Color(InterpTime, ColorT0, ColorT1, 2.0);
		Canvas.DrawText(int(PRI.Deaths), false);
		Canvas.DrawColor = DrawColor;
	}
	else
	{
		Canvas.DrawText(int(PRI.Deaths), false);
	}

	// Draw Damage Dealt
	Canvas.SetPos(Canvas.ClipX*RelPosX_DamageDealt, YOffset);
	if(RPRI != None)
	{
		InterpTime = Level.TimeSeconds - RPRI.DamageDealtTracker.TimeSeconds;
		ColorT0 = ColorsClass.Static.ColorRed();
		ColorT1 = ColorsClass.Static.ColorWhite();
		DrawColor = Canvas.DrawColor;
		Canvas.DrawColor = UtilitiesClass.Static.InterpQuadratic_Color(InterpTime, ColorT0, ColorT1, 2.0);
		Canvas.DrawText(RPRI.DamageDealt, false);
		Canvas.DrawColor = DrawColor;
	}
	else
	{
		Canvas.DrawText(int(PRI.Deaths), false);
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

	// Draw Awards
	AwardPos = Canvas.ClipX*0.8;
	Canvas.DrawColor = WhiteColor;
		//FONT ALTER
//	Canvas.Font = Font'SmallFont';
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticSmallFont();
	else
		Canvas.Font = Font'SmallFont';

	Canvas.StrLen("00", XL, YL);
	if (PRI.bFirstBlood)
	{	// First blood
		Canvas.SetPos(AwardPos-YL+XL*0.25, YOffset-YL*0.5);
		Canvas.DrawTile(FirstBloodIcon, YL*2, YL*2, 0, 0, FirstBloodIcon.USize, FirstBloodIcon.VSize);
		AwardPos += XL*2;
	}
	if (PRI.MaxSpree > 2)
	{	// Killing sprees
		Canvas.SetPos(AwardPos-YL+XL*0.25, YOffset-YL*0.5);
		Canvas.DrawTile(SpreeIcon, YL*2, YL*2, 0, 0, SpreeIcon.USize, SpreeIcon.VSize);
		Canvas.SetPos(AwardPos, YOffset);
		Canvas.DrawColor = WhiteColor;
		Canvas.DrawText(PRI.MaxSpree, false);
		Canvas.DrawColor = WhiteColor;
		AwardPos += XL*2;
	}
	if (PRI.HeadKills > 0)
	{	// Head kills
		Canvas.SetPos(AwardPos-YL+XL*0.25, YOffset-YL*0.5);
		Canvas.DrawTile(HeadIcon, YL*2, YL*2, 0, 0, HeadIcon.USize, HeadIcon.VSize);
		Canvas.SetPos(AwardPos, YOffset);
		Canvas.DrawColor = WhiteColor;
		Canvas.DrawText(PRI.HeadKills, false);
		Canvas.DrawColor = WhiteColor;
		AwardPos += XL*2;
	}
		//FONT ALTER
	//Canvas.Font = RegFont;
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticMedFont();
	else
		Canvas.Font = RegFont;
}


function ShowScores( canvas Canvas )
{
	local PlayerReplicationInfo PRI;
	local int PlayerCount,TeamPlayerCount,i,t;
	local float XL, YL;
	local float YOffset, YStart;
	local int TeamCount;
	local bool bTeamCounted;

	// Setup canvas
		//FONT ALTER
//	Canvas.Font = RegFont;
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticMedFont();
	else
		Canvas.Font = RegFont;

	Canvas.DrawColor = WhiteColor;
	Canvas.StrLen("TEST", XL, YL);

	// Header
	DrawHeader(Canvas);
	DrawTableHeadings(Canvas);

/*
RuneGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo).Teams[0].Score = 10;
RuneGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo).Teams[1].Score = 10;
RuneGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo).Teams[2].Score = 20;
RuneGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo).Teams[3].Score = 20;
for (i=0; i<32; i++)
{
	PRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];

	// Count the players
	if (PRI!=None && (!PRI.bIsSpectator || PRI.bWaitingPlayer) )
		PlayerCount++;
}
for(i=0; i<Playercount; i++)
{
	PlayerPawn(Owner).GameReplicationInfo.PRIArray[i].Score = i;
	PlayerPawn(Owner).GameReplicationInfo.PRIArray[i].Team = i%4;
}
PlayerCount=0;
*/

	// Sort the teams
	TeamCount=0;
	for (t=0; t<4; t++)
		OrderedTeams[t] = None;
	for (i=0; i<32; i++)
	{
		PRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];

		// Count the players
		if (PRI!=None && (!PRI.bIsSpectator || PRI.bWaitingPlayer) )
		{
			PlayerCount++;

			if (PRI.Team>=4)
				continue;

			// Check if this team has already been added
			bTeamCounted = false;
			for (t=0; t<4; t++)
				if (OrderedTeams[t]!=None && OrderedTeams[t].TeamIndex == PRI.Team)
					bTeamCounted = true;

			if (!bTeamCounted)
			{
				OrderedTeams[TeamCount] = RuneGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo).Teams[PRI.Team];
				TeamCount++;
				if (TeamCount == ArrayCount(OrderedTeams))
					break;
			}
		}
	}
	SortTeams(TeamCount);

	// Calculate vertical spacing
	YStart = Canvas.CurY;
	if (PlayerCount < 15)
		YL *= 2;
	else if (PlayerCount < 20)
		YL *= 1.5;
	if (PlayerCount > 15)
		PlayerCount = FMin(PlayerCount, (Canvas.ClipY - YStart)/YL - 1);

	DrawBackground(Canvas, 0.1*Canvas.ClipX, YStart-YL*0.25+1, 0.8*Canvas.ClipX, PlayerCount*YL);
	YOffset = YStart;

	// Sort and draw each team seperately
	for (t=0; t<TeamCount; t++)
	{
		// Sort the PRIs
		TeamPlayerCount=0;
		for (i=0; i<ArrayCount(Ordered); i++)
			Ordered[i] = None;
		for (i=0; i<32; i++)
		{
			PRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];

			if (PRI!=None && (!PRI.bIsSpectator || PRI.bWaitingPlayer))
			{
				if ( PRI.Team==OrderedTeams[t].TeamIndex )
				{
					Ordered[TeamPlayerCount] = PRI;
					TeamPlayerCount++;
					if (TeamPlayerCount == ArrayCount(Ordered))
						break;
				}
			}
		}

		SortScores(TeamPlayerCount);

		if (TeamPlayerCount > 0)
		{
			DrawTeamInfo(Canvas, OrderedTeams[t], 0, YStart);
			YStart += 20;

			//	draw the PRIs
			for (i=0; i<TeamPlayerCount; i++ )
			{
				YOffset = YStart + i*YL;
				DrawPlayerBackground(Canvas, Ordered[i], 0, YOffset, i);
				DrawPlayerInfo(Canvas, Ordered[i], 0, YOffset);
			}

			YStart = YOffset + YL;
		}
	}

	// Now draw any players not assigned to a team
	TeamPlayerCount=0;
	for (i=0; i<ArrayCount(Ordered); i++)
		Ordered[i] = None;
	for (i=0; i<32; i++)
	{
		if (PlayerPawn(Owner).GameReplicationInfo.PRIArray[i] != None)
		{
			PRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];
			if ( PRI.Team>=4 && (!PRI.bIsSpectator || PRI.bWaitingPlayer))
			{
				Ordered[TeamPlayerCount] = PRI;
				TeamPlayerCount++;
				if (TeamPlayerCount == ArrayCount(Ordered))
					break;
			}
		}
	}
	SortScores(TeamPlayerCount);
	if (TeamPlayerCount > 0)
	{
		//	draw the PRIs
		for (i=0; i<TeamPlayerCount; i++ )
		{
			YOffset = YStart + i*YL;
			DrawPlayerInfo(Canvas, Ordered[i], 0, YOffset);
		}

		YStart = YOffset + YL;
	}

	// Draw bottom seperator
	Canvas.StrLen("TEST", XL, YL);
	YOffset += YL;
	Canvas.SetPos(0, YOffset);

	// Trailer
	DrawTrailer(Canvas);

	Canvas.DrawColor = WhiteColor;
}

defaultproperties
{
     ColorsClass=Class'RMod.R_AColors'
     BackgroundAlpha=0.200000
}
