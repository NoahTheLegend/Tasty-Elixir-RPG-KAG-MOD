// Lantern script

#include "CustomBlocks.as";

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));
	this.addCommandID("light on");
	this.addCommandID("light off");
	AddIconToken("$lantern on$", "Lantern.png", Vec2f(8, 8), 0);
	AddIconToken("$lantern off$", "Lantern.png", Vec2f(8, 8), 3);

	this.Tag("dont deactivate");
	this.Tag("fire source");
	this.Tag("ignore_arrow");
	this.Tag("ignore fall");
}

void onTick(CBlob@ this)
{
	if (this.isLight() && this.isInWater())
	{
		Light(this, false);
	}
	if (getGameTime() % 30 == 0 && this.isLight())
	{
		CMap@ map = getMap();
		Tile tile = map.getTile(this.getPosition());
		if (this.isInInventory()
		|| tile.type == CMap::tile_inferno_ash_back
		|| tile.type == CMap::tile_inferno_ash_back_d0
		|| tile.type == CMap::tile_inferno_ash_back_d1
		|| tile.type == CMap::tile_inferno_ash_back_d2
		|| tile.type == CMap::tile_inferno_ash_back_d3
		|| tile.type == CMap::tile_inferno_ash_back_d4
		|| tile.type == CMap::tile_inferno_ash_back_d5
		|| tile.type == CMap::tile_inferno_ash_back_d6
		|| tile.type == CMap::tile_inferno_ash_back_d7
		|| tile.type == CMap::tile_inferno_ash_back_d8
		|| tile.type == CMap::tile_inferno_castle_back
		|| tile.type == CMap::tile_inferno_castle_back_d0
		|| tile.type == CMap::tile_inferno_castle_back_d1
		|| tile.type == CMap::tile_inferno_castle_back_d2
		|| tile.type == CMap::tile_inferno_castle_back_d3
		|| tile.type == CMap::tile_inferno_castle_back_d4
		|| tile.type == CMap::tile_inferno_castle_back_d5
		|| tile.type == CMap::tile_inferno_castle_back_d6
		|| tile.type == CMap::tile_inferno_castle_back_d7
		|| tile.type == CMap::tile_inferno_castle_back_d8)
		{
			Light(this, false);
		}
	}
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	Light(this, false);
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	Light(this, true);
}

void Light(CBlob@ this, bool on)
{
	if (!on)
	{
		this.SetLight(false);
		this.getSprite().SetAnimation("nofire");
	}
	else
	{
		this.SetLight(true);
		this.getSprite().SetAnimation("fire");
	}
	this.getSprite().PlaySound("SparkleShort.ogg");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate"))
	{
		Light(this, !this.isLight());
	}

}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    return blob.getShape().isStatic();
}
