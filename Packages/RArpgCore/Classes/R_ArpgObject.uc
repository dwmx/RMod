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
	var float FloatArgs[4];
	var Object ObjectArgs[2];
	var R_ArpgTag TagArg;
};

function InitializeArpgObject();

function LogDumpArpgObject()
{
	Log("Log Dump for ArpgObject (Class:" @ Self.Class $ "), (Instance:" @ Self $ ")");
}

function ReceiveArpgEvent(Name EventName, Object Sender, R_ArpgEventPayload Payload);
function ReceiveArpgEvent_TagPayload(Name EventName, Object Sender, R_ArpgTag Payload);