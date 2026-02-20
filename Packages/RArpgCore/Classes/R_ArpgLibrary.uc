//==============================================================================
//	R_ArpgLibrary
//==============================================================================
class R_ArpgLibrary extends Object abstract;

/**
	CreateArpgObject
	Main function for creating ArpgObject instances

	If bDeferredInitialization = true, caller must manually call
	ArpgObject.InitializeArpgObject
*/
static function R_ArpgObject CreateArpgObject(
	Class<R_ArpgObject> ArpgObjectClass,
	optional Object Outer,
	optional bool bDeferredInitialization)
{
	local R_ArpgObject ArpgObject;

	if(ArpgObjectClass == None)
	{
		return None;
	}

	ArpgObject = new(Outer) ArpgObjectClass;
	if(ArpgObject == None)
	{
		return None;
	}

	if(!bDeferredInitialization)
	{
		ArpgObject.InitializeArpgObject();
	}

	return ArpgObject;
}