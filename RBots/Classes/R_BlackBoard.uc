//==============================================================================
//	R_BlackBoard
//	Contains AI context state shared over multiple behaviors
//==============================================================================
class R_BlackBoard extends R_BotObject;

var private Inventory InventoryTarget;	// The Inventory this Bot wants

function SetInventoryTarget(Inventory NewInventoryTarget) { InventoryTarget = NewInventoryTarget; }
function Inventory GetInventoryTarget() { return InventoryTarget; }

defaultproperties
{
	bTickBotObject=false
}