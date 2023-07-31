class R_Scoreboard extends RuneScoreboard;

var class<R_AColors> ColorsClass;
var class<R_AUtilities> UtilitiesClass;

const SCOREBOARD_NOTES_COUNT = 5;
var String ScoreboardNotes[5];

var float RelPosX_Name;
var float RelPosX_Score;
var float RelPosX_Deaths;
var float RelPosX_DamageDealt;
var float RelPosX_Ping;
var float RelPosX_Awards;

var localized String DamageDealtText;

// Used for relative Canvas drawing
struct FCanvasContext
{
	var float OriginX;
	var float OriginY;
	var float ClipX;
	var float ClipY;
};
var private FCanvasContext CanvasContext;

simulated function SetCanvasContext(
	Canvas C,
	float OriginX, float OriginY,
	float Width, float Height)
{
		CanvasContext.ClipX = C.ClipX;
		CanvasContext.ClipY = C.ClipY;
		CanvasContext.OriginX = C.OrgX;
		CanvasContext.OriginY = C.OrgY;
		C.SetOrigin(OriginX, OriginY);
		C.SetClip(Width, Height);
}

simulated function RestoreCanvasContext(Canvas C)
{
	C.SetOrigin(CanvasContext.OriginX, CanvasContext.OriginY);
	C.SetClip(CanvasContext.ClipX, CanvasContext.ClipY);
}

simulated function DrawTextScrolling(
    Canvas C,
    float PosX, float PosY,
    float Width, float Height,
    String DrawString,
    optional float ScrollRate)
{
    local float StringW, StringH;
    local float d, t;

    C.Font = Font'MedFont';
    C.DrawColor = ColorsClass.Static.ColorWhite();/////////
    C.Style = EREnderStyle.STY_Translucent;
    C.StrLen(DrawString, StringW, StringH);

    // Duration for a full scroll
    if(ScrollRate == 0.0)
        ScrollRate = 20.0;
    d = (Width + StringW) / ScrollRate;

    // Linear interpolation
    t = UtilitiesClass.Static.InterpLinear(
            Level.TimeSeconds % d, Width, -StringW, d);

    // Draw the clipped text
    SetCanvasContext(C, PosX, PosY, Width, Height);
    C.SetPos(t, (Height * 0.5) - (StringH * 0.5));
    C.DrawTextClipped(DrawString);
    RestoreCanvasContext(C);
}

simulated function String GetMOTDString()
{
	local String S;
	local GameReplicationInfo GRI;
	local String Separator;
	
	GRI = PlayerPawn(Owner).GameReplicationInfo;
	
	Separator = "    <>    ";
	S = "";
	
	if(GRI.MOTDLine1 != "")
	{
		S = GRI.MOTDLine1;
	}
	
	if(GRI.MOTDLine2 != "")
	{
		if(S != "")
		{
			S = S $ Separator;
		}
		S = S $ GRI.MOTDLine2;
	}
	
	if(GRI.MOTDLine3 != "")
	{
		if(S != "")
		{
			S = S $ Separator;
		}
		S = S $ GRI.MOTDLine3;
	}
	
	if(GRI.MOTDLine4 != "")
	{
		if(S != "")
		{
			S = S $ Separator;
		}
		S = S $ GRI.MOTDLine4;
	}
	
	return S;
}

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

simulated function DrawBackground( canvas Canvas, int X, int Y, int W, int H)
{
	//Canvas.DrawColor = BackgroundColor;
	//Canvas.Style = ERenderStyle.STY_AlphaBlend;
	//Canvas.AlphaScale = BackgroundAlpha;
	//Canvas.SetPos(X, Y);
	//Canvas.DrawTile(Background, W, H, 0, 0, Background.USize, Background.VSize);
	//Canvas.Style = ERenderStyle.STY_Normal;
	//Canvas.AlphaScale = 1.0;
}

simulated function String GetSpectatorsString()
{
	local PlayerPawn P;
	local String Result;
	
	Result = "";
	foreach AllActors(class'Engine.PlayerPawn', P)
	{
		if(!P.bIsPlayer
		|| P.PlayerReplicationInfo == None
		|| !P.PlayerReplicationInfo.bIsSpectator)
		{
			continue;
		}
		
		Result = Result $ "    " $ P.PlayerReplicationInfo.PlayerName;
	}
	
	if(Result == "")
	{
		Result = "[No spectators]";
	}
	else
	{
		Result = "[Spectators]:    " $ Result;
	}
	
	return Result;
}

function DrawPlayerInfo( canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YOffset)
{
	local bool bLocalPlayer;
	local PlayerPawn PlayerOwner;
	local float XL,YL;
	local int AwardPos;
	local R_PlayerReplicationInfo RPRI;
	local color DrawColor, ColorT0, ColorT1;
	local float InterpTime;

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

		//FONT ALTER
	//Canvas.Font = RegFont;
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticMedFont();
	else
		Canvas.Font = RegFont;

	// Draw Frags
	Canvas.SetPos(Canvas.ClipX*RelPosX_Score, YOffset);
	Canvas.DrawText(int(PRI.Score), false);

	// Draw Deaths
	Canvas.SetPos(Canvas.ClipX*RelPosX_Deaths, YOffset);
	Canvas.DrawText(int(PRI.Deaths), false);

	// RMod stuff
	RPRI = R_PlayerReplicationInfo(PRI);
	if(RPRI != None)
	{
		// Draw Damage Dealt
		Canvas.SetPos(Canvas.ClipX*RelPosX_DamageDealt, YOffset);
		Canvas.DrawText(RPRI.DamageDealt, false);
	}

	if (Canvas.ClipX > 512 && Level.Netmode != NM_Standalone)
	{
		// Draw Ping
		Canvas.SetPos(Canvas.ClipX*0.7, YOffset);
		if(RPRI != None)
		{
			InterpTime = float(PRI.Ping);
			ColorT0 = ColorsClass.static.ColorGreen();
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
	        //Canvas.Font = RegFont;
		if(MyFonts != None)
			Canvas.Font = MyFonts.GetStaticMedFont();
		else
			Canvas.Font = RegFont;

		Canvas.DrawColor = WhiteColor;
	}

	// Draw Awards
	AwardPos = Canvas.ClipX*RelPosX_Awards;
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

defaultproperties
{
     ColorsClass=Class'RMod.R_AColors'
     UtilitiesClass=Class'RMod.R_AUtilities'
     ScoreboardNotes(0)="Hit stun enabled for shield users"
     ScoreboardNotes(1)="BattleHammer, WorkHammer, and PitMace deal 100% increased damaged to shields"
     ScoreboardNotes(2)="Thrown weapons of tier 1-3 cannot be blocked, but tiers 4-5 can be blocked"
     ScoreboardNotes(3)="Increased attack range of the DwarfBattleSword and SigurdAxe"
     ScoreboardNotes(4)="Enabled blade weaving for VikingAxe and SigurdAxe"
     RelPosX_Name=0.100000
     RelPosX_Score=0.350000
     RelPosX_Deaths=0.450000
     RelPosX_DamageDealt=0.550000
     RelPosX_Ping=0.700000
     RelPosX_Awards=0.800000
     DamageDealtText="Damage"
}
