class GasGrenade injects GasGrenade;

function SpawnCloudType(out class<Cloud> GasType, out Name tDamageType)
{
    GasType = class'PoisonGas';
    tDamageType = 'Poison';
    /* // mixed clouds, might be OP
    if (FRand() < 0.5)
    {
        GasType = class'PoisonGas';
        tDamageType = 'Poison';
    }
    else
    {
        GasType = class'TearGas';
        tDamageType = 'TearGas';
    }*/
}
