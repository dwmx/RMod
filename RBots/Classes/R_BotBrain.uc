//==============================================================================
//	R_BotBrain
//
//	Brain is the core decision-making component of a Bot
//
//	This Class's job is to take information from all other components of a Bot,
//	make decisions with that information, and write the results of those
//	decisions back to the Bot's BlackBoard
//
//	This is the only class, other than the Bot itself, that is allowed to
//	write to the BlackBoard
//==============================================================================
class R_BotBrain extends R_BotObject;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'BotBrain';

// Logic Layers
var private R_LogicLayer LogicLayers[32];
var private int NumLogicLayers;

// BlackBoard Write Interface -- Gets passed to all LogicLayers
var private R_BlackBoardWriteInterface BlackBoardWriteInterface;

//------------------------------------------------------------------------------

function SetBlackBoardWriteInterface(R_BlackBoardWriteInterface NewBlackBoardWriteInterface)
{
	BlackBoardWriteInterface = NewBlackBoardWriteInterface;
}

//------------------------------------------------------------------------------

function R_LogicLayer CreateLogicLayer(Class<R_LogicLayer> LogicLayerClass)
{
	local String LogWarning;
	local R_LogicLayer LogicLayer;

	if(NumLogicLayers >= ArrayCount(LogicLayers))
	{
		LogWarning = "CreateLogicLayer failed -- Array overflow";
		Warn(LogWarning);
		Utilities.Static.RLog(LogWarning, LogCategory);
		return None;
	}

	LogicLayer = new(None) LogicLayerClass;
	if(LogicLayer == None)
	{
		LogWarning = "CreateLogicLayer failed -- Failed to create from class" @ LogicLayerClass;
		Warn(LogWarning);
		Utilities.Static.RLog(LogWarning, LogCategory);
		return None;
	}

	LogicLayers[NumLogicLayers] = LogicLayer;
	++NumLogicLayers;

	LogicLayer.Initialize();
}

//------------------------------------------------------------------------------

function TickBotObject(float DeltaSeconds)
{
	TickLogicLayers(DeltaSeconds);
}

function TickLogicLayers(float DeltaSeconds)
{
	local R_Bot LocalBot;
	local R_BlackBoardWriteInterface LocalBlackBoardWriteInterface;
	local int i;

	LocalBot = GetBot();
	LocalBlackBoardWriteInterface = BlackBoardWriteInterface;

	if(LocalBot != None && LocalBlackBoardWriteInterface != None)
	{
		for(i = 0; i < NumLogicLayers; ++i)
		{
			if(LogicLayers[i] != None)
			{
				LogicLayers[i].TickLogicLayer(
					DeltaSeconds,
					LocalBot,
					LocalBlackBoardWriteInterface);
			}
		}
	}
}