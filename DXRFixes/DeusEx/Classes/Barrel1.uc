class Barrel1 injects Barrel1;

event TravelPreAccept()
{
    Super.TravelPreAccept();
    if( HandleTravel() )
        BeginPlay();
}

function bool HandleTravel()
{
    local DeusExPlayer player;
    local name skin_name;

    foreach AllActors(class'DeusExPlayer', player) { break; }
    if( player == None || player.CarriedDecoration != Self ) {
        return false;
    }

    skin_name = player.flagbase.GetName('barrel1_skin');
    if( skin_name == '' ) {
        return false;
    }

    SetPropertyText("SkinColor", string(skin_name) );
    player.flagbase.SetName('barrel1_skin', '',, -999);
    return true;
}

function PreTravel()
{
    local DeusExPlayer player;
    local name skin_name;

    foreach AllActors(class'DeusExPlayer', player) { break; }
    if( player != None && player.CarriedDecoration == Self ) {
        skin_name = player.rootWindow.StringToName(GetPropertyText("SkinColor"));
        player.flagbase.SetName('barrel1_skin', skin_name,, 999);
    }
}

auto state Active
{
}
