
#include "SkillsCommon.as";
#include "StatEffectsCommon.as";
#include "KnockedCommon.as";

void onInit(CBlob@ this)
{
    this.addCommandID("receive_skill");
    this.addCommandID("take_skill");
    this.addCommandID("activate_skill");
    this.addCommandID("check");

    for (u8 i = 0; i <= 21; ++i)
    {
        this.set_string("skill"+i, "");
        this.set_string("skilltype"+i, "");
        this.set_u8("skillpos"+i, i);
        this.set_u16("skillidx"+i, 255);
        this.set_u16("skillcd"+i, 0);
        this.set_u16("skillmaxcd"+i, 0);
    }
}

u16[] pskills = {

};

void DoInitGiveAway(CBlob@ this)
{
    CPlayer@ player = this.getPlayer();
    if (player !is null && player.isMyPlayer())
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
        	if (player !is null)

		//set skills
		for (u8 i = 0; i < 20; i++)
		{
            u16 ski = player.get_u16("hasskill"+i);
			if (ski > 0 && ski < 255)
			{
                bool skip;
				for (u8 i = 0; i < pskills.length; i++)
                {
                    if (ski == pskills[i]) skip = true;
                }
                if (skip) continue;
                pskills.push_back(ski);
            }
		}
    }
}

void onTick(CBlob@ this)
{
    CPlayer@ player = this.getPlayer();

    if (this.getTickSinceCreated() == 30 && player !is null && player.isMyPlayer())
	{
        //give skills. Causes *some command not found*. Probably because writing string in params?
	    DoInitGiveAway(this);

        CBitStream params;
        params.write_string("common");
        params.write_u16(0);
        this.SendCommand(this.getCommandID("receive_skill"), params);
	}

    if (pskills.length > 0)
    {
        CBitStream params;
        params.write_string(this.getName());
        params.write_u16(pskills[0]);
        this.SendCommand(this.getCommandID("receive_skill"), params);    
        pskills.erase(0);
    }
    
    //if (getGameTime()%90==0)printf("skilltimer: "+getSkillTime(this.getName(), this.get_u16("skillidx1")));
    if (getGameTime() % 30 == 0)
    {
        for (u8 i = 0; i <= 20; ++i)
        {
            if (this.get_u16("skillcd"+i) > 0) this.set_u16("skillcd"+i, this.get_u16("skillcd"+i) - 30);
            else if (this.get_u16("skillcd"+i) != 0)
            {
                this.set_u16("skillcd"+i, 0);
            }
        }
    }
}

void SetToFreeSkillSlot(CBlob@ this, u8 idx, u16 skill)
{
    this.Tag("has"+getSkillName(this.get_string("skilltype"), skill));
    string name = getSkillName(this.get_string("skilltype"), skill);
    u16 cooldown = getSkillCooldown(this.get_string("skilltype"), skill);
    this.set_string("skill"+idx, name);
    this.Sync("skill"+idx, true);
    this.set_u16("skillidx"+idx, skill);
    this.Sync("skillidx"+idx, true);
    this.set_u16("skillmaxcd"+idx, cooldown);
    this.Sync("skillmaxcd"+idx, true);
    this.set_string("skilltype"+idx, this.get_string("skilltype"));
    this.Sync("skilltype"+idx, true);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
    if (cmd == this.getCommandID("activate_skill"))
    {
        string type = params.read_string(); // skill type
        u8 index = params.read_u8(); // skill pos
        u16 skill = params.read_u16(); // skill tag\index\number

        this.set_string("skilltype", type);
        this.Sync("skilltype", true);

        if (this.get_u16("mana") > getSkillMana(this.get_string("skilltype"), skill) && isServer())
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
                    SetToFreeSlot(this, skillpos, "shieldblock`bool`true_blockchance`f32`25");
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
                    if (this.getHealth() < 1.0)
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

        //printf("type: "+type);
        //printf("skill: "+getSkillName(this.getName(), skill));

        //if (this.hasTag("has"+getSkillName(this.get_string("skilltype"), skill))) return;
        this.set_string("skilltype", type);
        this.Sync("skilltype", true);

        for (u8 i = 1; i <= 20; i++)
        {
            if (this.get_string("skill"+i) == "")
            {
                //printf("skill "+skill);
                SetToFreeSkillSlot(this, i, skill);
                return;
            }
        }
    }
    else if (cmd == this.getCommandID("take_skill"))
    {
        u8 pos = params.read_u8();

        this.set_string("skill"+pos, "");
        this.set_string("skilltype"+pos, "");
        this.set_u16("skillidx"+pos, 255);
        this.set_u16("skillcd"+pos, 0);
        this.set_u16("skillmaxcd"+pos, 0);
    }
}

u8 getEffectIndex(string name, u16 skiidx)
{
    if (name == "knight")
    {
        switch(skiidx)
        {
            case 0: return 5;
            case 1: return 9;
            case 2: return 10;
            case 3: return 11;
            case 4: return 12;
            case 5: return 13;
            case 6: return 14;
            case 7: return 15;
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

void SetEffects(CBlob@ this, u8 skillpos, string buffs, u8 idx)
{
    u16 indexs = this.get_u16("skillidx"+skillpos);
    string name = getSkillName(this.get_string("skilltype"+skillpos), indexs);
    if (isServer())
    {
        this.set_string("eff"+idx, getEffectIndex(this.get_string("skilltype"+skillpos), indexs)+"_"+name);
        this.set_string("buffs"+idx, buffs);
        this.set_u16("timer"+idx, getSkillTime(this.get_string("skilltype"+skillpos), indexs));
    }
    this.Sync("eff"+idx, true);
    this.Sync("buffs"+idx, true);
    this.Sync("timer"+idx, true);

    SetBuffs(this, buffs);
}

void SetToFreeSlot(CBlob@ this, u8 skillpos, string buffs)
{
    CPlayer@ player = this.getPlayer();
    if (player is null) return;

    if (this.get_string("eff1") == "")
        SetEffects(this, skillpos, buffs, 1);
    else if (this.get_string("eff2") == "")
        SetEffects(this, skillpos, buffs, 2);
    else if (this.get_string("eff3") == "")
        SetEffects(this, skillpos, buffs, 3);
    else if (this.get_string("eff4") == "")
        SetEffects(this, skillpos, buffs, 4);
    else if (this.get_string("eff5") == "")
        SetEffects(this, skillpos, buffs, 5);
    else if (this.get_string("eff6") == "")
        SetEffects(this, skillpos, buffs, 6);
    else if (this.get_string("eff7") == "")
        SetEffects(this, skillpos, buffs, 7);
    else if (this.get_string("eff8") == "")
        SetEffects(this, skillpos, buffs, 8);
    else if (this.get_string("eff9") == "")
        SetEffects(this, skillpos, buffs, 9);
    else if (this.get_string("eff10") == "")
        SetEffects(this, skillpos, buffs, 10);
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
        this.Sync(splitb1[0], true);
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
        this.Sync(splitb2[0], true);
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
        this.Sync(splitb3[0], true);
    }
}

const u16 scrwidth = getDriver().getScreenWidth();
const u16 scrheight = getDriver().getScreenHeight();

const Vec2f mid = Vec2f(scrwidth/2-24, scrheight/2-48); // - 24 cuz icons dimensions are 48x48

const Vec2f[] wheel_elem_poses = {
    Vec2f(0, -102)+mid,
    Vec2f(64, -48)+mid,
    Vec2f(120, 24)+mid,
    Vec2f(64, 96)+mid,
    Vec2f(0, 160)+mid,
    Vec2f(-64, 96)+mid,
    Vec2f(-120, 24)+mid,
    Vec2f(-64, -48)+mid,
    Vec2f(0, -196)+mid,
    Vec2f(88, -140)+mid,
    Vec2f(164, -76)+mid,
    Vec2f(216, 24)+mid,
    Vec2f(164, 124)+mid,
    Vec2f(88, 188)+mid,
    Vec2f(0, 248)+mid,
    Vec2f(-88, 188)+mid,
    Vec2f(-164, 124)+mid,
    Vec2f(-216, 24)+mid,
    Vec2f(-164, -76)+mid,
    Vec2f(-88, -140)+mid
};

bool isMouseOverSkillWheelElem(Vec2f mp, Vec2f pos, u8 size, u8 tolerance)
{
    if (mp.x >= pos.x-tolerance && mp.y >= pos.y-tolerance
    && mp.x <= pos.x+size+tolerance && mp.y <= pos.y+size+tolerance) return true;
    return false;
}

void DrawSkillWheel(CBlob@ this, Vec2f mousePos, f32 scale)
{
    string[] wskills;
    for (u8 i = 1; i <= 20; i++)
    {
        wskills.push_back(this.get_string("skill"+i));
    }

    SetScreenFlash(125, 0,0,0 , 0.1f);
    
    for (u8 i = 0; i < wskills.length; i++)
    {
        string skillname = wskills[i];
        Vec2f pos;
        
        pos = wheel_elem_poses[i];

        if (i == 0) 
        {
            //printf("x: "+pos.x+" y: "+pos.y);
            //printf(skillname);
        }
        string[] split = skillname.split(" "); // split and reconstruct if there is a space between words
        string name;
        if (split.length == 2) name = split[0]+split[1];
        else name = skillname;
        if (name != "") GUI::DrawIcon(name+"Icon.png", 0, Vec2f(48,48), Vec2f(pos), scale);

        if (isMouseOverSkillWheelElem(mousePos, pos, 48, 6))
        {
            GUI::DrawRectangle(pos-Vec2f(8,8), pos+Vec2f(48+8,48+8), SColor(100,255,255,255));
            //if (!this.hasTag("lockWheelSound"))
            //{
            //    this.Tag("lockWheelSound");
            //    this.getSprite().PlaySound("select.ogg");
            //}
        }
        else this.Untag("lockWheelSound");
    }
}

void RenderSkills(CSprite@ this, u8 idx, u16 offsetx, u16 offsety)
{
    CBlob@ blob = this.getBlob();
    if (blob is null || !blob.isMyPlayer()) return;

    Vec2f mousePos = getControls().getMouseScreenPos();

    bool mouseOnPos1 = (mousePos.x >= scrwidth/2-scrwidth/4-8 && mousePos.y >= scrheight-100 && mousePos.x <= scrwidth/2-scrwidth/4+48+8 && mousePos.y <= scrheight-100+48);
    bool mouseOnPos2 = (mousePos.x >= scrwidth/2-scrwidth/4+64-8 && mousePos.y >= scrheight-100 && mousePos.x <= scrwidth/2-scrwidth/4+48+64+8 && mousePos.y <= scrheight-100+48);
    bool mouseOnPos3 = (mousePos.x >= scrwidth/2-scrwidth/4+64*2-8 && mousePos.y >= scrheight-100 && mousePos.x <= scrwidth/2-scrwidth/4+48+64*2+8 && mousePos.y <= scrheight-100+48);
    bool mouseOnPos4 = (mousePos.x >= scrwidth/2-scrwidth/4+64*3-8 && mousePos.y >= scrheight-100 && mousePos.x <= scrwidth/2-scrwidth/4+48+64*3+8 && mousePos.y <= scrheight-100+48);
    bool mouseOnPos5 = (mousePos.x >= scrwidth/2-scrwidth/4+64*4-8 && mousePos.y >= scrheight-100 && mousePos.x <= scrwidth/2-scrwidth/4+48+64*4+8 && mousePos.y <= scrheight-100+48);
    bool mouseOnPos6 = (mousePos.x >= scrwidth/2-scrwidth/4+64*5-8 && mousePos.y >= scrheight-100 && mousePos.x <= scrwidth/2-scrwidth/4+48+64*5+8 && mousePos.y <= scrheight-100+48);
    bool mouseOnPos7 = (mousePos.x >= scrwidth/2-scrwidth/4+64*6-8 && mousePos.y >= scrheight-100 && mousePos.x <= scrwidth/2-scrwidth/4+48+64*6+8 && mousePos.y <= scrheight-100+48);
    bool mouseOnPos8 = (mousePos.x >= scrwidth/2-scrwidth/4+64*7-8 && mousePos.y >= scrheight-100 && mousePos.x <= scrwidth/2-scrwidth/4+48+64*7+8 && mousePos.y <= scrheight-100+48);
    bool mouseOnPos9 = (mousePos.x >= scrwidth/2-scrwidth/4+64*8-8 && mousePos.y >= scrheight-100 && mousePos.x <= scrwidth/2-scrwidth/4+48+64*8+8 && mousePos.y <= scrheight-100+48);
    bool mouseOnPos10 = (mousePos.x >= scrwidth/2-scrwidth/4+64*9-8 && mousePos.y >= scrheight-100 && mousePos.x <= scrwidth/2-scrwidth/4+48+64*9+8 && mousePos.y <= scrheight-100+48);
    bool mouseOnPos11 = (mousePos.x >= scrwidth/2-scrwidth/4-8 && mousePos.y >= scrheight-164 && mousePos.x <= scrwidth/2-scrwidth/4+48+8 && mousePos.y <= scrheight-164+48);
    bool mouseOnPos12 = (mousePos.x >= scrwidth/2-scrwidth/4+64-8 && mousePos.y >= scrheight-164 && mousePos.x <= scrwidth/2-scrwidth/4+48+64+8 && mousePos.y <= scrheight-164+48);
    bool mouseOnPos13 = (mousePos.x >= scrwidth/2-scrwidth/4+64*2-8 && mousePos.y >= scrheight-164 && mousePos.x <= scrwidth/2-scrwidth/4+48+64*2+8 && mousePos.y <= scrheight-164+48);
    bool mouseOnPos14 = (mousePos.x >= scrwidth/2-scrwidth/4+64*3-8 && mousePos.y >= scrheight-164 && mousePos.x <= scrwidth/2-scrwidth/4+48+64*3+8 && mousePos.y <= scrheight-164+48);
    bool mouseOnPos15 = (mousePos.x >= scrwidth/2-scrwidth/4+64*4-8 && mousePos.y >= scrheight-164 && mousePos.x <= scrwidth/2-scrwidth/4+48+64*4+8 && mousePos.y <= scrheight-164+48);
    bool mouseOnPos16 = (mousePos.x >= scrwidth/2-scrwidth/4+64*5-8 && mousePos.y >= scrheight-164 && mousePos.x <= scrwidth/2-scrwidth/4+48+64*5+8 && mousePos.y <= scrheight-164+48);
    bool mouseOnPos17 = (mousePos.x >= scrwidth/2-scrwidth/4+64*6-8 && mousePos.y >= scrheight-164 && mousePos.x <= scrwidth/2-scrwidth/4+48+64*6+8 && mousePos.y <= scrheight-164+48);
    bool mouseOnPos18 = (mousePos.x >= scrwidth/2-scrwidth/4+64*7-8 && mousePos.y >= scrheight-164 && mousePos.x <= scrwidth/2-scrwidth/4+48+64*7+8 && mousePos.y <= scrheight-164+48);
    bool mouseOnPos19 = (mousePos.x >= scrwidth/2-scrwidth/4+64*8-8 && mousePos.y >= scrheight-164 && mousePos.x <= scrwidth/2-scrwidth/4+48+64*8+8 && mousePos.y <= scrheight-164+48);
    bool mouseOnPos20 = (mousePos.x >= scrwidth/2-scrwidth/4+64*9-8 && mousePos.y >= scrheight-164 && mousePos.x <= scrwidth/2-scrwidth/4+48+64*9+8 && mousePos.y <= scrheight-164+48);

    bool mouseOnAnyPos = mouseOnPos1 || mouseOnPos2 || mouseOnPos3 || mouseOnPos4 || mouseOnPos5 || mouseOnPos6 || mouseOnPos8 || mouseOnPos9 || mouseOnPos10 || mouseOnPos11 || mouseOnPos12 || mouseOnPos13 || mouseOnPos14 || mouseOnPos15 || mouseOnPos16 || mouseOnPos17 || mouseOnPos18 || mouseOnPos19 || mouseOnPos20;
    if (mouseOnAnyPos && blob.isKeyPressed(key_action1))
    {
        blob.Tag("noAttack");
        //printf(""+blob.hasTag("noAttack"));
    }
    else
    {
        blob.Untag("noAttack");
        //printf(""+blob.hasTag("noAttack"));
    }
    
    //bool mouseOnPos = mouseOnPos1 || mouseOnPos2 || mouseOnPos3 || mouseOnPos4 || mouseOnPos5;
   
    if (blob.get_string("skill"+idx) != "")
    {
        float cooldown = blob.get_u16("skillcd"+idx);
        float maxcooldown = blob.get_u16("skillmaxcd"+idx);
        u16 index = blob.get_u16("skillidx"+idx);
        f32 res;
        if (maxcooldown > 0) res = (100*cooldown/maxcooldown)/2;

        switch (idx)
        {
            case 1:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos1)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
            case 2:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos2)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
            case 3:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos3)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
            case 4:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos4)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
            case 5:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos5)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
            case 6:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos6)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
            case 7:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos7)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
            case 8:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos8)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
            case 9:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos9)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
            case 10:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos10)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
            case 11:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos11)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
            case 12:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos12)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
            case 13:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos13)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
            case 14:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos14)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
            case 15:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos15)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
            case 16:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos16)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
            case 17:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos17)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
            case 18:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos18)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
            case 19:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos19)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
            case 20:
            {
                if (blob.isKeyJustPressed(key_action1)
                && mouseOnPos20)
                    blob.set_bool("skillholding"+idx, true);
                break;
            }
        }
        
        if (blob.isKeyJustReleased(key_action1))
        {
            blob.set_bool("skillholding"+idx, false);
        }

        if (blob.get_bool("skillholding"+idx))
        {
            u8 pos = 0;
            if (mouseOnPos1) pos = 1;
            else if (mouseOnPos2) pos = 2;
            else if (mouseOnPos3) pos = 3;
            else if (mouseOnPos4) pos = 4;
            else if (mouseOnPos5) pos = 5;
            else if (mouseOnPos6) pos = 6;
            else if (mouseOnPos7) pos = 7;
            else if (mouseOnPos8) pos = 8;
            else if (mouseOnPos9) pos = 9;
            else if (mouseOnPos10) pos = 10;
            else if (mouseOnPos11) pos = 11;
            else if (mouseOnPos12) pos = 12;
            else if (mouseOnPos13) pos = 13;
            else if (mouseOnPos14) pos = 14;
            else if (mouseOnPos15) pos = 15;
            else if (mouseOnPos16) pos = 16;
            else if (mouseOnPos17) pos = 17;
            else if (mouseOnPos18) pos = 18;
            else if (mouseOnPos19) pos = 19;
            else if (mouseOnPos20) pos = 20;

            if (pos > 0)
            {
                DrawBars(blob);
                u16 offsety;
                if (pos <= 10) offsety = 0;
                else offsety = 64;
                GUI::DrawIcon(getSkillIcon(blob.get_string("skilltype"+idx), index), 0, Vec2f(48,48), Vec2f(mousePos.x-24, mousePos.y-24), 0.5f);
                GUI::DrawRectangle(Vec2f(mousePos.x-24, mousePos.y-24+50-res), Vec2f(mousePos.x+48-24, mousePos.y+48-24), SColor(100, 255,255,255));
                u8 sindex = idx;
                //printf(""+pos);
                blob.set_string("skill255", blob.get_string("skill"+pos));
                blob.set_string("skilltype255", blob.get_string("skilltype"+pos));
                blob.set_u16("skillidx255", blob.get_u16("skillidx"+pos));
                blob.set_u16("skillcd255", blob.get_u16("skillcd"+pos));
                blob.set_u16("skillmaxcd255", blob.get_u16("skillmaxcd"+pos));

                blob.set_string("skill"+pos, blob.get_string("skill"+sindex));
                blob.set_string("skilltype"+pos, blob.get_string("skilltype"+sindex));
                blob.set_u16("skillidx"+pos, blob.get_u16("skillidx"+sindex));
                blob.set_u16("skillcd"+pos, blob.get_u16("skillcd"+sindex));
                blob.set_u16("skillmaxcd"+pos, blob.get_u16("skillmaxcd"+sindex));

                blob.set_string("skill"+sindex, blob.get_string("skill255"));
                blob.set_string("skilltype"+sindex, blob.get_string("skilltype255"));
                blob.set_u16("skillidx"+sindex, blob.get_u16("skillidx255"));
                blob.set_u16("skillcd"+sindex, blob.get_u16("skillcd255"));
                blob.set_u16("skillmaxcd"+sindex, blob.get_u16("skillmaxcd255"));
            }
        }
        else
        {
            GUI::DrawIcon(getSkillIcon(blob.get_string("skilltype"+idx), index), 0, Vec2f(48,48), Vec2f(scrwidth/2-scrwidth/4+offsetx, scrheight-100-offsety), 0.5f);
            GUI::DrawRectangle(Vec2f(scrwidth/2-scrwidth/4+offsetx, scrheight-50-res-offsety), Vec2f(scrwidth/2-scrwidth/4+48+offsetx, scrheight-100+48-offsety), SColor(100, 255,255,255));
        }
    }
}

void DrawBars(CBlob@ blob)
{
    GUI::DrawRectangle(Vec2f(scrwidth/2-scrwidth/4, scrheight-100), Vec2f(scrwidth/2-scrwidth/4+48+69*8.35, scrheight-100+48), SColor(100, 255,255,0));
    GUI::DrawRectangle(Vec2f(scrwidth/2-scrwidth/4, scrheight-164), Vec2f(scrwidth/2-scrwidth/4+48+69*8.35, scrheight-164+48), SColor(100, 255,255,0));
}

void onRender(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob is null || !blob.isMyPlayer()) return;
    CPlayer@ player = blob.getPlayer();
    if (player is null || !player.isMyPlayer()) return;

    Vec2f mousePos = getControls().getMouseScreenPos();
    CControls@ controls = blob.getControls();
    if (controls !is null)
    {
        if (controls.isKeyPressed(KEY_KEY_V))
        {
            DrawSkillWheel(blob, mousePos, 0.5);
            controls.setCameraLock(true);
        }
        else if (controls.isKeyJustReleased(KEY_KEY_V))
        {
            for (u8 i = 0; i < wheel_elem_poses.length; ++i)
            {
                if (isMouseOverSkillWheelElem(mousePos, wheel_elem_poses[i], 48, 6))
                {
                    u8 index = getSkillPosition(blob, blob.get_string("skill"+(i+1)));
                    if (blob.get_string("skill"+index) == "") continue; // skip if slot is empty, causing some problems
                    ActivateSkill(blob, index);
                    //printf("index "+index);
                    //printf("skill "+blob.get_string("skill"+index));
                }
            }
        }
        else 
        {
            controls.setCameraLock(false);
        }
    }

    if (blob.get_string("skill1") != "") 
        RenderSkills(this, 1, 0, 0);
    if (blob.get_string("skill2") != "") 
        RenderSkills(this, 2, 64, 0);
    if (blob.get_string("skill3") != "") 
        RenderSkills(this, 3, 64*2, 0);
    if (blob.get_string("skill4") != "") 
        RenderSkills(this, 4, 64*3, 0);
    if (blob.get_string("skill5") != "") 
        RenderSkills(this, 5, 64*4, 0);
    if (blob.get_string("skill6") != "") 
        RenderSkills(this, 6, 64*5, 0);
    if (blob.get_string("skill7") != "") 
        RenderSkills(this, 7, 64*6, 0);
    if (blob.get_string("skill8") != "") 
        RenderSkills(this, 8, 64*7, 0);
    if (blob.get_string("skill9") != "") 
        RenderSkills(this, 9, 64*8, 0);
    if (blob.get_string("skill10") != "") 
        RenderSkills(this, 10, 64*9, 0);
    if (blob.get_string("skill11") != "") 
        RenderSkills(this, 11, 0, 64);
    if (blob.get_string("skill12") != "") 
        RenderSkills(this, 12, 64, 64);
    if (blob.get_string("skill13") != "") 
        RenderSkills(this, 13, 64*2, 64);;
    if (blob.get_string("skill14") != "") 
        RenderSkills(this, 14, 64*3, 64);
    if (blob.get_string("skill15") != "") 
        RenderSkills(this, 15, 64*4, 64);
    if (blob.get_string("skill16") != "") 
        RenderSkills(this, 16, 64*5, 64);
    if (blob.get_string("skill17") != "") 
        RenderSkills(this, 17, 64*6, 64);
    if (blob.get_string("skill18") != "") 
        RenderSkills(this, 18, 64*7, 64);
    if (blob.get_string("skill19") != "") 
        RenderSkills(this, 19, 64*8, 64);
    if (blob.get_string("skill20") != "") 
        RenderSkills(this, 20, 64*9, 64);
    if (blob !is null && !blob.isKeyPressed(key_action1))
    {
        GUI::SetFont("menu");
        for (u8 i = 0; i <= 20; ++i)
        {
            DrawSkillDescription(blob, i, ManageRows(i), 64);
        }
    }
}

u16 ManageRows(u8 i)
{
    if (i <= 10) return 64*(i-1);
    else return 64*(i-1)-576;
}

void DrawSkillDescription(CBlob@ blob, u8 idx, u16 offsetx, u16 offsety)
{
    if (idx <= 10 && blob.get_u16("skillidx"+idx) != 255 && isMouseOverEffect(Vec2f(scrwidth/2-scrwidth/4+offsetx, scrheight-100)))
        GUI::DrawText(""+getSkillDescription(blob.get_string("skilltype"+idx), blob.get_u16("skillidx"+idx)), Vec2f(scrwidth/2-scrwidth/4+offsetx - 70, scrheight-175-64), SColor(255,255,255,255));
    else if (idx > 10 && blob.get_u16("skillidx"+idx) != 255 && isMouseOverEffect(Vec2f(scrwidth/2-scrwidth/4+offsetx-64, scrheight-164)))
        GUI::DrawText(""+getSkillDescription(blob.get_string("skilltype"+idx), blob.get_u16("skillidx"+idx)), Vec2f(scrwidth/2-scrwidth/4+offsetx-64 - 70, scrheight-175-64), SColor(255,255,255,255));
}

bool isMouseOverEffect(Vec2f offset)
{
	Vec2f mousePos = getControls().getMouseScreenPos();
	Vec2f effectPos = offset;

    if (mousePos.x >= effectPos.x-6 && mousePos.x <= effectPos.x + 48+6
    && mousePos.y >= effectPos.y-6 && mousePos.y <= effectPos.y + 48+6) return true;
    else return false;
}