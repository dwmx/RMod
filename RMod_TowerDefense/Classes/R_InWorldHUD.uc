//==============================================================================
//	R_InWorldHUD
//
//	HUD for R_Runeplayer which draws world-space HUD elements like player
//	names above their heads, floating health bars, etc
//==============================================================================
class R_InWorldHUD extends Object;

var R_RunePlayer OwningPlayer;

struct FInWorldMessage
{
	var float TimeStampSeconds;
	var String MessageString;
	var Color DrawColor;
	var Vector Location;
};
var FInWorldMessage InWorldMessages[64];
const MaxInWorldMessages = 64;
var float InWorldMessageLifeTimeSeconds;

function ReceiveInWorldMessage(String MessageString, Vector Location, Color DrawColor)
{
	local int i;
	local int OldestMessageIndex;
	local float OldestDeltaSeconds, DeltaSeconds;
	local float CurrentTimeSeconds;

	if(OwningPlayer == None)
	{
		return;
	}

	CurrentTimeSeconds = OwningPlayer.Level.TimeSeconds;

	// Either fill the first expired message slot, or replace the oldest message
	for(i = 0; i < MaxInWorldMessages; ++i)
	{
		DeltaSeconds = CurrentTimeSeconds - InWorldMessages[i].TimeStampSeconds;
		if(DeltaSeconds > InWorldMessageLifeTimeSeconds)
		{
			InWorldMessages[i].TimeStampSeconds = CurrentTimeSeconds;
			InWorldMessages[i].MessageString = MessageString;
			InWorldMessages[i].DrawColor = DrawColor;
			InWorldMessages[i].Location = Location;
			return;
		}
		else
		{
			if(DeltaSeconds > OldestDeltaSeconds)
			{
				OldestMessageIndex = i;
				OldestDeltaSeconds = DeltaSeconds;
			}
		}
	}

	// Push out the oldest message
	InWorldMessages[OldestMessageIndex].TimeStampSeconds = CurrentTimeSeconds;
	InWorldMessages[OldestMessageIndex].MessageString = MessageString;
	InWorldMessages[OldestMessageIndex].DrawColor = DrawColor;
	InWorldMessages[OldestMessageIndex].Location = Location;
}

function DrawInWorldMessages(Canvas C)
{
	local int i;
	local float CurrentTimeSeconds;
	local float DeltaSeconds;
	local float InterpAlpha;
	local Vector DrawLocation;
	local int ScreenX, ScreenY;

	if(OwningPlayer == None)
	{
		return;
	}

	//C.Font = C.CredsFont;
//	C.Font = Font'Engine.RuneMed';
	C.Font = Font(DynamicLoadObject("UWindowFonts.TahomaB20", class'Font'));

	CurrentTimeSeconds = OwningPlayer.Level.TimeSeconds;
	for(i = 0; i < MaxInWorldMessages; ++i)
	{
		DeltaSeconds = CurrentTimeSeconds - InWorldMessages[i].TimeStampSeconds;
		if(DeltaSeconds > InWorldMessageLifeTimeSeconds)
		{
			continue;
		}

		InterpAlpha = FClamp(DeltaSeconds / InWorldMessageLifeTimeSeconds, 0.0, 1.0);
		DrawLocation = InWorldMessages[i].Location;
		DrawLocation.Z += InterpAlpha * 32.0;
		C.DrawColor = InWorldMessages[i].DrawColor;

		C.Transformpoint(DrawLocation, ScreenX, ScreenY);
		C.SetPos(ScreenX, ScreenY);
		C.DrawText(InWorldMessages[i].MessageString);
	}
}

function InitializeInWorldHUD(R_RunePlayer NewOwningPlayer)
{
	OwningPlayer = NewOwningPlayer;
}

/**
*	InWorldHUDPostRender
*	Main draw function for the InWorldHUD
*	Should be called by owning player's PostRender event
*/
function InWorldHUDPostRender(Canvas C)
{
	local R_Mob MobIterator;

	// Draw messages
	DrawInWorldMessages(C);

	foreach OwningPlayer.AllActors(Class'R_Mob', MobIterator)
	{
		MobIterator.DrawInWorldHUD(C);
	}
}

defaultproperties
{
	InWorldMessageLifeTimeSeconds=2.0
}