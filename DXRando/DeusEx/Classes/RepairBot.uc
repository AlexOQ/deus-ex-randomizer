#ifdef injections
class DXRRepairBot merges RepairBot;
#else
class DXRRepairBot extends #var prefix RepairBot;
#endif

var int numUses;

function int ChargePlayer(DeusExPlayer PlayerToCharge)
{
    local int chargeAmount;

#ifdef injections
    chargeAmount = _ChargePlayer(PlayerToCharge);
#else
    chargeAmount = Super.ChargePlayer(PlayerToCharge);
#endif

    numUses++;

    return chargeAmount;
}

function int GetMaxUses()
{
    local DeusExPlayer p;

    foreach AllActors(class'DeusExPlayer', p){
        return p.flagBase.GetInt('Rando_repairbotuses');
    }

    return 0;
}

function int GetRemainingUses()
{
    return (GetMaxUses() - numUses);
}

function string GetRemainingUsesStr()
{
    local int uses;
    local string msg;

    uses = GetRemainingUses();

    if (uses == 1) {
        msg = " (1 Charges Left)";
    } else {
        msg = " ("$uses$" Charges Left)";
    }

    return msg;
}

function bool HasLimitedUses()
{
     return (GetMaxUses() != 0);
}

function bool ChargesRemaining()
{
    return GetRemainingUses()!=0;
}

function bool CanCharge()
{
#ifdef injections
    if (_CanCharge()) {
#else
    if (Super.CanCharge()) {
#endif
        if (HasLimitedUses()) {
            return (GetRemainingUses()>0);
        } else {
            return True;
        }
    } else {
        return False;
    }
}

function Float GetRefreshTimeRemaining()
{
    local int timeRemaining;

    timeRemaining = chargeRefreshTime - (Level.TimeSeconds - lastChargeTime);

    if (timeRemaining < 0) {
        timeRemaining = 0;
    }

    return timeRemaining;
}
