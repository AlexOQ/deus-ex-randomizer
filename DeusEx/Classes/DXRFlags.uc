class DXRFlags extends DXRBase transient;

var transient FlagBase f;

//rando flags
var int seed;
var int flagsversion;//if you load an old game with a newer version of the randomizer, we'll need to set defaults for new flags
var int gamemode;//0=original, 1=rearranged, 2=horde, 3=kill bob page, 4=stick to the prod, 5=stick to the prod +, 6=how about some soy food
var int loadout;//0=none, 1=stick with the prod, 2=stick with the prod plus
var int brightness, minskill, maxskill, ammo, multitools, lockpicks, biocells, medkits, speedlevel;
var int keysrando;//0=off, 1=dumb, 2=on (old smart), 3=copies, 4=smart (v1.3), 5=path finding?
var int doorsmode, doorspickable, doorsdestructible, deviceshackable, passwordsrandomized, gibsdropkeys;//could be bools, but int is more flexible, especially so I don't have to change the flag type
var int autosave;//0=off, 1=first time entering level, 2=every loading screen
var int removeinvisiblewalls, enemiesrandomized, enemyrespawn, infodevices;
var int dancingpercent;
var int skills_disable_downgrades, skills_reroll_missions, skills_independent_levels;
var int startinglocations, goals, equipment;//equipment is a multiplier on how many items you get?
var int medbots, repairbots;//there are 90 levels in the game, so 10% means approximately 9 medbots and 9 repairbots for the whole game, I think the vanilla game has 12 medbots, but they're also placed in smart locations so we might want to give more than that for Normal difficulty
var int turrets_move, turrets_add;
var int crowdcontrol;

var int undefeatabledoors, alldoors, keyonlydoors, highlightabledoors, doormutuallyinclusive, doorindependent, doormutuallyexclusive;

function PreTravel()
{
    Super.PreTravel();
    if( dxr != None && dxr.localURL == "INTRO" && f.GetInt('Rando_version') == 0 ) {
        info("PreTravel "$dxr.localURL$" SaveFlags");
        SaveFlags();
    }
    f = None;
    Self.Destroy();// for some reason, "f = tdxr.Player.FlagBase;" inside the Init function crashes if I don't do this, not sure why
}

function Init(DXRando tdxr)
{
    Super.Init(tdxr);
    f = tdxr.Player.FlagBase;
    tdxr.seed = seed;
    InitVersion();
}

function Timer()
{
    Super.Timer();

    if( f.GetInt('Rando_version') == 0 ) {
        info("flags got deleted, saving again");//the intro deletes all flags
        SaveFlags();
    }
}

function RollSeed()
{
    dxr.CrcInit();
    seed = dxr.Crc( Rand(MaxInt) @ (FRand()*1000000) @ (Level.TimeSeconds*1000) );
    seed = abs(seed) % 1000000;
    dxr.seed = seed;
}

function InitDefaults()
{
    InitVersion();
    CheckConfig();
    //dxr.CrcInit();

    undefeatabledoors = 1*256;
    alldoors = 2*256;
    keyonlydoors = 3*256;
    highlightabledoors = 4*256;
    doormutuallyinclusive = 1;
    doorindependent = 2;
    doormutuallyexclusive = 3;

    seed = 0;
    if( dxr != None ) RollSeed();
    gamemode = 0;
    loadout = 0;
    brightness = 10;
    minskill = 25;
    maxskill = 300;
    ammo = 90;
    multitools = 80;
    lockpicks = 80;
    biocells = 80;
    speedlevel = 1;
    keysrando = 4;
    doorsmode = keyonlydoors + doormutuallyexclusive;
    doorspickable = 50;
    doorsdestructible = 50;
    deviceshackable = 100;
    passwordsrandomized = 100;
    gibsdropkeys = 1;
    medkits = 90;
    autosave = 2;
    removeinvisiblewalls = 0;
    enemiesrandomized = 25;
    enemyrespawn = 0;
    infodevices = 100;
    dancingpercent = 25;
    skills_disable_downgrades = 0;
    skills_reroll_missions = 0;
    skills_independent_levels = 0;
    startinglocations = 100;
    goals = 100;
    equipment = 1;
    medbots = 15;
    repairbots = 15;
    turrets_move = 50;
    turrets_add = 20;
    crowdcontrol = 0;
}

function CheckConfig()
{
    if( config_version < 4 ) {
    }
    Super.CheckConfig();
}

function LoadFlags()
{
    local int stored_version;
    info("LoadFlags()");

    InitDefaults();

    stored_version = f.GetInt('Rando_version');

    if( stored_version == 0 && dxr.localURL != "DX" && dxr.localURL != "DXONLY" && dxr.localURL != "00_TRAINING" ) {
        err(dxr.localURL$" failed to load flags! using default randomizer settings");
        autosave = 0;//autosaving while slowmo is set to high speed crashes the game, maybe autosave should adjust its waittime by the slowmo speed
    }

    if( stored_version >= 1 ) {
        seed = f.GetInt('Rando_seed');
        dxr.seed = seed;
        brightness = f.GetInt('Rando_brightness');
        minskill = f.GetInt('Rando_minskill');
        maxskill = f.GetInt('Rando_maxskill');
        ammo = f.GetInt('Rando_ammo');
        multitools = f.GetInt('Rando_multitools');
        lockpicks = f.GetInt('Rando_lockpicks');
        biocells = f.GetInt('Rando_biocells');
        speedlevel = f.GetInt('Rando_speedlevel');
        keysrando = f.GetInt('Rando_keys');
        doorspickable = f.GetInt('Rando_doorspickable');
        doorsdestructible = f.GetInt('Rando_doorsdestructible');
        deviceshackable = f.GetInt('Rando_deviceshackable');
        passwordsrandomized = f.GetInt('Rando_passwordsrandomized');
        gibsdropkeys = f.GetInt('Rando_gibsdropkeys');
    }
    if( stored_version >= 2 ) {
        medkits = f.GetInt('Rando_medkits');
    }
    if( stored_version >= 3 ) {
        autosave = f.GetInt('Rando_autosave');
        removeinvisiblewalls = f.GetInt('Rando_removeinvisiblewalls');
        enemiesrandomized = f.GetInt('Rando_enemiesrandomized');
        infodevices = f.GetInt('Rando_infodevices');
        dancingpercent = f.GetInt('Rando_dancingpercent');
    }
    if( stored_version >= 4 ) {
        doorsmode = f.GetInt('Rando_doorsmode');
        gamemode = f.GetInt('Rando_gamemode');
        enemyrespawn = f.GetInt('Rando_enemyrespawn');
    }
    if( stored_version >= VersionToInt(1,4,4) ) {
        skills_disable_downgrades = f.GetInt('Rando_skills_disable_downgrades');
        skills_reroll_missions = f.GetInt('Rando_skills_reroll_missions');
        skills_independent_levels = f.GetInt('Rando_skills_independent_levels');

        if( gamemode == 4 ) loadout = 1;
        if( gamemode == 5 ) loadout = 2;
    }
    if( stored_version >= VersionToInt(1,4,7) ) {
        loadout = f.GetInt('Rando_banneditems');
    }
    if( stored_version >= VersionToInt(1,4,9) ) {
        startinglocations = f.GetInt('Rando_startinglocations');
        goals = f.GetInt('Rando_goals');
        equipment = f.GetInt('Rando_equipment');
        medbots = f.GetInt('Rando_medbots');
        repairbots = f.GetInt('Rando_repairbots');
    }
    if( stored_version >= VersionToInt(1,5,0) ) {
        turrets_move = f.GetInt('Rando_turrets_move');
        turrets_add = f.GetInt('Rando_turrets_add');
        crowdcontrol = f.GetInt('Rando_crowdcontrol');
    }
    if( stored_version >= VersionToInt(1,5,1) ) {
        loadout = f.GetInt('Rando_loadout');
    }

    if(stored_version < flagsversion ) {
        info("upgraded flags from "$stored_version$" to "$flagsversion);
        SaveFlags();
    }

    LogFlags("LoadFlags");
    dxr.Player.ClientMessage("Deus Ex Randomizer " $ VersionString() $ " seed: " $ seed $ ", difficulty: " $ dxr.Player.CombatDifficulty $ ", flags: " $ FlagsHash() );
    SetTimer(1.0, True);
}

function SaveFlags()
{
    l("SaveFlags()");

    InitVersion();
    f.SetInt('Rando_seed', seed);
    dxr.seed = seed;

    f.SetInt('Rando_version', flagsversion);
    f.SetInt('Rando_gamemode', gamemode);
    f.SetInt('Rando_loadout', loadout);
    f.SetInt('Rando_brightness', brightness);
    f.SetInt('Rando_minskill', minskill);
    f.SetInt('Rando_maxskill', maxskill);
    f.SetInt('Rando_ammo', ammo);
    f.SetInt('Rando_multitools', multitools);
    f.SetInt('Rando_lockpicks', lockpicks);
    f.SetInt('Rando_biocells', biocells);
    f.SetInt('Rando_medkits', medkits);
    f.SetInt('Rando_speedlevel', speedlevel);
    f.SetInt('Rando_keys', keysrando);
    f.SetInt('Rando_doorsmode', doorsmode);
    f.SetInt('Rando_doorspickable', doorspickable);
    f.SetInt('Rando_doorsdestructible', doorsdestructible);
    f.SetInt('Rando_deviceshackable', deviceshackable);
    f.SetInt('Rando_passwordsrandomized', passwordsrandomized);
    f.SetInt('Rando_gibsdropkeys', gibsdropkeys);
    f.SetInt('Rando_autosave', autosave);
    f.SetInt('Rando_removeinvisiblewalls', removeinvisiblewalls);
    f.SetInt('Rando_enemiesrandomized', enemiesrandomized);
    f.SetInt('Rando_enemyrespawn', enemyrespawn);
    f.SetInt('Rando_infodevices', infodevices);
    f.SetInt('Rando_dancingpercent', dancingpercent);

    f.SetInt('Rando_skills_disable_downgrades', skills_disable_downgrades);
    f.SetInt('Rando_skills_reroll_missions', skills_reroll_missions);
    f.SetInt('Rando_skills_independent_levels', skills_independent_levels);

    f.SetInt('Rando_startinglocations', startinglocations);
    f.SetInt('Rando_goals', goals);
    f.SetInt('Rando_equipment', equipment);

    f.SetInt('Rando_medbots', medbots);
    f.SetInt('Rando_repairbots', repairbots);
    f.SetInt('Rando_turrets_move', turrets_move);
    f.SetInt('Rando_turrets_add', turrets_add);
    f.SetInt('Rando_crowdcontrol', crowdcontrol);

    LogFlags("SaveFlags");
}

function LogFlags(string prefix)
{
    info(prefix$" - " $ VersionString() $ ", " $ "seed: "$seed$", difficulty: " $ dxr.Player.CombatDifficulty $ ", " $ StringifyFlags() );
}

function string StringifyFlags()
{
    return "flagsversion: "$flagsversion$", gamemode: "$gamemode $ ", difficulty: " $ dxr.Player.CombatDifficulty $ ", loadout: "$loadout$", brightness: "$brightness $ ", ammo: " $ ammo
        $ ", minskill: "$minskill$", maxskill: "$maxskill$", skills_disable_downgrades: " $ skills_disable_downgrades $ ", skills_reroll_missions: " $ skills_reroll_missions $ ", skills_independent_levels: " $ skills_independent_levels
        $ ", multitools: "$multitools$", lockpicks: "$lockpicks$", biocells: "$biocells$", medkits: "$medkits
        $ ", speedlevel: "$speedlevel$", keysrando: "$keysrando$", doorsmode: "$doorsmode$", doorspickable: "$doorspickable$", doorsdestructible: "$doorsdestructible
        $ ", deviceshackable: "$deviceshackable$", passwordsrandomized: "$passwordsrandomized$", gibsdropkeys: "$gibsdropkeys
        $ ", autosave: "$autosave$", removeinvisiblewalls: "$removeinvisiblewalls$", enemiesrandomized: "$enemiesrandomized$", enemyrespawn: "$enemyrespawn$", infodevices: "$infodevices
        $ ", startinglocations: "$startinglocations$", goals: "$goals$", equipment: "$equipment$", dancingpercent: "$dancingpercent$", medbots: "$medbots$", repairbots: "$repairbots$", turrets_move: "$turrets_move$", turrets_add: "$turrets_add$", crowdcontrol: "$crowdcontrol;
}

function int FlagsHash()
{
    local int hash;
    hash = dxr.Crc(StringifyFlags());
    hash = int(abs(hash));
    return hash;
}

function InitVersion()
{
    flagsversion = VersionNumber();
}

static function int VersionToInt(int major, int minor, int patch)
{
    local int ret;
    ret = major*10000+minor*100+patch;
    if( ret <= 10400 ) return minor;//v1.4 and earlier
    return ret;
}

static function string VersionToString(int major, int minor, int patch)
{
    if( patch == 0 )
        return "v" $ major $"."$ minor;
    else
        return "v" $ major $"."$ minor $"."$ patch;
}

static function int VersionNumber()
{
    return VersionToInt(1, 5, 1);
}

static function string VersionString()
{
    return VersionToString(1, 5, 1) $ " Alpha";
}

function MaxRando()
{
    //should have a chance to make some skills completely unattainable, like 999999 cost? would this also have to be an option in the GUI or can it be exclusive to MaxRando?
}

function RunTests()
{
    local int i, t;
    Super.RunTests();

    //this Crc function returns negative numbers
    testint( dxr.Crc("a bomb!"), -1813716842, "Crc32 test");
    testint( dxr.Crc("1723"), -441943723, "Crc32 test");
    testint( dxr.Crc("do you have a single fact to back that up"), -1473827402, "Crc32 test");

    SetSeed("smashthestate");
    testint( rng(1), 0, "rng(1) is 0");
    for(i=0;i<10;i++) {
        t=rng(100);
        test( t >=0 && t < 100, "rng(100) got " $t$" >= 0 and < 100");
    }
    dxr.SetSeed(-111);
    i = rng(100);
    test( rng(100) != i, "rng(100) != rng(100)");
}

function ExtendedTests()
{
    local int i;
    Super.ExtendedTests();

    testfloat( pow(5.7,3), 5.7*5.7*5.7, "pow");

    for(i=1;i<=5;i++)
        TestRngExp(25, 300, 100, i);
    for(i=1;i<=5;i++)
        TestRngExp(50, 300, 100, i);
    for(i=1;i<=5;i++)
        TestRngExp(50, 400, 100, i);
    for(i=1;i<=5;i++)
        TestRngExp(25, 150, 100, i);
}

function TestRngExp(int minrange, int maxrange, int mid, float curve)
{
    local int min, max, avg, lows, highs, mids, times;
    local int i, t;

    times = 10000;
    min=maxrange;
    max=minrange;
    highs=0;
    lows=0;
    mids=0;
    for(i=0; i<times; i++) {
        t=rngexp(minrange, maxrange, curve);
        avg += t;
        if(t<min) min=t;
        if(t>max) max=t;
        if(t<mid) lows++;
        if(t>mid) highs++;
        if(t==mid) mids++;
    }
    avg /= times;
    test( min >= minrange, "exponential ^"$curve$" - min: "$min);
    test( min < minrange+10, "exponential ^"$curve$" - min: "$min);
    test( max <= maxrange, "exponential ^"$curve$" - max: "$max);
    test( max > maxrange-10, "exponential ^"$curve$" - max: "$max);
    test( avg < maxrange, "exponential ^"$curve$" - avg "$avg$" < maxrange "$maxrange);
    test( avg > minrange, "exponential ^"$curve$" - avg "$avg$" > minrange "$minrange);
    test( lows > times/10, "exponential ^"$curve$" - lows "$lows$" > times/8 "$(times/10));
    test( highs > times/10, "exponential ^"$curve$" - highs "$highs$" > times/8 "$(times/10));
}
