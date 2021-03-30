class R_RunePlayerHUD_Arena extends RMod.R_RunePlayerHUD;

var Texture DisplayNumbers[10];
var float BackgroundFade;

simulated function PostRender( canvas Canvas )
{
	local PlayerPawn thePlayer;

	Super.PostRender(Canvas);

	thePlayer = PlayerPawn(Owner);

	if(thePlayer == None || HudMode == 0 || thePlayer.bShowMenu 
		|| thePlayer.bShowScores || Level.Pauser != "" || thePlayer.RendMap == 0)
	{
		return;
	}

	DrawCountdownTimer(Canvas);
	DrawQueueNumbers(Canvas);

	//Reset
	Canvas.Style = ERenderStyle.STY_Normal;		
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
}

simulated function DrawFragCount(canvas Canvas, int x, int y)
{
	local float textwidth, textheight;
	local int score, loses;
	local string text;
	local PlayerPawn PlayerOwner;

	PlayerOwner = PlayerPawn(Owner);

	if ( PlayerOwner.PlayerReplicationInfo == None )
		return;

	score = int(PlayerOwner.PlayerReplicationInfo.Score);
	loses = int(PlayerOwner.PlayerReplicationInfo.Deaths);


	text = score$"-"$loses$" ";
	
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticLargeFont();
	else
		Canvas.Font = Canvas.LargeFont;

	Canvas.DrawTextRightJustify(text, X, Y);
}

simulated function DrawCountdownTimer(canvas Canvas)
{
	local PlayerPawn PlayerOwner;
	local ArenaGameReplicationInfo ArenaRepInfo;
	local string strTime;
	local float XL, YL;

	PlayerOwner = PlayerPawn(Owner);

	if(PlayerOwner == None || PlayerOwner.GameReplicationInfo==None)
		return;

	if(PlayerOwner.PlayerReplicationInfo.Team == 255)
		return;

	ArenaRepInfo = ArenaGameReplicationInfo(PlayerOwner.GameReplicationInfo);
	if(ArenaRepInfo == None)
		return;

	if(!ArenaRepInfo.bDrawTimer)
		return;

	strTime = TwoDigitString(ArenaRepInfo.curTimer);
	if(ArenaRepInfo.curTimer <= 3)
		Canvas.SetColor(255, 0, 0);
	else
		Canvas.SetColor(255,255,255);
	
	Canvas.StrLen(strTime, XL, YL);
	Canvas.SetPos((Canvas.ClipX * 0.5) - (XL * 0.5), (Canvas.ClipY * 0.3) - (YL * 0.5));
	Canvas.DrawText(strTime, false);

	Canvas.SetColor(255,255,255);	
}

simulated function DrawQueueNumbers(canvas Canvas)
{
	local RunePlayer P;
	local PlayerPawn PlayerOwner;
	local int SX,SY;
	local float scale, dist;
	local Texture Tex;
	local vector pos;
	local int i, dispNumber;
	local int onesDigit, tensDigit;
	local ArenaGameReplicationInfo ArenaRepInfo;

	PlayerOwner = PlayerPawn(Owner);

	if(PlayerOwner == None)
		return;

	//Never want to draw the numbers if Player is in the Arena...
	if(!PlayerOwner.Region.Zone.IsA('QueueZone'))
		return;
	
	Canvas.Style = ERenderStyle.STY_AlphaBlend;
	Canvas.AlphaScale = BackgroundFade;

	foreach AllActors(class'RunePlayer', P)
	{
		if(P.PlayerReplicationInfo == None || P.PlayerReplicationInfo.TeamID > 16)
			continue;

		dispNumber = P.PlayerReplicationInfo.TeamID;

		pos = P.Location + vect(0, 0, 1.3) * P.CollisionHeight;
		if(!FastTrace(pos, PlayerOwner.ViewLocation))
			continue;

		Canvas.TransformPoint(pos, SX, SY);
		if(SX > 0 && SX < Canvas.ClipX && SY > 0 && SY < Canvas.ClipY)
		{
			dist = VSize(P.Location - PlayerOwner.ViewLocation);
			if(dist > 600)
				continue;

			dist = FClamp(dist, 1, 600);
			scale = 500.0/dist * 0.75;
			scale = FClamp(scale, 0.01, 0.75);

			if(dispNumber > 9)
			{
				//Special Handling for multi-digits
				onesDigit = dispNumber % 10;
				tensDigit = dispNumber / 10;
				
				Canvas.SetPos(SX-(DisplayNumbers[0].USize*scale*0.5)*0.5, SY-DisplayNumbers[0].VSize*scale*0.5);
				Canvas.DrawIcon(DisplayNumbers[tensDigit], scale * 0.5);
				Canvas.SetPos(SX+(DisplayNumbers[0].USize*scale*0.5)*0.5, SY-DisplayNumbers[0].VSize*scale*0.5);
				Canvas.DrawIcon(DisplayNumbers[onesDigit], scale * 0.5);
			}
			else
			{
				Canvas.SetPos(SX-(DisplayNumbers[0].USize*scale*0.5)*0.5, SY-DisplayNumbers[0].VSize*scale*0.5);
				Canvas.DrawIcon(DisplayNumbers[dispNumber], scale * 0.5);
			}		
		}
	}

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.AlphaScale = 1.0;

}//end-function

defaultproperties
{
     DisplayNumbers(0)=Texture'Arena.TexZero'
     DisplayNumbers(1)=Texture'Arena.TexOne'
     DisplayNumbers(2)=Texture'Arena.TexTwo'
     DisplayNumbers(3)=Texture'Arena.TexThree'
     DisplayNumbers(4)=Texture'Arena.TexFour'
     DisplayNumbers(5)=Texture'Arena.TexFive'
     DisplayNumbers(6)=Texture'Arena.TexSix'
     DisplayNumbers(7)=Texture'Arena.TexSeven'
     DisplayNumbers(8)=Texture'Arena.TexEight'
     DisplayNumbers(9)=Texture'Arena.TexNine'
     BackgroundFade=0.500000
}
