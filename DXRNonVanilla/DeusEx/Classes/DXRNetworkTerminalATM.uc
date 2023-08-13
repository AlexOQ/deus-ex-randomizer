#ifdef hx
class DXRNetworkTerminalATM extends HXNetworkTerminalATM;
#else
class DXRNetworkTerminalATM extends #var(prefix)ATMWindow;
#endif

var ComputerScreenKnownAccounts winKnownAccounts;
var ShadowWindow                winKnownShadow;

function ConfigurationChanged()
{
    local float hackAccountsWidth, hackAccountsHeight;
    local float hackWidth, hackHeight;

    Super.ConfigurationChanged();

    if (winHack != None)
    {
        winHack.QueryPreferredSize(hackWidth, hackHeight);
    }

    if (winKnownAccounts != None)
    {
        winKnownAccounts.QueryPreferredSize(hackAccountsWidth, hackAccountsHeight);
        winKnownAccounts.ConfigureChild(
            width - hackAccountsWidth, hackHeight + 20,
            hackAccountsWidth, hackAccountsHeight);

        // Place shadow
        winKnownShadow.ConfigureChild(
            width - hackAccountsWidth + winKnownAccounts.backgroundPosX - shadowOffsetX,
            hackHeight + 20 + winKnownAccounts.backgroundPosY - shadowOffsetY,
            winKnownAccounts.backgroundWidth + (shadowOffsetX * 2),
            winKnownAccounts.backgroundHeight + (shadowOffsetY * 2));
    }

}

function CreateKnownAccountsWindow()
{
    local int codes_mode;
    codes_mode = int(player.ConsoleCommand("get #var(package).MenuChoice_PasswordAutofill codes_mode"));
    if( codes_mode < 1 ) return;

    winKnownShadow = ShadowWindow(NewChild(Class'ShadowWindow'));

    winKnownAccounts = ComputerScreenKnownAccounts(NewChild(Class'ComputerScreenKnownAccounts'));
    if( codes_mode == 2 )
        winKnownAccounts.bShowPasswords = true;
    winKnownAccounts.SetNetworkTerminal(Self);
    winKnownAccounts.SetCompOwner(compOwner);
    winKnownAccounts.AskParentForReconfigure();
}

function CloseKnownAccountsWindow()
{
    if (winKnownAccounts != None)
    {
        winKnownAccounts.Destroy();
        winKnownAccounts = None;

        winKnownShadow.Destroy();
        winKnownShadow = None;
    }
}

function LogInAs(String user, String pass)
{
    local #var(prefix)ComputerScreenATM atm;

    if (winComputer.IsA('#var(prefix)ComputerScreenATM'))
    {
        atm = #var(prefix)ComputerScreenAtm(winComputer);
        atm.editAccount.SetText(user);
        atm.editPIN.SetText(pass);
        if(pass != "")
            atm.ProcessLogin();
        else
            atm.SetFocusWindow(atm.editPIN);
    }

    userName = user;
}


function ShowScreen(Class<#var(prefix)ComputerUIWindow> newScreen)
{
    newScreen = class'DXRNetworkTerminal'.static.ShowScreen(newScreen);

    Super.ShowScreen(newScreen);
}

event InitWindow()
{
    Super.InitWindow();
#ifndef hx
    class'DXRNetworkTerminal'.static.InitWindow(self);
#endif
}
