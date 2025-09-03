//==============================================================================
//	R_BotPerception
//	Bot sub-object which perceives other Actors in the level
//==============================================================================
class R_BotPerception extends R_BotObject;

const LogCategory = 'BotPerception';

var private Actor PerceivedActor;

function SetPerceivedActor(Actor NewPerceivedActor)
{
	PerceivedActor = NewPerceivedActor;
}

function Actor GetPerceivedActor()
{
	return PerceivedActor;
}

function TickBotObject(float DeltaSeconds)
{
	local PlayerPawn PP, PPIterator;

	PP = GetPlayerPawn();
	if(PP == None)
	{
		PerceivedActor = None;
		return;
	}

	foreach PP.AllActors(Class'Engine.PlayerPawn', PPIterator)
	{
		if(PPIterator == PP)
		{
			continue;
		}
		else
		{
			SetPerceivedActor(PPIterator);
			break;
		}
	}
}