class R_ARPGSession extends Actor;

var float TimeAccumulator;

struct SnapshotData
{
	var int d0, d1;
};

replication
{
	reliable if(RemoteRole==ROLE_AutonomousProxy)
		ClientReceiveSnapshot,
		ClientReceiveSnapshotData;

	reliable if(Role==ROLE_AutonomousProxy)
		ServerRequestSnapshot,
		ServerReceiveAck;
}

function RequestSnapshot()
{
	Log("Sending RequestSnapshot");
	ServerRequestSnapshot();
}

function ServerRequestSnapshot()
{
	Log("Received snapshot request, telling client to get ready for snapshot");
	SendSnapshot();
}

function SendSnapshot()
{
	Log("Sending Snapshot");
	ClientReceiveSnapshot();
}

function ClientReceiveSnapshot()
{
	Log("Received Snapshot");
	SendAck();
}

function SendAck()
{
	Log("Sending Ack");
	ServerReceiveAck();
}

function ServerReceiveAck()
{
	Log("Received Ack");
	SendSnapshotData();
}

function SendSnapshotData()
{
	local int i;
	local SnapshotData Payload;

	for(i = 0; i < 10; ++i)
	{
		Payload.d0 = i;
		Payload.d1 = i * 5;
		ClientReceiveSnapshotData(Payload);
	}

	Log("Finished sending snapshot data");
}

function ClientReceiveSnapshotData(SnapshotData Payload)
{
	Log("Received Snapshot data:" @ Payload.d0 @ Payload.d1);
}

event BeginPlay()
{
	local Pawn P;
	
	for(P = Level.PawnList; P != None; P = P.NextPawn)
	{
		if(PlayerPawn(P) != None)
		{
			SetOwner(P);
		}
	}

	Log(Self @ "in the house with owner:" @ Owner);
}

event Tick(float DeltaSeconds)
{
	if(Role == ROLE_AutonomousProxy)
	{
		TimeAccumulator += DeltaSeconds;
		if(TimeAccumulator > 30.0)
		{
			TimeAccumulator = 0.0;
			RequestSnapshot();
		}
	}

	//if(Role == ROLE_Authority)
	//{
	//	TimeAccumulator += DeltaSeconds;
	//	if(TimeAccumulator > 5.0)
	//	{
	//		TimeAccumulator = 0.0;
	//		SendSnapshot();
	//	}
	//}
	
}

defaultproperties
{
	RemoteRole=ROLE_AutonomousProxy
	DrawType=DT_None
}