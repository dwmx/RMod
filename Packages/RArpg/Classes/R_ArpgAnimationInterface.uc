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

function CancelCurrentAnim();

function bool SetAnimParameter(Name AnimParameter, float Value);
function bool GetAnimParameter(Name AnimParameter, out float Value);
function GetAvailableAnimParameters(out Name AnimParameters[32], out int Count);