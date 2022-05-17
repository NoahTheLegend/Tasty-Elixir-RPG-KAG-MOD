#include "SpawnerCommon.as";

void onInit(CBlob@ this)
{
    this.Tag("spawner");
    this.addCommandID("spawn_mobs");

    Spawner@ spawner;
    this.set("spawnerInfo", @spawner);

    u8 rand = XORRandom(10); // define size
    if (rand < 5) //50% small 30% medium, 20% big
        this.set_u8("size", 0);
    else if (rand >= 5 && rand < 8)
        this.set_u8("size", 1);
    else
        this.set_u8("size", 2);

    CMap@ map = getMap();
    if (map !is null)
        this.set_string("theme", defineBiome(this, this.getPosition(), map));
    //printf(this.get_string("theme"));

    switch (this.get_u8("size"))
    {
        case 0:
        {
            if (theme == "surface")
            {

            }
            else if (theme == "caves")
            {

            }
            else if (theme == "castle")
            {
                mobs.push_back("skeleton");
                mobs.push_back("zombie");
            }
            else if (theme == "inferno")
            {

            }
            else if (theme == "abyss")
            {

            }
            else if (theme == "basic")
            {

            }
            else if (isServer()) this.server_Die();

            this.set_u16("spawn_frequency", 30*(XORRandom(11)+10)) // ticks, from 10 to 20 seconds
            this.set_f32("activate_radius", 128.0f) // 16 blocks
            this.set_f32("spawn_radius", 64.0f) // 8 blocks
            this.set_u16("delay_after_activation", 300); // 10 s
            this.set_bool("is_active", false);
            this.set_string("file_name", "Spawners.png");
            break;
        }
        case 1:
        {

        }
        case 2:
        {

        }
    }
}