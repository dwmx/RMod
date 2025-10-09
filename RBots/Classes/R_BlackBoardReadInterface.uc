//==============================================================================
//	R_BlackBoardReadInterface
//	The public interface for reading a BlackBoard
//==============================================================================
class R_BlackBoardReadInterface extends R_BotObject;

var private R_BlackBoard BlackBoard;

function SetBlackBoard(R_BlackBoard NewBlackBoard)
{
	BlackBoard = NewBlackBoard;
}

function bool GetInt(Name Key, out int OutValue)
{
	if(BlackBoard != None)
	{
		return BlackBoard.GetInt(Key, OutValue);
	}
	return false;
}

function bool GetFloat(Name Key, out float OutValue)
{
	if(BlackBoard != None)
	{
		return BlackBoard.GetFloat(Key, OutValue);
	}
	return false;
}

function bool GetVector(Name Key, out Vector OutValue)
{
	if(BlackBoard != None)
	{
		return BlackBoard.GetVector(Key, OutValue);
	}
	return false;
}

function bool GetActor(Name Key, out Actor OutValue)
{
	if(BlackBoard != None)
	{
		return BlackBoard.GetActor(Key, OutValue);
	}
	return false;
}

function int GetNumKeys()
{
	if(BlackBoard != None)
	{
		return BlackBoard.GetNumKeys();
	}
	return 0;
}

function bool GetKeyTypeAtIndex(int Index, out Name OutKey, out int OutBlackBoardTypeCode)
{
	if(BlackBoard != None)
	{
		return BlackBoard.GetKeyTypeAtIndex(Index, OutKey, OutBlackBoardTypeCode);
	}
	return false;
}

defaultproperties
{
	bTickBotObject=false	
}