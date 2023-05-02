//=============================================================================
// MenuScreenRandoOptions
//=============================================================================

class MenuScreenRandoOptions expands MenuUIScreenWindow;

event InitWindow()
{
    local int i;

    choices[i++]=Class'MenuChoice_Telemetry';
    choices[i++]=Class'MenuChoice_ShowNews';

    if(#defined(vanilla)) {
        choices[i++]=Class'MenuChoice_EnergyDisplay';
        choices[i++]=Class'MenuChoice_ShowKeys';
    }
    if(!#defined(revision)) {
        choices[i++]=Class'MenuChoice_ContinuousMusic';
        choices[i++]=Class'MenuChoice_RandomMusic';
        choices[i++]=Class'MenuChoice_ChangeSong';
    }
    choices[i++]=Class'MenuChoice_PasswordAutofill';
    choices[i++]=Class'MenuChoice_BrightnessBoost';
    choices[i++]=Class'MenuChoice_ConfirmNoteDelete';

    choices[i++]=Class'MenuChoice_JoinDiscord';
    choices[i++]=Class'MenuChoice_ReleasePage';  //This should probably always be the bottom option

    //Automatic sizing to the number of entries...
    ClientHeight = (i+1) * 36;
    helpPosY = ClientHeight - 36;

	Super.InitWindow();
}

// ----------------------------------------------------------------------
// SaveSettings()
// ----------------------------------------------------------------------

function SaveSettings()
{
	Super.SaveSettings();
	player.SaveConfig();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     actionButtons(0)=(Align=HALIGN_Right,Action=AB_Cancel)
     actionButtons(1)=(Align=HALIGN_Right,Action=AB_OK)
     actionButtons(2)=(Action=AB_Reset)
     Title="Randomizer Options"
     ClientWidth=500
     ClientHeight=50
     helpPosY=10
     choiceStartY=12
}
