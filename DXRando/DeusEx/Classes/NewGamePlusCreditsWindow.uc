class NewGamePlusCreditsWindow injects CreditsWindow;

event DestroyWindow()
{
    local DXRFlags f;
    // Check to see if we need to load the intro
    if (bLoadIntro)
    {
        foreach player.AllActors(class'DXRFlags', f) {
            f.NewGamePlus();
            bLoadIntro=false;
        }
    }

    Super.DestroyWindow();
}



function AddDXRCreditsGeneral() 
{
    PrintHeader("Deus Ex Randomizer");
    PrintText("Version"@class'DXRFlags'.static.VersionString());
    PrintLn();    
    PrintHeader("Contributors");
    PrintText("Die4Ever");
    PrintText("TheAstropath");
    
    PrintLn();    
    PrintHeader("Home Page");
    PrintText("https://github.com/Die4Ever/deus-ex-randomizer");
    
    PrintLn();    
    PrintHeader("Discord Community");
    PrintText("https://discord.gg/daQVyAp2ds");
    
    PrintLn();    
    PrintLn();    
}

function AddDXRandoCredits()
{
    local DXRBase mod;
    
    AddDXRCreditsGeneral();
    
    foreach player.AllActors(class'DXRBase', mod) {
        mod.AddDXRCredits(Self);
    }
    
    PrintLn();    
    PrintHeader("Original Developers");
    PrintLn();    

}

function ProcessText()
{
	PrintPicture(CreditsBannerTextures, 2, 1, 505, 75);
	PrintLn();
    AddDXRandoCredits();
	Super(CreditsScrollWindow).ProcessText();
}
