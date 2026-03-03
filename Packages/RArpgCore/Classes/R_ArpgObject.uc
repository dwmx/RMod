//==============================================================================
//	R_ArpgObject
//	Base class for all ArpgObject types
//==============================================================================
class R_ArpgObject extends Object abstract;

const INVALID_INDEX = -1;

const ArpgLib = Class'RArpgCore.R_ArpgLibrary';
const TagLib = Class'RArpgCore.R_ArpgTagLibrary';

struct R_ArpgTag
{
	var Name T[4];
};

struct R_ArpgEventPayload
{
	var Name NameArg;
	var float FloatArgs[2];    // For handling OldValue / NewValue event types
	var Object OptionalObject;
};

function InitializeArpgObject();

function LogDumpArpgObject()
{
	Log("Log Dump for ArpgObject (Class:" @ Self.Class $ "), (Instance:" @ Self $ ")");
}

function ReceiveArpgEvent(Name EventName, Object Sender, R_ArpgEventPayload Payload);