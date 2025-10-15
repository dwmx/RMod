//==============================================================================
//	R_BTNode_Composite
//	Abstract base Node class for all BT Nodes that can have children
//==============================================================================
class R_BTNode_Composite extends R_BTNode abstract;

function bool IsFull();
function AddChild(R_BTNode ChildNode);