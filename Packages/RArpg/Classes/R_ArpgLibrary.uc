class R_ArpgLibrary extends Object abstract;

static function R_ArpgObject CreateArpgObject(Class<R_ArpgObject> ArpgObjectClass, optional Object Outer)
{
	local R_ArpgObject ArpgObject;

	ArpgObject = new(Outer) ArpgObjectClass;
	if(ArpgObject != None)
	{
		ArpgObject.InitializeArpgObject();
	}

	return ArpgObject;
}