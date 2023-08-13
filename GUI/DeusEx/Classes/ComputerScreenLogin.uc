class DXRComputerScreenLogin injects ComputerScreenLogin;

function CloseScreen(String action)
{
    local int compIndex;

    if (action=="LOGIN")
    {
#ifdef injections
        //Mark the account as known
        Computers(compOwner).SetAccountKnownByName(editUserName.GetText());
#else
        if (DXRComputerPersonal(compOwner)!=None){
            DXRComputerPersonal(compOwner).SetAccountKnownByName(editUserName.GetText());
        }
#endif
    }

#ifdef injections
    winTerm.CloseKnownAccountsWindow();
#else
    if(DXRNetworkTerminalPersonal(winTerm)!=None){
        DXRNetworkTerminalPersonal(winTerm).CloseKnownAccountsWindow();
    }
#endif

	Super.CloseScreen(action);
}

function SetNetworkTerminal(NetworkTerminal newTerm)
{
	Super.SetNetworkTerminal(newTerm);

#ifdef injections
    winTerm.CreateKnownAccountsWindow();
#else
    if(DXRNetworkTerminalPersonal(winTerm)!=None){
        DXRNetworkTerminalPersonal(winTerm).CreateKnownAccountsWindow();
    }
#endif
}
