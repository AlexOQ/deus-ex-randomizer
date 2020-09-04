class DXRActorsBase extends DXRBase;

var globalconfig class<Actor> skipactor_types[6];

function CheckConfig()
{
    local class<Actor> temp_skipactor_types[6];
    local int i, t;
    if( config_version == 0 && skipactor_types[0] == None ) {
        for(i=0; i < ArrayCount(skipactor_types); i++) {
            skipactor_types[0] = None;
        }
        i=0;
        skipactor_types[i++] = class'BarrelAmbrosia';
        skipactor_types[i++] = class'BarrelVirus';
        skipactor_types[i++] = class'NanoKey';
    }
    Super.CheckConfig();

    //sort skipactor_types so that we only need to check until the first None
    t=0;
    for(i=0; i < ArrayCount(skipactor_types); i++) {
        if( skipactor_types[i] != None )
            temp_skipactor_types[t++] = skipactor_types[i];
    }
    for(i=0; i < ArrayCount(skipactor_types); i++) {
        skipactor_types[i] = temp_skipactor_types[i];
    }
}

function SwapAll(name classname)
{
    local Actor a, b;
    local int num, i, slot;

    SetSeed( "SwapAll " $ classname );
    num=0;
    foreach AllActors(class'Actor', a )
    {
        if( SkipActor(a, classname) ) continue;
        num++;
    }

    foreach AllActors(class'Actor', a )
    {
        if( SkipActor(a, classname) ) continue;

        i=0;
        slot=rng(num-1);
        foreach AllActors(class'Actor', b )
        {
            if( SkipActor(b, classname) ) continue;

            if(i==slot) {
                Swap(a, b);
                break;
            }
            i++;
        }
    }
}

function vector AbsEach(vector v)
{// not a real thing in math? but it's convenient
    v.X = abs(v.X);
    v.Y = abs(v.Y);
    v.Z = abs(v.Z);
    return v;
}

function bool AnyGreater(vector a, vector b)
{
    return a.X > b.X || a.Y > b.Y || a.Z > b.Z;
}

function bool CarriedItem(Actor a)
{// I need to check Engine.Inventory.bCarriedItem
    if( a == dxr.Player.carriedDecoration )
        return true;
    return a.Owner != None && a.Owner.IsA('Pawn');
}

function bool IsHuman(Actor a)
{
    return HumanMilitary(a) != None || HumanThug(a) != None || HumanCivilian(a) != None;
}

function bool HasItem(ScriptedPawn p, class c)
{
    local int i;
    
    for (i=0; i<ArrayCount(p.InitialInventory); i++)
    {
        if ((p.InitialInventory[i].Inventory != None) && (p.InitialInventory[i].Count > 0))
        {
            if( p.InitialInventory[i].Inventory.Class == c ) return True;
        }
    }
    return p.FindInventoryType(c) != None;
}

function bool SkipActorBase(Actor a)
{
    if( a == dxr.Player.carriedDecoration )
        return true;
    if( (a.Owner != None) || a.bStatic || a.bHidden || a.bMovable==False )
        return true;
    if( a.Base != None )
        return a.Base.IsA('ScriptedPawn');
    return false;
}

function bool SkipActor(Actor a, name classname)
{
    local int i;
    if( SkipActorBase(a) || ( ! a.IsA(classname) ) ) {
        return true;
    }
    for(i=0; i < ArrayCount(skipactor_types); i++) {
        if(skipactor_types[i] == None) break;
        if( a.IsA(skipactor_types[i].name) ) return true;
    }
    return false;
}

function Swap(Actor a, Actor b)
{
    local vector newloc;
    local rotator newrot;
    local bool asuccess, bsuccess;
    local Actor abase, bbase;
    local bool AbCollideActors, AbBlockActors, AbBlockPlayers, BbCollideActors, BbBlockActors, BbBlockPlayers;
    local EPhysics aphysics, bphysics;

    if( a == b ) return;

    //l("swapping "$ActorToString(a)$" and "$ActorToString(b));
    l("swapping "$ActorToString(a)$" and "$ActorToString(b)$" distance == " $ VSize(a.Location - b.Location) );

    // https://docs.unrealengine.com/udk/Two/ActorVariables.html#Advanced
    // native(262) final function SetCollision( optional bool NewColActors, optional bool NewBlockActors, optional bool NewBlockPlayers );
    AbCollideActors = a.bCollideActors;
    AbBlockActors = a.bBlockActors;
    AbBlockPlayers = a.bBlockPlayers;
    BbCollideActors = b.bCollideActors;
    BbBlockActors = b.bBlockActors;
    BbBlockPlayers = b.bBlockPlayers;
    a.SetCollision(false, false, false);
    b.SetCollision(false, false, false);

    newloc = b.Location + (a.CollisionHeight - b.CollisionHeight) * vect(0,0,1);
    newrot = b.Rotation;

    bsuccess = b.SetLocation(a.Location + (b.CollisionHeight - a.CollisionHeight) * vect(0,0,1) );
    b.SetRotation(a.Rotation);

    if( bsuccess == false )
        l("failed to move " $ ActorToString(b) $ " into location of " $ ActorToString(a) );

    asuccess = a.SetLocation(newloc);
    a.SetRotation(newrot);

    if( asuccess == false )
        l("failed to move " $ ActorToString(a) $ " into location of " $ ActorToString(b) );

    aphysics = a.Physics;
    bphysics = b.Physics;
    abase = a.Base;
    bbase = b.Base;

    if(asuccess)
    {
        a.SetPhysics(bphysics);
        if(abase != bbase) a.SetBase(bbase);
    }
    if(bsuccess)
    {
        b.SetPhysics(aphysics);
        if(abase != bbase) b.SetBase(abase);
    }

    a.SetCollision(AbCollideActors, AbBlockActors, AbBlockPlayers);
    b.SetCollision(BbCollideActors, BbBlockActors, BbBlockPlayers);
}

function bool DestroyActor( Actor d )
{
    // If this item is in an inventory chain, unlink it.
    local Decoration downer;

    if( d.IsA('Inventory') && d.Owner != None && d.Owner.IsA('Pawn') )
    {
        Pawn(d.Owner).DeleteInventory( Inventory(d) );
    }
    return d.Destroy();
}

function Actor ReplaceActor(Actor oldactor, string newclassstring)
{
    local Actor a;
    local class<Actor> newclass;
    local float scalefactor;
    local float largestDim;

    newclass = class<Actor>(DynamicLoadObject(newclassstring, class'class'));
    a = Spawn(newclass,,,oldactor.Location);

    //Get the scaling to match
    if (a.CollisionRadius > a.CollisionHeight) {
        largestDim = a.CollisionRadius;
    } else {
        largestDim = a.CollisionHeight;
    }
    scalefactor = oldactor.CollisionHeight/largestDim;
    
    //DrawScale doesn't work right for Inventory objects
    a.DrawScale = scalefactor;
    if (a.IsA('Inventory')) {
        Inventory(a).PickupViewScale = scalefactor;
    }
    
    //Floating decorations don't rotate
    if (a.IsA('DeusExDecoration')) {
        DeusExDecoration(a).bFloating = False;
    }
    
    //Get it at the right height
    a.move(a.PrePivot);
    oldactor.bHidden = true;
    oldactor.Destroy();

    return a;
}

function string ActorToString( Actor a )
{
    local string out;
    out = a.Class.Name$":"$a.Name$"("$a.Location$")";
    if( a.Base != None && a.Base.Class!=class'LevelInfo' )
        out = out $ "(Base:"$a.Base.Class$":"$a.Base.Name$")";
    return out;
}

function SetActorScale(Actor a, float scale)
{
    local bool AbCollideActors, AbBlockActors, AbBlockPlayers;
    local Vector newloc;
    
    AbCollideActors = a.bCollideActors;
    AbBlockActors = a.bBlockActors;
    AbBlockPlayers = a.bBlockPlayers;
    a.SetCollision(false, false, false);
    newloc = a.Location + ( (a.CollisionHeight*scale - a.CollisionHeight*a.DrawScale) * vect(0,0,1) );
    a.SetCollisionSize(a.CollisionRadius, a.CollisionHeight / a.DrawScale * scale);
    a.DrawScale = scale;
    a.SetLocation(newloc);
    a.SetCollision(AbCollideActors, AbBlockActors, AbBlockPlayers);
}

function Vector GetCenter(Actor test)
{
    local Vector MinVect, MaxVect;

    test.GetBoundingBox(MinVect, MaxVect);
    return (MinVect+MaxVect)/2;
}

function bool _PositionIsSafeOctant(Vector oldloc, Vector TestPoint, Vector newloc)
{
    local Vector distsold, diststest, distsoldtest;
    //l("results += testbool( _PositionIsSafeOctant(vect("$oldloc$"), vect("$ TestPoint $"), vect("$newloc$")), truefalse, \"test\");");
    distsoldtest = AbsEach(oldloc - TestPoint);
    distsold = AbsEach(newloc - oldloc) - (distsoldtest*0.999);
    diststest = AbsEach(newloc - TestPoint);
    if ( AnyGreater( distsold, diststest ) ) return False;
    return True;
}

function bool PositionIsSafe(Vector oldloc, Actor test, Vector newloc)
{// https://github.com/Die4Ever/deus-ex-randomizer/wiki#smarter-key-randomization
    local Vector TestPoint;
    local float distold, disttest;

    TestPoint = GetCenter(test);

    distold = VSize(newloc - oldloc);
    disttest = VSize(newloc - TestPoint);

    return _PositionIsSafeOctant(oldloc, TestPoint, newloc);
}

function bool PositionIsSafeLenient(Vector oldloc, Actor test, Vector newloc)
{// https://github.com/Die4Ever/deus-ex-randomizer/wiki#smarter-key-randomization
    return _PositionIsSafeOctant(oldloc, GetCenter(test), newloc);
}

defaultproperties
{
}
