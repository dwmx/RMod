//==============================================================================
//	R_ArpgEntity
//	An ArpgEntity is any object which implements the core concepts of
//	attributes and tags
//==============================================================================
class R_ArpgEntity extends R_ArpgObject;

var private R_ArpgEntityTagContainer TagContainer;
var private R_ArpgEntityAttributeSet AttributeSet;

function R_ArpgEntityTagContainer GetEntityTagContainer() { return TagContainer; }
function R_ArpgEntityAttributeSet GetEntityAttributeSet() { return AttributeSet; }

function InitializeArpgObject()
{
	TagContainer = R_ArpgEntityTagContainer(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgEntityTagContainer', Self));
	AttributeSet = R_ArpgEntityAttributeSet(ArpgLib.Static.CreateArpgObject(Class'RArpg.R_ArpgEntityAttributeSet', Self));

	AttributeSet.AddAttribute('MaxHealth');
	AttributeSet.AddAttribute('Health');
	AttributeSet.AddAttribute('MaxMana');
	AttributeSet.AddAttribute('Mana');
}