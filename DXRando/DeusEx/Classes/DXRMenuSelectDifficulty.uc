class DXRMenuSelectDifficulty extends DXRMenuBase;

event InitWindow()
{
    Super.InitWindow();
    InitDxr();
    Init(InitDxr());
}

function CheckConfig()
{
    if( config_version < class'DXRFlags'.static.VersionNumber() ) {
        num_rows=default.num_rows;
        num_cols=default.num_cols;
        col_width_odd=default.col_width_odd;
        col_width_even=default.col_width_even;
        row_height=default.row_height;
        padding_width=default.padding_width;
        padding_height=default.padding_height;
    }
    Super.CheckConfig();
}

function BindControls(bool writing, optional string action)
{
    local float difficulty;
    local DXRFlags f;
    local string sseed;
    local DXRLoadouts loadout;
    local DXRTelemetry t;
    local DXRCrowdControl cc;
    local int temp, i;

    Super.BindControls(writing);

    f = InitFlags();

    NewMenuItem("", "Choose a game mode!");
    EnumOption("Original Story", 0, writing, f.gamemode);
    EnumOption("Entrance Randomization", 1, writing, f.gamemode);
    EnumOption("Horde Mode", 2, writing, f.gamemode);
    //EnumOption("Kill Bob Page (Alpha)", 3, writing, f.gamemode);
    //EnumOption("How About Some Soy Food?", 6, writing, f.gamemode);
    //EnumOption("Max Rando", 7, writing, f.gamemode);

    NewMenuItem("", "Which items and augs you start with and which are banned.");
    foreach f.AllActors(class'DXRLoadouts', loadout) { break; }
    if( loadout == None )
        EnumOption("All Items Allowed", 0, writing, f.loadout);
    else {
        for(i=0; i < 20; i++) {
            if( loadout.GetName(i) == "" ) continue;
            EnumOption(loadout.GetName(i), i, writing, f.loadout);
        }
    }

    NewMenuItem("Difficulty", "Difficulty determines the default settings for the randomizer.");
    if( (InStr(f.VersionString(), "Alpha")>=0 || InStr(f.VersionString(), "Beta")>=0) )
        i=0;
    else
        i=1;
    
    for( i=i; i < ArrayCount(f.difficulty_names); i++ ) {
        if( f.difficulty_names[i] == "" ) continue;
        EnumOption(f.difficulty_names[i], i, writing, f.difficulty);
    }
#ifndef hx
    // TODO: menus for HX?
    if(writing)
        difficulty = f.SetDifficulty(f.difficulty).CombatDifficulty;
#endif

    NewMenuItem("Autosave", "Saves the game in case you die!");
    EnumOption("Every Entry", 2, writing, f.autosave);
    EnumOption("First Entry", 1, writing, f.autosave);
    EnumOption("Autosaves-Only (Hardcore)", 3, writing, f.autosave);
    EnumOption("Off", 0, writing, f.autosave);

    NewMenuItem("Crowd Control", "Let your Twitch viewers troll you or help you!");
    EnumOption("Enabled (Anonymous)", 2, writing, f.crowdcontrol);
    EnumOption("Enabled (With Names)", 1, writing, f.crowdcontrol);
    EnumOption("Disabled", 0, writing, f.crowdcontrol);

    foreach f.AllActors(class'DXRTelemetry', t) { break; }
    if( t == None ) t = f.Spawn(class'DXRTelemetry');
    t.CheckConfig();
    temp = Int(t.enabled);
    NewMenuItem("Help us improve", "Send error reports and get notified about updates!");
    if( EnumOption("Enabled", 1, writing, temp) ) {
        t.set_enabled(true);
    }
    if( EnumOption("Disabled", 0, writing, temp) ) {
        t.set_enabled(false);
    }

    NewMenuItem("Seed", "Enter a seed if you want to play the same game again.");
    sseed = EditBox("", "1234567890", writing);
    if( sseed != "" ) {
        f.seed = int(sseed);
        dxr.seed = f.seed;
    } else {
        f.RollSeed();
    }

    if(writing) {
        if( action == "ADVANCED" ) NewGameSetup(difficulty);
        else _InvokeNewGameScreen(difficulty, InitDxr());
    }
}

function InvokeNewGameScreen(float difficulty)
{
    _InvokeNewGameScreen(difficulty, InitDxr());
}

function NewGameSetup(float difficulty)
{
    local DXRMenuSetupRando newGame;

    newGame = DXRMenuSetupRando(root.InvokeMenuScreen(Class'DXRMenuSetupRando'));

    if (newGame != None) {
        newGame.SetDifficulty(difficulty);
        newGame.Init(dxr);
    }
}

defaultproperties
{
    actionButtons(2)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Advanced",Key="ADVANCED")
    Title="DX Rando Options"
    ClientWidth=672
    ClientHeight=357
    bUsesHelpWindow=False
    bEscapeSavesSettings=False
    num_rows=8;
    num_cols=2;
    col_width_odd=160;
    col_width_even=220;
    row_height=20;
    padding_width=20;
    padding_height=10;
}
