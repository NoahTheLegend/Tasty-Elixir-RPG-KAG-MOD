
#include "SkillsCommon.as";
#include "StatEffectsCommon.as";

void onInit(CBlob@ this)
{
    this.addCommandID("receive_skill");
    this.addCommandID("take_skill");
    this.addCommandID("activate_skill");

    this.set_string("skill1", "");
    this.set_string("skill2", "");
    this.set_string("skill3", "");
    this.set_string("skill4", "");
    this.set_string("skill5", "");

    this.set_string("skilltype1", "");
    this.set_string("skilltype2", "");
    this.set_string("skilltype3", "");
    this.set_string("skilltype4", "");
    this.set_string("skilltype5", "");

    this.set_u8("skillpos1", 1);
    this.set_u8("skillpos2", 2);
    this.set_u8("skillpos3", 3);
    this.set_u8("skillpos4", 4);
    this.set_u8("skillpos5", 5);

    this.set_u16("skillidx1", 255);
    this.set_u16("skillidx2", 255);
    this.set_u16("skillidx3", 255);
    this.set_u16("skillidx4", 255);
    this.set_u16("skillidx5", 255);

    this.set_u16("skillcd1", 0);
    this.set_u16("skillcd2", 0);
    this.set_u16("skillcd3", 0);
    this.set_u16("skillcd4", 0);
    this.set_u16("skillcd5", 0);

    this.set_u16("skillmaxcd1", 0);
    this.set_u16("skillmaxcd2", 0);
    this.set_u16("skillmaxcd3", 0);
    this.set_u16("skillmaxcd4", 0);
    this.set_u16("skillmaxcd5", 0);

    //give skills. Causes *some command not found*. Probably because writing string in params?
	DoInitGiveAway(this);
}

void DoInitGiveAway(CBlob@ this)
{
    if (this.getName() == "knight")
    {
        CBitStream params;
        params.write_string("knight");
        params.write_u16(0);
        this.SendCommand(this.getCommandID("receive_skill"), params);
    }
    else if (this.getName() == "archer")
    {
        CBitStream params;
        params.write_string("archer");
        params.write_u16(0);
        this.SendCommand(this.getCommandID("receive_skill"), params);
    }
    else if (this.getName() == "rogue")
    {
        CBitStream params;
        params.write_string("rogue");
        params.write_u16(0);
        this.SendCommand(this.getCommandID("receive_skill"), params);
    }
}

void onTick(CBlob@ this)
{
    CPlayer@ player = this.getPlayer();
	if (this.getTickSinceCreated() == 60 && player !is null)
	{
    	if (this.getPlayer().isMod())
    	{
    	    CBitStream params;
    	    params.write_string("common");
    	    params.write_u16(0);
    	    this.SendCommand(this.getCommandID("receive_skill"), params);
    	}
	}
    
    //if (getGameTime()%90==0)printf("skilltimer: "+getSkillTime(this.getName(), this.get_u16("skillidx1")));
    if (getGameTime() % 30 == 0)
    {
        if (this.get_u16("skillcd1") > 0) this.set_u16("skillcd1", this.get_u16("skillcd1") - 30);
        else if (this.get_u16("skillcd") != 0)
        {
            this.set_u16("skillcd", 0);
        }
        if (this.get_u16("skillcd2") > 0) this.set_u16("skillcd2", this.get_u16("skillcd2") - 30);
        else if (this.get_u16("skillcd") != 0)
        {
            this.set_u16("skillcd", 0);
        }
        if (this.get_u16("skillcd3") > 0) this.set_u16("skillcd3", this.get_u16("skillcd3") - 30);
        else if (this.get_u16("skillcd") != 0)
        {
            this.set_u16("skillcd", 0);
        }
        if (this.get_u16("skillcd4") > 0) this.set_u16("skillcd4", this.get_u16("skillcd4") - 30);
        else if (this.get_u16("skillcd") != 0)
        {
            this.set_u16("skillcd", 0);
        }
        if (this.get_u16("skillcd5") > 0) this.set_u16("skillcd5", this.get_u16("skillcd5") - 30);
        else if (this.get_u16("skillcd") != 0)
        {
            this.set_u16("skillcd", 0);
        }
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
    if (cmd == this.getCommandID("activate_skill"))
    {
        string type = params.read_string(); // skill type
        u8 index = params.read_u8(); // skill pos
        u16 skill = params.read_u16(); // skill tag\index\number

        if (type == "knight")
        {
            this.set_string("skilltype", "knight");
            this.Sync("skilltype", true);
        }
        else if (type == "archer")
        {
            this.set_string("skilltype", "archer");
            this.Sync("skilltype", true);
        }
        else if (type == "rogue")
        {
            this.set_string("skilltype", "rogue");
            this.Sync("skilltype", true);
        }
        else if (type == "common")
        {
            this.set_string("skilltype", "common");
            this.Sync("skilltype", true);
        }

        if (this.get_u16("mana") > getSkillMana(this.get_string("skilltype"), skill))
        {
            this.set_u16("mana", this.get_u16("mana") - getSkillMana(this.get_string("skilltype"), skill));
            this.Sync("mana", true);
        }
        else return;

        string name = getSkillName(this.get_string("skilltype"), skill);
        u16 cooldown = getSkillCooldown(this.get_string("skilltype"), skill);
        u16 time = getSkillTime(this.get_string("skilltype"), skill);
        u8 skillpos = getSkillPosition(this, name);
        
        //printf(name);
        //printf(""+skillpos);
        //printf(""+index);
        //printf(this.get_string("skilltype"));

        if (this.get_string("skilltype") == "knight")
        {
            switch(skill)
            {
                case 0:
                {
                    SetToFreeSlot(this, skillpos, "shieldblock`bool`true_blockchance`f32`50");
                    break;
                }
                case 1: break;
                case 2: break;
                case 3: break;
                case 4: break;
            }
        }
        else if (this.get_string("skilltype") == "archer")
        {
            switch(skill)
            {
                case 0:
                {
                    SetToFreeSlot(this, skillpos, "concentration`bool`true_damagebuff`f32`2.0");
                    break;
                }
                case 1: break;
                case 2: break;
                case 3: break;
                case 4: break;
            }
        }
        else if (this.get_string("skilltype") == "rogue")
        {  
            switch(skill)
            {
                case 0:
                {
                    SetToFreeSlot(this, skillpos, "silence`bool`true_critchance`f32`500");
                    if (this.getHealth() < 2.0)
                    {
                        this.set_u16("silenceskilltimer", 5*30);
                        this.Sync("silenceskilltimer", true);
                        this.set_f32("velocity", this.get_f32("velocity")+0.75);
                        this.Sync("velocity", true);
                    }
                    break;
                }
                case 1: break;
                case 2: break;
                case 3: break;
                case 4: break;
            }
        }
        else if (this.get_string("skilltype") == "common")
        {
            switch(skill)
            {
                case 0:
                {
                    SetToFreeSlot(this, skillpos, "damagereduction`f32`0.5");
                    break;
                }
                case 1: break;
                case 2: break;
                case 3: break;
                case 4: break;
            }
        }
    }
    else if (cmd == this.getCommandID("receive_skill"))
    { // made giving more open but messy in code, because i will want to see a knight w rogue skills
        string type = params.read_string();
        u16 skill = params.read_u16();

        if (type == "knight")
        {
            this.set_string("skilltype", "knight");
            this.Sync("skilltype", true);
        }
        else if (type == "archer")
        {
            this.set_string("skilltype", "archer");
            this.Sync("skilltype", true);
        }
        else if (type == "rogue")
        {
            this.set_string("skilltype", "rogue");
            this.Sync("skilltype", true);
        }
        else if (type == "common")
        {
            this.set_string("skilltype", "common");
            this.Sync("skilltype", true);
        }

        if (this !is null)
        {
            if (this.get_string("skill1") == "")
            {
                string name = getSkillName(this.get_string("skilltype"), skill);
                u16 cooldown = getSkillCooldown(this.get_string("skilltype"), skill);
                this.set_string("skill1", name);
                this.Sync("skill1", true);
                this.set_u16("skillidx1", skill);
                this.Sync("skillidx1", true);
                this.set_u16("skillmaxcd1", cooldown);
                this.set_string("skilltype1", this.get_string("skilltype"));
                this.Sync("skilltype1", true);
            }
            else if (this.get_string("skill2") == "")
            {
                string name = getSkillName(this.get_string("skilltype"), skill);
                u16 cooldown = getSkillCooldown(this.get_string("skilltype"), skill);
                this.set_string("skill2", name);
                this.Sync("skill2", true);
                this.set_u16("skillidx2", skill);
                this.Sync("skillidx2", true);
                this.set_u16("skillmaxcd2", cooldown);
                this.set_string("skilltype2", this.get_string("skilltype"));
                this.Sync("skilltype2", true);
            }
            else if (this.get_string("skill3") == "")
            {
                string name = getSkillName(this.get_string("skilltype"), skill);
                u16 cooldown = getSkillCooldown(this.get_string("skilltype"), skill);
                this.set_string("skill3", name);
                this.Sync("skill3", true);
                this.set_u16("skillidx3", skill);
                this.Sync("skillidx3", true);
                this.set_u16("skillmaxcd3", cooldown);
                this.set_string("skilltype3", this.get_string("skilltype"));
                this.Sync("skilltype3", true);
            }
            else if (this.get_string("skill4") == "")
            {
                string name = getSkillName(this.get_string("skilltype"), skill);
                u16 cooldown = getSkillCooldown(this.get_string("skilltype"), skill);
                this.set_string("skill4", name);
                this.Sync("skill4", true);
                this.set_u16("skillidx4", skill);
                this.Sync("skillidx4", true);
                this.set_u16("skillmaxcd4", cooldown);
                this.set_string("skilltype4", this.get_string("skilltype"));
                this.Sync("skilltype4", true);
            }
            else if (this.get_string("skill5") == "")
            {
                string name = getSkillName(this.get_string("skilltype"), skill);
                u16 cooldown = getSkillCooldown(this.get_string("skilltype"), skill);
                this.set_string("skill5", name);
                this.Sync("skill5", true);
                this.set_u16("skillidx5", skill);
                this.Sync("skillidx5", true);
                this.set_u16("skillmaxcd5", cooldown);
                this.set_string("skilltype5", this.get_string("skilltype"));
                this.Sync("skilltype5", true);
            }
        }
    }
    else if (cmd == this.getCommandID("take_skill"))
    {

    }
}

u8 getEffectIndex(string name, u16 skiidx)
{
    if (name == "knight")
    {
        switch(skiidx)
        {
            case 0: return 5;
        }
    }
    else if (name == "archer")
    {
        switch(skiidx)
        {
            case 0: return 6;
        }
    }
    else if (name == "rogue")
    {
        switch(skiidx)
        {
            case 0: return 7;
        }
    }
    else if (name == "common")
    {
        switch(skiidx)
        {
            case 0: return 8;
        }
    }
    return 255;
}

void SetToFreeSlot(CBlob@ this, u8 skillpos, string buffs)
{
    if (this.get_string("eff1") == "")
    {
        u16 indexs = this.get_u16("skillidx"+skillpos);
        string name = getSkillName(this.get_string("skilltype"+skillpos), indexs);
        this.set_string("eff1", getEffectIndex(this.get_string("skilltype"+skillpos), indexs)+"_"+name);
        this.set_string("buffs1", buffs);
        this.set_u16("timer1", getSkillTime(this.get_string("skilltype"+skillpos), indexs));
        this.set_u16("skillcd"+skillpos, getSkillCooldown(this.get_string("skilltype"+skillpos), indexs));

        SetBuffs(this, buffs);
    }
    else if (this.get_string("eff2") == "")
    {
        u16 indexs = this.get_u16("skillidx"+skillpos);
        string name = getSkillName(this.get_string("skilltype"+skillpos), indexs);
        this.set_string("eff2", getEffectIndex(this.get_string("skilltype"+skillpos), indexs)+"_"+name);
        this.set_string("buffs2", buffs);
        this.set_u16("timer2", getSkillTime(this.get_string("skilltype"+skillpos), indexs));
        this.set_u16("skillcd"+skillpos, getSkillCooldown(this.get_string("skilltype"+skillpos), indexs));

        SetBuffs(this, buffs);
    }
    else if (this.get_string("eff3") == "")
    {
        u16 indexs = this.get_u16("skillidx"+skillpos);
        string name = getSkillName(this.get_string("skilltype"+skillpos), indexs);
        this.set_string("eff3", getEffectIndex(this.get_string("skilltype"+skillpos), indexs)+"_"+name);
        this.set_string("buffs3", buffs);
        this.set_u16("timer3", getSkillTime(this.get_string("skilltype"+skillpos), indexs));
        this.set_u16("skillcd"+skillpos, getSkillCooldown(this.get_string("skilltype"+skillpos), indexs));

        SetBuffs(this, buffs);
    }
    else if (this.get_string("eff4") == "")
    {
        u16 indexs = this.get_u16("skillidx"+skillpos);
        string name = getSkillName(this.get_string("skilltype"+skillpos), indexs);
        this.set_string("eff4", getEffectIndex(this.get_string("skilltype"+skillpos), indexs)+"_"+name);
        this.set_string("buffs4", buffs);
        this.set_u16("timer4", getSkillTime(this.get_string("skilltype"+skillpos), indexs));
        this.set_u16("skillcd"+skillpos, getSkillCooldown(this.get_string("skilltype"+skillpos), indexs));

        SetBuffs(this, buffs);
    }
    else if (this.get_string("eff5") == "")
    {
        u16 indexs = this.get_u16("skillidx"+skillpos);
        string name = getSkillName(this.get_string("skilltype"+skillpos), indexs);
        this.set_string("eff5", getEffectIndex(this.get_string("skilltype"+skillpos), indexs)+"_"+name);
        this.set_string("buffs5", buffs);
        this.set_u16("timer5", getSkillTime(this.get_string("skilltype"+skillpos), indexs));
        this.set_u16("skillcd"+skillpos, getSkillCooldown(this.get_string("skilltype"+skillpos), indexs));

        SetBuffs(this, buffs);
    }
    else if (this.get_string("eff6") == "")
    {
        u16 indexs = this.get_u16("skillidx"+skillpos);
        string name = getSkillName(this.get_string("skilltype"+skillpos), indexs);
        this.set_string("eff6", getEffectIndex(this.get_string("skilltype"+skillpos), indexs)+"_"+name);
        this.set_string("buffs6", buffs);
        this.set_u16("timer6", getSkillTime(this.get_string("skilltype"+skillpos), indexs));
        this.set_u16("skillcd"+skillpos, getSkillCooldown(this.get_string("skilltype"+skillpos), indexs));

        SetBuffs(this, buffs);
    }
    else if (this.get_string("eff7") == "")
    {
        u16 indexs = this.get_u16("skillidx"+skillpos);
        string name = getSkillName(this.get_string("skilltype"+skillpos), indexs);
        this.set_string("eff7", getEffectIndex(this.get_string("skilltype"+skillpos), indexs)+"_"+name);
        this.set_string("buffs7", buffs);
        this.set_u16("timer7", getSkillTime(this.get_string("skilltype"+skillpos), indexs));
        this.set_u16("skillcd"+skillpos, getSkillCooldown(this.get_string("skilltype"+skillpos), indexs));

        SetBuffs(this, buffs);
    }
    else if (this.get_string("eff8") == "")
    {
        u16 indexs = this.get_u16("skillidx"+skillpos);
        string name = getSkillName(this.get_string("skilltype"+skillpos), indexs);
        this.set_string("eff8", getEffectIndex(this.get_string("skilltype"+skillpos), indexs)+"_"+name);
        this.set_string("buffs8", buffs);
        this.set_u16("timer8", getSkillTime(this.get_string("skilltype"+skillpos), indexs));
        this.set_u16("skillcd"+skillpos, getSkillCooldown(this.get_string("skilltype"+skillpos), indexs));

        SetBuffs(this, buffs);
    }
    else if (this.get_string("eff9") == "")
    {
        u16 indexs = this.get_u16("skillidx"+skillpos);
        string name = getSkillName(this.get_string("skilltype"+skillpos), indexs);
        this.set_string("eff9", getEffectIndex(this.get_string("skilltype"+skillpos), indexs)+"_"+name);
        this.set_string("buffs9", buffs);
        this.set_u16("timer9", getSkillTime(this.get_string("skilltype"+skillpos), indexs));
        this.set_u16("skillcd"+skillpos, getSkillCooldown(this.get_string("skilltype"+skillpos), indexs));

        SetBuffs(this, buffs);
    }
    else if (this.get_string("eff10") == "")
    {
        u16 indexs = this.get_u16("skillidx"+skillpos);
        string name = getSkillName(this.get_string("skilltype"+skillpos), indexs);
        this.set_string("eff10", getEffectIndex(this.get_string("skilltype"+skillpos), indexs)+"_"+name);
        this.set_string("buffs10", buffs);
        this.set_u16("timer10", getSkillTime(this.get_string("skilltype"+skillpos), indexs));
        this.set_u16("skillcd"+skillpos, getSkillCooldown(this.get_string("skilltype"+skillpos), indexs));

        SetBuffs(this, buffs);
    }
}

void SetBuffs(CBlob@ this, string buffs)
{
    string[] spl = buffs.split("_");

    string[] splitb1;
    string[] splitb2;
    string[] splitb3;

    if (spl.length > 0) splitb1 = spl[0].split("`");
    if (spl.length > 1) splitb2 = spl[1].split("`");
    if (spl.length > 2) splitb3 = spl[2].split("`");

    if (splitb1.length > 0)
    {
        if (splitb1[1] == "bool")
        {
            this.set_bool(splitb1[0], true);
        }
        else if (splitb1[1] == "u16")
        {
            this.set_u16(splitb1[0], this.get_u16(splitb1[0]) + parseFloat(splitb1[2]));
        }
        else if (splitb1[1] == "f32")
        {
            this.set_f32(splitb1[0], this.get_f32(splitb1[0]) + parseFloat(splitb1[2]));
        }
    }
    if (splitb2.length > 0)
    {
        if (splitb2[1] == "bool")
        {
            this.set_bool(splitb2[0], true);
        }
        else if (splitb2[1] == "u16")
        {
            this.set_u16(splitb2[0], this.get_u16(splitb2[0]) + parseFloat(splitb2[2]));
        }
        else if (splitb2[1] == "f32")
        {
            this.set_f32(splitb2[0], this.get_f32(splitb2[0]) + parseFloat(splitb2[2]));
        }
    }
    if (splitb3.length > 0)
    {
        if (splitb3[1] == "bool")
        {
            this.set_bool(splitb3[0], true);
        }
        else if (splitb3[1] == "u16")
        {
            this.set_u16(splitb3[0], this.get_u16(splitb3[0]) + parseFloat(splitb3[2]));
        }
        else if (splitb3[1] == "f32")
        {
            this.set_f32(splitb3[0], this.get_f32(splitb3[0]) + parseFloat(splitb3[2]));
        }
    }
}

void onRender(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob is null || !blob.isMyPlayer()) return;

    //printf(""+index1);
    //printf(blob.get_string("eff1"));
    //printf(blob.get_string("skill1"));
    
    u16 scrwidth = getDriver().getScreenWidth();
    u16 scrheight = getDriver().getScreenHeight();

    if (blob.get_string("skill1") != "") 
    {
        float cooldown = blob.get_u16("skillcd1");
        float maxcooldown = blob.get_u16("skillmaxcd1");
        u16 index = blob.get_u16("skillidx1");
        f32 res = (100*cooldown/maxcooldown)/2;

        GUI::DrawIcon(getSkillIcon(blob.get_string("skilltype1"), index), 0, Vec2f(48,48), Vec2f(scrwidth/2-scrwidth/4, scrheight-100), 0.5f);
        GUI::DrawRectangle(Vec2f(scrwidth/2-scrwidth/4, scrheight-50-res), Vec2f(scrwidth/2-scrwidth/4+48, scrheight-100+48), SColor(100, 255,255,255));
    }
    if (blob.get_string("skill2") != "")
    {
        float cooldown = blob.get_u16("skillcd2");
        float maxcooldown = blob.get_u16("skillmaxcd2");
        u16 index = blob.get_u16("skillidx2");
        f32 res = (100*cooldown/maxcooldown)/2;

        GUI::DrawIcon(getSkillIcon(blob.get_string("skilltype2"), index), 0, Vec2f(48,48), Vec2f(scrwidth/2-scrwidth/4+64, scrheight-100), 0.5f);
        GUI::DrawRectangle(Vec2f(scrwidth/2-scrwidth/4+64, scrheight-50-res), Vec2f(scrwidth/2-scrwidth/4+48+64, scrheight-100+48), SColor(100, 255,255,255));
    }
    if (blob.get_string("skill3") != "")
    {
        float cooldown = blob.get_u16("skillcd3");
        float maxcooldown = blob.get_u16("skillmaxcd3");
        u16 index = blob.get_u16("skillidx3");
        f32 res = (100*cooldown/maxcooldown)/2;

        GUI::DrawIcon(getSkillIcon(blob.get_string("skilltype3"), index), 0, Vec2f(48,48), Vec2f(scrwidth/2-scrwidth/4+128, scrheight-100), 0.5f);
        GUI::DrawRectangle(Vec2f(scrwidth/2-scrwidth/4+128, scrheight-50-res), Vec2f(scrwidth/2-scrwidth/4+48+128, scrheight-100+48), SColor(100, 255,255,255));
    }
    if (blob.get_string("skill4") != "")
    {
        float cooldown = blob.get_u16("skillcd4");
        float maxcooldown = blob.get_u16("skillmaxcd4");
        u16 index = blob.get_u16("skillidx4");
        f32 res = (100*cooldown/maxcooldown)/2;

        GUI::DrawIcon(getSkillIcon(blob.get_string("skilltype4"), index), 0, Vec2f(48,48), Vec2f(scrwidth/2-scrwidth/4+192, scrheight-100), 0.5f);
        GUI::DrawRectangle(Vec2f(scrwidth/2-scrwidth/4+192, scrheight-50-res), Vec2f(scrwidth/2-scrwidth/4+48+192, scrheight-100+48), SColor(100, 255,255,255));
    }
    if (blob.get_string("skill5") != "")
    {
        float cooldown = blob.get_u16("skillcd5");
        float maxcooldown = blob.get_u16("skillmaxcd5");
        u16 index = blob.get_u16("skillidx5");
        f32 res = (100*cooldown/maxcooldown)/2;

        GUI::DrawIcon(getSkillIcon(blob.get_string("skilltyp5e"), index), 0, Vec2f(48,48), Vec2f(scrwidth/2-scrwidth/4+256, scrheight-100), 0.5f);
        GUI::DrawRectangle(Vec2f(scrwidth/2-scrwidth/4+256, scrheight-50-res), Vec2f(scrwidth/2-scrwidth/4+48+256, scrheight-100+48), SColor(100, 255,255,255));
    }

    if (blob !is null)
    {
        GUI::SetFont("menu");
        if (blob.get_u16("skillidx1") != 255 && isMouseOverEffect(Vec2f(scrwidth/2-scrwidth/4, scrheight-100)))
        {
           GUI::DrawText(""+getSkillDescription(blob.get_string("skilltype1"), blob.get_u16("skillidx1")), Vec2f(scrwidth/2-scrwidth/4 - 70, scrheight-175), SColor(255,255,255,255));
        }
        else if (blob.get_u16("skillidx2") != 255 && isMouseOverEffect(Vec2f(scrwidth/2-scrwidth/4+64, scrheight-100)))
        {
           GUI::DrawText(""+getSkillDescription(blob.get_string("skilltype2"), blob.get_u16("skillidx2")), Vec2f(scrwidth/2-scrwidth/4+64 - 70, scrheight-175), SColor(255,255,255,255));
        }
        else if (blob.get_u16("skillidx3") != 255 && isMouseOverEffect(Vec2f(scrwidth/2-scrwidth/4+128, scrheight-100)))
        {
           GUI::DrawText(""+getSkillDescription(blob.get_string("skilltype3"), blob.get_u16("skillidx3")), Vec2f(scrwidth/2-scrwidth/4+128 - 70, scrheight-175), SColor(255,255,255,255));
        }
        else if (blob.get_u16("skillidx4") != 255 && isMouseOverEffect(Vec2f(scrwidth/2-scrwidth/4+192, scrheight-100)))
        {
           GUI::DrawText(""+getSkillDescription(blob.get_string("skilltype4"), blob.get_u16("skillidx4")), Vec2f(scrwidth/2-scrwidth/4+192 - 70, scrheight-175), SColor(255,255,255,255));
        }
        else if (blob.get_u16("skillidx5") != 255 && isMouseOverEffect(Vec2f(scrwidth/2-scrwidth/4+256, scrheight-100)))
        {
           GUI::DrawText(""+getSkillDescription(blob.get_string("skilltype5"), blob.get_u16("skillidx5")), Vec2f(scrwidth/2-scrwidth/4+256 - 70, scrheight-175), SColor(255,255,255,255));
        }
    }
}

bool isMouseOverEffect(Vec2f offset)
{
	Vec2f mousePos = getControls().getMouseScreenPos();
	Vec2f effectPos = offset;

    if (mousePos.x >= effectPos.x-16 && mousePos.x <= effectPos.x + 48+16
    && mousePos.y >= effectPos.y-16 && mousePos.y <= effectPos.y + 48+16) return true;
    else return false;
}