class R_RBotsDebug_Behavior_Wander extends R_BotBehavior;

function BehaviorActivated()
{}

function BehaviorTick(float DeltaSeconds)
{
	local R_NavQueryInterface NavQueryInterface;
	local R_BotPawnController Controller;
	local Vector Location;
	local int NavZoneIndex;
	local Vector MovementDirection, MovementInput;

	Controller = GetBotPawnController();
	NavQueryInterface = GetNavQueryInterface();
	if(Controller != None && NavQueryInterface != None)
	{
		Location = GetPlayerPawnLocation();
		NavZoneIndex = NavQueryInterface.GetNavZoneIndexByName('BattleAxe');

		if(NavQueryInterface.FindDirectionTowardsNavZoneByIndex(
			Location,
			NavZoneIndex,
			MovementDirection))
		{
			MovementInput = Normal(Vect(1,1,0) * MovementDirection);
			Controller.AddMovementInput_WorldSpace(MovementInput);
		}
	}
}