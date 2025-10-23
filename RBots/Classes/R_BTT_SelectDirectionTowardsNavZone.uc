//==============================================================================
//	R_BTT_SelectDirectionTowardsNavZone
//==============================================================================
class R_BTT_SelectDirectionTowardsNavZone extends R_BehaviorTask;

const ParamNavZoneIndexKey = 'NavZoneIndexKey';
const ParamDirectionKey = 'DirectionKey';

function AddParameters(R_BehaviorActionInstance Instance)
{
	Instance.AddParameter(ParamNavZoneIndexKey, TypeCodeName);
	Instance.AddParameter(ParamDirectionKey, TypeCodeName);
}

function int TickTask(R_BTI_TaskInstance TaskInstance, R_Bot Bot, R_BlackBoard BlackBoard, float ActiveTime, float DeltaSeconds)
{
	local Name NavZoneIndexKey;
	local Name DirectionKey;

	if(!TaskInstance.GetNameParameter(ParamNavZoneIndexKey, NavZoneIndexKey)
	|| !TaskInstance.GetNameParameter(ParamDirectionKey, DirectionKey))
	{
		return TaskFail;
	}

	BlackBoard.Set(NavZoneIndexKey, MakeIntVariant(Rand(5)));
	BlackBoard.Set(DirectionKey, MakeVectorVariant(VRand()));
	return TaskSuccess;
}