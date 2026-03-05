//==============================================================================
//	R_ArpgData_ItemInstructions
//==============================================================================
class R_ArpgData_ItemInstructions extends R_ArpgObject;

var R_ArpgTag InstructionsTag;
var String InstructionsString;

struct R_ArpgAffixInstruction
{
	var Class<R_ArpgAffix> AffixClass;
	var int ParameterMin;
	var int ParameterMax;
};
var private R_ArpgAffixInstruction AffixInstructions[32];
var private int AffixInstructionCount;

function AddAffixInstruction(Class<R_ArpgAffix> AffixClass, int ParameterMin, int ParameterMax)
{
	if(AffixInstructionCount < 0 || AffixInstructionCount >= ArrayCount(AffixInstructions))
	{
		return;
	}

	ParameterMin = Min(ParameterMin, ParameterMax);

	AffixInstructions[AffixInstructionCount].AffixClass = AffixClass;
	AffixInstructions[AffixInstructionCount].ParameterMin = ParameterMin;
	AffixInstructions[AffixInstructionCount].ParameterMax = ParameterMax;
	++AffixInstructionCount;
}

function int GetAffixInstructionCount()
{
	return AffixInstructionCount;
}

function bool RollAffix(int AffixInstructionIndex, out Class<R_ArpgAffix> OutAffixClass, out int OutParameters)
{
	if(AffixInstructionIndex < 0 || AffixInstructionIndex >= AffixInstructionCount)
	{
		return false;
	}

	OutAffixClass = AffixInstructions[AffixInstructionIndex].AffixClass;
	OutParameters = AffixInstructions[AffixInstructionIndex].ParameterMin + Rand(AffixInstructions[AffixInstructionIndex].ParameterMax);
	return true;
}