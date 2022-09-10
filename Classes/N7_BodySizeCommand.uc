class N7_BodySizeCommand extends N7_SizeCommand;

/** @Override */
protected function DoActionForSingleTarget
    (N7_CommandExecutionState ExecState, PlayerController PC)
{
    local float NewBodyScale;

    NewBodyScale = N7_CommandPreservedState(ExecState).LoadNumberF();
    GSU.ResizePlayer(PC, NewBodyScale);
    AddResizedPlayer(PC, NewBodyScale);
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;
    local float NewBodyScale;

    TargetName = LoadTarget(ExecState);
    NewBodyScale = N7_CommandPreservedState(ExecState).LoadNumberF();

    return "Your body size scale is set to "$NewBodyScale;
}

/** @Override */
protected function string GetSenderSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;
    local float NewBodyScale;

    TargetName = LoadTarget(ExecState);
    NewBodyScale = N7_CommandPreservedState(ExecState).LoadNumberF();

    if (TargetName ~= "all")
    {
        return "All players' body size scale is set to "$NewBodyScale;
    } 
    else if (TargetName ~= ExecState.GetSender().PlayerReplicationInfo.PlayerName)
    {
        return "Your body size scale is set to "$NewBodyScale;
    } 

    return TargetName$"'s body size scale is set to "$NewBodyScale;
}

defaultproperties
{
    bAdminOnly=true
    Aliases(0)="BODY"
    Aliases(1)="BODYSIZE"
    Signature="<? float BodyScale, ? (string TargetName | 'all')>"
    Description="Set Player's body size scale"
    bNotifySenderOnSuccess=true
}