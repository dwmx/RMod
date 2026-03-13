//==============================================================================
//	R_ArpgAnimationInterface
//==============================================================================
class R_ArpgAnimationInterface extends R_ArpgObject abstract;

function bool TryPlayStandardAnim(
	Name StandardName,
	optional Name SlotName,
	optional float Rate,
	optional float Tween,
	optional R_ArpgObject CallbackObject);

function bool TryPlayAnim(
	Name AnimName,
	optional Name SlotName,
	optional float Rate,
	optional float Tween,
	optional R_ArpgObject CallbackObject);

function SetAnimParameter(Name AnimParameter, float Value);