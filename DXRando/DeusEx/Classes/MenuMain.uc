class DXRMenuMain injects MenuMain;

var float countdown;
var int nameLen, firstSpace, secondSpace;

#ifdef injections
function UpdateButtonStatus()
{
    Super.UpdateButtonStatus();
    if( ! class'DXRAutosave'.static.AllowManualSaves(player) ) winButtons[1].SetSensitivity(False);
}
#endif

function SetTitle(String newTitle)
{
    bTickEnabled = true;
#ifdef gmdx
    title = "GMDX RANDOMIZER " $ class'DXRVersion'.static.VersionString();
    nameLen = 14;
    firstSpace = 4;
    secondSpace = 999;
#elseif revision
    title = "REVISION RANDOMIZER " $ class'DXRVersion'.static.VersionString();
    nameLen = 18;
    firstSpace = 8;
    secondSpace = 999;
#elseif vmd
    title = "VMD RANDOMIZER " $ class'DXRVersion'.static.VersionString();
    nameLen = 13;
    firstSpace = 3;
    secondSpace = 999;
#else
    title = "DEUS EX RANDOMIZER " $ class'DXRVersion'.static.VersionString();
    nameLen = 16;
    firstSpace = 4;
    secondSpace = 7;
#endif
    winTitle.SetTitle( title );
    countdown = 0.5;
}

function Tick(float DeltaTime)
{
    local int i;
    local string l, r, letter;

    countdown -= DeltaTime;
    if( countdown > 0 ) return;

    countdown = Float(Rand(500)) / 2000.0 + 0.1;

    i = Rand(nameLen);
    if(i >= firstSpace) i++;//skip the space after DEUS
    if(i >= secondSpace) i++;//skip the space after EX

    l = Left(title, i);
    r = Mid(title, i+1);
    letter = Chr( Rand(26) + 65 );

    title = l $ letter $ r;

    winTitle.SetTitle( title );
}

function InitTraining()
{
    local DXRFlags f;

    foreach player.AllActors(class'DXRFlags', f) {
        f.DisableRandomization();
        f.SaveFlags();
    }
}

function ConfirmTraining()
{
    local DeusExLevelInfo info;

    info = player.GetLevelInfo();

    // If the game is running, first *PROMPT* the user, becauase
    // otherwise the current game will be lost

    if (((info != None) && (info.MissionNumber >= 0)) &&
       !((player.IsInState('Dying')) || (player.IsInState('Paralyzed'))))
    {
    }
    else
    {
        InitTraining();
    }

    Super.ConfirmTraining();
}


event bool BoxOptionSelected(Window button, int buttonNumber)
{
    local bool ret;

    switch(messageBoxMode)
    {
        case MB_AskToTrain:
            if (buttonNumber == 0)
                InitTraining();
            break;

        case MB_Training:
            if (buttonNumber == 0)
                InitTraining();
            break;
    }

    ret = Super.BoxOptionSelected(button, buttonNumber);
    return ret;
}
