//=============================================================================
// RuneScoreBoard
//=============================================================================
class RuneScoreBoard extends ScoreBoard;

#exec Texture Import File=Textures\sb_seperator.pcx Name=sb_seperator Mips=Off Flags=0
#exec Texture Import File=Textures\sb_vertramp.pcx Name=sb_vertramp Mips=Off Flags=0
#exec Texture Import File=Textures\sb_horizramp.pcx Name=sb_horizramp Mips=Off Flags=0

#exec Texture Import File=Textures\trophyskull.pcx Name=TrophyHeads Mips=Off Flags=2
#exec Texture Import File=Textures\trophyblood.pcx Name=TrophyFirstBlood Mips=Off Flags=2
#exec Texture Import File=Textures\trophycrossbones.pcx Name=TrophySpree Mips=Off Flags=2

var color GreenColor, WhiteColor, GoldColor, CyanColor, RedColor, LightCyanColor, LightGreenColor, VioletColor, BlueColor, BackgroundColor;
var PlayerReplicationInfo Ordered[32];
var bool bTimeDown;
var localized string ReadyText;
var localized string RemainingTimeMsg, ElapsedTimeMsg, GameTypeMsg, MapTitleMsg, IdealPlayerCountMsg, NumPlayersMsg;
var localized string RestartMsg, ContinueMsg, ContinueTrailer;
var localized string NameText, FragsText, DeathsText, PingText, AwardsText;
var Texture FirstBloodIcon, SpreeIcon, HeadIcon, Seperator, Background;
var() float BackgroundAlpha;

var globalconfig string FontInfoClass;
var FontInfo MyFonts;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(FontInfoClass != "")
		MyFonts = FontInfo(spawn(Class<Actor>(DynamicLoadObject(FontInfoClass, class'Class'))));


}
function DrawHeader( canvas Canvas )
{
	local GameReplicationInfo GRI;
	local float XL, YL;
	local float YOffset;
	local PlayerPawn PlayerOwner;

	Canvas.DrawColor = GreenColor;
	PlayerOwner = PlayerPawn(Owner);
	Canvas.StrLen("TEST", XL, YL);
	YOffset = 8*YL;

	if (Canvas.ClipX > 500)
	{
		GRI = PlayerOwner.GameReplicationInfo;

		// Left Column
		Canvas.SetPos(0.1*Canvas.ClipX, YOffset);
		Canvas.DrawText(MapTitleMsg$Level.Title, true);
		YOffset += YL;

		Canvas.SetPos(0.1*Canvas.ClipX, YOffset);
		Canvas.DrawText("Author: "$Level.Author, true);
		YOffset += YL;

		if (Level.IdealPlayerCount != "")
		{
			Canvas.SetPos(0.1*Canvas.ClipX, YOffset);
			Canvas.DrawText(IdealPlayerCountMsg$Level.IdealPlayerCount, true);
			YOffset += YL;
		}

		// Right Column
		YOffset = 8*YL;
		if (Level.Netmode != NM_StandAlone)
		{
			Canvas.DrawTextRightJustify(GRI.ServerName, 0.9*Canvas.ClipX, YOffset);
			YOffset += YL;
		}

		Canvas.DrawTextRightJustify(GameTypeMsg$GRI.GameName, 0.9*Canvas.ClipX, YOffset);
		YOffset += YL;

		Canvas.DrawTextRightJustify(GRI.NumPlayers$NumPlayersMsg, 0.9*Canvas.ClipX, YOffset);
		YOffset += 2*YL;

		Canvas.SetPos(0.0, YOffset);
	}
}

function string TwoDigitString(int Num)
{
	if ( Num < 10 )
		return "0"$Num;
	else
		return string(Num);
}

function DrawTrailer( canvas Canvas )
{
	local int Hours, Minutes, Seconds;
	local string HourString, MinuteString, SecondString;
	local float XL, YL;
	local PlayerPawn PlayerOwner;
	local int YOffset;

	PlayerOwner = PlayerPawn(Owner);
	Canvas.bCenter = true;
	Canvas.DrawColor = WhiteColor;
	Canvas.StrLen("Test", XL, YL);

	// Bottom seperator
	YOffset = Canvas.CurY;
	YOffset += YL*0.25;
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
		Canvas.DrawText(RestartMsg, true);
	Canvas.bCenter = false;
}

function DrawBackground( canvas Canvas, int X, int Y, int W, int H)
{
	Canvas.DrawColor = BackgroundColor;
	Canvas.Style = ERenderStyle.STY_AlphaBlend;
	Canvas.AlphaScale = BackgroundAlpha;
	Canvas.SetPos(X, Y);
	Canvas.DrawTile(Background, W, H, 0, 0, Background.USize, Background.VSize);
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.AlphaScale = 1.0;
}

function DrawTableHeadings( canvas Canvas)
{
	local float XL, YL;
	local float YOffset;

	Canvas.DrawColor = GoldColor;
	Canvas.StrLen("00", XL, YL);
	YOffset = Canvas.CurY;

	// Name
	Canvas.SetPos(Canvas.ClipX*0.1, YOffset);
	Canvas.DrawText(NameText, false);

	// Score
	Canvas.SetPos(Canvas.ClipX*0.5, YOffset);
	Canvas.DrawText(FragsText, false);

	// Draw Deaths
	Canvas.SetPos(Canvas.ClipX*0.6, YOffset);
	Canvas.DrawText(DeathsText, false);

	// Draw Awards
	Canvas.SetPos(Canvas.ClipX*0.8, YOffset);
	Canvas.DrawText(AwardsText, false);

	if (Canvas.ClipX > 512)
	{
		// Ping
		Canvas.SetPos(Canvas.ClipX*0.7, YOffset);
		Canvas.DrawText(PingText, false);
	}

	// Draw seperator
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

	PlayerOwner = PlayerPawn(Owner);
	bLocalPlayer = (PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName);
	//FONT ALTER
	//	Canvas.Font = RegFont;
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
		Canvas.DrawColor = WhiteColor;

	// Draw Name
	if (PRI.bAdmin)	//FONT ALTER
	{
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

	Canvas.SetPos(Canvas.ClipX*0.1, YOffset);
	Canvas.DrawText(PRI.PlayerName, false);
		//FONT ALTER
	//Canvas.Font = RegFont;
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticMedFont();
	else
		Canvas.Font = RegFont;

	// Draw Score
	Canvas.SetPos(Canvas.ClipX*0.5, YOffset);
	Canvas.DrawText(int(PRI.Score), false);

	// Draw Deaths
	Canvas.SetPos(Canvas.ClipX*0.6, YOffset);
	Canvas.DrawText(int(PRI.Deaths), false);

	if (Canvas.ClipX > 512 && Level.Netmode != NM_Standalone)
	{
		// Draw Ping
		Canvas.SetPos(Canvas.ClipX*0.7, YOffset);
		Canvas.DrawText(PRI.Ping, false);

		// Packetloss
			//FONT ALTER
		//Canvas.Font = RegFont;
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
	//Canvas.Font = Font'SmallFont';
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
		Canvas.DrawColor = CyanColor;
		Canvas.DrawText(PRI.MaxSpree, false);
		Canvas.DrawColor = WhiteColor;
		AwardPos += XL*2;
	}
	if (PRI.HeadKills > 0)
	{	// Head kills
		Canvas.SetPos(AwardPos-YL+XL*0.25, YOffset-YL*0.5);
		Canvas.DrawTile(HeadIcon, YL*2, YL*2, 0, 0, HeadIcon.USize, HeadIcon.VSize);
		Canvas.SetPos(AwardPos, YOffset);
		Canvas.DrawColor = CyanColor;
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

function SortScores(int N)
{
	local int i,j,Max;
	local PlayerReplicationInfo TempPRI;

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

function ShowScores( canvas Canvas )
{
	local PlayerReplicationInfo PRI;
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
		//FONT ALTER
	//Canvas.Font = RegFont;
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticMedFont();
	else
		Canvas.Font = RegFont;

	Canvas.DrawColor = WhiteColor;

	// Header
	DrawHeader(Canvas);
	DrawTableHeadings(Canvas);

	// Calculate vertical spacing
	Canvas.StrLen("TEST", XL, YL);
	YStart = Canvas.CurY;

	//TODO: Calculate continuous spacing based on screensize available

	if (PlayerCount < 15)
		YL *= 2;
	else if (PlayerCount < 20)
		YL *= 1.5;
	if (PlayerCount > 15)
		PlayerCount = FMin(PlayerCount, (Canvas.ClipY - YStart)/YL - 1);

	DrawBackground(Canvas, 0.1*Canvas.ClipX, YStart-YL*0.25+1, 0.8*Canvas.ClipX, PlayerCount*YL);

	YOffset = YStart;
	for ( I=0; I<PlayerCount; I++ )
	{
		YOffset = YStart + I*YL;
		DrawPlayerInfo(Canvas, Ordered[I], 0, YOffset);
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
     GreenColor=(G=255)
     WhiteColor=(R=255,G=255,B=255)
     GoldColor=(R=255,G=255)
     CyanColor=(G=255,B=255)
     RedColor=(R=255)
     LightCyanColor=(R=128,G=255,B=255)
     LightGreenColor=(G=128,B=128)
     VioletColor=(R=228,B=228)
     BlueColor=(B=255)
     BackgroundColor=(R=255,G=255,B=255)
     ReadyText="R"
     RemainingTimeMsg="Remaining Time: "
     ElapsedTimeMsg="Elapsed Time: "
     GameTypeMsg="Game Type: "
     MapTitleMsg="Map: "
     IdealPlayerCountMsg="Ideal Player Load:"
     NumPlayersMsg=" Players"
     RestartMsg="You are dead.  Hit [Fire] to respawn!"
     ContinueMsg="The match has ended. "
     ContinueTrailer="reached."
     NameText="Name"
     FragsText="Frags"
     DeathsText="Deaths"
     PingText="Ping"
     AwardsText="Trophies"
     FirstBloodIcon=Texture'RuneI.TrophyFirstBlood'
     SpreeIcon=Texture'RuneI.TrophySpree'
     HeadIcon=Texture'RuneI.TrophyHeads'
     Seperator=Texture'RuneI.sb_seperator'
     Background=Texture'RuneI.sb_horizramp'
     BackgroundAlpha=0.100000
     RegFont=Font'Engine.MedFont'
}
