class DXRando extends Info config(DXRando) transient;

var transient DeusExPlayer Player;
var transient FlagBase flagbase;
var transient DXRFlags flags;
var transient DXRTelemetry telemetry;
var transient DeusExLevelInfo dxInfo;
var transient string localURL;

var int newseed;
var int seed;

var transient private int CrcTable[256]; // for string hashing to do more stable seeding

var transient DXRBase modules[32];
var transient int num_modules;

var config string modules_to_load[31];// 1 less than the modules array, because we always load the DXRFlags module
var config int config_version;

var transient bool runPostFirstEntry;
var transient bool bTickEnabled;// bTickEnabled is just for DXRandoTests to inspect


/*reliable if( Role==ROLE_Authority )
        SetdxInfo, Init, DXRTick, RandoEnter, Login;*/
    /*reliable if( Role==ROLE_Authority )
        Login;*/
    
    /*reliable if( Role<ROLE_Authority )
        l, info, warning, err;*/
replication
{
    reliable if( Role==ROLE_Authority )
        modules, num_modules, runPostFirstEntry, bTickEnabled, localURL, dxInfo, telemetry, flags, flagbase, Player, CrcTable, seed;
    
    /*reliable if( Role==ROLE_Authority )
        Login;*/
}

simulated event PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
    log(Self$".PostNetBeginPlay()", self.class.name);
    SetTimer(1, true);
}

simulated event Timer()
{
    local int i;
    if( bTickEnabled == true ) return;
    for(i=0; i<num_modules; i++) {
        if( modules[i].dxr != Self) {
            log(Self$".Timer() bailing", self.class.name);
            return;
        }
    }
    SetTimer(0, false);
    Login(GetPlayerPawn());
}

function SetdxInfo(DeusExLevelInfo i)
{
    dxInfo = i;
    localURL = Caps(dxInfo.mapName);
    l("SetdxInfo got localURL: " $ localURL);

#ifdef vanilla
    // undo the damage that DXRBacktracking has done to prevent saves from being deleted
    // must do this before the mission script is loaded, so we can't wait for finding the player and loading modules
    class'DXRBacktracking'.static.LevelInit(Self);
#endif

    CrcInit();
    ClearModules();
    LoadFlagsModule();
    CheckConfig();

    Enable('Tick');
    bTickEnabled = true;
}

function Init()
{
#ifdef hx
    local HXSteve steve;
#endif
    l("Init has localURL == " $ localURL);
    foreach AllActors(class'DeusExPlayer', Player) {
        flagbase = Player.FlagBase;
        break;
    }
#ifdef hx
    foreach AllActors(class'HXSteve', steve) {
        flagbase = steve.FlagBase;
        break;
    }
#endif
    if( Player == None ) {
        warn("Init() didn't find player?");
        return;
    }
    l("found Player "$Player);
    
    flags.LoadFlags();
    LoadModules();
    RandoEnter();
}

function CheckConfig()
{
    local int i;

    if( class'DXRFlags'.static.VersionOlderThan(config_version, 1,5,8) ) {
        for(i=0; i < ArrayCount(modules_to_load); i++) {
            modules_to_load[i] = "";
        }

        i=0;
#ifdef vanilla
        modules_to_load[i++] = "DXRMissions";
#endif
        modules_to_load[i++] = "DXRSwapItems";
        //modules_to_load[i++] = "DXRAddItems";
#ifdef vanilla
        modules_to_load[i++] = "DXRFixup";
        modules_to_load[i++] = "DXRBacktracking";
        modules_to_load[i++] = "DXRKeys";
#endif
        modules_to_load[i++] = "DXRSkills";
#ifdef vanilla
        modules_to_load[i++] = "DXRPasswords";
        modules_to_load[i++] = "DXRAugmentations";
        modules_to_load[i++] = "DXRReduceItems";
        modules_to_load[i++] = "DXRNames";
#endif
        modules_to_load[i++] = "DXRMemes";
        modules_to_load[i++] = "DXREnemies";
#ifdef vanilla
        modules_to_load[i++] = "DXREntranceRando";
        modules_to_load[i++] = "DXRAutosave";
        modules_to_load[i++] = "DXRHordeMode";
        //modules_to_load[i++] = "DXRKillBobPage";
        modules_to_load[i++] = "DXREnemyRespawn";
        modules_to_load[i++] = "DXRLoadouts";
        modules_to_load[i++] = "DXRWeapons";
        modules_to_load[i++] = "DXRCrowdControl";
#endif
        modules_to_load[i++] = "DXRMachines";
        modules_to_load[i++] = "DXRTelemetry";
#ifdef vanilla
        modules_to_load[i++] = "DXRStats";
        modules_to_load[i++] = "DXRFashion";
        modules_to_load[i++] = "DXRNPCs";
#endif
        //modules_to_load[i++] = "DXRTestAllMaps";
    }
    if( config_version < class'DXRFlags'.static.VersionNumber() ) {
        info("upgraded config from "$config_version$" to "$class'DXRFlags'.static.VersionNumber());
        config_version = class'DXRFlags'.static.VersionNumber();
        SaveConfig();
    }
}

function DXRFlags LoadFlagsModule()
{
    flags = DXRFlags(LoadModule(class'DXRFlags'));
    return flags;
}

function DXRBase LoadModule(class<DXRBase> moduleclass)
{
    local DXRBase m;
    l("loading module "$moduleclass);

    m = FindModule(moduleclass);
    if( m != None ) {
        info("found already loaded module "$m);
        if(m.dxr != Self) m.Init(Self);
        return m;
    }

    m = Spawn(moduleclass, None);
    if ( m == None ) {
        err("failed to load module "$moduleclass);
        return None;
    }
    modules[num_modules] = m;
    num_modules++;
    m.Init(Self);
    l("finished loading module "$m);
    return m;
}

function LoadModules()
{
    local int i;
    local class<Actor> c;
    for( i=0; i < ArrayCount( modules_to_load ); i++ ) {
        if( modules_to_load[i] == "" ) continue;
#ifdef hx
        c = flags.GetClassFromString( "HXRandomizer." $ modules_to_load[i], class'DXRBase');
#else
        c = flags.GetClassFromString(modules_to_load[i], class'DXRBase');
#endif
        LoadModule( class<DXRBase>(c) );
    }
}

simulated final function DXRBase FindModule(class<DXRBase> moduleclass)
{
    local DXRBase m;
    local int i;
    for(i=0; i<num_modules; i++)
        if( modules[i] != None )
            if( modules[i].Class == moduleclass )
                return modules[i];

    foreach AllActors(class'DXRBase', m)
    {
        if( m.Class == moduleclass ) {
            l("FindModule("$moduleclass$") found "$m);
            m.Init(Self);
            modules[num_modules] = m;
            num_modules++;
            return m;
        }
    }

    l("didn't find module "$moduleclass);
    return None;
}

function ClearModules()
{
    num_modules=0;
    flags=None;
}

simulated event Tick(float deltaTime)
{
    log("Tick", self.class.name);
    if( Role < ROLE_Authority ) {
        Disable('Tick');
        return;
    }
    DXRTick(deltaTime);
}

function DXRTick(float deltaTime)
{
    local PlayerPawn pawn;
    local int i;
    SetTimer(0, false);
    if( dxInfo == None )
    {
        //waiting...
    }
    if( Player == None )
    {
        Init();
    }
    else if(runPostFirstEntry)
    {
        for(i=0; i<num_modules; i++) {
            modules[i].PostFirstEntry();
        }
        info("done randomizing "$localURL$" PostFirstEntry using seed " $ seed $ ", deltaTime: " $ deltaTime);
        runPostFirstEntry = false;
    }
    else
    {
        RunTests();

        for(i=0; i<num_modules; i++) {
            modules[i].PostAnyEntry();
        }
        
        Disable('Tick');
        bTickEnabled = false;

        foreach AllActors(class'PlayerPawn', pawn) {
            Login(pawn);
        }
    }
}

function RandoEnter()
{
    local int i;
    local bool firstTime;
    local name flagName;
    local bool IsTravel;

    if( flags.f == None ) {
        err("RandoEnter() flags.f == None");
        return;
    }

    IsTravel = flags.f.GetBool('PlayerTraveling');

    flagName = Player.rootWindow.StringToName("M"$localURL$"_Randomized");
    if (!flags.f.GetBool(flagName))
    {
        firstTime = True;
        flags.f.SetBool(flagName, True,, 999);
    }

    info("RandoEnter() firstTime: "$firstTime$", IsTravel: "$IsTravel$", seed: "$seed @ localURL);

    if ( firstTime == true )
    {
        //if( !IsTravel ) warning(localURL$": loaded save but FirstEntry? firstTime: "$firstTime$", IsTravel: "$IsTravel);
        SetSeed( Crc(seed $ localURL) );

        info("randomizing "$localURL$" using seed " $ seed);

        for(i=0; i<num_modules; i++) {
            modules[i].PreFirstEntry();
        }

        for(i=0; i<num_modules; i++) {
            modules[i].FirstEntry();
        }

        runPostFirstEntry = true;
        info("done randomizing "$localURL$" using seed " $ seed);
    }
    else
    {
        for(i=0; i<num_modules; i++) {
            modules[i].ReEntry(IsTravel);
        }
    }

    for(i=0; i<num_modules; i++) {
        modules[i].AnyEntry();
    }

}

simulated function Login(PlayerPawn pawn)
{
    local DeusExPlayer p;
    local int i;

    info("Login("$pawn$"), bTickEnabled: "$bTickEnabled);
    if( bTickEnabled == true ) return;

    p = DeusExPlayer(pawn);
    if( p == None ) {
        err("Login("$pawn$") not DeusExPlayer?");
        return;
    }

    info("Login("$pawn$") do it "$p);
    for(i=0; i<num_modules; i++) {
        modules[i].Login(p);
    }
}

simulated final function int SetSeed(int s)
{
    local int oldseed;
    oldseed = newseed;
    //log("SetSeed old seed == "$newseed$", new seed == "$s);
    newseed = s;
    return oldseed;
}

simulated final function int rng(int max)
{
    local int gen1, gen2;
    gen2 = 2147483643;
    gen1 = gen2/2;
    newseed = gen1 * newseed * 5 + gen2 + (newseed/5) * 3;
    newseed = abs(newseed);
    return (newseed >>> 8) % max;
}


// ============================================================================
// CrcInit https://web.archive.org/web/20181105143221/http://unrealtexture.com/Unreal/Downloads/3DEditing/UnrealEd/Tutorials/unrealwiki-offline/crc32.html
//
// Initializes CrcTable and prepares it for use with Crc.
// ============================================================================

simulated final function CrcInit() {

    const CrcPolynomial = 0xedb88320;

    local int CrcValue;
    local int IndexBit;
    local int IndexEntry;

  for (IndexEntry = 0; IndexEntry < 256; IndexEntry++) {
        CrcValue = IndexEntry;

        for (IndexBit = 8; IndexBit > 0; IndexBit--)
        {
            if ((CrcValue & 1) != 0)
                CrcValue = (CrcValue >>> 1) ^ CrcPolynomial;
            else
                CrcValue = CrcValue >>> 1;
        }
        
        CrcTable[IndexEntry] = CrcValue;
    }
}


// ============================================================================
// Crc
//
// Calculates and returns a checksum of the given string. Call CrcInit before.
// ============================================================================

simulated final function int Crc(coerce string Text) {

    local int CrcValue;
    local int IndexChar;

    CrcValue = 0xffffffff;

    for (IndexChar = 0; IndexChar < Len(Text); IndexChar++)
        CrcValue = (CrcValue >>> 8) ^ CrcTable[Asc(Mid(Text, IndexChar, 1)) ^ (CrcValue & 0xff)];

    return CrcValue;
}

simulated function l(string message)
{
    log(message, class.name);
}

simulated function info(string message)
{
    log("INFO: " $ message, class.name);
    class'DXRTelemetry'.static.SendLog(Self, Self, "INFO", message);
}

simulated function warning(string message)
{
    log("WARNING: " $ message, class.name);
    class'DXRTelemetry'.static.SendLog(Self, Self, "WARNING", message);
}

simulated function err(string message)
{
    log("ERROR: " $ message, class.name);
    if( Player != None )
        Player.ClientMessage( Class @ message, 'ERROR' );

    class'DXRTelemetry'.static.SendLog(Self, Self, "ERROR", message);
}

function RunTests()
{
    local int i, failures;
    l("starting RunTests()");
    for(i=0; i<num_modules; i++) {
        modules[i].StartRunTests();
        if( modules[i].fails > 0 ) {
            failures++;
            player.ShowHud(true);
            err( "ERROR: " $ modules[i] @ modules[i].fails $ " tests failed!" );
        }
        else
            l( modules[i] $ " passed tests!" );
    }

    if( failures == 0 ) {
        l( "all tests passed!" );
    } else {
        player.ShowHud(true);
        err( "ERROR: " $ failures $ " modules failed tests!" );
    }
}

function ExtendedTests()
{
    local int i, failures;
    l("starting ExtendedTests()");
    for(i=0; i<num_modules; i++) {
        modules[i].StartExtendedTests();
        if( modules[i].fails > 0 ) {
            failures++;
            player.ShowHud(true);
            err( "ERROR: " $ modules[i] @ modules[i].fails $ " tests failed!" );
        }
        else
            l( modules[i] $ " passed tests!" );
    }

    if( failures == 0 ) {
        l( "all extended tests passed!" );
    } else {
        player.ShowHud(true);
        err( "ERROR: " $ failures $ " modules failed tests!" );
    }
}

defaultproperties
{
    NetPriority=0.1
    bAlwaysRelevant=True
    bGameRelevant=True
    bTickEnabled=True
    RemoteRole=ROLE_SimulatedProxy
}
