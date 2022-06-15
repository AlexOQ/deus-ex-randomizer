#ifdef revision
class DXRandoRootWindow extends RevRootWindow;
#else
class DXRandoRootWindow extends DeusExRootWindow;
#endif

function DeusExBaseWindow InvokeMenuScreen(Class<DeusExBaseWindow> newScreen, optional bool bNoPause)
{
    log("DXRandoRootWindow InvokeMenuScreen "$newScreen);
    switch(newScreen) {
#ifdef vmd
        case class'VMDMenuSelectAppearance':
            newScreen = class'DXRVMDMenuSelectAppearance';
            break;

        case class'VMDMenuSelectSkills':
            newScreen = class'DXRVMDMenuSelectSkills';
            break;
#else
        case class'MenuScreenNewGame':
            newScreen = class'DXRMenuScreenNewGame';
            break;
#endif
        case class'MenuSelectDifficulty':
            newScreen = class'DXRMenuSelectDifficulty';
            break;

        case class'CreditsWindow':
            newScreen = class'NewGamePlusCreditsWindow';
            break;
    }
    return Super.InvokeMenuScreen(newScreen, bNoPause);
}

function InvokeMenu(Class<DeusExBaseWindow> newMenu)
{
    log("DXRandoRootWindow InvokeMenu "$newMenu);
    switch(newMenu) {
        case class'MenuMain':
            newMenu = class'DXRMenuMain';
            break;

        // VMD
        case class'MenuSelectDifficulty':
            newMenu = class'DXRMenuSelectDifficulty';
            break;
    }
    Super.InvokeMenu(newMenu);
}

function DeusExBaseWindow InvokeUIScreen(Class<DeusExBaseWindow> newScreen, optional Bool bNoPause)
{
    log("DXRandoRootWindow InvokeUIScreen "$newScreen);
    switch(newScreen) {
        /*case class'ATMWindow':
            newScreen = class'DXRATMWindow';
            break;
        case class'NetworkTerminalATM':
            newScreen = class'DXRNetworkTerminalATM';
            break;*/

        case class'HUDMedBotAddAugsScreen':
            newScreen = class'DXRHUDMedBotAddAugsScreen';
            break;
        case class'HUDMedBotHealthScreen':
            newScreen = class'DXRHUDMedBotHealthScreen';
            break;
        case class'HUDRechargeWindow':
            newScreen = class'DXRHUDRechargeWindow';
            break;
        case class'NetworkTerminalPersonal':
            newScreen = class'DXRNetworkTerminalPersonal';
            break;
        case class'NetworkTerminalPublic':
            newScreen = class'DXRNetworkTerminalPublic';
            break;
        case class'NetworkTerminalSecurity':
            newScreen = class'DXRNetworkTerminalSecurity';
            break;
        case class'PersonaScreenSkills':
            newScreen = class'DXRPersonaScreenSkills';
            break;
        case class'PersonaScreenGoals':
            newScreen = class'DXRPersonaScreenGoals';
            break;
        default:
            if(class<NetworkTerminal>(newScreen) != None) {
                log("WARNING: InvokeUIScreen "$newScreen);
            }
            break;
    }
    return Super.InvokeUIScreen(newScreen, bNoPause);
}
