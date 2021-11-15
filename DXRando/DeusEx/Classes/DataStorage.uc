#ifdef hx
class DataStorage extends Inventory config(HXRandoDataStorage) transient;
#elseif gmdx
class DataStorage extends Inventory config(GMDXRandoDataStorage) transient;
#elseif revision
class DataStorage extends Inventory config(RevRandoDataStorage) transient;
#else
class DataStorage extends Inventory config(DXRDataStorage) transient;
#endif

struct KVP {
    var string key;
    var string value;
    var int expiration;
    var int created;
};

var transient config KVP config_data[512];
var transient bool config_dirty;
var travel int playthrough_id;

var travel int EntranceRandoMissionNumber;
var travel int numConns;
var travel string conns[120];

#ifdef multiplayer
// DeusExNotes
var transient config int notes_playthrough;
var transient config name textTags[512];
var transient config string texts[512];
var transient config int notes_start, notes_len;

simulated function _AddNote(int i, Name textTag, bool bUserNote, String text)
{
    textTags[i] = textTag;
    texts[i] = text;
    log(self$".AddNote("$textTag$", "$text$") added to slot "$i);
    config_dirty = true;
}

simulated function AddNote(Name textTag, bool bUserNote, String text)
{
    local int i, end;

    log(self$".AddNote("$textTag$", "$text$"), bUserNote: "$bUserNote$", notes_playthrough: "$notes_playthrough$", playthrough_id: "$playthrough_id);
    if( bUserNote ) return;

    if( notes_playthrough != playthrough_id ) {
        for(i=0; i<ArrayCount(textTags); i++) {
            textTags[i]='';
            texts[i]="";
        }
        notes_start = 0;
        notes_len = 0;
        notes_playthrough = playthrough_id;
        config_dirty = true;
    }

    if( textTag != '' ) {
        for(i=0; i<ArrayCount(textTags); i++) {
            if( textTags[i] == textTag ) {
                _AddNote(i, textTag, bUserNote, text);
                return;
            }
        }
    }
    else {
        for(i=0; i<ArrayCount(textTags); i++) {
            if( texts[i] == text ) {
                return;
            }
        }
    }

    end = (notes_start + notes_len) % ArrayCount(textTags);
    _AddNote(end, textTag, bUserNote, text);
    if( notes_len == ArrayCount(textTags) )
        notes_start = (notes_start+1) % ArrayCount(textTags);
    else
        notes_len++;
}

function HXLoadNotes()
{
    local int i;
    local HXGameInfo g;

    log(self$".HXLoadNotes, notes_playthrough: "$notes_playthrough$", playthrough_id: "$playthrough_id);

    if( notes_playthrough != playthrough_id ) {
        return;
    }

    g = HXGameInfo(Level.Game);

    for(i=0; i<ArrayCount(textTags); i++) {
        if( texts[i] == "" ) continue;
        g.AddNote( texts[i], false, false, textTags[i] );
    }
}

#endif

replication
{
    reliable if( Role==ROLE_Authority )
        config_data, config_dirty, playthrough_id, EntranceRandoMissionNumber, numConns, conns;
}

function PreTravel()
{
    Flush();
}

function Destroyed()
{
    Flush();
}

function Flush()
{
    if( config_dirty ) {
        SaveConfig();
        config_dirty = false;
    }
}

function EndPlaythrough()
{
    local string pid;
    local int i, slen, time, expired;
    pid = " " $ playthrough_id;
    slen = Len(pid);

    time = SystemTime();
    expired = time-1;
    for( i=0; i < ArrayCount(config_data); i++) {
        if( ! IsData(config_data[i], time) ) continue;
        if( Right(config_data[i].key, slen) != pid ) continue;

        config_data[i].expiration = expired;
        config_dirty=true;
    }
}

static function int _SystemTime(LevelInfo Level)
{
    local int time, m;
    time = Level.Second + (Level.Minute*60) + (Level.Hour*3600) + (Level.Day*86400);

    switch(Level.Month) {
        // in case 12, we add the days of november not december, because we're still in december
        // all the cases roll over to add the other days of the year that have passed
        case 12:
            time += 30 * 86400;
        case 11:
            time += 31 * 86400;
        case 10:
            time += 30 * 86400;
        case 9:
            time += 31 * 86400;
        case 8:
            time += 31 * 86400;
        case 7:
            time += 30 * 86400;
        case 6:
            time += 31 * 86400;
        case 5:
            time += 30 * 86400;
        case 4:
            time += 31 * 86400;
        case 3:
            time += 28 * 86400;
        case 2:
            time += 31 * 86400;
    }

    time += (Level.Year-1970) * 86400 * 365;

    // leap years...
    time += (Level.Year-1)/4 * 86400;// leap year every 4th year
    time -= (Level.Year-1)/100 * 86400;// but not every 100th year
    time += (Level.Year-1)/400 * 86400;// unless it's also a 400th year
    // if the current year is a leap year, have we passed it?
    if ( (Level.Year % 4) == 0 && ( (Level.Year % 100) != 0 || (Level.Year % 400) == 0 ) && Level.Month > 2 )
        time += 86400;
    return time;
}

final function int SystemTime()
{
    return _SystemTime(Level);
}

#ifdef hx
simulated function static DataStorage GetObj(Actor p)
#else
simulated function static DataStorage GetObj(DeusExPlayer p)
#endif
{
    local DataStorage d;
    local DXRFlags f;

    if( p == None ) return None;
    
#ifdef hx
    d = HXRandoGameInfo(p.Level.Game).ds;
#else
    d = DataStorage(p.FindInventoryType(class'DataStorage'));
#endif
    if( d == None ) {
        d = p.Spawn(class'DataStorage');
#ifdef hx
        HXRandoGameInfo(p.Level.Game).ds = d;
#else
        d.GiveTo(p);
        d.SetBase(p);
#endif
    }
    if( d.playthrough_id == 0 ) {
        foreach d.AllActors(class'DXRFlags', f) {
            d.playthrough_id = f.playthrough_id;
            break;
        }
    }
    return d;
}

final function GetRange(string key, out int min, out int max)
{
    local int hash, len, blocksize, num_blocks;
    len = ArrayCount(config_data);
    // case sensitive, and you want the first and last letters to be unique
    hash = playthrough_id + Asc(key)*73 + Asc(Mid(key, 1, 1));
    blocksize = 32;
    num_blocks = len / blocksize;
    //the last block is reserved space because of the way we overlap
    min = (hash%(num_blocks-1))*blocksize;
    //length is doubled so that there's overlap across blocks
    max = min + blocksize*2;
}

function string GetConfigKey(coerce string key)
{
    local int i, min, max, time;

    GetRange(key, min, max);
    time = SystemTime();
    key = key@playthrough_id;

    for( i=min; i < max; i++) {
        if( config_data[i].key == key ) {
            if( IsData(config_data[i], time) ) {
                return config_data[i].value;
            }
            else return "";
        }
    }
    return "";
}

function string GetConfigIndex(int i, optional out string key)
{
    if( IsData(config_data[i], SystemTime()) ) {
        key = config_data[i].key;
        return config_data[i].value;
    }
    else return "";
}

function bool SetConfig(coerce string key, coerce string value, int expire_seconds)
{
    local int i, min, max, time, oldest, oldestcreated;

    GetRange(key, min, max);
    time = SystemTime();
    key = key@playthrough_id;

    for( i=min; i < max; i++) {
        if( config_data[i].key == key ) {
            if( SetKVP(config_data[i], key, value, expire_seconds, time) ) {
                config_dirty = true;
                return true;
            }
            else return false;
        }
    }
    for( i=min; i < max; i++) {
        if( ! IsData(config_data[i], time) ) {
            if( SetKVP(config_data[i], key, value, expire_seconds, time) ) {
                config_dirty = true;
                return true;
            }
            else return false;
        }
    }

    //emergency! find oldest item and overwrite it (oldest, not the item closest to expiration)
    oldest = min;
    oldestcreated = config_data[oldest].created;

    for( i=min; i < max; i++) {
        if( config_data[i].created - oldestcreated < 0 ) {
            oldest = i;
            oldestcreated = config_data[i].created;
        }
    }

    if( SetKVP(config_data[oldest], key, value, expire_seconds, time) ) {
        config_dirty = true;
        return true;
    }
    
    return false;
}

final function bool IsData(KVP data, int time)
{
    // subtraction is more resistant to integer overflow than just doing a < operator
    if( data.expiration - time < 0 ) return false;
    if( data.key == "" ) return false;
    if( data.value == "" ) return false;
    return true;
}

final function bool SetKVP(out KVP data, coerce string key, coerce string value, int expire_seconds, int time)
{
    data.key = key;
    data.value = value;
    data.created = time;
    data.expiration = expire_seconds + data.created;
    return true;
}

final function BindConn(int slot_a, int slot_b, out string val, bool writing)
{
    if( writing )
        conns[slot_a*6 + slot_b] = val;
    else
        val = conns[slot_a*6 + slot_b];
}

defaultproperties
{
    bDisplayableInv=False
    ItemName="DataStorage"
    bHidden=True
    Physics=PHYS_None
}
