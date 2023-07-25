class DXRPiano injects #var(prefix)WHPiano;

var int SongPlayed[38];
var DXRando dxr;

var #var(PlayerPawn) player;
var string message;
var int soundHandle, currentSong;

function bool ValidSong(int i)
{
    if (i==1 || i==2 || i==6 || i==25){
        return False;
    }

    return True;
}

function Timer()
{
    if (dxr==None){
        foreach AllActors(class'DXRando', dxr) {break;}
    }

    if (SongPlayed[currentSong]==0){
        SongPlayed[currentSong]=1;
        class'DXREvents'.static.MarkBingo(dxr,"PianoSong"$currentSong$"Played");
        if (ValidSong(currentSong)){
            class'DXREvents'.static.MarkBingo(dxr,"PianoSongPlayed");
        }
    }

    if(player != None) {
        player.ClientMessage(message);
        player = None;
    }

    bUsing = False;
    message = "";
    soundHandle = 0;
    currentSong = -1;
}

function Frob(actor Frobber, Inventory frobWith)
{
    local int rnd;
    local float duration;
    local Sound SelectedSound;

    Super(WashingtonDecoration).Frob(Frobber, frobWith);

#ifdef hx
    if ( NextUseTime>Level.TimeSeconds || IsInState('Conversation') || IsInState('FirstPersonConversation') )
        return;
#else
    if (bUsing && soundHandle!=0) {
        StopSound(soundHandle);
    }
#endif

    player = #var(PlayerPawn)(Frobber);
    message = "";
    soundHandle = 0;
    rnd = currentSong;
    while(rnd == currentSong) {
        rnd = Rand(38); //make sure this matches the number of sounds below
    }
    currentSong = rnd;
    switch(currentSong){
        case 0:
            //DX Theme, Correct
            SelectedSound = sound'Piano1';
            duration = 1.5;
            break;
        case 1:
            //Random Key Mashing, DX Vanilla
            SelectedSound = sound'Piano2';
            duration = 1.5;
            break;
        case 2:
            //Max Payne Piano, Slow, Learning
            SelectedSound = sound'MaxPaynePianoSlow';
            duration = 8;
            break;
        case 3:
            //Max Payne Piano, Fast
            SelectedSound = sound'MaxPaynePianoFast';
            duration = 4;
            break;
        case 4:
            //Megalovania
            SelectedSound = sound'Megalovania';
            duration = 3;
            break;
        case 5:
            //Song of Storms
            SelectedSound = sound'SongOfStorms';
            duration = 4;
            break;
        case 6:
            // The six arrive, the fire lights their eyes
            SelectedSound = sound'T7GPianoBad';
            duration = 6;
            break;
        case 7:
            // invited here to learn to play.... THE GAME
            SelectedSound = sound'T7GPianoGood';
            duration = 7;
            break;
        case 8:
            // You fight like a dairy farmer!
            SelectedSound = sound'MonkeyIsland';
            duration = 5;
            break;
        case 9:
            SelectedSound = sound'BloodyTears';
            duration = 4;
            break;
        case 10:
            SelectedSound = sound'GreenHillZone';
            duration = 6;
            break;
        case 11:
            SelectedSound = sound'KirbyGreenGreens';
            duration = 6;
            break;
        case 12:
            SelectedSound = sound'MetroidItem';
            duration = 5;
            break;
        case 13:
            SelectedSound = sound'NeverGonnaGive';
            duration = 5;
            break;
        case 14:
            SelectedSound = sound'MiiChannel';
            duration = 7;
            break;
        case 15:
            SelectedSound = sound'SpinachRag';
            duration = 5;
            break;
        case 16:
            SelectedSound = sound'FurElise';
            duration = 5;
            break;
        case 17:
            SelectedSound = sound'EightMelodiesM1';
            duration = 7;
            break;
        case 18:
            SelectedSound = sound'EightMelodiesM2';
            duration = 5;
            break;
        case 19:
            SelectedSound = sound'FurretWalk';
            duration = 7;
            break;
        case 20:
            SelectedSound = sound'ProfOaksLab';
            duration = 5;
            break;
        case 21:
            SelectedSound = sound'FF4Battle1';
            duration = 8;
            break;
        case 22:
            SelectedSound = sound'AquaticAmbience';
            duration = 8;
            break;
        case 23:
            SelectedSound = sound'ChronoTriggerTheme';
            duration = 8;
            break;
        case 24:
            SelectedSound = sound'DoomE1M1';
            duration = 5;
            break;
        case 25:
            SelectedSound = sound'DoomE1M1Wrong';
            duration = 5;
            break;
        case 26:
            SelectedSound = sound'FFVictoryFanfare';
            duration = 5;
            break;
        case 27:
            SelectedSound = sound'GangplankGalleonIntro';
            duration = 9;
            break;
        case 28:
            SelectedSound = sound'Grabbag';
            duration = 7;
            break;
        case 29:
            SelectedSound = sound'MegaManStageStart';
            duration = 8;
            break;
        case 30:
            SelectedSound = sound'MGS2MainTheme';
            duration = 8;
            break;
        case 31:
            SelectedSound = sound'Halo';
            duration = 11;
            break;
        case 32:
            SelectedSound = sound'SH2PromiseReprise';
            duration = 8;
            break;
        case 33:
            SelectedSound = sound'SH2EndingTheme';
            duration = 7;
            break;
        case 34:
            SelectedSound = sound'StillAlive';
            duration = 7;
            break;
        case 35:
            SelectedSound = sound'DireDireDocks';
            duration = 8;
            break;
        case 36:
            SelectedSound = sound'GuilesTheme';
            duration = 7;
            break;
        case 37:
            SelectedSound = sound'TetrisThemeA';
            duration = 8;
            break;
        default:
            log("DXRPiano went too far this time!  Got "$currentSong);
            return;
    }

    if(SelectedSound == None) {
        log("DXRPiano got an invalid sound!  Got "$currentSong);
        return;
    }

    if(message == "") {
        message = "You played " $ SelectedSound;
    }

    soundHandle = PlaySound(SelectedSound, SLOT_Misc,5.0,, 500);

#ifdef hx
    duration += 0.5;
    NextUseTime = Level.TimeSeconds + duration;
#else
    duration = FMax(duration-0.5, 1);// some leniency
    bUsing = True;
    SetTimer(duration, False);
#endif
}

defaultproperties
{
    currentSong=-1
}
