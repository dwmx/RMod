//=============================================================================
// OrdersDispatcher: receives one trigger (corresponding to its name) as input, 
// then triggers a set of specifid events with optional delays.
//=============================================================================
class OrdersDispatcher extends Dispatcher;


struct OrderPair
{
	var() name PawnTag;
	var() name ScriptTag;
};

var(Dispatcher) OrderPair OutOrders[8];
var int maxnum;

//
// Dispatch events.
//
state Dispatch
{
	function BeginState()
	{
		maxnum = Max(ArrayCount(OutEvents), ArrayCount(OutOrders));
	}

	function FireEvents()
	{
		if( OutEvents[i] != '' )
		{
			foreach AllActors( class 'Actor', Target, OutEvents[i] )
				Target.Trigger( Self, Instigator );
		}
	}

	function FireOrders()
	{
		local ScriptPawn P;

		if( OutOrders[i].PawnTag != '' && OutOrders[i].ScriptTag != '' )
		{
			foreach AllActors( class 'ScriptPawn', P, OutOrders[i].PawnTag )
			{
				P.FollowOrders('Scripting', OutOrders[i].ScriptTag);
			}
		}
	}

Begin:
	disable('Trigger');
	for( i=0; i<maxnum; i++ )
	{
		Sleep( OutDelays[i] );

		FireEvents();
		FireOrders();
	}

	if(bIsLooping)
	{
		goto('Begin');
	}

	enable('Trigger');
}

defaultproperties
{
}
