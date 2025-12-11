//==============================================================================
//	R_NavMeshActorTracker_Implementation
//	Underlying implementation for NavMeshActorTracker
//==============================================================================
class R_NavMeshActorTracker_Implementation extends R_NavMeshActorTracker;

var private R_NavMesh NavMesh;
var private Actor TrackedActors[128];

struct R_ActorGroup
{
	var Actor ActorArray[32];
};
// The size of this array should match however many PolyGroups your NavMesh implements
var private R_ActorGroup PolyGroupActorGroups[32];

function SetNavMesh(R_NavMesh NewNavMesh)
{
	NavMesh = NewNavMesh;
}

function TrackActor(Actor NewActor)
{
	local int i;

	for(i = 0; i < ArrayCount(TrackedActors); ++i)
	{
		if(TrackedActors[i] == None || TrackedActors[i].bDeleteMe)
		{
			TrackedActors[i] = NewActor;
			return;
		}
	}
}

function Update()
{
	local int PolyGroupIndex;
	local int i, j;

	// Clear out all actor groups
	for(i = 0; i < ArrayCount(PolyGroupActorGroups); ++i)
	{
		for(j = 0; j < ArrayCount(PolyGroupActorGroups[i].ActorArray); ++j)
		{
			PolyGroupActorGroups[i].ActorArray[j] = None;
		}
	}

	if(NavMesh != None)
	{
		// Re-add all actors to actor groups
		for(i = 0; i < ArrayCount(TrackedActors); ++i)
		{
			if(TrackedActors[i] != None)
			{
				if(TrackedActors[i].bDeleteMe)
				{
					TrackedActors[i] = None;
				}
				else
				{
					PolyGroupIndex = NavMesh.FindContainingPolyGroupIndex(TrackedActors[i].Location);
					InsertActorToPolyGroup(PolyGroupIndex, TrackedActors[i]);
				}
			}
		}
	}
}

function InsertActorToPolyGroup(int PolyGroupIndex, Actor A)
{
	local int i;

	if(PolyGroupIndex >= 0 && PolyGroupIndex < ArrayCount(PolyGroupActorGroups))
	{
		for(i = 0; i < ArrayCount(PolyGroupActorGroups[PolyGroupIndex].ActorArray); ++i)
		{
			if(PolyGroupActorGroups[PolyGroupIndex].ActorArray[i] == None)
			{
				PolyGroupActorGroups[PolyGroupIndex].ActorArray[i] = A;
				return;
			}
		}
	}
}

function GetActorsByPolyGroupIndex(int PolyGroupIndex, out Actor OutActors[32], out int OutNumActors)
{
	local Actor A;
	local int i;

	if(PolyGroupIndex >=0 && PolyGroupIndex < ArrayCount(PolyGroupActorGroups))
	{
		OutNumActors = 0;
		for(i = 0; i < ArrayCount(PolyGroupActorGroups[PolyGroupIndex].ActorArray); ++i)
		{
			A = PolyGroupActorGroups[PolyGroupIndex].ActorArray[i];
			if(A != None)
			{
				OutActors[OutNumActors] = A;
				++OutNumActors;
			}
		}
	}
}