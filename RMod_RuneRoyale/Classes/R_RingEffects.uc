class R_RingEffects extends Actor;

simulated event PostBeginPlay()
{
    local Class<Object> ClassObject;
    local SheetBuilder SB;

    ClassObject = class<Object>(DynamicLoadObject("Editor.SheetBuilder", class'Class'));

    SB = new Class'Engine.SheetBuilder';

    SB.Height = 100.0;
    SB.Width = 100.0;
    SB.Axis = AX_XAxis;
    SB.Build();
}

simulated event Tick(float DeltaSeconds)
{
}

defaultproperties
{
    DrawType=DT_Brush
}