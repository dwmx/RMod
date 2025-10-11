//==============================================================================
//	R_LogicLayer
//	Represents a single layer of a larger decision-making system controlled
//	by a R_BotBrain
//==============================================================================
class R_LogicLayer extends R_RBotsObject abstract;

//------------------------------------------------------------------------------
//	BlackBoard Keys
const BBKey_WantWeapon 		= 'WantWeapon';		// Float
const BBKey_WantShield		= 'WantShield';		// Float
const BBKey_WantHealth		= 'WantHealth';		// Float
const BBKey_WantStrength	= 'WantStrength';	// Float
const BBKey_WantRunePower	= 'WantRunePower';	// Float

const BBKey_InventoryTarget = 'InventoryTarget';	// Actor

//------------------------------------------------------------------------------

function Initialize();
function TickLogicLayer(
	float DeltaSeconds,
	R_Bot Bot,
	R_BlackBoardWriteInterface BlackBoardWriteInterface);