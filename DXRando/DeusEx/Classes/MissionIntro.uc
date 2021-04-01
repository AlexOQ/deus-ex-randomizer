class MissionIntro injects MissionIntro;

var bool started_conv;
var bool ran_first_frame;

function PostPostBeginPlay()
{
    savedSoundVolume = SoundVolume;
    Super.PostPostBeginPlay();
}

function FirstFrame()
{
    ran_first_frame = true;
    started_conv = false;

    if( flags.GetBool('Intro_Played') ) {
        log("ERROR: "$self$": Intro_Played already set before FirstFrame?");
        flags.DeleteFlag('Intro_Played', FLAG_Bool);
    }
}


function Timer()
{
    if ( flags.GetInt('Rando_newgameplus_loops') > 0 ) {
        player.bStartNewGameAfterIntro = true;
    }
    if( ran_first_frame == false ) {
        Level.Game.SetGameSpeed(0.05);
        SetTimer(0.075, True);
    }
    if( ran_first_frame == true && started_conv == false ) {
        Super.FirstFrame();
        started_conv = true;
        Level.Game.SetGameSpeed(1);
        SetTimer(checkTime, True);
    }
    Super.Timer();
}

function PreTravel()
{
    if( player != None )
        Super.PreTravel();
}
