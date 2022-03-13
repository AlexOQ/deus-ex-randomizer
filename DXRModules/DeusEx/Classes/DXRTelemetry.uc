class DXRTelemetry extends DXRActorsBase transient;

var transient Telemetry t;

var config int config_version;
var config bool enabled, death_markers;
var config string server;
var config string path;
var config int cache_addr;
var config string last_notification;

var string notification_url;

function CheckConfig()
{
    if( server == "" || config_version < VersionNumber() ) {
        server = "raycarro.com";
        path = "/dxrando/log.py";
        cache_addr = 0;
    }
    Super.CheckConfig();
}

function AnyEntry()
{
    local #var PlayerPawn  p;
    Super.AnyEntry();
#ifdef hx
    //SetTimer(300, true);
#endif
    //info log player's health, item counts...?
    p = player();
    if( p == None ) return;
    info("health: "$p.health$", HealthLegLeft: "$p.HealthLegLeft$", HealthLegRight: "$p.HealthLegRight$", HealthTorso: "$p.HealthTorso$", HealthHead: "$p.HealthHead$", HealthArmLeft: "$p.HealthArmLeft$", HealthArmRight: "$p.HealthArmRight);
}

function Timer()
{
    local int numActors, numObjects;
    local Actor a;
    local Object o, last;
    local name names[4096];
    local int counts[4096], slot, i;

    foreach AllObjects(class'Object', o) {
        if( o.IsA('Actor') ) {
            numActors++;
            continue;
        }
        numObjects++;
        last = o;
        slot = Abs(dxr.Crc( String(o.class.name) )) % ArrayCount(names);
        if( names[slot] == '' || names[slot] == o.class.name ) {
            names[slot] = o.class.name;
            counts[slot]++;
        }
    }

    info("numActors: "$numActors$", numObjects: "$numObjects$", last object: "$last);
    for(i=0; i<ArrayCount(names); i++) {
        if( names[i] == '' ) continue;
        info(names[i] @ counts[i]);
    }
}

function set_enabled(bool e, bool set_death_markers)
{
    log(Self$": set_enabled "$e);
    enabled = e;
    death_markers = set_death_markers;
    SaveConfig();
}

function CacheAddr( int Addr )
{
    if( cache_addr != Addr ) {//these should never be equal anyways in this function?
        cache_addr = Addr;
        SaveConfig();
        log(Self$": cached addr " $ Addr);
    }
}

function int GetAddrFromCache()
{
    log(Self$": got addr from cache " $ cache_addr );
    return cache_addr;
}

function ReceivedData(string data)
{
    local string status;
    local Json j;
    j = class'Json'.static.parse(Level, data);
    data = "";
    status = j.get("status");
    if( InStr(status,"ERROR") >= 0 || InStr(status, "ok") == -1 ) {
        l("HTTPReceivedData: " $ status);
    }
    CheckNotification(j.get("notification"), j.get("message"));
    CheckDeaths(j);
}

function bool CanShowNotification()
{
    /*local DeusExRootWindow r;
    local DeusExHUD hud;*/

    if( dxr.localURL == "DX" || dxr.localURL == "DXONLY" ) return true;

    /*if( player() == None ) return false;
    r = DeusExRootWindow(player().rootWindow);
    if( r == None ) return false;
    hud = r.hud;
    if( hud == None ) return false;
    if( ! hud.IsVisible() ) return false;
    return true;*/
    return false;
}


function CheckNotification(string title, string message)
{
    local int i;

    if( ! CanShowNotification() ) return;
    if( title == "" || title == last_notification ) return;
    last_notification = title;
    SaveConfig();

    i = InStr(message, "https://");
    notification_url = Mid(message, i);
    i = InStr(notification_url, " ");
    if( i != -1 ) notification_url = Left(notification_url, i);

    message = ReplaceText(message, "https://", "");
    CreateMessageBox(title, message, 0, Self, 1);
}

function MessageBoxClicked(int button, int callbackId){
    Super.MessageBoxClicked(button, callbackId);
    if( button == 0 ) {
        player().ConsoleCommand("start "$notification_url);
    }
    //Implementations in subclasses just need to call Super to pop the window, then can handle the message however they want
    //Buttons:
    //Yes = 0
    //No = 1
    //OK = 2
}

function CheckDeaths(Json j) {
    local string k, t;
    local int i;
    local vector loc;

    // if death_markers is disabled, we still should parse the list so we can tell the server the newest one we've already received?

    for(i=0; i<j.count(); i++) {
        k = j.key_at(i);
        if( InStr(k, "deaths.") == 0 ) {
            loc.x = float(j.at(i, 5));
            loc.y = float(j.at(i, 6));
            loc.z = float(j.at(i, 7));
            if(death_markers) {
                l("CheckDeaths key: "$k$" new deathmarker "$loc);
                // New(Actor a, vector loc, string playername, string killerclass, string killer, string damagetype, int age, int numtimes)
                class'DeathMarker'.static.New(Self, loc, j.at(i, 1), j.at(i, 8), j.at(i, 2), j.at(i, 3), int(j.at(i, 4)), int(j.at(i, 0)));
            }
        }
    }
}

function _SendLog(Actor a, string LogLevel, string message)
{
    if( ! enabled ) return;
    message = LogLevel $ ": " $ a $ ": " $ message;
    if( t != None && t.Queue(message) )  return;

    foreach a.AllActors(class'Telemetry', t) {
        if( t.Queue(message) ) return;
    }
    t = a.Spawn(class'Telemetry');
    t.module = Self;
    t.Queue(message);
}

static function SendLog(DXRando dxr, Actor a, string LogLevel, string message)
{
    local DXRTelemetry module;
    if(dxr == None) return;
    module = dxr.telemetry;
    if( module != None ) module._SendLog(a, LogLevel, message);
}

static function AddDeath(DXRando dxr, #var PlayerPawn  player, optional Pawn Killer, optional coerce string damageType, optional vector HitLocation)
{
    local string msg, killername, playername;
    local #var prefix ScriptedPawn sp;
    local #var PlayerPawn  killerplayer;

    killerplayer = #var PlayerPawn (Killer);
    sp = #var prefix ScriptedPawn(Killer);

#ifdef hx
    playername = player.PlayerReplicationInfo.PlayerName;
    if(killerplayer != None) {
        killername = killerplayer.TruePlayerName;
    }
#else
    playername = player.TruePlayerName;
    if(killerplayer != None) {
        killername = killerplayer.TruePlayerName;
    }
#endif
    // bImportant ScriptedPawns don't get their names randomized
    else if(sp != None && sp.bImportant)
        killername = Killer.FamiliarName;
    // randomized names aren't really meaningful here so use their default name
    else if(Killer != None)
        killername = Killer.default.FamiliarName;

    if(damageType == "shot") {
        if( !IsHuman(Killer) && Robot(Killer) == None ) {
            // only humans and robots can shoot? karkians deal shot damage
            damageType = "";
        }
    }

    if(Killer != None)
        msg = playername $ " was killed by " $ Killer.Class.Name @ killername $ " with " $ damageType $ " damage in " $ dxr.localURL $ " (" $ player.Location $ ")";
    else
        msg = playername $ " was killed with " $ damageType $ " damage in " $ dxr.localURL $ " (" $ player.Location $ ")";

    log("DEATH: " $ msg, 'DXRTelemetry');
    SendLog(dxr, player, "DEATH", msg);
}

static function BeatGame(DXRando dxr, int ending, int time)
{
    local string msg, playername;
    local #var PlayerPawn   player;

    player = dxr.player;

#ifdef hx
    playername = player.PlayerReplicationInfo.PlayerName;
#else
    playername = player.TruePlayerName;
#endif

    msg =       "{";
    msg = msg $ "\"type\":\"BeatGame\",";
    msg = msg $ "\"seed\":"$dxr.seed$",";
    msg = msg $ "\"PlayerName\":\""$playername$"\",";
    msg = msg $ "\"ending\":"$ending$",";
    msg = msg $ "\"time\":"$time;
    msg = msg $ "}";

    log("EVENT: BeatGame: " $ msg, 'DXRTelemetry');
    SendLog(dxr, player, "EVENT", msg);
}

static function SendEvent(DXRando dxr, Actor a, string name, Json j)
{
    local string msg;
    // TODO: convert Json j to string
    // TODO: convert AddDeath to use this
    log("EVENT: " $ name $ ": " $ msg, 'DXRTelemetry');
    SendLog(dxr, a, "EVENT", msg);
}

function ExtendedTests()
{
    local vector loc;
    loc = vect(1,2,3);
    teststring(string(loc), loc.x$","$loc.y$","$loc.z, "vector to string x,y,z");
}

defaultproperties
{
    death_markers=true
}
