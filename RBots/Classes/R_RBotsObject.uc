//==============================================================================
//	R_RBotsObject
//	Base class for most objects in RBots, other than those extending Actor
//==============================================================================
class R_RBotsObject extends Object abstract;

const Utilities = Class'RBots.R_BotUtilities';
const LogCategory = 'RBots';

var private R_RBotsServerActor RBots;

var bool bLogCreation;

const InvalidIndex = -1;

struct R_EventPayload
{
	var Object HostObject;
	var Name HostTag;
};

final function SetRBotsServerActor(R_RBotsServerActor NewRBots) { RBots = NewRBots; }
final function R_RBotsServerActor GetRBotsServerActor() { return RBots; }

final function BaseCreated()
{
	if(bLogCreation)
	{
		Utilities.Static.RLog("Created" @ String(Self.Class) @ "with Outer" @ Outer, LogCategory);
	}
	Created();
}

//------------------------------------------------------------------------------

function Created();
function Initialize();
function ReceiveEvent(Name EventName, bool bContainsPaylod, out R_EventPayload InPayload);

defaultproperties
{
	bLogCreation=false
}