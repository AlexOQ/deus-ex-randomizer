class VMDR175MenuSelectDifficulty extends DXRMenuSelectDifficulty;

function _InvokeNewGameScreen(float difficulty, DXRando dxr)
{
    local DXRMenuScreenNewGame newGame;
#ifdef vmd
    local VMDMenuSelectCustomDifficulty VMDNewGame;
    local VMDBufferPlayer VMP;

    dxr.flags.SaveFlags();
    // I think we really just need to run DXRSkills here
    dxr.RandoEnter();
    VMDNewGame = VMDMenuSelectCustomDifficulty(root.InvokeMenuScreen(Class'VMDMenuSelectCustomDifficulty'));

    //MADDERS: Call relevant reset data.
    VMP = VMDBufferPlayer(Player);
    if (VMP != None)
    {
        VMP.VMDResetNewGameVars(1);
    }

    Player.CombatDifficulty = Difficulty;
#endif
}

function NewGameSetup(float difficulty)
{
    local DXRMenuSetupRando newGame;

    newGame = DXRMenuSetupRando(root.InvokeMenuScreen(Class'VMDR175MenuSetupRando'));

    if (newGame != None) {
        newGame.SetDifficulty(difficulty);
        newGame.Init(dxr);
    }
}
