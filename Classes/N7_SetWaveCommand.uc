class N7_SetWaveCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_WAVE,
};

var protected const int MinWave;
var protected int MaxWave;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local KFGameReplicationInfo KFGRI;
    local Controller C;
    local bool bTradeTime;
    local int WaveNum;

    KFGRI = KFGameReplicationInfo(Level.Game.GameReplicationInfo);

    GSU.KillAllZeds(true);
    GSU.StopZedTime();

    /** Restarting when the entire squad is wiped out */
    if (KFGT.bGameEnded && KFGRI.EndGameType == 1)
    {
        KFGT.Reset();
        KFGT.VotingHandler.SetTimer(0, false);
        KFGT.bGameRestarted = false;

        KFGRI.Reset();
        KFGRI.EndGameType = 0;

        KFGT.StartMatch();
        GSU.DoWaveEnd();
    }
    /** 
     * When default patriarch gets killed all players' controllers set
     * BehindView and ViewTargets which breaks aiming 
     */
    else if (KFGT.WaveNum == KFGT.FinalWave)
    {
        for (C = Level.ControllerList; C != None; C = C.NextController)
        {
            if (PlayerController(C) != None)
            {
                PlayerController(C).bBehindView = false;
                PlayerController(C).ClientSetBehindView(false);
                PlayerController(C).SetViewTarget(C.Pawn);
                PlayerController(C).ClientSetViewTarget(C.Pawn);
            }
        }
    }

    /** 
     * Pre-first wave time is not considered Trade Time by default
     * But wave management is handled in the same manner 
     */
    bTradeTime = KFGT.bTradingDoorsOpen || (KFGT.WaveNum == 0 && KFGT.WaveCountDown > 0);
    WaveNum = ToInt(ExecState.GetArg(ECmdArgs.ARG_WAVE));

    /**
     * KFGT.WaveNum is actual Wave, starting from 0 
     * KFGRI.WaveNumber is the wave number displayed in HUD, byte value that gets incremented in the default HUD
     * Under different conditions different wave setting setup is required
     */
    if (bTradeTime && KFGT.WaveCountDown >= 5)
    {
        KFGT.WaveNum = WaveNum - 1;
        KFGRI.WaveNumber = Max(KFGT.WaveNum - 1, 0);
    }
    else if (bTradeTime && KFGT.WaveCountDown < 5)
    {
        KFGT.WaveNum = WaveNum - 1;
        KFGRI.WaveNumber = KFGT.WaveNum;
    }
    else
    {
        KFGT.WaveNum = WaveNum - 2;
        KFGRI.WaveNumber = Max(KFGT.WaveNum, 0);
    }
    ExecState.SaveNumber(WaveNum);
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress') 
        || KFGT.bGameEnded && KFGameReplicationInfo(Level.Game.GameReplicationInfo).EndGameType == 1;
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local int WaveNum;
    MaxWave = KFGT.FinalWave;
    WaveNum = ToInt(ExecState.GetArg(ECmdArgs.ARG_WAVE));

    return IsInRange(WaveNum, MinWave, MaxWave);
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string StyledWaveNum;
    StyledWaveNum = ColorizeValue(ExecState.LoadNumber());

    return "Wave set to "$StyledWaveNum$" by "$ColorizeSender(ExecState);
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Wave can be changed only during the game";
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "Wave number must be in range from "$MinWave$" to "$MaxWave;
}

defaultproperties
{
    MinWave=1
    MaxWave=11
    MinArgsNum=1
    MaxArgsNum=1
    Aliases(0)="WN"
    Aliases(1)="FW"
    Aliases(2)="WAVE"
    Aliases(3)="WAVENUM"
    Aliases(4)="SETWAVE"
    Aliases(5)="WAVENUM"
    ArgTypes(0)="number"
    Signature="<int WaveNum>"
    Description="Set Wave number"
}
