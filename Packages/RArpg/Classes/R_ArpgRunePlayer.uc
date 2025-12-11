class R_ArpgRunePlayer extends R_RunePlayer;

const InWorldUIClass = Class'RArpg.R_UI_InWorldUI';
var private R_UI_UserInterface InWorldUI;

// Overridden to initialize custom UI
// This has to be done here because Player is not valid in any of the BeginPlay functions,
// and the UI needs reference to Player's Console
event Possess()
{
	Super.Possess();

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

	if(InWorldUI != None)
	{
		InWorldUI.PostRender(C);
	}
}