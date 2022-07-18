class R_RunePlayerHUD extends RuneHUD;

var class<R_AColors> ColorsClass;

// Extended localized message struct for player name coloring
struct FHUDLocalizedMessageExtended
{
    var Class<LocalMessage> Message;
    var int Switch;
    var PlayerReplicationInfo RelatedPRI;
    var Object OptionalObject;
    var float EndOfLife;
    var float LifeTime;
    var bool bDrawing;
    var int numLines;
    var string StringMessage;
    var color DrawColor;
    var font StringFont;
    var float XL, YL;
    var float YPos;

	// Extension
	var String PlayerName;
};
var FHUDLocalizedMessageExtended MessageQueueExtended[4];

// For drawing players through walls
struct FSavedActorDrawData
{
    var Vector          DesiredColorAdjust;
    var Vector          ColorAdjust;
    var bool            bUnlit;
    var bool            bHidden;
    var float           AlphaScale;
    var ERenderStyle    Style;
    var float           DrawScale;
    var byte            Fatness;
    var byte            DesiredFatness;
    var Texture         SkelGroupSkins[16];
};

//==============================================================================
//  CheckActorObscured
//  Returns true if Actor A is visually obscured.
simulated function bool CheckActorObscured(Actor A)
{
    local Vector TraceStart;
    local Vector TraceEnd;

    TraceStart  = Pawn(Owner).ViewLocation;
    TraceEnd    = A.Location;

    if(FastTrace(TraceEnd, TraceStart))
    {
        return false;
    }    
    return true;
}

//==============================================================================
//  GetActorTransformedDrawPointAndScale
//
//  Get the point directly above a pawn's head, used for drawing things like
//  team indicator and chat bubble.
simulated function GetActorTransformedDrawPointAndScale(
    Canvas C, Actor A,
    out float PosX,
    out float PosY,
    out float Scale)
{
    local Vector    WorldLocation;
    local float     ViewDistance;
    local int       CPosX, CPosY;

    WorldLocation = A.Location;
    WorldLocation.Z += A.CollisionHeight;
    WorldLocation.Z += 16.0;

    C.TransformPoint(WorldLocation, CPosX, CPosY);
    PosX = float(CPosX);
    PosY = float(CPosY);

    ViewDistance = VSize(WorldLocation - Pawn(Owner).ViewLocation);
    Scale = 256.0 / ViewDistance;
    Scale = FClamp(Scale, 0.3, 1.0);
}

//==============================================================================
simulated function private SaveActorDrawData(
    Actor A, out FSavedActorDrawData DrawData)
{
    local int i;
    DrawData.DesiredColorAdjust    = A.DesiredColorAdjust;
    DrawData.ColorAdjust           = A.ColorAdjust;
    DrawData.bUnlit                = A.bUnlit;
    DrawData.bHidden               = A.bHidden;
    DrawData.AlphaScale            = A.AlphaScale;
    DrawData.Style                 = A.Style;
    DrawData.DrawScale             = A.DrawScale;
    DrawData.DesiredFatness        = A.DesiredFatness;
    DrawData.Fatness               = A.Fatness;
    for(i = 0; i < 16; ++i)
    {
        DrawData.SkelGroupSkins[i] = A.SkelGroupSkins[i];
    }
}

simulated function private RestoreActorDrawData(
    Actor A, out FSavedActorDrawData DrawData)
{
    local int i;
    A.DesiredColorAdjust    = DrawData.DesiredColorAdjust;
    A.ColorAdjust           = DrawData.ColorAdjust;
    A.bUnlit                = DrawData.bUnlit;
    A.bHidden               = DrawData.bHidden;
    A.AlphaScale            = DrawData.AlphaScale;
    A.Style                 = DrawData.Style;
    A.DrawScale             = DrawData.DrawScale;
    A.DesiredFatness        = DrawData.DesiredFatness;
    A.Fatness               = DrawData.Fatness;
    for(i = 0; i < 16; ++i)
    {
        A.SkelGroupSkins[i] = DrawData.SkelGroupSkins[i];
    }
}

//==============================================================================
//  DrawActorSilhouette
//  Draw a colored silhouette in place of the Actor.
simulated function DrawActorSilhouette(
    Canvas C, Actor A, Color DrawColor, bool bClearZ, optional byte Fatness)
{
    local Vector                VectorColor;
    local Actor                 ActorArray[3];
    local FSavedActorDrawData   ActorArraySaved[3];
    local int                   ActorCount;
    local int                   i, j;

    if(Fatness == 0)
    {
        Fatness = A.Fatness;
    }

    VectorColor.X = DrawColor.R;
    VectorColor.Y = DrawColor.G;
    VectorColor.Z = DrawColor.B;

    ActorCount = 0;
    ActorArray[ActorCount++] = A;
    if(Pawn(A) != None)
    {
        if(Pawn(A).Weapon != None)
        {
            ActorArray[ActorCount++] = Pawn(A).Weapon;
        }
        if(Pawn(A).Shield != None)
        {
            ActorArray[ActorCount++] = Pawn(A).Shield;
        }
    }

    // Saved Actor properties and apply silhouette properties
    // TODO: Perform this for stowed but visible inventories as well
    for(i = 0; i < ActorCount; ++i)
    {
        SaveActorDrawData(ActorArray[i], ActorArraySaved[i]);
        //for(j = 0; j < 16; ++j)
        //{
        //    ActorArray[i].SkelGroupSkins[j] = Texture'RMenu.icons.stonemenub';
        //}
        
        ActorArray[i].DesiredColorAdjust    = VectorColor;
        ActorArray[i].ColorAdjust           = VectorColor;
        ActorArray[i].bUnlit                = true;
        ActorArray[i].bHidden               = false;
        ActorArray[i].AlphaScale            = 1.0;
        ActorArray[i].Style                 = STY_AlphaBlend;
        ActorArray[i].DesiredFatness        = Fatness;
        ActorArray[i].Fatness               = Fatness;
    }

    // Draw only the recieved Actor. If Actor is a Pawn, its Weapon and Shield 
    // will also be drawn.
    C.DrawActor(A, false, bClearZ);

    // Restore Actor properties
    for(i = 0; i < ActorCount; ++i)
    {
        RestoreActorDrawData(ActorArray[i], ActorArraySaved[i]);
    }
}

function ClearMessageExtended(out FHUDLocalizedMessageExtended M)
{
    M.Message = None;
    M.Switch = 0;
    M.RelatedPRI = None;
    M.OptionalObject = None;
    M.EndOfLife = 0;
    M.StringMessage = "";
    M.DrawColor = WhiteColor;
    M.XL = 0;
    M.bDrawing = false;

	// Extension
	M.PlayerName = "";
}

function CopyMessageExtended(out FHUDLocalizedMessageExtended M1, FHUDLocalizedMessageExtended M2)
{
    M1.Message = M2.Message;
    M1.Switch = M2.Switch;
    M1.RelatedPRI = M2.RelatedPRI;
    M1.OptionalObject = M2.OptionalObject;
    M1.EndOfLife = M2.EndOfLife;
    M1.StringMessage = M2.StringMessage;
    M1.DrawColor = M2.DrawColor;
    M1.XL = M2.XL;
    M1.YL = M2.YL;
    M1.YPos = M2.YPos;
    M1.bDrawing = M2.bDrawing;
    M1.LifeTime = M2.LifeTime;
    M1.numLines = M2.numLines;

	// Extension
	M1.PlayerName = M2.PlayerName;
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
    {   // If unique, stomp any identical existing message
        for (i=0; i<QueueSize; i++)
        {
            if (MessageQueueExtended[i].Message != None)
            {
                if (MessageQueueExtended[i].Message == Message)
                {
                    MessageQueueExtended[i].Message = Message;
                    MessageQueueExtended[i].Switch = Switch;
                    MessageQueueExtended[i].RelatedPRI = RelatedPRI_1;
                    MessageQueueExtended[i].OptionalObject = OptionalObject;
                    MessageQueueExtended[i].LifeTime = Message.Static.GetLifeTime(CriticalString);
                    MessageQueueExtended[i].EndOfLife = MessageQueueExtended[i].LifeTime + Level.TimeSeconds;
                    MessageQueueExtended[i].StringMessage = CriticalString;
                    MessageQueueExtended[i].DrawColor = Message.Static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);
                    MessageQueueExtended[i].XL = 0;

					if(MessageQueueExtended[i].RelatedPRI != None)
					{
						MessageQueueExtended[i].PlayerName = MessageQueueExtended[i].RelatedPRI.PlayerName;
					}

                    return;
                }
            }
        }
    }
    for (i=0; i<QueueSize; i++)
    {
        if (MessageQueueExtended[i].Message == None)
        {
            MessageQueueExtended[i].Message = Message;
            MessageQueueExtended[i].Switch = Switch;
            MessageQueueExtended[i].RelatedPRI = RelatedPRI_1;
            MessageQueueExtended[i].OptionalObject = OptionalObject;
            MessageQueueExtended[i].LifeTime = Message.Static.GetLifeTime(CriticalString);
            MessageQueueExtended[i].EndOfLife = MessageQueueExtended[i].LifeTime + Level.TimeSeconds;
            MessageQueueExtended[i].StringMessage = CriticalString;
            MessageQueueExtended[i].DrawColor = Message.Static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);
            MessageQueueExtended[i].XL = 0;

			if(MessageQueueExtended[i].RelatedPRI != None)
			{
				MessageQueueExtended[i].PlayerName = MessageQueueExtended[i].RelatedPRI.PlayerName;
			}

            return;
        }
    }

    // No empty slots.  Force a message out.
    for (i=0; i<QueueSize-1; i++)
        CopyMessageExtended(MessageQueueExtended[i],MessageQueueExtended[i+1]);

    MessageQueueExtended[QueueSize-1].Message = Message;
    MessageQueueExtended[QueueSize-1].Switch = Switch;
    MessageQueueExtended[QueueSize-1].RelatedPRI = RelatedPRI_1;
    MessageQueueExtended[QueueSize-1].OptionalObject = OptionalObject;
    MessageQueueExtended[QueueSize-1].LifeTime = Message.Static.GetLifeTime(CriticalString);
    MessageQueueExtended[QueueSize-1].EndOfLife = MessageQueueExtended[QueueSize-1].LifeTime + Level.TimeSeconds;
    MessageQueueExtended[QueueSize-1].StringMessage = CriticalString;
    MessageQueueExtended[QueueSize-1].DrawColor = Message.Static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);              
    MessageQueueExtended[QueueSize-1].XL = 0;

	if(MessageQueueExtended[i].RelatedPRI != None)
	{
		MessageQueueExtended[i].PlayerName = MessageQueueExtended[i].RelatedPRI.PlayerName;
	}
}

// Draw messages in the RuneMessageQueue
simulated function DrawMessages(canvas Canvas)
{
	local int i,j,k;
	local float XL, YL, YPos, FadeValue;
	local string Message;
	local float SavedX, SavedY;
	local float DimX, DimY;

	for (i=0; i<QueueSize; i++)
	{
		if ( MessageQueueExtended[i].Message != None )
		{
			if (MessageQueueExtended[i].Message.Default.bFadeMessage && Level.bHighDetailMode)
			{
				FadeValue = (MessageQueueExtended[i].EndOfLife - Level.TimeSeconds);
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

			if (MessageQueueExtended[i].Message.Default.bCenter)
				Canvas.bCenter = true;
			Canvas.StrLen("TEST", XL, YL);
			if ( bResChanged || MessageQueueExtended[i].XL == 0 )
			{	// Determine dimensions of text
				if ( MessageQueueExtended[i].Message.Default.bComplexString )
					Canvas.StrLen(MessageQueueExtended[i].Message.Static.AssembleString( 
											self,
											MessageQueueExtended[i].Switch,
											MessageQueueExtended[i].RelatedPRI,
											MessageQueueExtended[i].StringMessage), 
								   MessageQueueExtended[i].XL, MessageQueueExtended[i].YL);
				else
				{
					if(MessageQueueExtended[i].Message == class'RMod.R_Message_Say')
					{
						Canvas.StrLen(
							MessageQueueExtended[i].PlayerName $ ":" @ MessageQueueExtended[i].StringMessage,
							MessageQueueExtended[i].XL, MessageQueueExtended[i].YL);
					}
					else
					{
						Canvas.StrLen(MessageQueueExtended[i].StringMessage, MessageQueueExtended[i].XL, MessageQueueExtended[i].YL);
					}
				}
				MessageQueueExtended[i].numLines = Max(1, MessageQueueExtended[i].YL / YL);
			}

			//// Set the position
			//MessageQueueExtended[i].YPos = MessageQueueExtended[i].Message.Static.GetOffset(MessageQueueExtended[i].Switch, MessageQueueExtended[i].YL, Canvas.ClipY);
			//if (MessageQueueExtended[i].YPos == 0)
			//{
			//	Canvas.SetPos(0, 2 + YL * YPos);
			//	YPos += MessageQueueExtended[i].numLines;
			//}
			//else
			//{
			//	Canvas.SetPos(0, MessageQueueExtended[i].YPos);
			//}

			// Draw the text
			if(MessageQueueExtended[i].Message == class'RMod.R_Message_Say')
			{
				Canvas.bCenter = false;

				// Set the position
				MessageQueueExtended[i].YPos = MessageQueueExtended[i].Message.Static.GetOffset(MessageQueueExtended[i].Switch, MessageQueueExtended[i].YL, Canvas.ClipY);
				if (MessageQueueExtended[i].YPos == 0)
				{
					Canvas.SetPos(0, 2 + YL * YPos);
					YPos += MessageQueueExtended[i].numLines;
				}
				else
				{
					Canvas.SetPos(0, MessageQueueExtended[i].YPos);
				}
				
				// Draw Player name
				if (MessageQueueExtended[i].Message.Default.bFadeMessage && Level.bHighDetailMode)
				{
					Canvas.Style = ERenderStyle.STY_Translucent;
					Canvas.DrawColor = MessageQueueExtended[i].DrawColor * (FadeValue/MessageQueueExtended[i].LifeTime);
				}
				else
				{
					Canvas.DrawColor = MessageQueueExtended[i].Message.Default.DrawColor;
				}
				Canvas.StrLen(MessageQueueExtended[i].PlayerName $ ": ", XL, YL);
				//SavedX = -MessageQueueExtended[i].XL * 0.5;
				//SavedX = -MessageQueueExtended[i].XL * 0.5;
				SavedX = Canvas.ClipX * 0.5 - MessageQueueExtended[i].XL * 0.5;
				SavedY = Canvas.CurY;
				Canvas.SetPos(SavedX, SavedY);
				Canvas.DrawText(MessageQueueExtended[i].PlayerName $ ": ", False);
				
				// Draw player message
				if (MessageQueueExtended[i].Message.Default.bFadeMessage && Level.bHighDetailMode)
				{
					Canvas.Style = ERenderStyle.STY_Translucent;
					Canvas.DrawColor = ColorsClass.Static.ColorWhite() * (FadeValue/MessageQueueExtended[i].LifeTime);
				}
				else
				{
					Canvas.DrawColor = ColorsClass.Static.ColorWhite();
				}
				//Canvas.StrLen(MessageQueueExtended[i].StringMessage, XL, YL);
				//SavedX = MessageQueueExtended[i].XL * 0.5;
				SavedX += XL;
				Canvas.SetPos(SavedX, SavedY);
				Canvas.DrawText(MessageQueueExtended[i].StringMessage, False);
			}
			else
			{
				// Set the position
				MessageQueueExtended[i].YPos = MessageQueueExtended[i].Message.Static.GetOffset(MessageQueueExtended[i].Switch, MessageQueueExtended[i].YL, Canvas.ClipY);
				if (MessageQueueExtended[i].YPos == 0)
				{
					Canvas.SetPos(0, 2 + YL * YPos);
					YPos += MessageQueueExtended[i].numLines;
				}
				else
				{
					Canvas.SetPos(0, MessageQueueExtended[i].YPos);
				}
				
				// Draw the message
				if ( MessageQueueExtended[i].Message.Default.bComplexString )
				{
					// Use this for string messages with multiple colors.
					MessageQueueExtended[i].Message.Static.RenderComplexMessage( 
						Canvas,
						MessageQueueExtended[i].XL,  YL,
						MessageQueueExtended[i].StringMessage,
						MessageQueueExtended[i].Switch,
						MessageQueueExtended[i].RelatedPRI,
						None,
						MessageQueueExtended[i].OptionalObject
						);
				} 
				else
				{
					if (MessageQueueExtended[i].Message.Default.bFadeMessage && Level.bHighDetailMode)
					{
						Canvas.Style = ERenderStyle.STY_Translucent;
						Canvas.DrawColor = MessageQueueExtended[i].DrawColor * (FadeValue/MessageQueueExtended[i].LifeTime);
					}
					else
					{
						Canvas.DrawColor = MessageQueueExtended[i].Message.Default.DrawColor;
					}
					
					Canvas.DrawText(MessageQueueExtended[i].StringMessage, False);
//					Canvas.DrawText(YPos@MessageQueueExtended[i].StringMessage @ "NL="$MessageQueueExtended[i].numLines @ "YL="$YL, False);
				}
			}

			// Cleanup
			Canvas.bCenter = false;
			Canvas.Style = ERenderStyle.STY_Normal;
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
			//MessageClass=class'SayMessage';
			MessageClass=class'RMod.R_Message_Say';
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

// Overridden to avoid drawing chat bubble for players in spectator state
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
		if(P.PlayerReplicationInfo == None
		|| P.PlayerReplicationInfo.bIsSpectator
		|| !P.bIsTyping)
		{
			continue;
		}

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

simulated function Pawn GetPawnContext()
{
	if(Owner != None
	&& Owner.GetStateName() == 'PlayerSpectating'
	&& R_RunePlayer(Owner) != None
	&& R_RunePlayer(Owner).Camera != None
	&& R_RunePlayer(Owner).Camera.ViewTarget != None)
	{
		return R_RunePlayer(Owner).Camera.ViewTarget;
	}
	else
	{
		return Pawn(Owner);
	}
}

simulated function Tick(float DeltaSeconds)
{
	local float delta;
	local Pawn P;
	local int i;

	Super(HUD).Tick(DeltaSeconds);
	P = GetPawnContext();
	
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

simulated function PostRender( canvas Canvas )
{
	local PlayerPawn thePlayer;
	local Texture Tex;
	local float XSize, YSize;
	local String DrawString;

	thePlayer = PlayerPawn(Owner);
	//thePlayer = GetPawnContext();
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

	if (!Owner.IsA('Spectator')
		&& !(R_RunePlayer(Owner) != None
		&& Owner.GetStateName() == 'PlayerSpectating'
		&& R_RunePlayer(Owner).Camera != None
		&& R_RunePlayer(Owner).Camera.ViewTarget == None))
	{
		thePlayer = PlayerPawn(GetPawnContext());
		if(thePlayer != None)
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
	}

	DrawMessages(Canvas);
	DrawRuneMessages(Canvas);

	// Reset the translucency of the HUD back to normal
	Canvas.Style = ERenderStyle.STY_Normal;		
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;

	// Draw scoreboard (if active)
	thePlayer = PlayerPawn(Owner);
	if ( thePlayer.bShowScores )
	{
		if ( (thePlayer.Scoring == None) && (thePlayer.ScoringType != None) )
			thePlayer.Scoring = Spawn(thePlayer.ScoringType, thePlayer);
		if ( thePlayer.Scoring != None )
		{ 
			thePlayer.Scoring.ShowScores(Canvas);
			//return;
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

simulated function DrawFragCount(canvas Canvas, int x, int y)
{
	local float textwidth, textheight;
	local int score, fraglimit;
	local string text;
	local PlayerPawn PlayerOwner;

	//PlayerOwner = PlayerPawn(Owner);
	PlayerOwner = PlayerPawn(GetPawnContext());
	if(PlayerOwner == None)
	{
		return;
	}

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
	
	//P = Pawn(Owner);
	P = GetPawnContext();
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
	
	//P = Pawn(Owner);
	P = GetPawnContext();
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

	//P = Pawn(Owner);
	P = GetPawnContext();
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

	//P = Pawn(Owner);
	P = GetPawnContext();
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

defaultproperties
{
     ColorsClass=Class'RMod.R_AColors'
}
