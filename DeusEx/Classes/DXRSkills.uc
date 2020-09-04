class DXRSkills extends DXRBase;

struct SkillCostMultiplier {
    var class<Skill> type;//you can use Class'DeusEx.Skill' to make it apply to all skills
    var int percent;//percent to multiply, stacks
    var int minLevel;//the first skill level this adjustment will apply to
    var int maxLevel;//the highest skill level this adjustment will apply to
};

var config SkillCostMultiplier SkillCostMultipliers[16];

function CheckConfig()
{
    local int i;
    if( config_version == 0 ) {
        for(i=0; i < ArrayCount(SkillCostMultipliers); i++) {
            SkillCostMultipliers[i].type = None;
            SkillCostMultipliers[i].percent = 100;
            SkillCostMultipliers[i].minLevel = 1;
            SkillCostMultipliers[i].maxLevel = ArrayCount(class'Skill'.default.Cost);
        }
    }
    Super.CheckConfig();
}

function AnyEntry()
{
    Super.AnyEntry();
    RandoSkills();
}

function RandoSkills()
{
    local Skill aSkill;
    local int i, m;
    local int percent;
    local float f;
    local SkillCostMultiplier scm;

    l("randomizing skills with seed " $ dxr.seed $ ", min: "$dxr.flags.minskill$", max: "$dxr.flags.maxskill);
    dxr.SetSeed(dxr.seed);

    if( dxr.flags.minskill > dxr.flags.maxskill ) dxr.flags.maxskill = dxr.flags.minskill;

    aSkill = dxr.Player.SkillSystem.FirstSkill;
    while(aSkill != None)
    {
        percent = rng(dxr.flags.maxskill - dxr.flags.minskill + 1) + dxr.flags.minskill;
        l( aSkill $ " percent: "$percent$"%");
        for(i=0; i<arrayCount(aSkill.Cost); i++)
        {
            f = float(aSkill.default.Cost[i]) * float(percent) / 100.0;
            for(m=0; m < ArrayCount(SkillCostMultipliers); m++) {
                scm = SkillCostMultipliers[m];
                if( scm.type == None ) continue;
                if( aSkill.IsA(scm.type.name) && i+1 >= scm.minLevel && i < scm.maxLevel ) {
                    f *= float(scm.percent) / 100.0;
                }
            }
            aSkill.Cost[i] = int(f);
        }
        aSkill = aSkill.next;
    }
}
