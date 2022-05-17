#include "SpawnerCommon.as";

string[] mobs;

void onInit(CBlob@ this)
{
    this.getCurrentScript().tickFrequency = 30;
    this.Tag("spawner");
    this.addCommandID("spawn_mobs");

    Spawner@ spawner;
    this.set("spawnerInfo", @spawner);

    u8 rand = XORRandom(10); // define size
    if (rand < 6) //60% small 30% medium, 10% big
        this.set_u8("size", 0);
    else if (rand >= 6 && rand < 9)
        this.set_u8("size", 1);
    else
        this.set_u8("size", 2);

    CMap@ map = getMap();
    if (map !is null)
        this.set_string("theme", defineBiome(this, this.getPosition(), map));
    //printf(this.get_string("theme"));

    this.set_bool("is_active", false);
    this.set_string("file_name", "Spawners.png");
    string theme = this.get_string("theme");
    switch (this.get_u8("size"))
    {
        case 0:
        {
            if (theme == "surface")
            {
                mobs.push_back("bison");
            }
            else if (theme == "caves")
            {

            }
            else if (theme == "castle")
            {
                mobs.push_back("skeleton");
                mobs.push_back("zombie");
                mobs.push_back("wraith");
            }
            else if (theme == "inferno")
            {

            }
            else if (theme == "abyss")
            {

            }
            else if (theme == "basic")
            {
                mobs.push_back("skeleton");
                mobs.push_back("zombie");
            }
            else if (isServer()) this.server_Die();

            this.set_u16("spawn_frequency", 30*(XORRandom(11)+10)); // ticks, from 10 to 20 seconds
            this.set_f32("activate_radius", 128.0f); // 16 blocks
            this.set_f32("spawn_radius", 128.0f); // 16 blocks
            this.set_u16("delay_after_activation", 450); // 15 s
            break;
        }
        case 1:
        {
            if (theme == "surface")
            {
                mobs.push_back("bison");
            }
            else if (theme == "caves")
            {
                mobs.push_back("skeleton");
                mobs.push_back("zombie");
            }
            else if (theme == "castle")
            {
                mobs.push_back("skeleton");
                mobs.push_back("zombie");
                mobs.push_back("zombieknight");
            }
            else if (theme == "inferno")
            {
                mobs.push_back("wraith");
            }
            else if (theme == "abyss")
            {

            }
            else if (theme == "basic")
            {
                mobs.push_back("skeleton");
                mobs.push_back("zombie");
            }
            else if (isServer()) this.server_Die();

            this.set_u16("spawn_frequency", 30*(XORRandom(16)+15)); // ticks, from 15 to 25 seconds
            this.set_f32("activate_radius", 192.0f); // 24 blocks
            this.set_f32("spawn_radius", 192.0f); // 24 blocks
            this.set_u16("delay_after_activation", 900); // 30 s
            break;
        }
        case 2:
        {
            if (theme == "surface")
            {
                mobs.push_back("bison");
            }
            else if (theme == "caves")
            {
                mobs.push_back("skeleton");
                mobs.push_back("zombie");
            }
            else if (theme == "castle")
            {
                mobs.push_back("skeleton");
                mobs.push_back("zombie");
                mobs.push_back("wraith");
                mobs.push_back("zombieknight");
                mobs.push_back("necromancer");
            }
            else if (theme == "inferno")
            {
                mobs.push_back("wraith");
            }
            else if (theme == "abyss")
            {

            }
            else if (theme == "basic")
            {
                mobs.push_back("skeleton");
                mobs.push_back("zombie");
                mobs.push_back("zombieknight");
            }
            else if (isServer()) this.server_Die();

            this.set_u16("spawn_frequency", 30*(XORRandom(21)+20)); // ticks, from 20 to 30 seconds
            this.set_f32("activate_radius", 384.0f); // 48 blocks
            this.set_f32("spawn_radius", 384.0f); // 48 blocks
            this.set_u16("delay_after_activation", 1800); // 60 s
            break;
        }
    }

    //printf("theme: "+theme);
    printf("size: "+this.get_u8("size"));
    //printf("spawn_frequency: "+this.get_u16("spawn_frequency"));
    //printf("activate_radius: "+this.get_f32("activate_radius"));
    //printf("spawn_radius: "+this.get_f32("spawn_radius"));

    this.set_u32("delay_timer", 0);
    this.set_u32("last_spawn", XORRandom(this.get_u16("spawn_frequency")));
}

void onTick(CBlob@ this) // 1 tick every second!
{
    Spawner@ spawner;
    if (!this.get("spawnerInfo", @spawner)) return;

    bool active = isActive(this);

    CBlob@[] limit;
    getBlobsByTag("LimitBy"+this.getNetworkID(), limit);
    if (limit.length > 0) return;

    bool activatedelay;
    s32 gametime = getGameTime();
    //printf(""+this.get_u32("delay_timer"));
    //printf(""+active);

    if (active) this.Tag("willdelay");

    if (active || this.get_u32("delay_timer") > gametime)
    {
        printf(""+this.get_u32("last_spawn"));
        if (this.get_u32("last_spawn") <= 30)
        {
            //printf("spawned?");
            SpawnMobs(this);
            this.set_u32("last_spawn", this.get_u16("spawn_frequency"));
        }
        else
        {
            if (this.get_u32("last_spawn") > 7500 || this.get_u32("last_spawn") < 0)
                this.set_u32("last_spawn", 0);
            this.set_u32("last_spawn", this.get_u32("last_spawn") - 30);
        }
    }
    else if (this.hasTag("willdelay"))
    {
        this.set_u32("delay_timer", gametime+this.get_u16("delay_after_activation"));
        this.Untag("willdelay");
        //printf("delayed");
    }
}

void SpawnMobs(CBlob@ this)
{
    f32 spawn_radius = this.get_f32("spawn_radius");
    u8 size = this.get_u8("size"); // define the size of the spawner (0 - small, 1 - medium, 2 - big)
    u8 modifier = size+2; // modifier

    for (u8 i = 0; i < modifier; i++)
    {
        for (u8 i = 0; i < mobs.length; i++)
        {
            if (XORRandom(10) < size) continue; // chance that depends on the spawner's size
            if (isServer()) 
            {
               CBlob@ blob = server_CreateBlob(mobs[i], 255, FindSpace(this, this.getPosition(), spawn_radius));
               blob.Tag("LimitBy"+this.getNetworkID());
            }
        }
    }
}

Vec2f FindSpace(CBlob@ this, Vec2f pos, f32 radius)
{
    CMap@ map = getMap();
    if (map is null) return pos;
    TileType tile = 1;

    while (tile != 0)
    {
        Vec2f find = pos+Vec2f(XORRandom(radius)-radius/2, XORRandom(radius/2)-radius/4);
        //printf("x: "+find.x+" y: "+find.y);
        tile = map.getTile(find).type;
        if (tile == 0)
            return find;
    }

    return pos;
}