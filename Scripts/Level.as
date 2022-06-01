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
            CBlob@[] blobs;
            CMap@ map = getMap();
            if (map is null) return;
            map.getBlobsInRadius(this.getPosition(), 400.0f, blobs);
            CBlob@[] players;
            for (u16 i = 0; i < blobs.length; i++)
            {
                if (blobs[i] is null) continue;
                if (blobs[i].getPlayer() !is null) players.push_back(blobs[i]);
            }

            u16[] levels;
            for (u8 i = 0; i < players.length; i++)
            {
                CPlayer@ p = players[i].getPlayer();
                levels.push_back(p.get_u16("level"));
                //printf(""+p.get_u16("level"));
            }

            u16 mod;
            for (u8 i = 0; i < levels.length; i++)
            {
                mod += levels[i];
            }
            mod /= levels.length;
            //printf("mod="+mod);

            if (isServer())
            {
                this.server_SetHealth(this.getInitialHealth()*mod/2);
                this.server_SetHealth(this.getHealth()-(XORRandom(this.getHealth()/2)));
                this.set_f32("damage_mod", mod/15);
                //printf("hp="+this.getHealth());
                //printf("damage_mod="+this.get_f32("damage_mod"));
            }
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
        player.set_u16("skillpoints", player.get_u16("skillpoints") + 1);
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