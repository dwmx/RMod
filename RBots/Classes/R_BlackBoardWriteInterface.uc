//==============================================================================
//	R_BlackBoardWriteInterface
//	The public interface for writing to a BlackBoard
//==============================================================================
class R_BlackBoardWriteInterface extends R_BotObject;

var private R_BlackBoard BlackBoard;

function SetBlackBoard(R_BlackBoard NewBlackBoard)
{
	BlackBoard = NewBlackBoard;
}

function bool SetInt(Name Key, int Value)
{
	if(BlackBoard != None)
	{
		return BlackBoard.SetInt(Key, Value);
	}
	return false;
}

function bool SetFloat(Name Key, float Value)
{
	if(BlackBoard != None)
	{
		return BlackBoard.SetFloat(Key, Value);
	}
	return false;
}

function bool SetVector(Name Key, Vector Value)
{
	if(BlackBoard != None)
	{
		return BlackBoard.SetVector(Key, Value);
	}
	return false;
}

function bool SetActor(Name Key, Actor Value)
{
	if(BlackBoard != None)
	{
		return BlackBoard.SetActor(Key, Value);
	}
	return false;
}