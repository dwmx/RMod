//==============================================================================
//	R_ArpgDBView
//	Base class for all Arpg debug views
//==============================================================================
class R_ArpgDBView extends RDebugTools.R_DBView abstract;

const CanvasLib = Class'RBase.R_ACanvasLibrary';

function R_ArpgDBMutator GetArpgDebugMutator()
{
	local R_ArpgDBMutator LocalDBM;

	LocalDBM = R_ArpgDBMutator(GetDebugMutator());
	return LocalDBM;
}