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

function InitializeArpgObject();

function LogDumpArpgObject()
{
	Log("Log Dump for ArpgObject (Class:" @ Self.Class $ "), (Instance:" @ Self $ ")");
}

function ReceiveArpgEvent(Name EventName, Object Sender, optional Object OptionalPayload);