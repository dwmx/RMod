//==============================================================================
//	R_RBotsDebug_View_Player
//	Debug View for player information relevant to RBots
//==============================================================================
class R_RBotsDebug_View_Player extends R_RBotsDebug_View;

const LogCategory = 'DebugViewPlayer';

const DebugCategory_Player = 'Player';
const DebugCategory_AnimInfo = 'PlayerAnimInfo';

const DebugFloatStringDecimalPlaces = 2;

var private R_AnimData AnimData;

// Draw switches
var private config bool bDrawAnimInfo;

function ToggleDrawAnimationInfo()
{
	bDrawAnimInfo = !bDrawAnimInfo;
	SaveConfig();
}

function DrawDebugView(Canvas C, R_DBStringManager StringManager)
{
	local PlayerPawn PPOwner;

	if(AnimData == None)
	{
		AnimData = new(None) Class'RBots.R_AnimData';
	}

	StringManager.AddCategory(DebugCategory_Player);

	// View from whoever is playing
	PPOwner = GetPlayerPawnOwner();
	if(PPOwner == None)
	{
		StringManager.AddWarning(DebugCategory_Player, "Invalid PlayerPawn owner");
		return;
	}
	StringManager.AddActor(DebugCategory_Player, "PlayerPawn", PPOwner);

	if(bDrawAnimInfo)
	{
		DrawPlayerAnimInfo(C, StringManager, PPOwner);
	}
}

function DrawPlayerAnimInfo(Canvas C, R_DBStringManager StringManager, PlayerPawn PPOwner)
{
	local AnimationProxy AP;
	local float AnimDurationSeconds;

	StringManager.AddCategory(DebugCategory_AnimInfo);

	if(PPOwner != None)
	{
		AP = PPOwner.AnimProxy;
	}

	if(PPOwner == None)		StringManager.AddWarning(DebugCategory_AnimInfo, "Invalid PlayerPawn owner");
	if(AP == None)			StringManager.AddWarning(DebugCategory_AnimInfo, "Invalid AnimProxy");
	if(AnimData == None)	StringManager.AddWarning(DebugCategory_AnimInfo, "Invalid AnimData");

	if(PPOwner == None)
	{	// Have to have PlayerPawn reference
		return;
	}

	StringManager.AddName(DebugCategory_AnimInfo, "AnimProxy AnimSequence", AP.AnimSequence);
	StringManager.AddFloat(DebugCategory_AnimInfo, "AnimProxy AnimFrame", AP.AnimFrame, DebugFloatStringDecimalPlaces);
	StringManager.AddFloat(DebugCategory_AnimInfo, "AnimProxy AnimLast", AP.AnimLast, DebugFloatStringDecimalPlaces);
	StringManager.AddFloat(DebugCategory_AnimInfo, "AnimProxy AnimRate", AP.AnimRate, DebugFloatStringDecimalPlaces);

	AnimDurationSeconds = -1.0;
	if(AnimData != None)
	{
		AnimDurationSeconds = AnimData.GetAnimDuration(AP.AnimSequence);
	}
	StringManager.AddFloat(DebugCategory_AnimInfo, "AnimProxy AnimDuration Seconds", AnimDurationSeconds);
}

defaultproperties
{
	bDrawAnimInfo=true
}