class R_Scoreboard_Valball extends R_Scoreboard;

var float RelPosX_BallHoldTime;

var localized String BallHoldTimeText;

simulated function DrawTableHeadings( canvas Canvas)
{
	local float XL, YL;
	local float YOffset;
	local String SpectatorsString;

	Canvas.StrLen("00", XL, YL);
	YOffset = Canvas.CurY;

	// Draw seperator
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.DrawColor = WhiteColor;
	Canvas.SetPos(Canvas.ClipX*0.1, YOffset);
	Canvas.DrawTile(Seperator, Canvas.ClipX*0.8, YL*0.5, 0, 0, Seperator.USize, Seperator.VSize);
	YOffset += YL*0.75;
	Canvas.SetPos(Canvas.ClipX*0.1, YOffset);
	
	// Scrolling MOTD
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
	YOffset += YL*0.75;
	Canvas.SetPos(Canvas.ClipX*0.1, YOffset);

	YOffset += 48.0;

	// Name
	Canvas.SetPos(Canvas.ClipX*RelPosX_Name, YOffset);
	Canvas.DrawText(NameText, false);

    // Ball hold time
    Canvas.SetPos(Canvas.ClipX*RelPosX_BallHoldTime, YOffset);
    Canvas.DrawText(BallHoldTimeText, false);

	// Score
	Canvas.SetPos(Canvas.ClipX*RelPosX_Score, YOffset);
	Canvas.DrawText(FragsText, false);

	// Draw Deaths
	Canvas.SetPos(Canvas.ClipX*RelPosX_Deaths, YOffset);
	Canvas.DrawText(DeathsText, false);

	// Draw Damage Dealt
	Canvas.SetPos(Canvas.ClipX*RelPosX_DamageDealt, YOffset);
	Canvas.DrawText(DamageDealtText, false);

	// Draw Awards
	Canvas.SetPos(Canvas.ClipX*RelPosX_Awards, YOffset);
	Canvas.DrawText(AwardsText, false);

	if (Canvas.ClipX > 512)
	{
		// Ping
		Canvas.SetPos(Canvas.ClipX*RelPosX_Ping, YOffset);
		Canvas.DrawText(PingText, false);
	}

	// Draw seperator
	Canvas.Style = ERenderStyle.STY_Normal;
	YOffset += YL*1.25;
	Canvas.DrawColor = WhiteColor;
	Canvas.SetPos(Canvas.ClipX*0.1, YOffset);
	Canvas.DrawTile(Seperator, Canvas.ClipX*0.8, YL*0.5, 0, 0, Seperator.USize, Seperator.VSize);
	YOffset += YL*0.75;
	Canvas.SetPos(Canvas.ClipX*0.1, YOffset);
}

function DrawPlayerInfo( canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YOffset)
{
	local bool bLocalPlayer;
	local PlayerPawn PlayerOwner;
	local float XL,YL;
	local int AwardPos;
	local float TeamScore;
	local R_PlayerReplicationInfo RPRI;
    local R_PlayerReplicationInfo_Valball RPRIV;
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

	//Canvas.DrawColor = GetTeamColor(PRI.Team);
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
    RPRIV = R_PlayerReplicationInfo_Valball(RPRI);

    // Draw Hold Time
    Canvas.SetPos(Canvas.ClipX*RelPosX_BallHoldTime, YOffset);
    if(RPRIV != None)
	{
		InterpTime = Level.TimeSeconds - RPRI.ScoreTracker.TimeSeconds;
		ColorT0 = ColorsClass.Static.ColorGreen();
		ColorT1 = ColorsClass.Static.ColorWhite();
		DrawColor = Canvas.DrawColor;
		Canvas.DrawColor = UtilitiesClass.Static.InterpQuadratic_Color(InterpTime, ColorT0, ColorT1, 2.0);
		Canvas.DrawText(int(RPRIV.HoldTimeSeconds), false);
		Canvas.DrawColor = DrawColor;
	}
	else
	{
		Canvas.DrawText(int(RPRIV.HoldTimeSeconds), false);
	}

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

defaultproperties
{
    RelPosX_Name=0.100000
    RelPosX_BallHoldTime=0.25
    RelPosX_Score=0.350000
    RelPosX_Deaths=0.450000
    RelPosX_DamageDealt=0.550000
    RelPosX_Ping=0.700000
    RelPosX_Awards=0.800000
    BallHoldTimeText="Hold Time"
}