class DXRando extends Info config(DXRando) transient;

var transient DeusExPlayer Player;
var transient DXRFlags flags;
var transient DeusExLevelInfo dxInfo;
var transient string localURL;

var int newseed;
var int seed;

var transient private int CrcTable[256]; // for string hashing to do more stable seeding

var transient DXRBase modules[32];
var transient int num_modules;

var config string modules_to_load[31];// 1 less than the modules array, because we always load the DXRFlags module
var config int config_version;

function SetdxInfo(DeusExLevelInfo i)
{
    dxInfo = i;
    localURL = Caps(dxInfo.mapName);
    l("SetdxInfo got localURL: " $ localURL);
    PostPostBeginPlay();
}

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();

    if( localURL == "" ) {
        l("PostPostBeginPlay returning because localURL == " $ localURL);
        return;
    }

    l("PostPostBeginPlay has localURL == " $ localURL);
    Player = DeusExPlayer(GetPlayerPawn());
    if( Player == None ) {
        l("PostPostBeginPlay() didn't find player?");
        SetTimer(0.1, False);
        return;
    }
    l("found Player "$Player);
    CrcInit();
    ClearModules();
    LoadFlagsModule();
    flags.LoadFlags();
    CheckConfig();
    LoadModules();

    RandoEnter();

    SetTimer(1.0, True);
}

function CheckConfig()
{
    local int i;
    //force modules to be referenced so they will get compiled, even if we don't want them to be loaded by default
    local DXRNoStory compile1;
    local DXRTestAllMaps compile2;
    local DXREntranceRando compile3;
    local DXRKillBobPage compile4;

    if( config_version == 0 ) {
        for(i=0; i < ArrayCount(modules_to_load); i++) {
            modules_to_load[i] = "";
        }

        i=0;
        modules_to_load[i++] = "DXRKeys";
        modules_to_load[i++] = "DXREnemies";
        modules_to_load[i++] = "DXRSkills";
        modules_to_load[i++] = "DXRPasswords";
        modules_to_load[i++] = "DXRAugmentations";
        modules_to_load[i++] = "DXRSwapItems";
        modules_to_load[i++] = "DXRReduceItems";
        modules_to_load[i++] = "DXRNames";
        modules_to_load[i++] = "DXRFixup";
        modules_to_load[i++] = "DXRAutosave";
        modules_to_load[i++] = "DXRMemes";
        modules_to_load[i++] = "DXREntranceRando";
        modules_to_load[i++] = "DXRHordeMode";
    }
    if( config_version < class'DXRFlags'.static.VersionNumber() ) {
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
        l("found already loaded module "$moduleclass);
        if(m.dxr != Self) m.Init(Self);
        return m;
    }

    //m = new(None) moduleclass;
    m = Spawn(moduleclass, None);
    if ( m == None ) {
        l("failed to load module "$moduleclass);
        return None;
    }
    m.Init(Self);
    modules[num_modules] = m;
    num_modules++;
    l("finished loading module "$moduleclass);
    return m;
}

function LoadModules()
{
    local int i;
    local class<Actor> c;
    for( i=0; i < ArrayCount( modules_to_load ); i++ ) {
        if( modules_to_load[i] == "" ) continue;
        c = flags.GetClassFromString(modules_to_load[i], class'DXRBase');
        LoadModule( class<DXRBase>(c) );
    }
    RunTests();
}

function DXRBase FindModule(class<DXRBase> moduleclass)
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
    local DXRBase m;
    num_modules=0;
    flags=None;
}

event Destroyed()
{
    local int i;
    l("Destroyed()");

    num_modules = 0;
    flags = None;
    Player = None;
    Super.Destroyed();
}

function PreTravel()
{
    local int i;
    l("PreTravel()");
    // turn off the timer
    SetTimer(0, False);

    ClearModules();
    Player=None;
}

function Timer()
{
    local int i;
    if( Player == None ) {
        PostPostBeginPlay();
        return;
    }
}

function RandoEnter()
{
    local int i;
    local bool firstTime;
    local name flagName;

    flagName = Player.rootWindow.StringToName("M"$localURL$"_Randomized");
    if (!flags.f.GetBool(flagName))
    {
        firstTime = True;
        flags.f.SetBool(flagName, True,, 999);
    }

    l("RandoEnter() firstTime: "$firstTime);

    if ( firstTime == true )
    {
        SetSeed( Crc(seed $ "MS_" $ dxInfo.MissionNumber $ localURL) );

        l("randomizing "$localURL$" using seed " $ seed);

        for(i=0; i<num_modules; i++) {
            modules[i].FirstEntry();
        }

        l("done randomizing "$localURL);
    }
    else
    {
        for(i=0; i<num_modules; i++) {
            modules[i].ReEntry();
        }
    }

    for(i=0; i<num_modules; i++) {
        modules[i].AnyEntry();
    }
}

function int SetSeed(int s)
{
    newseed = s;
}

function int rng(int max)
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

final function CrcInit() {

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

final function int Crc(coerce string Text) {

    local int CrcValue;
    local int IndexChar;

    CrcValue = 0xffffffff;

    for (IndexChar = 0; IndexChar < Len(Text); IndexChar++)
        CrcValue = (CrcValue >>> 8) ^ CrcTable[Asc(Mid(Text, IndexChar, 1)) ^ (CrcValue & 0xff)];

    return CrcValue;
}

function l(string message)
{
    log(message, class.name);
}

function RunTests()
{
    local int i, results;
    for(i=0; i<num_modules; i++) {
        results = modules[i].RunTests();
        if( results > 0 ) {
            l( modules[i] @ results $ " tests failed!" );
            Player.ClientMessage( modules[i].Class @ results $ " tests failed!" );
        }
        else
            l( modules[i] $ " passed tests!" );
    }
}

defaultproperties
{
     bAlwaysRelevant=True
}
