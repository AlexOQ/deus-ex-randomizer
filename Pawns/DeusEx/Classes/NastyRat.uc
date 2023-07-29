//=============================================================================
// NastyRat.
//
// This is (at least for now) intended to only be spawned as a Crowd Control
// effect (simulated or real).
//=============================================================================
class NastyRat extends Rat;

var float CheckTime;
var float NextThrowTime;

var float ThrowFrequency;
var float CheckFrequency;

function Tick(float deltaSeconds)
{
    local Vector HitNormal, HitLocation, ThrowPoint;
    local #var(PlayerPawn) player;
    local Rotator Aim;

    if (CheckTime < Level.TimeSeconds) {
        if (CheckTime == 0.0) {
            //Don't throw a grenade the moment we spawn...
            NextThrowTime = Level.TimeSeconds + ThrowFrequency;
        }

        CheckTime = Level.TimeSeconds + CheckFrequency;

        if (NextThrowTime > Level.TimeSeconds){
            return;
        }

        foreach AllActors(class'#var(PlayerPawn)',player){break;}
        if (player==None){
            return;
        }

        //If the rat is close...
        if (VSize(player.Location - Location)<1000){
            if (Trace(HitLocation,HitNormal,player.Location,Location,True)==player){
                //... and it has line of sight
                ThrowPoint = Location + vect(0,0,20);
                Aim = rotator(player.Location - ThrowPoint);
                Spawn(PickAGrenade(),,,ThrowPoint,Aim);
                NextThrowTime = Level.TimeSeconds + ThrowFrequency;
            }

        }
    }
}

function class<Projectile> PickAGrenade()
{
    local int i;

    i = rand(4);

    switch(i){
        case 0:
            return class'LAM';
        case 1:
            return class'GasGrenade';
        case 2:
            return class'EMPGrenade';
        case 3:
            return class'NanoVirusGrenade';
    }
    log("ERROR:  NastyRat somehow didn't pick a valid grenade!  Rolled "$i);
    return class'GasGrenade';
}

function bool ShouldBeStartled(Pawn startler)
{
    return False;
}

defaultproperties
{
     CheckTime=0.00000
     NextThrowTime=0.0000
     ThrowFrequency=6.0
     CheckFrequency=2.0
     CollisionRadius=20.000000
     CollisionHeight=17.50000
     DrawScale=4.000000
     MinHealth=0
     HealthHead=150
     HealthTorso=150
     HealthLegLeft=150
     HealthLegRight=150
     HealthArmLeft=150
     HealthArmRight=150
     Health=150
     bFleeBigPawns=False
     bBlockActors=True
     bForceStasis=False
     Restlessness=1.00000
     Wanderlust=1.00000
     Orders=Shadowing
     MaxStepHeight=25.00000
     BaseEyeHeight=3.000000
     JumpZ=30.000000
     WalkingSpeed=1.0
     GroundSpeed=100.000000
     WaterSpeed=24.000000
     AirSpeed=60.000000
     Mass=30.000
     BindName="NastyRat"
     FamiliarName="Nasty Rat"
     UnfamiliarName="Nasty Rat"
     AttitudeToPlayer=ATTITUDE_Follow
}
