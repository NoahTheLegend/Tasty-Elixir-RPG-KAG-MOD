
shared class Spawner
{
    string theme;
    string[] mobs;
    u8 size; // 0 - small, 1 - medium, 2 - big

    u16 spawn_frequency;
    f32 activate_radius;
    f32 spawn_radius;
    u16 delay_after_activation; // to prevent instantly turning off when player is going away
    bool is_active;
    string file_name = "Spawners.png";
};

bool isActive(CBlob@ this)
{
    Spawner@ spawner;
    if (!this.get("spawnerInfo", @spawner))
	{
		return false;
	}

    CMap@ map = getMap();
    if (map is null) return false;

    // activate spawner
    CBlob@[] blobs;
    map.getBlobsInRadius(this.getPosition(), this.get_f32("activate_radius"), blobs);

    //if (getGameTime()%60==0) printf(""+this.get_f32("activate_radius");

    bool activate = false;

    for (u16 i = 0; i < blobs.length; i++)
    {
        if (blobs[i] is null) continue;
        if (blobs[i].hasTag("player")) activate = true;
    }

    return activate;
}

string defineBiome(CBlob@ this, Vec2f pos, CMap@ map)
{
    string biome = "basic";

    const TileType down = map.getTile(pos).type;

    if (map.isTileGround(map.getTile(pos+Vec2f(0, -24)).type) && map.isTileGrass(map.getTile(pos+Vec2f(0, -16)).type)) return "surface"; // 3 blocks lower = dirt, 2 blocks lower = grass

    if (down >= 32 && down <= 40) biome = "caves"; // dirt bg
    else if (down >= 64 && down <= 70 // stone bg & mossy stone bg
    || down >= 243 && down <= 247) biome = "castle";
    else if (down >= 448 && down <= 457 // ash bg
    || down >= 416 && down <= 431) biome = "inferno";
    else if (down >= 496 && down <= 506) biome = "abyss";

    return biome;
}