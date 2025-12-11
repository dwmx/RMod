class R_ArpgRunePlayer extends R_RunePlayer;

const InWorldUIClass = Class'RArpg.R_UI_InWorldUI';
var private R_UI_GameUserInterface InWorldUI;

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

	if(InWorldUI != None)
	{
		InWorldUI.PostRender(C);
	}
}