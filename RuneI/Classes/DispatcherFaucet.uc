//=============================================================================
// DispatcherFaucet: Like a dispatcher, but turns off when UnTriggered
//=============================================================================
class DispatcherFaucet extends Dispatcher;


function UnTrigger(actor Other, Pawn EventInstigator)
{
	enable('Trigger');
	GotoState('');
}

defaultproperties
{
}
