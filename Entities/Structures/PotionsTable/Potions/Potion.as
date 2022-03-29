// should've move this mud into another file, but let it be

void onInit(CBlob@ this)
{
    this.set_string("buff1", "");
    this.set_string("buff2", "");
    this.set_string("buff3", "");
    this.set_bool("rip?", false);

    this.addCommandID("drinkpotion");

    string[] potionkeys = {
        this.get_string("key1"),
        this.get_string("key2"),
        this.get_string("key3"),
        this.get_string("key4"),
        this.get_string("key5"),
        this.get_string("key6"),
    };
    u8 rand = XORRandom(20);
    CSprite@ sprite = this.getSprite();
    Animation@ anim = sprite.addAnimation("potions", 0, false);
    int[] frames = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19};
    anim.AddFrames(frames);
    sprite.SetAnimation("potions");
    if (sprite !is null) sprite.SetFrameIndex(rand);
    this.inventoryIconFrame = rand;

    setEffect(this);
}
// (+DE)BUFFS NOTE:
// 
// damage reduction
// dodge chance
// strength (damage buff)
// crit chance
// velocity
// jump height
// max mana
// mana regen time
// hp regen time
//
// NOT DONE BUFFS YET, REQUIRES BUFFDEBUFF BAR (for some)
//
// attack speed
// armor (damagereduction) penetration
// vampirism
// glownesss
// gravity reducing
// stun/bash chance
// magic damage reduction
// inc crit chance / damage reduction
// 
void setEffect(CBlob@ this)
{
    if (this is null) return;

    string a1 = this.get_string("add1");
    string a2 = this.get_string("add2");
    string a3 = this.get_string("add3");
    string a4 = this.get_string("add4");

    string k1 = this.get_string("key1");
    string k2 = this.get_string("key2");
    string k3 = this.get_string("key3");
    string k4 = this.get_string("key4");
    string k5 = this.get_string("key5");
    string k6 = this.get_string("key6");

    CSprite@ sprite = this.getSprite();

    if (sprite !is null)
    {
        sprite.SetFrameIndex(XORRandom(20));
        this.inventoryIconFrame = XORRandom(20);
    }
    
    //printf(this.get_string("add1")+" - add1p");
	//printf(this.get_string("add2")+" - add2p");
	//printf(this.get_string("add3")+" - add3p");
	//printf(this.get_string("add4")+" - add4p");
	//printf(this.get_string("key1")+" - key1p");
	//printf(this.get_string("key2")+" - key2p");
	//printf(this.get_string("key3")+" - key3p");
	//printf(this.get_string("key4")+" - key4p");
	//printf(this.get_string("key5")+" - key5p");
	//printf(this.get_string("key6")+" - key6p");

    // buffs that are fit in their main category get x3 multiplier
    if (a1 == k1) // defining main buff type
    { // Strength
        if (a2 == k2) this.set_string("buff1", "damagebuff`f32`2.25"); //str
        else if (a2 == k3) this.set_string("buff1", "damagereduction`f32`0.50"); //def
        else if (a2 == k4) this.set_string("buff1", "velocity`f32`0.30"); //agi
        else if (a2 == k5) this.set_string("buff1", "glowness`bool`true"); //oth
        else if (a2 == k6) this.set_string("buff1", "damagebuff`f32`-1.0"); //deb
        else
        {
            u8 rand = XORRandom(3);

            switch (rand)
            {
                case 0: this.set_string("buff1", "glowness`bool`true"); //oth
                case 1: this.set_string("buff1", "poisoned`bool`true"); //deb
                case 2: this.set_string("buff1", "velocity`f32`0.50"); //agi
            }
        }
        if (a3 == k2) this.set_string("buff2", "critchance`f32`22.5"); //str
        else if (a3 == k3) this.set_string("buff2", "dodgechance`f32`7.5"); //def
        else if (a3 == k4) this.set_string("buff2", "jumpheight`f32`?"); //agi
        else if (a3 == k5) this.set_string("buff2", "manaregtime`f32`-60"); //oth
        else if (a3 == k6) this.set_string("buff2", "critchance`f32`-10"); //deb
        else
        {
            u8 rand = XORRandom(3);

            switch (rand)
            {
                case 0: this.set_string("buff2", "dodgechance`f32`7.5"); //def
                case 1: this.set_string("buff1", "poisoned`bool`true"); //deb
                case 2: this.set_string("buff3", "hpregtime`f32`-60"); //def
            }
        }
        if (a4 == k2) this.set_string("buff3", "attackspeed`f32`0.30"); //str
        else if (a4 == k3) this.set_string("buff3", "hpregtime`f32`-60"); //def
        else if (a4 == k4) this.set_string("buff3", "gravity`f32`-?"); //agi
        else if (a4 == k5) this.set_string("buff3", "vampirism-`f32`?"); //oth
        else if (a4 == k6) this.set_string("buff3", "attackspeed`f32`-0.50"); //deb
        else
        {
            u8 rand = XORRandom(3);

            switch (rand)
            {
                case 0: this.set_string("buff1", "damagereduction`f32`0.50"); //def
                case 1: this.set_string("buff1", "poisoned`bool`true"); //deb
                case 2: this.set_string("buff3", "vampirism`f32`?"); //oth
            }
        }
    }
    else if (a2 == k1)
    { // Defence
        if (a1 == k2) this.set_string("buff1", "damagebuff`f32`0.75"); //str
        else if (a1 == k3) this.set_string("buff1", "damagereduction`f32`1.50"); //def
        else if (a1 == k4) this.set_string("buff1", "velocity`f32`0.30"); //agi
        else if (a1 == k5) this.set_string("buff1", "glowness`bool`true"); //oth
        else if (a1 == k6) this.set_string("buff1", "damagereduction`f32`-1.0"); //deb
        else
        {
            u8 rand = XORRandom(3);

            switch (rand)
            {
                case 0: this.set_string("buff1", "damagereduction`f32`0.50"); //def
                case 1: this.set_string("buff1", "poisoned`bool`true"); //deb
                case 2: this.set_string("buff3", "vampirism`f32`?"); //oth
            }
        }
        if (a3 == k2) this.set_string("buff2", "critchance`f32`7.5"); //str
        else if (a3 == k3) this.set_string("buff2", "dodgechance`f32`22.5"); //def
        else if (a3 == k4) this.set_string("buff2", "jumpheight`f32`?"); //agi
        else if (a3 == k5) this.set_string("buff2", "manaregtime`f32`-60"); //oth
        else if (a3 == k6) this.set_string("buff2", "dodgechance`f32`-15.0"); //deb
        else
        {
            u8 rand = XORRandom(3);

            switch (rand)
            {
                case 0: this.set_string("buff1", "glowness`bool`true"); //oth
                case 1: this.set_string("buff1", "poisoned`bool`true"); //deb
                case 2: this.set_string("buff1", "velocity`f32`0.50"); //agi
            }
        }
        if (a4 == k2) this.set_string("buff3", "attackspeed`f32`0.10"); //str
        else if (a4 == k3) this.set_string("buff3", "hpregtime`f32`-180"); //def
        else if (a4 == k4) this.set_string("buff3", "gravity`f32`-?"); //agi
        else if (a4 == k5) this.set_string("buff3", "vampirism`f32`?"); //oth
        else if (a4 == k6) this.set_string("buff3", "hpregtime`f32`120"); //deb
        else
        {
            u8 rand = XORRandom(3);

            switch (rand)
            {
                case 0: this.set_string("buff2", "dodgechance`f32`7.5"); //def
                case 1: this.set_string("buff1", "poisoned`bool`true"); //deb
                case 2: this.set_string("buff3", "hpregtime`f32`-60"); //def
            }
        }
    }
    else if (a3 == k1)
    { // Agility
        if (a2 == k2) this.set_string("buff1", "damagebuff`f32`0.75"); //str
        else if (a2 == k3) this.set_string("buff1", "damagereduction`f32`0.50"); //def
        else if (a2 == k4) this.set_string("buff1", "velocity`f32`0.90"); //agi
        else if (a2 == k5) this.set_string("buff1", "glowness`bool`true"); //oth
        else if (a2 == k6) this.set_string("buff1", "velocity`f32`-0.60"); //deb
        else
        {
            u8 rand = XORRandom(3);

            switch (rand)
            {
                case 0: this.set_string("buff2", "dodgechance`f32`7.5"); //def
                case 1: this.set_string("buff1", "poisoned`bool`true"); //deb
                case 2: this.set_string("buff3", "hpregtime`f32`-60"); //def
            }
        }
        if (a1 == k2) this.set_string("buff2", "critchance`f32`7.5"); //str
        else if (a1 == k3) this.set_string("buff2", "dodgechance`f32`7.5"); //def
        else if (a1 == k4) this.set_string("buff2", "jumpheight`f32`?"); //agi
        else if (a1 == k5) this.set_string("buff2", "manaregtime`f32`-60"); //oth
        else if (a1 == k6) this.set_string("buff2", "jumpheight`f32`-?"); //deb
        else
        {
            u8 rand = XORRandom(3);

            switch (rand)
            {
                case 0: this.set_string("buff1", "glowness`bool`true"); //oth
                case 1: this.set_string("buff1", "poisoned`bool`true"); //deb
                case 2: this.set_string("buff1", "velocity`f32`0.50"); //agi
            }
        }
        if (a4 == k2) this.set_string("buff3", "attackspeed`f32`0.10"); //str
        else if (a4 == k3) this.set_string("buff3", "hpregtime`f32`-60"); //def
        else if (a4 == k4) this.set_string("buff3", "gravity`f32`-?"); //agi
        else if (a4 == k5) this.set_string("buff3", "vampirism`f32`?"); //oth
        else if (a4 == k6) this.set_string("buff3", "gravity`f32`?"); //deb
        else
        {
            u8 rand = XORRandom(3);

            switch (rand)
            {
                case 0: this.set_string("buff1", "damagereduction`f32`0.50"); //def
                case 1: this.set_string("buff1", "poisoned`bool`true"); //deb
                case 2: this.set_string("buff3", "vampirism`f32`?"); //oth
            }
        }
    }
    else if (a4 == k1)
    { // Other
        if (a2 == k2) this.set_string("buff1", "damagebuff`f32`0.75"); //str
        else if (a2 == k3) this.set_string("buff1", "damagereduction`f32`0.50"); //def
        else if (a2 == k4) this.set_string("buff1", "velocity`f32`0.30"); //agi
        else if (a2 == k5) this.set_string("buff1", "glowness2`bool`true"); //oth
        else if (a2 == k6) this.set_string("buff1", "poisoned`bool`true"); //deb
        else
        {
            u8 rand = XORRandom(3);

            switch (rand)
            {
                case 0: this.set_string("buff1", "damagereduction`f32`0.50"); //def
                case 1: this.set_string("buff1", "poisoned`bool`true"); //deb
                case 2: this.set_string("buff3", "vampirism`f32`?"); //oth
            }
        }
        if (a3 == k2) this.set_string("buff2", "critchance`f32`7.5"); //str
        else if (a3 == k3) this.set_string("buff2", "dodgechance`f32`7.5"); //def
        else if (a3 == k4) this.set_string("buff2", "jumpheight`f32`?"); //agi
        else if (a3 == k5) this.set_string("buff2", "manaregtime`f32`-180"); //oth
        else if (a3 == k6) this.set_string("buff2", "manaregtime`f32`120"); //deb
        else
        {
            u8 rand = XORRandom(3);

            switch (rand)
            {
                case 0: this.set_string("buff2", "dodgechance`f32`7.5"); //def
                case 1: this.set_string("buff1", "poisoned`bool`true"); //deb
                case 2: this.set_string("buff3", "hpregtime`f32`-60"); //def
            }
        }
        if (a1 == k2) this.set_string("buff3", "attackspeed`f32`0.10"); //str
        else if (a1 == k3) this.set_string("buff3", "hpregtime`f32`-60"); //def
        else if (a1 == k4) this.set_string("buff3", "gravity`f32`-?"); //agi
        else if (a1 == k5) this.set_string("buff3", "vampirism`f32`?"); //oth
        else if (a1 == k6) this.set_string("buff3", "isfish`bool`true"); //deb (waterbreathingonly)
        else
        {
            u8 rand = XORRandom(3);

            switch (rand)
            {
                case 0: this.set_string("buff1", "glowness`bool`true"); //oth
                case 1: this.set_string("buff1", "poisoned`bool`true"); //deb
                case 2: this.set_string("buff1", "velocity`f32`0.50"); //agi
            }
        }
    }
    else
    { // Debuff. Better luck next time!
        if (a1 == k5 || a1 == k6) this.set_string("buff1", "damagebuff`f32`-5.0"); //str
        else if (a2 == k5 || a2 == k6) this.set_string("buff2", "damagereduction`f32`-100.0"); //def
        else if (a3 == k5 || a3 == k6) this.set_string("buff1", "velocity`f32`-1.90"); //agi
        else if (a4 == k5 || a4 == k6) this.set_bool("rip?", true); //ded
    }
    //printf(this.get_string("buff1")+"_"+this.get_string("buff2")+"_"+this.get_string("buff3"));
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
    if (this is null || caller is null) return;
    if (!this.isAttached()) return;
    if (caller.hasTag("potioned")) return;

    CBitStream params;
    params.write_u16(caller.getNetworkID());
    params.write_string(this.get_string("buff1")+"_"+this.get_string("buff2")+"_"+this.get_string("buff3"));
    caller.CreateGenericButton("$"+this.getName()+"$", Vec2f(0, 0), this, this.getCommandID("drinkpotion"), "Drink " + this.getName(), params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
    if (cmd == this.getCommandID("drinkpotion"))
    {
        u16 blobid = params.read_u16();
        CBlob@ blob = getBlobByNetworkID(blobid);
        string buffs = params.read_string();

        if (blob !is null)
        {
            string[] spl = buffs.split("_"); // split buffs

            string buff1 = spl[0];
            string buff2 = spl[1];
            string buff3 = spl[2];

            string[] splb1 = buff1.split("`"); // split buffs into name & type & value
            string[] splb2 = buff2.split("`");
            string[] splb3 = buff3.split("`");

            string effdata;

            if (splb1[0] != "") effdata = effdata+splb1[0]+" "+splb1[2]+"`";
            if (splb2[0] != "") effdata = effdata+splb2[0]+" "+splb2[2]+"`";
            if (splb3[0] != "") effdata = effdata+splb3[0]+" "+splb3[2];

            if (blob.get_string("eff1") == "")
            {
                blob.set_string("eff1", "1_potion_"+effdata);
                blob.set_string("buffs1", buffs);
                blob.set_u16("timer1", spl.length * XORRandom(300) + XORRandom(1800)+900);
            }
            else if (blob.get_string("eff2") == "")
            {
                blob.set_string("eff2", "1_potion_"+effdata);
                blob.set_string("buffs2", buffs);
                blob.set_u16("timer2", spl.length * XORRandom(300) + XORRandom(1800)+900);
            }
            else if (blob.get_string("eff3") == "")
            {
                blob.set_string("eff3", "1_potion_"+effdata);
                blob.set_string("buffs3", buffs);
                blob.set_u16("timer3", spl.length * XORRandom(300) + XORRandom(1800)+900);
            }
            else if (blob.get_string("eff4") == "")
            {
                blob.set_string("eff4", "1_potion_"+effdata);
                blob.set_string("buffs4", buffs);
                blob.set_u16("timer4", spl.length * XORRandom(300) + XORRandom(1800)+900);
            }
            else if (blob.get_string("eff5") == "")
            {
                blob.set_string("eff5", "1_potion_"+effdata);
                blob.set_string("buffs5", buffs);
                blob.set_u16("timer5", spl.length * XORRandom(300) + XORRandom(1800)+900);
            }
            else if (blob.get_string("eff6") == "")
            {
                blob.set_string("eff6", "1_potion_"+effdata);
                blob.set_string("buffs6", buffs);
                blob.set_u16("timer6", spl.length * XORRandom(300) + XORRandom(1800)+900);
            }
            else if (blob.get_string("eff7") == "")
            {
                blob.set_string("eff7", "1_potion_"+effdata);
                blob.set_string("buffs7", buffs);
                blob.set_u16("timer7", spl.length * XORRandom(300) + XORRandom(1800)+900);
            }
            else if (blob.get_string("eff8") == "")
            {
                blob.set_string("eff8", "1_potion_"+effdata);
                blob.set_string("buffs8", buffs);
                blob.set_u16("timer8", spl.length * XORRandom(300) + XORRandom(1800)+900);
            }
            else if (blob.get_string("eff9") == "")
            {
                blob.set_string("eff9", "1_potion_"+effdata);
                blob.set_string("buffs9", buffs);
                blob.set_u16("timer9", spl.length * XORRandom(300) + XORRandom(1800)+900);
            }
            else if (blob.get_string("eff10") == "")
            {
                blob.set_string("eff10", "1_potion_"+effdata);
                blob.set_string("buffs10", buffs);
                blob.set_u16("timer10", spl.length * XORRandom(300) + XORRandom(1800)+900);
            }

            if (buff1 != "")
            {
                if (splb1[1] == "bool")
                {
                    blob.set_bool(splb1[0], true);
                }
                else if (splb1[1] == "u16")
                {
                    u16 stat = blob.get_f32(splb1[0]);
                    blob.set_u16(splb1[0], blob.get_u16(splb1[0]) + parseFloat(splb1[2]));
                    //if (blob.get_u16(splb1[0]) + parseFloat(splb1[2]) > 200 || blob.get_u16(splb1[0]) + parseFloat(splb1[2]) < 0)
                    //    blob.set_u16(splb1[0], stat);
                    //printf(blob.get_u16(splb1[0])+"");
                }
                else if (splb1[1] == "f32")
                {
                    f32 stat = blob.get_f32(splb1[0]);
                    blob.set_f32(splb1[0], blob.get_f32(splb1[0]) + parseFloat(splb1[2]));
                    //if (blob.get_f32(splb1[0]) + parseFloat(splb1[2]) > 200 || blob.get_f32(splb1[0]) + parseFloat(splb1[2]) < 0)
                    //    blob.set_f32(splb1[0], stat);
                    //printf(blob.get_f32(splb1[0])+"");
                }
                blob.Sync(splb1[0], true);
            }
            if (buff2 != "")
            {
                if (splb2[1] == "bool")
                {
                    blob.set_bool(splb2[0], true);
                }
                else if (splb2[1] == "u16")
                {
                    u16 stat = blob.get_f32(splb2[0]);
                    blob.set_u16(splb2[0], blob.get_u16(splb2[0]) + parseFloat(splb2[2]));
                    //if (blob.get_u16(splb2[0]) + parseFloat(splb2[2]) > 200 || blob.get_u16(splb2[0]) + parseFloat(splb2[2]) < 0)
                    //    blob.set_u16(splb2[0], stat);
                    //printf(blob.get_u16(splb2[0])+"");
                }
                else if (splb2[1] == "f32")
                {
                    f32 stat = blob.get_f32(splb2[0]);
                    blob.set_f32(splb2[0], blob.get_f32(splb2[0]) + parseFloat(splb2[2]));
                    //if (blob.get_f32(splb2[0]) > 500 || blob.get_f32(splb2[0]) < 0)
                    //    blob.set_f32(splb2[0], stat);
                    //printf(blob.get_f32(splb2[0])+"");
                }
                blob.Sync(splb2[0], true);
            }
            if (buff3 != "")
            {
                if (splb3[1] == "bool")
                {
                    blob.set_bool(splb3[0], true);
                }
                else if (splb3[1] == "u16")
                {
                    u16 stat = blob.get_f32(splb3[0]);
                    blob.set_u16(splb3[0], blob.get_u16(splb3[0]) + parseFloat(splb3[2]));
                    //if (blob.get_u16(splb3[0]) + parseFloat(splb3[2]) > 500 || blob.get_u16(splb3[0]) + parseFloat(splb3[2]) < 0)
                    //    blob.set_u16(splb3[0], stat);
                    //printf(blob.get_u16(splb3[0])+"");
                }
                else if (splb3[1] == "f32")
                {
                    f32 stat = blob.get_f32(splb3[0]);
                    blob.set_f32(splb3[0], blob.get_f32(splb3[0]) + parseFloat(splb3[2]));
                    //if (blob.get_f32(splb3[0]) + parseFloat(splb3[2]) > 500 || blob.get_f32(splb3[0]) + parseFloat(splb3[2]) < 0)
                    //    blob.set_f32(splb3[0], stat);
                    //printf(blob.get_f32(splb3[0])+"");
                }
                blob.Sync(splb3[0], true);


                if (this.get_bool("rip?")) blob.Tag("ded");
                blob.Tag("potioned");
            }
            blob.Tag("potioned");
            this.server_Die();
        }
    }
}