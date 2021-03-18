//=============================================================================
// RunePolyobj.
//=============================================================================
class RunePolyobj expands Polyobj;


var(Sounds) Sound DestroySound;


function PreBeginPlay()
{
	switch (matter)
	{
		case MATTER_WOOD:
		case MATTER_BREAKABLEWOOD:
			if (OpeningSound == None)		OpeningSound =		Sound'DoorsSnd.Wood.doorwoodlayer04';
			if (OpenedSound == None)		OpenedSound =		Sound'DoorsSnd.Metal.doormetalslam02';
			if (ClosingSound == None)		ClosingSound =		Sound'DoorsSnd.Wood.doorwoodslam10';
			if (ClosedSound == None)		ClosedSound =		Sound'DoorsSnd.Wood.doorwoodlocked03';
			if (MoveAmbientSound == None)	MoveAmbientSound =	Sound'DoorsSnd.Wood.doorwoodmove02';
			break;
		case MATTER_METAL:
			if (OpeningSound == None)		OpeningSound =		Sound'DoorsSnd.Metal.doormetalslam05';
			if (OpenedSound == None)		OpenedSound =		Sound'DoorsSnd.Wood.doorwoodlayer03';
			if (ClosingSound == None)		ClosingSound =		Sound'DoorsSnd.Metal.doormetalslam04';
			if (ClosedSound == None)		ClosedSound =		Sound'DoorsSnd.Wood.doorwoodslam07';
			if (MoveAmbientSound == None)	MoveAmbientSound =	Sound'DoorsSnd.Metal.doormetalmove01';
			break;
		case MATTER_STONE:
		case MATTER_BREAKABLESTONE:
		default:
			if (OpeningSound == None)		OpeningSound =		Sound'DoorsSnd.Stone.doorstoneslam01';
			if (OpenedSound == None)		OpenedSound =		Sound'DoorsSnd.Wood.doorwoodslam10';
			if (ClosingSound == None)		ClosingSound =		Sound'DoorsSnd.Stone.doorstoneslam01';
			if (ClosedSound == None)		ClosedSound =		Sound'DoorsSnd.Wood.doorwoodslam06';
			if (MoveAmbientSound == None)	MoveAmbientSound =	Sound'DoorsSnd.Stone.doorstonemove04';
			break;
	}

	Super.PreBeginPlay();
}

function Explode(vector Momentum)
{
	local DebrisCloud c;

	// Spawn appropriate debris based on matter type
	if (DebrisType == None)
	{
		switch(matter)
		{
			case MATTER_FLESH:
				DebrisType = class'debrisflesh';
				PlaySound(Sound'WeaponsSnd.impflesh.impactflesh02', SLOT_Pain);
				break;
			case MATTER_WOOD:
				DebrisType = class'debriswood';
				PlaySound(Sound'WeaponsSnd.impcrashes.crashwood01', SLOT_Pain);
				break;
			case MATTER_ICE:
				DebrisType = class'debrisice';
				PlaySound(Sound'WeaponsSnd.impcrashes.crashglass02', SLOT_Pain);
				break;
			case MATTER_STONE:
				DebrisType = class'debrisstone';
				PlaySound(Sound'WeaponsSnd.impcrashes.crashxstone01', SLOT_Pain);
				break;
			case MATTER_EARTH:
				DebrisType = class'debrisstone';
				PlaySound(Sound'WeaponsSnd.impcrashes.crashxstone01', SLOT_Pain);
				break;
			default:
				break;
		}
	}
	if (DestroySound == None)
	{
		switch(matter)
		{
			case MATTER_FLESH:
				DestroySound=Sound'WeaponsSnd.impflesh.impactflesh02';
				break;
			case MATTER_WOOD:
				DestroySound=Sound'WeaponsSnd.impcrashes.crashwood01';
				break;
			case MATTER_ICE:
				DestroySound=Sound'WeaponsSnd.impcrashes.crashglass02';
				break;
			case MATTER_STONE:
				DestroySound=Sound'WeaponsSnd.impcrashes.crashxstone01';
				break;
			case MATTER_EARTH:
				DestroySound=Sound'WeaponsSnd.impcrashes.crashxstone01';
				break;
		}
	}

	PlaySound(DestroySound, SLOT_Pain);

	// Spawn cloud
	if (DebrisSpawnRadius == 0)
		DebrisSpawnRadius = GetCollisionRadius();
	c = Spawn(class'DebrisCloud');
	c.SetRadius(DebrisSpawnRadius);

	// Allow Polyobj to spawn
	Super.Explode(Momentum);
}

defaultproperties
{
}
