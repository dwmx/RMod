class R_RunePlayerHUD_Valball extends R_RunePlayerHUD;

simulated function DrawBallHUD(Canvas C, R_Ball Ball, String StringText)
{
    local int ScreenX, ScreenY;

    C.TransformPoint(Ball.Location, ScreenX, ScreenY);
    C.SetPos(ScreenX, ScreenY);
    C.DrawText(StringText);
}

simulated event PostRender(Canvas C)
{
    local R_Ball Ball;
    local Name BallStateName;
    local String StringText;

    Super.PostRender(C);

    foreach AllActors(Class'RMod_Valball.R_Ball', Ball)
    {
        BallStateName = Ball.GetCurrentBallStateName();
        if(BallStateName == 'PreSpawn')
        {
            StringText = "Ball spawning...";
        }
        else if(BallStateName == 'Active')
        {
            StringText = "Ball here";
        }
        DrawBallHUD(C, Ball, StringText);
    }
}