// Level.as is supposed to maintain levelling in game and skill\stat progression
u32[] progression = {
    100, 200, 350, 600, 900, 1200, 1600, 2000, 2500, 3000
};

void SetLevel(CBlob@ this, CPlayer@ player)
{
    if (player !is null)
    {
        string name = player.getUsername();
        CRules@ rules = getRules();
        if (rules is null) return;

        if (rules.get_u16(name+"level") != 0)
        {
            player.set_u16("level", rules.get_u16(name+"level"));
            //printf("blevel="+player.get_u16("level"));
            if (rules.get_u32(name+"exp") != 0)
            {
                player.set_u32("exp", rules.get_u32(name+"exp"));
                //printf("bexp="+player.get_u32("exp"));
            }
            player.set_u32("progressionstep", progression[player.get_u16("level")]);
        }
        else
        {
            ResetLevel(this, player);
        }
    }
    else
    {
        if (this.hasTag("mob"))
        {
            // mob modifications here
        }
    }
}

void LevelUpdate(CBlob@ this, CPlayer@ player)
{
    if (player.get_u16("level") >= progression.length)
    {
        //printf("e");
        return;
    }
    //player.set_u32("exp", player.get_u32("exp")+11);
    //if (getGameTime()%30==0)
    //{
    //    printf("exp="+player.get_u32("exp"));
    //    printf("level="+player.get_u16("level"));
    //}
    if (player.get_u32("exp") > progression[player.get_u16("level")])
    {
        player.set_u32("exp", player.get_u32("exp")-progression[player.get_u16("level")]);
        player.set_u16("level", player.get_u16("level")+1);
        player.set_u32("progressionstep", progression[player.get_u16("level")]);
        //printf(""+progression[player.get_u16("level")]);
        if (player.get_u32("exp") > 15000) player.set_u32("exp", 0);
    }
}

void ResetLevel(CBlob@ this, CPlayer@ player)
{
    player.set_u16("level", 0);
    player.set_u32("exp", 0);
    player.set_u32("progressionstep", progression[player.get_u16("level")]);
}

void ManageSkills(CBlob@ this, u8 index, string type, bool remove)
{
    if (!remove)
    {
        CBitStream params;
        params.write_string(type);
        params.write_u16(index);
        this.SendCommand(this.getCommandID("receive_skill"), params);
    }
    else
    {
        CBitStream params;
        params.write_string(type);
        params.write_u16(index);
        this.SendCommand(this.getCommandID("take_skill"), params);
    }
}