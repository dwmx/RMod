class R_MyButton extends RuneButton;

var int BuildableIndex;

simulated function Click(float X, float Y)
{
	local R_RunePlayer_TD LocalOwner;
	Super.Click(X, Y);

	LocalOwner = R_RunePlayer_TD(GetPlayerOwner());
	if(LocalOwner != None)
	{
		LocalOwner.TestBuildableIndex(BuildableIndex);
	}
	//Log("Button was clicked" @ GetPlayerOwner());
}