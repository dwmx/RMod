class R_Scoreboard extends RuneScoreboard;

var class<R_AColors> ColorsClass;
var class<R_AUtilities> UtilitiesClass;

const SCOREBOARD_NOTES_COUNT = 5;
var String ScoreboardNotes[5];

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
	Canvas.DrawColor = WhiteColor;
	Canvas.SetPos(Canvas.ClipX*0.1, YOffset);
	Canvas.DrawTile(Seperator, Canvas.ClipX*0.8, YL*0.5, 0, 0, Seperator.USize, Seperator.VSize);
	YOffset += YL*0.75;
	Canvas.SetPos(Canvas.ClipX*0.1, YOffset);

	YOffset += 48.0;

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

defaultproperties
{
     ColorsClass=Class'RMod.R_AColors'
     UtilitiesClass=Class'RMod.R_AUtilities'
     ScoreboardNotes(0)="Hit stun enabled for shield users"
     ScoreboardNotes(1)="BattleHammer, WorkHammer, and PitMace deal 100% increased damaged to shields"
     ScoreboardNotes(2)="Thrown weapons of tier 1-3 cannot be blocked, but tiers 4-5 can be blocked"
     ScoreboardNotes(3)="Increased attack range of the DwarfBattleSword and SigurdAxe"
     ScoreboardNotes(4)="Enabled blade weaving for VikingAxe and SigurdAxe"
}
