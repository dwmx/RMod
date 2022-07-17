class R_RunePlayerHUD_Valball extends R_RunePlayerHUD;

//native(465) final function DrawText( coerce string Text, optional bool CR );
//native(492) final function TransformPoint( vector P1, out int X, out int Y );
//final function SetPos( float X, float Y )

simulated function DrawBallHUD(Canvas C, R_Ball Ball)
{
    local int ScreenX, ScreenY;

    C.TransformPoint(Ball.Location, ScreenX, ScreenY);
    C.SetPos(ScreenX, ScreenY);
    C.DrawText("BALL HERE");
}

simulated event PostRender(Canvas C)
{
    local R_Ball Ball;

    Super.PostRender(C);

    foreach AllActors(Class'RMod_Valball.R_Ball', Ball)
    {
        DrawBallHUD(C, Ball);
    }
}