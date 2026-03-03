//==============================================================================
//	R_ArpgEntity
//	An ArpgEntity is any object which implements the core concepts of
//	attributes and tags
//==============================================================================
class R_ArpgEntity extends R_ArpgObject;

var private R_ArpgEntityTagContainer TagContainer;
var private R_ArpgAttributeSet AttributeSet;

function R_ArpgEntityTagContainer GetEntityTagContainer() { return TagContainer; }
function R_ArpgAttributeSet GetEntityAttributeSet() { return AttributeSet; }

function InitializeArpgObject()
{
	TagContainer = R_ArpgEntityTagContainer(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgEntityTagContainer', Self));
	AttributeSet = R_ArpgAttributeSet(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgAttributeSet', Self));
}