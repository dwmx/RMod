//==============================================================================
//	R_ArpgRunePlayer
//	RunePlayer class for Arpg game modes
//==============================================================================
class R_ArpgRunePlayer extends R_RunePlayer;

const InWorldUIClass = Class'RArpg.R_UI_InWorldUI';
var private R_UI_GameUserInterface InWorldUI;

const SessionEndPointClass = Class'RArpg.R_ArpgSessionEndPoint';
var private R_ArpgSessionEndPoint SessionEndPoint;

replication
{
	reliable if(Role == ROLE_Authority)
		SessionEndPoint;
}

//------------------------------------------------------------------------------

event PostBeginPlay()
{
	Super.PostBeginPlay();
	InitializeSessionEndPoint();
}

function InitializeSessionEndPoint()
{
	SessionEndPoint = Spawn(SessionEndPointClass, Self);
}

exec function TestSession()
{
	SessionEndPoint.TestSession();
}

function InitializeGameUserInterface()
{
	InWorldUI = new(Self) InWorldUIClass;
	InWorldUI.Initialize(Self.Player);
}

event Tick(float DeltaSeconds)
{
	Super.Tick(DeltaSeconds);

	if(InWorldUI != None)
	{
		InWorldUI.Tick(DeltaSeconds);
	}
}

event PostRender(Canvas C)
{
	Super.PostRender(C);

	/*
	if(InWorldUI != None)
	{
		InWorldUI.PostRender(C);
	}
		*/
}