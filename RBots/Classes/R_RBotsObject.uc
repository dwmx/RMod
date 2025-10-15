//==============================================================================
//	R_RBotsObject
//	Base class for most objects in RBots, other than those extending Actor
//==============================================================================
class R_RBotsObject extends Object abstract;

const InvalidIndex = -1;

struct R_EventPayload
{
	var Object HostObject;
	var Name HostTag;
};

function ReceiveEvent(Name EventName, bool bContainsPaylod, out R_EventPayload InPayload);