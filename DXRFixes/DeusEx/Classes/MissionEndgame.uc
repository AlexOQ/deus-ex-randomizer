class MissionEndgame injects MissionEndgame;

struct EndQuote
{
    var string quote;
    var string attribution;
};

var EndQuote quotes[50];
var int numQuotes;


function AddQuote(string quote, string attribution)
{
    quotes[numQuotes].quote = quote;
    quotes[numQuotes].attribution = "    -- "$attribution;
    numQuotes++;
}

function LoadQuotes()
{
    //Original Endgame Quotes
    AddQuote("YESTERDAY WE OBEYED KINGS AND BENT OUR NECKS BEFORE EMPERORS.  BUT TODAY WE KNEEL ONLY TO TRUTH...","KAHLIL GIBRAN");
    AddQuote("IF THERE WERE NO GOD, IT WOULD BE NECESSARY TO INVENT HIM.","VOLTAIRE");
    AddQuote("BETTER TO REIGN IN HELL, THAN SERVE IN HEAVEN.","PARADISE LOST, JOHN MILTON");
    
    //DX Quotes
    AddQuote("A BOMB!","JC DENTON");
    AddQuote("OH MY GOD! JC! A BOMB!","JOCK");
    AddQuote("I SPILL MY DRINK!","IVAN");
    AddQuote("THANKS FOR GETTING ME IN!","MERCEDES");
    AddQuote("WHAT A SHAME...","JC DENTON");
    AddQuote("YOU CAN'T FIGHT IDEAS WITH BULLETS.","LEO GOLD");
    AddQuote("WHAT AN EXPENSIVE MISTAKE YOU TURNED OUT TO BE.","WALTON SIMONS");
    AddQuote("JUMP! YOU CAN MAKE IT!","BOB PAGE");
    AddQuote("THE MORE POWER YOU THINK YOU HAVE, THE MORE QUICKLY IT SLIPS FROM YOUR GRASP.","TRACER TONG");
    AddQuote("I NEVER HAD TIME TO TAKE THE OATH OF SERVICE TO THE COALITION. HOW ABOUT THIS ONE? I SWEAR NOT TO REST UNTIL UNATCO IS FREE OF YOU AND THE OTHER CROOKED BUREAUCRATS WHO HAVE PERVERTED ITS MISSION.","JC DENTON");
    AddQuote("WE ARE THE INVISIBLE HAND. WE ARE THE ILLUMINATI. WE COME BEFORE AND AFTER. WE ARE FOREVER. AND EVENTUALLY... EVENTUALLY WE WILL LEAD THEM INTO THE DAY.","MORGAN EVERETT");
    AddQuote("THE NEED TO BE OBSERVED AND UNDERSTOOD WAS ONCE SATISFIED BY GOD. NOW WE CAN IMPLEMENT THE SAME FUNCTIONALITY WITH DATA-MINING ALGORITHMS.","MORPHEUS");
    AddQuote("I ORDER YOU TO STAND IN THE SPOTLIGHT AND GROWL AT THE WOMEN LIKE A DOG WHO NEEDS A MASTER.","DOOR GIRL");
    AddQuote("I WANTED ORANGE. IT GAVE ME LEMON-LIME.","GUNTHER HERMANN");
    
    //Why not some Zero Wing?
    AddQuote("SOMEBODY SET UP US THE BOMB.","MECHANIC");
    AddQuote("ALL YOUR BASE ARE BELONG TO US.","CATS");
    AddQuote("YOU HAVE NO CHANCE TO SURVIVE MAKE YOUR TIME.","CATS");
    
    //A bit of Zelda perhaps?
    AddQuote("AND THE MASTER SWORD SLEEPS AGAIN... FOREVER!","A LINK TO THE PAST");
    AddQuote("IT'S A SECRET TO EVERYBODY","MOBLIN");
    AddQuote("AH, THE SCROLL OF SHURMAK, BEARER OF SAD NEWS THESE MANY YEARS AGO.","GASPRA");
    AddQuote("SHADOW AND LIGHT ARE TWO SIDES OF THE SAME COIN, ONE CANNOT EXIST WITHOUT THE OTHER.","PRINCESS ZELDA");
    AddQuote("A SWORD WIELDS NO STRENGTH UNLESS THE HAND THAT HOLDS IT HAS COURAGE","THE HERO'S SHADE");
    AddQuote("THE WIND... IT IS BLOWING...","GANONDORF");
    AddQuote("DO NOT THINK IT ENDS HERE... THE HISTORY OF LIGHT AND SHADOW WILL BE WRITTEN IN BLOOD!","GANONDORF");
    
    //A bit of this and that
    AddQuote("UNFORTUNATELY, KLLING IS ONE OF THOSE THINGS THAT GETS EASIER THE MORE YOU DO IT.","SOLID SNAKE");
    AddQuote("WHAT IS A MAN? A MISERABLE LITTLE PILE OF SECRETS!","DRACULA");
    AddQuote("THE RIGHT MAN IN THE WRONG PLACE CAN MAKE ALL THE DIFFERENCE IN THE WORLD","G-MAN");
    AddQuote("HACK THE PLANET!","HACKERS");
    AddQuote("I NEVER ASKED FOR THIS","ADAM JENSEN");
    AddQuote("BRING ME A BUCKET, AND I'LL SHOW YOU A BUCKET!","PSYCHO");
    AddQuote("THANK YOU MARIO! BUT OUR PRINCESS IS IN ANOTHER CASTLE!","TOAD");
    AddQuote("DO A BARREL ROLL!","PEPPY HARE");
    AddQuote("WAR.  WAR NEVER CHANGES.","RON PERLMAN");
    AddQuote("PRAISE THE SUN!","SOLAIRE OF ASTORA");
    AddQuote("STUPID BANJO AND DUMB KAZOOIE. I'LL BE BACK IN BANJO-TOOIE!","GRUNTILDA");
    AddQuote("IF HISTORY IS TO CHANGE, LET IT CHANGE.  IF THE WORLD IS TO BE DESTROYED, SO BE IT.  IF MY FATE IS TO DIE, I MUST SIMPLY LAUGH","MAGUS");
    AddQuote("LIFE... DREAMS... HOPE... WHERE DO THEY COME FROM? AND WHERE DO THEY GO...? SUCH MEANINGLESS THINGS... I'LL DESTROY THEM ALL!","KEFKA");
    AddQuote("DO NOT HATE HUMANS. IF YOU CANNOT LIVE WITH THEM, THEN AT LEAST DO THEM NO HARM, FOR THEIRS IS ALREADY A HARD LOT","LISA");
    AddQuote("UH, BOYS? HOW ABOUT THAT EVAC? COMMANDER? JIM? WHAT THE HELL IS GOING ON UP THERE??","SARAH KERRIGAN");
    AddQuote("LOOK AT YOU, HACKER: A PATHETIC CREATURE OF MEAT AND BONE, PANTING AND SWEATING AS YOU RUN THROUGH MY CORRIDORS.  HOW CAN YOU CHALLENGE A PERFECT, IMMORTAL MACHINE?","SHODAN");
    AddQuote("NANONMACHINES, SON.","SENATOR ARMSTRONG");
}


function EndQuote PickRandomQuote()
{
    local DXRando dxr;
    
    foreach AllActors(class'DXRando',dxr)
        break;

    return quotes[dxr.rng(numQuotes)];
}

function PostPostBeginPlay()
{
    savedSoundVolume = SoundVolume;
    Super.PostPostBeginPlay();
}

// ----------------------------------------------------------------------
// InitStateMachine()
// ----------------------------------------------------------------------

function InitStateMachine()
{
    Super(MissionScript).InitStateMachine();

    // Destroy all flags!
    //if (flags != None)
    //    flags.DeleteAllFlags();

    // Set the PlayerTraveling flag (always want it set for 
    // the intro and endgames)
    flags.SetBool('PlayerTraveling', True, True, 0);
}

// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
    Super(MissionScript).FirstFrame();

    endgameTimer = 0.0;

    if (Player != None)
    {
        // Make sure all the flags are deleted.
        //DeusExRootWindow(Player.rootWindow).ResetFlags();

        // Start the conversation
        if (localURL == "ENDGAME1")
            Player.StartConversationByName('Endgame1', Player, False, True);
        else if (localURL == "ENDGAME2")
            Player.StartConversationByName('Endgame2', Player, False, True);
        else if (localURL == "ENDGAME3")
            Player.StartConversationByName('Endgame3', Player, False, True);

        // turn down the sound so we can hear the speech
        savedSoundVolume = SoundVolume;
        SoundVolume = 32;
        Player.SetInstantSoundVolume(SoundVolume);
    }
}

function PrintEndgameQuote(int num)
{
	local int i;
	local DeusExRootWindow root;
    local EndQuote quote;

	bQuotePrinted = True;
	flags.SetBool('EndgameExplosions', False);
    
    LoadQuotes();

	root = DeusExRootWindow(Player.rootWindow);
	if (root != None)
	{
		quoteDisplay = HUDMissionStartTextDisplay(root.NewChild(Class'HUDMissionStartTextDisplay', True));
		if (quoteDisplay != None)
		{
			quoteDisplay.displayTime = endgameDelays[num];
			quoteDisplay.SetWindowAlignments(HALIGN_Center, VALIGN_Center);
            
            quote = PickRandomQuote();

		    quoteDisplay.AddMessage(quote.quote);
		    quoteDisplay.AddMessage(quote.attribution);

			quoteDisplay.StartMessage();
		}
	}
}
