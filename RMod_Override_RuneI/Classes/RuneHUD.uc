//=============================================================================
// RuneHUD.
//=============================================================================
class RuneHUD extends HUD;

#exec TEXTURE IMPORT NAME=IconSkull  FILE=Textures\HUD\HealthIcon.pcx MIPS=OFF

#exec TEXTURE IMPORT NAME=PowerTick FILE=Textures\HUD\Tick.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=NetOutage FILE=Textures\HUD\NetOutage.pcx MIPS=OFF FLAGS=2

#exec TEXTURE IMPORT NAME=ShieldIcon FILE=Textures\HUD\ShieldIcon.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=AirIcon FILE=Textures\HUD\AirIcon.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=ShieldEmpty FILE=Textures\HUD\ShieldEmpty.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=AirEmpty FILE=Textures\HUD\AirEmpty.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=BloodEmpty FILE=Textures\HUD\BloodEmpty.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=ShieldFull FILE=Textures\HUD\ShieldFull.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=AirFull FILE=Textures\HUD\AirFull.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=BloodFull FILE=Textures\HUD\BloodFull.pcx MIPS=OFF FLAGS=2

#exec TEXTURE IMPORT NAME=HealthIcon FILE=Textures\HUD\HealthIcon.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=HealthEmpty FILE=Textures\HUD\HealthEmpty.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=HealthFull FILE=Textures\HUD\HealthFull.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=HealthEmptyTop FILE=Textures\HUD\HealthEmptyTop.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=HealthFullTop FILE=Textures\HUD\HealthFullTop.pcx MIPS=OFF FLAGS=2

#exec TEXTURE IMPORT NAME=RuneIcon FILE=Textures\HUD\RuneIcon.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=RuneEmpty FILE=Textures\HUD\RuneEmpty.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=RuneFull FILE=Textures\HUD\RuneFull.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=RuneEmptyTop FILE=Textures\HUD\RuneEmptyTop.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=RuneFullTop FILE=Textures\HUD\RuneFullTop.pcx MIPS=OFF FLAGS=2

// SarkHud textures
#exec TEXTURE IMPORT NAME=SarkShieldIcon FILE=Textures\HUD\SarkShieldIcon.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=SarkAirIcon FILE=Textures\HUD\SarkAirIcon.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=SarkShieldEmpty FILE=Textures\HUD\SarkShieldEmpty.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=SarkAirEmpty FILE=Textures\HUD\SarkAirEmpty.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=SarkBloodEmpty FILE=Textures\HUD\SarkBerserkEmpty.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=SarkShieldFull FILE=Textures\HUD\SarkShieldFull.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=SarkAirFull FILE=Textures\HUD\SarkAirFull.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=SarkBloodFull FILE=Textures\HUD\SarkBerserkFull.pcx MIPS=OFF FLAGS=2

#exec TEXTURE IMPORT NAME=SarkHealthIcon FILE=Textures\HUD\SarkHealthIcon.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=SarkHealthEmpty FILE=Textures\HUD\SarkHealthEmpty.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=SarkHealthFull FILE=Textures\HUD\SarkHealthFull.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=SarkHealthEmptyTop FILE=Textures\HUD\SarkHealthEmptyTop.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=SarkHealthFullTop FILE=Textures\HUD\SarkHealthFullTop.pcx MIPS=OFF FLAGS=2

#exec TEXTURE IMPORT NAME=SarkRuneIcon FILE=Textures\HUD\SarkRuneIcon.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=SarkRuneEmpty FILE=Textures\HUD\SarkRuneEmpty.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=SarkRuneFull FILE=Textures\HUD\SarkRuneFull.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=SarkRuneEmptyTop FILE=Textures\HUD\SarkRuneEmptyTop.pcx MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=SarkRuneFullTop FILE=Textures\HUD\SarkRuneFullTop.pcx MIPS=OFF FLAGS=2

var float CineLoc;
var() float CineSpeed;
var() Texture TypingIcon;

var() float HudScale; // DEBUG!

// Variables used for smoothing out the fill bars
var float HudHealth;
var float HudPower;
var float HudShield;
var float HudBloodlust;
var float HudAir;

// Variables used for fading the various bars in and out
var float FadeHealth;
var float FadePower;
var float FadeShield;
var float FadeBloodlust;
var float FadeAir;

var bool bHealth;
var bool bPower;
var bool bShield;
var bool bBloodLust;
var bool bAir;
var bool bResChanged;
var bool bTimeDown;
var int OldClipX;

var float BloodScale;

var globalconfig string FontInfoClass;
var FontInfo MyFonts;

struct HUDRuneMessage
{
	var vector		Position;
	var string		Text;
	var float		Age;			// Time passed
	var float		LifeTime;		// Total time to live (not including fade in/out)
	var float		EndOfLife;		// Time to remove
	var color		DrawColor;
	var font		DrawFont;
	var float		FadeAlpha;		// Current fade alpha
	var float		FadeTime;		// Fade In/Out interval
	var bool		bFade;
	var bool		bUsed;
	var E_RMAlign	align;
};

const QueueSize		= 4;					// Size of MessageQueue
var HUDLocalizedMessage MessageQueue[4];
var HUDRuneMessage RuneMessageQueue[16];


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	//FONT ALTER
	if(FontInfoClass != "")
		MyFonts = FontInfo(spawn(Class<Actor>(DynamicLoadObject(FontInfoClass, class'Class'))));

	HudHealth = 0;
	HudPower = 0;
	HudShield = 0;
	HudBloodlust = 0;
	HudAir = 0;	

	FadeHealth = 0;
	FadePower = 0;
	FadeShield = 0;
	FadeBloodlust = 0;
	FadeAir = 0;

	BloodScale = 0.5;

	SetTimer(1.0, True);
}

function Timer()
{
	local int i, j;

	// Age the message queues
	for (i=0; i<QueueSize; i++)
	{	// Purge expired messages.
		if ( (MessageQueue[i].Message != None) && (Level.TimeSeconds >= MessageQueue[i].EndOfLife) )
			ClearMessage(MessageQueue[i]);
	}

	for (i=0; i<16; i++)
	{
		if ( RuneMessageQueue[i].bUsed && Level.TimeSeconds >= RuneMessageQueue[i].EndOfLife)
			RuneMessageQueue[i].bUsed = false;
	}

	// Clean empty slots.
	for (i=0; i<QueueSize-1; i++)
	{
		if ( MessageQueue[i].Message == None )
		{
			for (j=i; j<QueueSize; j++)
			{
				if ( MessageQueue[j].Message != None )
				{
					CopyMessage(MessageQueue[i],MessageQueue[j]);
					ClearMessage(MessageQueue[j]);
					break;
				}
			}
		}
	}
}

simulated function Tick(float DeltaSeconds)
{
	local float delta;
	local Pawn P;
	local int i;

	Super.Tick(DeltaSeconds);

	P = Pawn(Owner);
	
	// Smooth Health		
	delta = P.Health - HudHealth;
	if(delta != 0)
	{
		HudHealth += delta * DeltaSeconds * 6;
		if((delta > 0 && HudHealth > P.Health) || (delta < 0 && HudHealth < P.Health))
			HudHealth = P.Health;
	}

	// Smooth Power	
	delta = P.RunePower - HudPower;
	if(delta != 0)
	{
		HudPower += delta * DeltaSeconds * 6;
		if((delta > 0 && HudPower > P.RunePower) || (delta < 0 && HudPower < P.RunePower))
			HudPower = P.RunePower;
	}
	
	// Smooth Shield
	if(P.Shield != None)
	{
		delta = P.Shield.Health - HudShield;
		if(delta != 0)
		{
			HudShield += delta * DeltaSeconds * 6;
			if((delta > 0 && HudShield > P.Shield.Health) || (delta < 0 && HudShield < P.Shield.Health))
				HudShield = P.Shield.Health;
		}
	}

	// Smooth Bloodlust
	delta = P.Strength - HudBloodlust;
	if(delta != 0)
	{
		HudBloodlust += delta * DeltaSeconds * 6;
		if((delta > 0 && HudBloodlust > P.Strength) || (delta < 0 && HudBloodlust < P.Strength))
			HudBloodlust = P.Strength;
	}	
	
	// Smooth Air
	if(P.HeadRegion.Zone.bWaterZone)
	{
		delta = P.PainTime - HudAir;
		if(delta != 0)
		{
			HudAir += delta * DeltaSeconds * 6;
			if((delta > 0 && HudAir > P.PainTime) || (delta < 0 && HudAir < P.PainTime))
				HudAir = P.PainTime;
		}
	}
	else
	{
		delta = P.UnderWaterTime - HudAir;
		if(delta != 0)
		{
			HudAir += delta * DeltaSeconds * 6;
			if((delta > 0 && HudAir > P.UnderWaterTime) || (delta < 0 && HudAir < P.UnderWaterTime))
				HudAir = P.UnderWaterTime;
		}
	}
	
	// Smooth out the fades
	if(bHealth)
	{
		FadeHealth += DeltaSeconds * 2;
		if(FadeHealth > 1)
			FadeHealth = 1;
	}
	else
	{
		FadeHealth -= DeltaSeconds * 2;
		if(FadeHealth < 0)
			FadeHealth = 0;
	}

	if(bPower)
	{
		FadePower += DeltaSeconds * 2;
		if(FadePower > 1)
			FadePower = 1;
	}
	else
	{
		FadePower -= DeltaSeconds * 2;
		if(FadePower < 0)
			FadePower = 0;
	}

	if(bBloodLust)
	{
		FadeBloodlust += DeltaSeconds * 2;
		if(FadeBloodlust > 1)
			FadeBloodlust = 1;
	}
	else
	{
		FadeBloodlust -= DeltaSeconds * 2;
		if(FadeBloodlust < 0)
			FadeBloodlust = 0;
	}

	if(bShield)
	{
		FadeShield += DeltaSeconds * 2;
		if(FadeShield > 1)
			FadeShield = 1;
	}
	else
	{
		FadeShield -= DeltaSeconds * 2;
		if(FadeShield < 0)
			FadeShield = 0;
	}

	if(bAir)
	{
		FadeAir += DeltaSeconds * 2;
		if(FadeAir> 1)
			FadeAir = 1;
	}
	else
	{
		FadeAir -= DeltaSeconds * 2;
		if(FadeAir < 0)
			FadeAir = 0;
	}

	// Smooth BloodLust Scale (scaled up when the player is bloodlusting)
	if(PlayerPawn(Owner).bBloodLust)
	{
		BloodScale += DeltaSeconds * 2;
		if(BloodScale > 1)
			BloodScale = 1.0;
	}
	else
	{
		BloodScale -= DeltaSeconds * 2;
		if(BloodScale < 0.5)
			BloodScale = 0.5;
	}

	// Fade RuneMessageQueue
	for (i=0; i<16; i++)
	{
		if (RuneMessageQueue[i].bUsed && RuneMessageQueue[i].bFade)
		{
			RuneMessageQueue[i].Age += DeltaSeconds;
			if (RuneMessageQueue[i].Age < RuneMessageQueue[i].FadeTime)
			{	// Fading In
				RuneMessageQueue[i].FadeAlpha = RuneMessageQueue[i].Age / RuneMessageQueue[i].FadeTime;
				if (RuneMessageQueue[i].FadeAlpha > 1)
					RuneMessageQueue[i].FadeAlpha = 1;
			}
			else if (RuneMessageQueue[i].Age > RuneMessageQueue[i].FadeTime + RuneMessageQueue[i].LifeTime)
			{	// Fading Out
				RuneMessageQueue[i].FadeAlpha = 1 - ((RuneMessageQueue[i].Age-RuneMessageQueue[i].LifeTime-RuneMessageQueue[i].FadeTime) / RuneMessageQueue[i].FadeTime);
				if (RuneMessageQueue[i].FadeAlpha < 0)
					RuneMessageQueue[i].FadeAlpha = 0;
				if (RuneMessageQueue[i].FadeAlpha > 1)
					RuneMessageQueue[i].FadeAlpha = 1;
			}
		}
	}
}


simulated function ChangeHud(int d)
{
	HudMode = HudMode + d;
	if ( HudMode>1 ) HudMode = 0;
	else if ( HudMode < 0 ) HudMode = 1;
}

simulated function DefaultCanvas( canvas Canvas )
{
	Canvas.Reset();
	Canvas.SpaceX=0;
	Canvas.SpaceY=0;
	Canvas.bNoSmooth = True;
	Canvas.DrawColor.r = 255;
	Canvas.DrawColor.g = 255;
	Canvas.DrawColor.b = 255;	
//	FONT ALTER
//	Canvas.Font = Canvas.LargeFont;
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticLargeFont();
	else
		Canvas.Font = Canvas.LargeFont;
}


simulated function CreateMenu()
{
	if ( MainMenu == None )
		MainMenu = Spawn(MainMenuType, self);
		
	if ( MainMenu == None )
	{
		PlayerPawn(Owner).bShowMenu = false;
		Level.bPlayersOnly = false;
		return;
	}
	else
	{
		MainMenu.PlayerOwner = PlayerPawn(Owner);
		MainMenu.PlayEnterSound();
		MainMenu.MenuInit();
	}
}

simulated function DisplayMenu( canvas Canvas )
{
	local float VersionW, VersionH;

	if ( MainMenu == None )
		CreateMenu();
	if ( MainMenu != None )
		MainMenu.DrawMenu(Canvas);

	if ( MainMenu.Class == MainMenuType )
	{
		Canvas.bCenter = false;
		//FONT ALTER
		//Canvas.Font = Canvas.MedFont;
		if(MyFonts != None)
			Canvas.Font = MyFonts.GetStaticMedFont();
		else
			Canvas.Font = Canvas.MedFont;

		Canvas.Style = 1;
		Canvas.StrLen(Level.EngineVersion, VersionW, VersionH);
		Canvas.SetPos(Canvas.ClipX - VersionW - 4, 4);	
		Canvas.DrawText(Level.EngineVersion, False);	
	}
}

simulated function DisplayProgressMessage( canvas Canvas )
{
	local int i;
	local float YOffset, XL, YL;

	Canvas.SetColor(255, 255, 255);
	Canvas.bCenter = true;
	//FONT ALTER
	//Canvas.Font = Canvas.MedFont;
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticMedFont();
	else
		Canvas.Font = Canvas.MedFont;

	YOffset = 0;
	Canvas.StrLen("TEST", XL, YL);
	for (i=0; i<5; i++)
	{
		Canvas.SetPos(0, 0.25 * Canvas.ClipY + YOffset);
		Canvas.DrawColor = PlayerPawn(Owner).ProgressColor[i];
		Canvas.DrawText(PlayerPawn(Owner).ProgressMessage[i], false);
		YOffset += YL + 1;
	}
	Canvas.bCenter = false;
	Canvas.SetColor(255, 255, 255);
}

function RuneMessage( string Msg, vector Position, optional color DrawColor, optional Font aFont, optional float Life, optional bool bFade, optional float FadeTime, optional E_RMAlign align)
{
	local int i;

	for (i=0; i<16; i++)
	{
		if (!RuneMessageQueue[i].bUsed)
		{
			RuneMessageQueue[i].bUsed = true;
			RuneMessageQueue[i].Text = Msg;
			RuneMessageQueue[i].Position = Position;
			RuneMessageQueue[i].Age = 0;
			RuneMessageQueue[i].LifeTime = Life;
			RuneMessageQueue[i].EndOfLife = Level.TimeSeconds + Life;
			RuneMessageQueue[i].DrawColor = DrawColor;
			RuneMessageQueue[i].bFade = bFade;
			RuneMessageQueue[i].Align = Align;
			if (bFade)
			{
				if (FadeTime != 0)
					RuneMessageQueue[i].FadeTime = FadeTime;
				else
					RuneMessageQueue[i].FadeTime = 1;

				RuneMessageQueue[i].FadeAlpha = 0;
				RuneMessageQueue[i].EndOfLife += FadeTime*2;
			}
			else
			{
				RuneMessageQueue[i].FadeAlpha = 1;
			}
			//FONT ALTER
			if (aFont != None)
			{
				if(MyFonts != None)
				{
				 	switch(aFont)
					{
					
					case Font'SmallFont':
						RuneMessageQueue[i].DrawFont = MyFonts.GetStaticSmallFont();
						break;
					case Font'MedFont':
						RuneMessageQueue[i].DrawFont = MyFonts.GetStaticMedFont();
						break;
					case Font'Haettenschweiler16': 
					case Font'RuneBig':
						RuneMessageQueue[i].DrawFont = MyFonts.GetStaticBigFont();
						break;
					case Font'RuneLarge':
						RuneMessageQueue[i].DrawFont = MyFonts.GetStaticLargeFont();
						break;
					case Font'RuneMed':
						RuneMessageQueue[i].DrawFont = MyFonts.GetStaticRuneMedFont();
						break;
					case Font'RuneCred':
						RuneMessageQueue[i].DrawFont = MyFonts.GetStaticCreditsFont();
						break;
					case Font'RuneButton':
						RuneMessageQueue[i].DrawFont = MyFonts.GetStaticButtonFont();
						break;
					default:
						RuneMessageQueue[i].DrawFont = aFont;
						break;
					}
				}
				else
					RuneMessageQueue[i].DrawFont = aFont;
			}
			else	//FONT ALTER
			{//RuneMessageQueue[i].DrawFont = class'Canvas'.Default.SmallFont;
				if(MyFonts != None)
					RuneMessageQueue[i].DrawFont = MyFonts.GetStaticSmallFont();
				else
					RuneMessageQueue[i].DrawFont = class'Canvas'.Default.SmallFont;
			}
			return;
		}
	}
}


simulated function Class<LocalMessage> DetermineClass(name MsgType)
{
	local Class<LocalMessage> MessageClass;

	switch (MsgType)
	{
		case 'Subtitle':
			MessageClass=class'SubtitleMessage';
			break;
		case 'RedSubtitle':
			MessageClass=class'SubtitleRed';
			break;
		case 'Pickup':
			MessageClass=class'PickupMessage';
			break;
		case 'Say':
		case 'TeamSay':
			MessageClass=class'SayMessage';
			break;
		case 'NoRunePower':
			MessageClass=class'NoRunePowerMessage';
			break;
		case 'CriticalEvent':
		case 'DeathMessage':
		case 'Event':
		default:
			MessageClass=class'GenericMessage';
			break;
	}
	return MessageClass;
}

// Entry point for string messages.(OBSOLETE)
simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	local Class<LocalMessage> MessageClass;

	switch (MsgType)
	{
		case 'Subtitle':
			MessageClass=class'SubtitleMessage';
			break;
		case 'RedSubtitle':
			MessageClass=class'SubtitleRed';
			break;
		case 'Pickup':
			MessageClass=class'PickupMessage';
			break;
		case 'Say':
		case 'TeamSay':
			MessageClass=class'SayMessage';
			break;
		case 'NoRunePower':
			MessageClass=class'NoRunePowerMessage';
			break;
		case 'CriticalEvent':
		case 'DeathMessage':
		case 'Event':
		default:
			MessageClass=class'GenericMessage';
			break;
	}

	LocalizedMessage(MessageClass, 0, PRI, None, None, Msg);
}


// Entry point for localized messages
simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional String CriticalString )
{
	local int i;

	if ( Message.Static.KillMessage() )
		return;

	if ( CriticalString == "" )
		CriticalString = Message.Static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	Message.Static.MangleString(CriticalString, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if ( Message.Default.bIsUnique )
	{	// If unique, stomp any identical existing message
		for (i=0; i<QueueSize; i++)
		{
			if (MessageQueue[i].Message != None)
			{
				if (MessageQueue[i].Message == Message)
				{
					MessageQueue[i].Message = Message;
					MessageQueue[i].Switch = Switch;
					MessageQueue[i].RelatedPRI = RelatedPRI_1;
					MessageQueue[i].OptionalObject = OptionalObject;
					MessageQueue[i].LifeTime = Message.Static.GetLifeTime(CriticalString);
					MessageQueue[i].EndOfLife = MessageQueue[i].LifeTime + Level.TimeSeconds;
					MessageQueue[i].StringMessage = CriticalString;
					MessageQueue[i].DrawColor = Message.Static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);
					MessageQueue[i].XL = 0;
					return;
				}
			}
		}
	}
	for (i=0; i<QueueSize; i++)
	{
		if (MessageQueue[i].Message == None)
		{
			MessageQueue[i].Message = Message;
			MessageQueue[i].Switch = Switch;
			MessageQueue[i].RelatedPRI = RelatedPRI_1;
			MessageQueue[i].OptionalObject = OptionalObject;
			MessageQueue[i].LifeTime = Message.Static.GetLifeTime(CriticalString);
			MessageQueue[i].EndOfLife = MessageQueue[i].LifeTime + Level.TimeSeconds;
			MessageQueue[i].StringMessage = CriticalString;
			MessageQueue[i].DrawColor = Message.Static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);
			MessageQueue[i].XL = 0;
			return;
		}
	}

	// No empty slots.  Force a message out.
	for (i=0; i<QueueSize-1; i++)
		CopyMessage(MessageQueue[i],MessageQueue[i+1]);

	MessageQueue[QueueSize-1].Message = Message;
	MessageQueue[QueueSize-1].Switch = Switch;
	MessageQueue[QueueSize-1].RelatedPRI = RelatedPRI_1;
	MessageQueue[QueueSize-1].OptionalObject = OptionalObject;
	MessageQueue[QueueSize-1].LifeTime = Message.Static.GetLifeTime(CriticalString);
	MessageQueue[QueueSize-1].EndOfLife = MessageQueue[QueueSize-1].LifeTime + Level.TimeSeconds;
	MessageQueue[QueueSize-1].StringMessage = CriticalString;
	MessageQueue[QueueSize-1].DrawColor = Message.Static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);				
	MessageQueue[QueueSize-1].XL = 0;
}

simulated function ClearMessagesOfType(name MsgType)
{
	local Class<LocalMessage> MessageClass;
	local int i;

	MessageClass = DetermineClass(MsgType);
	if (MessageClass == None)
		return;

	for(i=0; i<QueueSize; i++)
	{
		if (MessageQueue[i].Message == MessageClass)
		{	// Kill Message
			ClearMessage(MessageQueue[i]);
		}
	}
}

simulated function bool DisplayMessages( canvas Canvas)
{	// We are drawing messages instead of Console
	return true;
//	return false;
}

simulated function DrawMessages(canvas Canvas)
{
	local int i,j,k;
	local float XL, YL, YPos, FadeValue;
	local string Message;

	for (i=0; i<QueueSize; i++)
	{
		if ( MessageQueue[i].Message != None )
		{
			if (MessageQueue[i].Message.Default.bFadeMessage && Level.bHighDetailMode)
			{
				FadeValue = (MessageQueue[i].EndOfLife - Level.TimeSeconds);
				if (FadeValue <= 0.0)
					continue;
			}

			j++;
			//FONT ALTER
			//Canvas.Font = Canvas.BigFont;
			if(MyFonts != None)
				Canvas.Font = MyFonts.GetStaticBigFont();
			else
				Canvas.Font = Canvas.BigFont;

			if (MessageQueue[i].Message.Default.bCenter)
				Canvas.bCenter = true;
			Canvas.StrLen("TEST", XL, YL);
			if ( bResChanged || MessageQueue[i].XL == 0 )
			{	// Determine dimensions of text
				if ( MessageQueue[i].Message.Default.bComplexString )
					Canvas.StrLen(MessageQueue[i].Message.Static.AssembleString( 
											self,
											MessageQueue[i].Switch,
											MessageQueue[i].RelatedPRI,
											MessageQueue[i].StringMessage), 
								   MessageQueue[i].XL, MessageQueue[i].YL);
				else
					Canvas.StrLen(MessageQueue[i].StringMessage, MessageQueue[i].XL, MessageQueue[i].YL);
				MessageQueue[i].numLines = Max(1, MessageQueue[i].YL / YL);
			}

			// Set the position
			MessageQueue[i].YPos = MessageQueue[i].Message.Static.GetOffset(MessageQueue[i].Switch, MessageQueue[i].YL, Canvas.ClipY);
			if (MessageQueue[i].YPos == 0)
			{
				Canvas.SetPos(0, 2 + YL * YPos);
				YPos += MessageQueue[i].numLines;
			}
			else
			{
				Canvas.SetPos(0, MessageQueue[i].YPos);
			}

			// Draw the text
			if ( MessageQueue[i].Message.Default.bComplexString )
			{
				// Use this for string messages with multiple colors.
				MessageQueue[i].Message.Static.RenderComplexMessage( 
					Canvas,
					MessageQueue[i].XL,  YL,
					MessageQueue[i].StringMessage,
					MessageQueue[i].Switch,
					MessageQueue[i].RelatedPRI,
					None,
					MessageQueue[i].OptionalObject
					);
			} 
			else
			{
				if (MessageQueue[i].Message.Default.bFadeMessage && Level.bHighDetailMode)
				{
					Canvas.Style = ERenderStyle.STY_Translucent;
					Canvas.DrawColor = MessageQueue[i].DrawColor * (FadeValue/MessageQueue[i].LifeTime);
				}
				else
				{
					Canvas.DrawColor = MessageQueue[i].Message.Default.DrawColor;
				}
				Canvas.DrawText(MessageQueue[i].StringMessage, False);
//				Canvas.DrawText(YPos@MessageQueue[i].StringMessage @ "NL="$MessageQueue[i].numLines @ "YL="$YL, False);
			}

			// Cleanup
			Canvas.bCenter = false;
			Canvas.Style = ERenderStyle.STY_Normal;
		}
	}
}

// Draw messages in the RuneMessageQueue
simulated function DrawRuneMessages(canvas Canvas)
{
	local int i;
	local int SX,SY;
	local float XL,YL;

	Canvas.Style = ERenderStyle.STY_Translucent;

	for (i=0; i<16; i++)
	{
		if ( RuneMessageQueue[i].bUsed )
		{
			Canvas.Font = RuneMessageQueue[i].DrawFont;
			Canvas.StrLen(RuneMessageQueue[i].Text, XL, YL);

			if (RuneMessageQueue[i].Position.Z != 0)
			{	// Transform from world coords
				Canvas.TransformPoint(RuneMessageQueue[i].Position, SX, SY);

				// Center message around transformed point
				SX -= XL/2;
				SY -= YL/2;
			}
			else
			{
				SX = RuneMessageQueue[i].Position.X * Canvas.ClipX / 640.0;
				SY = RuneMessageQueue[i].Position.Y * Canvas.ClipY / 480.0;

				switch(RuneMessageQueue[i].align)
				{
					case RMALIGN_CENTER:
						SX -= XL/2;
						SY -= YL/2;
						break;
					case RMALIGN_LEFT:
						break;
					case RMALIGN_RIGHT:
						SX -= XL;
						break;
				}

			}
			Canvas.SetPos(SX, SY);
			Canvas.DrawColor = RuneMessageQueue[i].DrawColor * RuneMessageQueue[i].FadeAlpha;
			Canvas.DrawTextClipped(RuneMessageQueue[i].Text, false);
		}
	}

	Canvas.bCenter = false;
	Canvas.Style = ERenderStyle.STY_Normal;	
}

simulated function string TwoDigitString(int Num)
{
	if ( Num < 10 )
		return "0"$Num;
	else
		return string(Num);
}

simulated function DrawRemainingTime(canvas Canvas, int x, int y)
{
	local int timeleft;
	local int Hours, Minutes, Seconds;

	if (PlayerPawn(Owner)==None || PlayerPawn(Owner).GameReplicationInfo==None)
		return;

	timeleft = PlayerPawn(Owner).GameReplicationInfo.RemainingTime;
	Hours   = timeleft / 3600;
	Minutes = timeleft / 60;
	Seconds = timeleft % 60;
	//FONT ALTER
	//Canvas.Font = Canvas.LargeFont;
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticLargeFont();
	else
		Canvas.Font = Canvas.LargeFont;

	Canvas.SetPos(x, y);
	if (timeleft <= 30)
		Canvas.SetColor(255,0,0);
	Canvas.DrawText(TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), true);
	Canvas.SetColor(255,255,255);
}

simulated function DrawFragCount(canvas Canvas, int x, int y)
{
	local float textwidth, textheight;
	local int score, fraglimit;
	local string text;
	local PlayerPawn PlayerOwner;

	PlayerOwner = PlayerPawn(Owner);

	// Draw Frag Icon
//	Canvas.SetPos(X-100,Y);
//	Canvas.DrawIcon(Texture'IconSkull', 1.0);	
//	Canvas.CurX -= 19;
//	Canvas.CurY += 23;

	if ( PlayerOwner.PlayerReplicationInfo == None )
		return;

	score = int(PlayerOwner.PlayerReplicationInfo.Score);
	if (RuneGameReplicationInfo(PlayerOwner.GameReplicationInfo) != None && 
		RuneGameReplicationInfo(PlayerOwner.GameReplicationInfo).FragLimit > 0)
	{
		fraglimit= RuneGameReplicationInfo(PlayerOwner.GameReplicationInfo).FragLimit;
		if (score == fraglimit-1)
			Canvas.SetColor(255,0,0);
		text = score$"/"$fraglimit$" ";
	}
	else
	{
		text = score$" ";
	}
	//FONT ALTER
	//Canvas.Font = Canvas.LargeFont;
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticLargeFont();
	else
		Canvas.Font = Canvas.LargeFont;

	Canvas.DrawTextRightJustify(text, X, Y);
	Canvas.SetColor(255,255,255);
}


simulated function DrawStrength(Canvas Canvas, int X, int Y)
{
	local Texture TexFull, TexEmpty;
	local Pawn P;
	local float scale;
	local float percent;

	P = Pawn(Owner);
	if(P == None)
		return;

	if(Owner.IsA('SarkRagnar'))
	{ // Use Sark HUD
		TexFull = Texture'SarkBloodFull';
		TexEmpty = Texture'SarkBloodEmpty';
	}
	else
	{
		TexFull = Texture'BloodFull';
		TexEmpty = Texture'BloodEmpty';
	}

	scale = BloodScale * HudScale;
	
	// Set up for drawing actual bar	
	X -= TexFull.USize * scale * 0.5;
	Y -= TexFull.VSize * scale;
	Canvas.SetPos(X,Y);

	if(HudBloodlust == 0)
	{
		Canvas.DrawIcon(TexEmpty, scale);
	}
	else if(HudBloodlust == 100) // NOTE:  This should be the max bloodlust amount
	{
		Canvas.DrawIcon(TexFull, scale);
	}
	else
	{ // Left-right fill bar
		percent = (HudBloodlust / 100); // NOTE:  MaxShield
		Canvas.DrawTile(TexFull, TexFull.USize * scale * percent, scale * TexFull.VSize,
			0, 0, TexFull.USize * percent, TexFull.VSize);
		Canvas.SetPos(X + percent * scale * TexFull.USize, Y); // Adjust for the second half
		Canvas.DrawTile(TexEmpty, TexEmpty.USize * scale - TexEmpty.USize * scale * percent, TexEmpty.VSize * scale, 
			percent * TexEmpty.USize, 0, TexEmpty.USize * (1.0 - percent), TexEmpty.VSize);
	}
}

simulated function DrawPower(Canvas Canvas, int X, int Y)
{
	local int i;
	local Texture TexFull, TexEmpty, TexIcon, TexTick;
	local Texture TexFullTop, TexEmptyTop;
	local Texture tex1, tex2;
	local float XSize, YSize;
	local Pawn P;
	local float scale;
	local int IconCount;
	local int Cell;
	local float percent;
	local float curY;
	local float PixelsPerPowerUnit;
		
	scale = HudScale; // TweakMe!

	curY = Y;
	
	P = Pawn(Owner);
	if(P == None)
		return;

	if(Owner.IsA('SarkRagnar'))
	{ // Use Sark HUD
		TexIcon = Texture'SarkRuneIcon';
		TexFull = Texture'SarkRuneFull';
		TexEmpty = Texture'SarkRuneEmpty';
		TexFullTop = Texture'SarkRuneFullTop';
		TexEmptyTop = Texture'SarkRuneEmptyTop';
		TexTick = Texture'PowerTick';
	}
	else
	{ // Normal Ragnar HUD
		TexIcon = Texture'RuneIcon';
		TexFull = Texture'RuneFull';
		TexEmpty = Texture'RuneEmpty';
		TexFullTop = Texture'RuneFullTop';
		TexEmptyTop = Texture'RuneEmptyTop';
		TexTick = Texture'PowerTick';
	}

	// Draw base icon
	curY -= TexIcon.VSize * scale;	
	Canvas.SetPos(X, curY);

	if (P.Weapon != None && P.Weapon.bCanBePoweredUp)
	{
		// Draw powerup icon
		if (P.Weapon.bPoweredUp)
			Canvas.DrawIcon(P.Weapon.PowerupIconAnim, scale);
		else
			Canvas.DrawIcon(P.Weapon.PowerupIcon, scale);
	}
	else
	{
		Canvas.DrawIcon(TexIcon, scale);
	}

	if (RunePlayer(Owner).RunePower <= 0)
		return;

	if(HudPower > P.MaxPower)
		HudPower = P.MaxPower;
		
	IconCount = (P.MaxPower - 1) / 20;
	if(IconCount > 10)
		IconCount = 10;
		
	Cell = int((HudPower - 1) / 20);
	if(Cell < 0)
		Cell = 0;
	else if(Cell > IconCount)
		Cell = IconCount;
				
	// Draw Full Icons
	curY -= TexFull.VSize * scale;
	for(i = 0; i < Cell; i++)
	{
		Canvas.SetPos(X, curY);
		Canvas.DrawIcon(TexFull, scale);
		curY -= TexFull.VSize * scale;
	}
	
	// Draw partially full icon
	if(HudPower > 0)
	{
		if(Cell == IconCount)
		{
			tex1 = TexEmptyTop;
			tex2 = TexFullTop;
		}
		else
		{
			tex1 = TexEmpty;
			tex2 = TexFull;
		}

		Canvas.SetPos(X, curY); // reset position
		percent = 1.0 - ((HudPower - 1) - Cell * 20) / 20;
	
		Canvas.DrawTile(tex1, 32 * Scale, percent * Scale * 32, 
			0, 0, 32, 32 * percent);
		Canvas.SetPos(X, curY + percent * Scale * 32); // Adjust for the second half
		Canvas.DrawTile(tex2, 32 * Scale, 32 * scale - percent * Scale * 32, 
			0, percent * 32, 32, 32 - 32 * percent);
		Canvas.SetPos(X, curY); // reset position
	}
	else
	{ // Draw an empty slot instead of the split when health is zero
		Canvas.SetPos(X, curY); // reset position
		Canvas.DrawIcon(TexEmpty, scale);
	}
	
	// Draw Empty Icons
	curY -= TexEmpty.VSize * scale;
	for(i = Cell; i < IconCount; i++)
	{
		Canvas.SetPos(X, curY);

		if(i == IconCount - 1)
			Canvas.DrawIcon(TexEmptyTop, scale);
		else
			Canvas.DrawIcon(TexEmpty, scale);
		
		curY -= TexEmpty.VSize * scale;
	}

	// Draw amount of rune power required
	if (P.Weapon != None && P.Weapon.bCanBePoweredUp)
	{
		PixelsPerPowerUnit = (TexEmpty.VSize*scale) / 20.0;
		curY = Y;
		curY -= TexIcon.VSize * scale;
		curY -= float(P.Weapon.RunePowerRequired)*PixelsPerPowerUnit;
		curY += 2.0*scale;
		curY -= TexTick.VSize/2;

		if (P.Weapon.RunePowerRequired <= P.MaxPower)	// Make sure not off the chart
		{
			if (P.RunePower >= P.Weapon.RunePowerRequired)
			{	// Use different graphic when powerupable?
			}

			Canvas.SetPos(X, curY);
			Canvas.DrawIcon(TexTick, scale);
		}
	}
}

simulated function DrawHealth(Canvas Canvas, int X, int Y)
{
	local int i;
	local Texture TexFull, TexEmpty, TexIcon;
	local Texture TexFullTop, TexEmptyTop;
	local Texture tex1, tex2;
	local float XSize, YSize;
	local Pawn P;
	local float scale;
	local int IconCount;
	local int Cell;
	local float percent;
		
	scale = HudScale * (1.5 - BloodScale); // Health scales down if bloodlust is enabled
	
	P = Pawn(Owner);
	if(P == None)
		return;

	if(Owner.IsA('SarkRagnar'))
	{ // Use Sark HUD
		TexIcon = Texture'SarkHealthIcon';
		TexFull = Texture'SarkHealthFull';
		TexEmpty = Texture'SarkHealthEmpty';
		TexFullTop = Texture'SarkHealthFullTop';
		TexEmptyTop = Texture'SarkHealthEmptyTop';
	}
	else
	{ // Normal Ragnar HUD
		TexIcon = Texture'HealthIcon';
		TexFull = Texture'HealthFull';
		TexEmpty = Texture'HealthEmpty';
		TexFullTop = Texture'HealthFullTop';
		TexEmptyTop = Texture'HealthEmptyTop';
	}
	
	// Draw base icon
	Y -= TexIcon.VSize * scale;	
	Canvas.SetPos(X, Y);
	Canvas.DrawIcon(TexIcon, scale);

	if(HudHealth > P.MaxHealth)
		HudHealth = P.MaxHealth;
		
	IconCount = (P.MaxHealth - 1) / 20;
	if(IconCount > 10)
		IconCount = 10;
		
	Cell = int((HudHealth - 1) / 20);
	if(Cell < 0)
		Cell = 0;
	else if(Cell > IconCount)
		Cell = IconCount;
				
	// Draw Full Icons
	Y -= TexFull.VSize * scale;
	for(i = 0; i < Cell; i++)
	{
		Canvas.SetPos(X, Y);
		Canvas.DrawIcon(TexFull, scale);
		Y -= TexFull.VSize * scale;
	}
	
	// Draw partially full icon
	if(HudHealth > 0)
	{
		if(Cell == IconCount)
		{
			tex1 = TexEmptyTop;
			tex2 = TexFullTop;
		}
		else
		{
			tex1 = TexEmpty;
			tex2 = TexFull;
		}

		Canvas.SetPos(X, Y); // reset position
		percent = 1.0 - ((HudHealth - 1) - Cell * 20) / 20;
	
		Canvas.DrawTile(tex1, 32 * Scale, percent * Scale * 32, 
			0, 0, 32, 32 * percent);
		Canvas.SetPos(X, Y + percent * Scale * 32); // Adjust for the second half
		Canvas.DrawTile(tex2, 32 * Scale, 32 * scale - percent * Scale * 32, 
			0, percent * 32, 32, 32 - 32 * percent);
		Canvas.SetPos(X, Y); // reset position
	}
	else
	{ // Draw an empty slot instead of the split when health is zero
		Canvas.SetPos(X, Y); // reset position
		Canvas.DrawIcon(TexEmpty, scale);
	}
	
	
	// Draw Empty Icons
	Y -= TexEmpty.VSize * scale;
	for(i = Cell; i < IconCount; i++)
	{
		Canvas.SetPos(X, Y);

		if(i == IconCount - 1)
			Canvas.DrawIcon(TexEmptyTop, scale);
		else
			Canvas.DrawIcon(TexEmpty, scale);
		
		Y -= TexEmpty.VSize * scale;
	}
}

simulated function DrawShield(canvas Canvas, int X, int Y)
{
	local Texture TexFull, TexEmpty, TexIcon;
	local float XSize, YSize;
	local Pawn P;
	local float scale;
	local float percent;

	P = Pawn(Owner);
	if(P == None)
		return;

	if(P.Shield == None)
		return;

	if(Owner.IsA('SarkRagnar'))
	{ // Use Sark HUD
		TexIcon = Texture'SarkShieldIcon';
		TexFull = Texture'SarkShieldFull';
		TexEmpty = Texture'SarkShieldEmpty';
	}
	else
	{
		TexIcon = Texture'ShieldIcon';
		TexFull = Texture'ShieldFull';
		TexEmpty = Texture'ShieldEmpty';
	}

	scale = HudScale * 0.5; // TweakMe!
	
	// Draw base icon
	Y -= TexIcon.VSize * scale;	
	Canvas.SetPos(X, Y);
	Canvas.DrawIcon(TexIcon, scale);

	// Set up for drawing actual bar	
	Y -= TexFull.VSize * scale;
	Canvas.SetPos(X,Y);

	HudShield = Clamp(HudShield, 0, 100);
	if(HudShield == 0)
	{
		Canvas.DrawIcon(TexEmpty, scale);
	}
	else if(HudShield == 100) // NOTE:  This should be the max shield amount
	{
		Canvas.DrawIcon(TexFull, scale);
	}
	else
	{
		percent = 1.0 - (HudShield / 100); // NOTE:  MaxShield
		Canvas.DrawTile(TexEmpty, TexEmpty.USize * Scale, percent * Scale * TexEmpty.VSize,
			0, 0, TexEmpty.USize, TexEmpty.VSize * percent);
		Canvas.SetPos(X, Y + percent * Scale * TexEmpty.VSize); // Adjust for the second half
		Canvas.DrawTile(TexFull, TexEmpty.USize * Scale, 
			TexEmpty.VSize * scale - percent * Scale * TexEmpty.VSize, 
			0, percent * TexEmpty.VSize, TexEmpty.USize, TexEmpty.VSize - TexEmpty.VSize * percent);
	}
}

simulated function DrawAir(canvas Canvas, int X, int Y)
{
	local Texture TexFull, TexEmpty, TexIcon;
	local float XSize, YSize;
	local Pawn P;
	local float scale;
	local float percent;

	P = Pawn(Owner);
	if(P == None)
		return;

	if(Owner.IsA('SarkRagnar'))
	{ // Use Sark HUD
		TexIcon = Texture'SarkAirIcon';
		TexFull = Texture'SarkAirFull';
		TexEmpty = Texture'SarkAirEmpty';
	}
	else
	{
		TexIcon = Texture'AirIcon';
		TexFull = Texture'AirFull';
		TexEmpty = Texture'AirEmpty';
	}

	scale = HudScale * 0.5; // TweakMe!
		
	// Draw base icon
	Y -= TexIcon.VSize * scale;	
	Canvas.SetPos(X, Y);
	Canvas.DrawIcon(TexIcon, scale);

	// Set up for drawing actual bar	
	Y -= TexFull.VSize * scale;
	Canvas.SetPos(X,Y);

	if(HudAir == 0 || P.bDrowning)
	{
		Canvas.DrawIcon(TexEmpty, scale);
	}
	else if(HudAir >= P.UnderWaterTime)
	{
		Canvas.DrawIcon(TexFull, scale);
	}
	else
	{
		percent = 1.0 - (HudAir / P.UnderWaterTime);
		Canvas.DrawTile(TexEmpty, TexEmpty.USize * Scale, percent * Scale * TexEmpty.VSize,
			0, 0, TexEmpty.USize, TexEmpty.VSize * percent);
		Canvas.SetPos(X, Y + percent * Scale * TexEmpty.VSize); // Adjust for the second half
		Canvas.DrawTile(TexFull, TexEmpty.USize * Scale, 
			TexEmpty.VSize * scale - percent * Scale * TexEmpty.VSize, 
			0, percent * TexEmpty.VSize, TexEmpty.USize, TexEmpty.VSize - TexEmpty.VSize * percent);
	}
}

simulated function DrawWeapon(canvas Canvas, int X, int Y)
{
	if (Pawn(Owner).Weapon == None)
		return;

	Canvas.SetPos(X,Y);
}

simulated function SetHudFade(canvas Canvas, float fade)
{
	local float HudAlpha;

	if (PlayerPawn(Owner)!=None)
		HudAlpha = PlayerPawn(Owner).HudTranslucency;
	else
		HudAlpha = 1.0;

	Canvas.AlphaScale = fade * HudAlpha;

	if(HudAlpha < 1.0 || fade < 1.0)
		Canvas.Style = ERenderStyle.STY_AlphaBlend;
	else
		Canvas.Style = ERenderStyle.STY_Normal;	
}

simulated function PostRender( canvas Canvas )
{
	local PlayerPawn thePlayer;
	local Texture Tex;
	local float XSize, YSize;

	thePlayer = PlayerPawn(Owner);
	if (thePlayer == None || thePlayer.RendMap == 0)
		return;

	if (HudMode==0)
	{	// Hud is off
		DrawMessages(Canvas);
		DrawRuneMessages(Canvas);

		// Draw Progress Bar
		Canvas.SetColor(255,255,255);
		if ( thePlayer.ProgressTimeOut > Level.TimeSeconds )
			DisplayProgressMessage(Canvas);
		Canvas.SetColor(255,255,255);

		// Reset the translucency of the HUD back to normal
		Canvas.Style = ERenderStyle.STY_Normal;		
		Canvas.DrawColor.R = 255;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 255;
		return;
	}

	DefaultCanvas(Canvas);
	bResChanged = (Canvas.ClipX != OldClipX);
	OldClipX = Canvas.ClipX;

	// Set the relative HUD scale to 640x480
	HudScale = Canvas.ClipX / 640;

	if (!Owner.IsA('Spectator'))
	{
		bHealth = true;

		if(thePlayer.bBloodLust)
			bBloodLust = true;
		else
			bBloodLust = false;

/*
		if(thePlayer.Weapon != None)
		{ // Combat Mode
			bPower = true;
			bBloodLust = true;
			if(thePlayer.Shield != None)
				bShield = true;
			else
				bShield = false;
		}
		else
		{ // Explore mode
			bPower = false;
			bShield = false;
		}
*/
//		if(RunePlayer(Owner).RunePower > 0)
		if(thePlayer.Weapon != None || thePlayer.RunePower > 0)
			bPower = true;

		bBloodLust = true;
		if(thePlayer.Shield != None)
			bShield = true;
		else
			bShield = false;


		if(thePlayer.Region.Zone.bWaterZone)
			bAir = true;
		else
			bAir = false;

		// Draw Health/Shield/Strength Bars
		SetHudFade(Canvas, FadeHealth);
		DrawHealth(Canvas, 4 * HudScale, Canvas.ClipY - 4 * HudScale);

		if(FadeBloodlust > 0)
		{
			SetHudFade(Canvas, FadeBloodlust);
			DrawStrength(Canvas, Canvas.ClipX * 0.5, Canvas.ClipY - 4 * HudScale);
		}
		if(FadePower > 0)	
		{
			SetHudFade(Canvas, FadePower);
			DrawPower(Canvas, Canvas.ClipX - 36 * HudScale, Canvas.ClipY - 4 * HudScale);
		}
		if(FadeShield > 0)
		{
			SetHudFade(Canvas, FadeShield);
			DrawShield(Canvas, Canvas.ClipX - 60 * HudScale, Canvas.ClipY - 4 * HudScale);
		}
		if(FadeAir > 0 && Level.Netmode==NM_Standalone)
		{
			SetHudFade(Canvas, FadeAir);
			DrawAir(Canvas, 40 * HudScale, Canvas.ClipY - 4 * HudScale);
		}
	}

	DrawMessages(Canvas);
	DrawRuneMessages(Canvas);

	// Reset the translucency of the HUD back to normal
	Canvas.Style = ERenderStyle.STY_Normal;		
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;

	// Draw scoreboard (if active)
	if ( thePlayer.bShowScores )
	{
		if ( (thePlayer.Scoring == None) && (thePlayer.ScoringType != None) )
			thePlayer.Scoring = Spawn(thePlayer.ScoringType, thePlayer);
		if ( thePlayer.Scoring != None )
		{ 
			thePlayer.Scoring.ShowScores(Canvas);
			return;
		}
	}

	DrawNetPlug(Canvas);

	// Draw Remaining Time
	if ( bTimeDown || (thePlayer.GameReplicationInfo != None && thePlayer.GameReplicationInfo.RemainingTime > 0) )
	{
		bTimeDown = true;
		DrawRemainingTime(Canvas, 0, 0);
	}

	if (!Owner.IsA('Spectator'))
	{
		// Draw Frag count
		if ( (Level.Game == None) || Level.Game.bDeathMatch ) 
		{
			DrawFragCount(Canvas, Canvas.ClipX, 0);
		}
	}

	if ( HUDMutator != None )
		HUDMutator.PostRender(Canvas);

	// Draw Menu (if active)
	if ( thePlayer.bShowMenu )
	{
		DisplayMenu(Canvas);
		return;
	}

	if ( Level.NetMode != NM_StandAlone)
		DrawTypingPlayers(Canvas);

	// Draw Progress Bar
	Canvas.SetColor(255,255,255);
	if ( thePlayer.ProgressTimeOut > Level.TimeSeconds )
		DisplayProgressMessage(Canvas);
	Canvas.SetColor(255,255,255);
}

simulated function DrawNetPlug(canvas Canvas)
{
	local PlayerPawn thePlayer;

	if (Level.NetMode == NM_StandAlone)
		return;
	
	thePlayer = PlayerPawn(Owner);
	if (thePlayer == None || !thePlayer.bBadConnectionAlert)
		return;

	Canvas.SetPos(10,10);
	Canvas.DrawIcon(Texture'NetOutage', 1.0);
}

simulated function DrawTypingPlayers(canvas Canvas)
{
	local RunePlayer P;
	local int SX,SY;
	local float scale, dist;
	local Texture Tex;
	local vector pos;

	if (TypingIcon==None || Pawn(Owner)==None)
		return;

	foreach AllActors(class'RunePlayer', P)
	{
		if (!P.bIsTyping)
			continue;
//		if (P == self)
//			continue;

		pos = P.Location+vect(0,0,1.2)*P.CollisionHeight;
		if (!FastTrace(pos, Pawn(Owner).ViewLocation))
			continue;

		Canvas.TransformPoint(pos, SX, SY);
		if (SX > 0 && SX < Canvas.ClipX &&
			SY > 0 && SY < Canvas.ClipY)
		{
			dist = VSize(P.Location-Pawn(Owner).ViewLocation);
			dist = FClamp(dist, 1, 10000);
			scale = 500.0/dist;
			scale = FClamp(scale, 0.01, 2.0);

			Canvas.SetPos(SX-(TypingIcon.USize*scale)*0.5, SY-TypingIcon.VSize*scale);
			Canvas.DrawIcon(TypingIcon, scale);
		}
	}
}


//=============================================================================
//
// STATE Idle
//
// Idle state.  For a HUD, this does nothing
//=============================================================================

state Idle
{
begin:
}

//=============================================================================
//
// STATE Cinematic
//
//=============================================================================

state Cinematic
{
	simulated function Tick(float DeltaSeconds)
	{
		CineLoc += CineSpeed * DeltaSeconds;

		if(CineSpeed > 0 && CineLoc > 1)
		{
			CineLoc = 1;
		}
		else if(CineSpeed < 0 && CineLoc < 0)
		{
			CineLoc = 0;
			GotoState('Idle');
		}

		global.Tick(DeltaSeconds);
	}

	simulated function PostRender( canvas Canvas )
	{
		local PlayerPawn thePlayer;
		local Texture Tex;
		local float XSize, YSize;
	
		thePlayer = PlayerPawn(Owner);
		if (thePlayer == None || thePlayer.RendMap == 0)
			return;
	
		DefaultCanvas(Canvas);

		Tex = Texture'RuneFX.Letterbox';
		XSize = Canvas.ClipX;
		YSize = Canvas.ClipY * 0.15;
			
		Canvas.SetPos(0, -YSize * (1.0 - CineLoc));
		Canvas.DrawTile(Tex, XSize, YSize, 0, 0, Tex.USize, Tex.VSize);
		Canvas.SetPos(0, Canvas.ClipY - YSize + YSize * (1.0 - CineLoc));
		Canvas.DrawTile(Tex, XSize, YSize, 0, 0, Tex.USize, Tex.VSize);

		DrawMessages(Canvas);
		DrawRuneMessages(Canvas);
		
		// Draw Menu (if active)
		if ( thePlayer.bShowMenu )
		{
			DisplayMenu(Canvas);
			return;
		}	

		// Draw Progress Bar
		Canvas.SetColor(255,255,255);
		if ( thePlayer.ProgressTimeOut > Level.TimeSeconds )
			DisplayProgressMessage(Canvas);
		Canvas.SetColor(255,255,255);
	}

	function BeginState()
	{
		CineLoc = 0;
		CineSpeed = 3;
	}

begin:
//	CineLoc = 0;
//	CineSpeed = 3;
	Goto('wait');

end:
	ClearMessagesOfType('Subtitle');
	ClearMessagesOfType('RedSubtitle');
	CineLoc = 1.0;
	CineSpeed = -3;

wait:
}

//=============================================================================
//
// Debug
//
//=============================================================================

simulated function Debug(Canvas canvas, int mode)
{	
	Super.Debug(canvas, mode);

	Canvas.DrawText("RuneHUD:");
	Canvas.CurY -= 8;
	Canvas.DrawText("CineLoc: " $ CineLoc);
	Canvas.CurY -= 8;
	Canvas.DrawText("CineSpeed: " $ CineSpeed);
	Canvas.CurY -= 8;
	Canvas.DrawText("HudHealth: " $ HudHealth);
}

defaultproperties
{
     TypingIcon=Texture'RuneFX2.Wordballoon'
     HudScale=1.000000
}
