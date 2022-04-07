// LoaderUtilities.as

#include "DummyCommon.as";
#include "CustomBlocks.as";

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	if(map.getTile(offset).type > 255)
	{
		if (map.getTile(offset).type == CMap::tile_inferno_ash_back)
		{
			return false;
		}
		else if (map.getTile(offset).type == CMap::tile_inferno_ash)
		{
			return false;
		}
		else if (map.getTile(offset).type == CMap::tile_abyss_dirt)
		{
			return false;
		}
		else if (map.getTile(offset).type == CMap::tile_abyss_dirt_back)
		{
			return false;
		}
	}
	else if(isDummyTile(map.getTile(offset).type))
	{
		CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
		if(blob !is null)
		{
			blob.server_Die();
		}
	}
	return true;
}
/*
void DoLavaFill(u16 index, TileType up, TileType down, TileType left, TileType right, CMap@ map)
{ // also add some sounds && incibility for lava tile
	if (left == CMap::tile_lava_d0 || right == CMap::tile_lava_d0
	|| left == CMap::tile_lava_d1 || right == CMap::tile_lava_d1)
	{
		map.SetTile(index, CMap::tile_lava_d1);
	}

}
*/
TileType server_onTileHit(CMap@ map, f32 damage, u32 index, TileType oldTileType)
{
	if (map.getTile(index).type > 255)
	{
		/*if ((oldTileType != CMap::tile_empty && map.getTile(index).type == CMap::tile_empty)
		|| (oldTileType != CMap::tile_inferno_ash_back && map.getTile(index).type == CMap::tile_inferno_ash_back))
		{ // check if lava nearby
			printf("detected");
			const TileType up = map.getTile(index - map.tilemapwidth).type;
			const TileType down = map.getTile(index + map.tilemapwidth).type;
			const TileType left = map.getTile(index - 1).type;
			const TileType right = map.getTile(index + 1).type;

			DoLavaFill(index, up, down, left, right, map);
		}*/
		switch (oldTileType)
		{
			case CMap::tile_lava: // return CMap::tile_lava; // lava
			case CMap::tile_lava_d0: // return CMap::tile_lava_d0;
			case CMap::tile_lava_d1: return oldTileType; // return CMap::tile_lava_d1;
			case CMap::tile_abyss_dirt:
			case CMap::tile_abyss_dirt_d0:
			case CMap::tile_abyss_dirt_d1:
			case CMap::tile_abyss_dirt_d2:
			case CMap::tile_abyss_dirt_d3:
			{
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_dirt" + (1 + XORRandom(3)) + ".ogg", pos, 0.5f, 0.5f);
					if (XORRandom(11) < 1) Sound::Play("AbyssDirtBroke.ogg", pos, 0.5f, 1.0f);
				}
				return oldTileType;
			}
			case CMap::tile_abyss_dirt_back:
			case CMap::tile_abyss_dirt_back_d0:
			case CMap::tile_abyss_dirt_back_d1:
			case CMap::tile_abyss_dirt_back_d2:
			case CMap::tile_abyss_dirt_back_d3:
			case CMap::tile_abyss_dirt_back_d4:
			case CMap::tile_abyss_dirt_back_d5:
			case CMap::tile_abyss_dirt_back_d6:
			case CMap::tile_abyss_dirt_back_d7:
			case CMap::tile_abyss_dirt_back_d8:
			{
				return oldTileType;
			}
			case CMap::tile_iron: // iron start
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 1.0f, 1.1f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_iron");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+1);
					}
				}
				return CMap::tile_iron_d1;
			}
			case CMap::tile_iron_d0:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 1.0f, 1.1f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_iron");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+1);
					}
				}
				return CMap::tile_iron_d1;
			}
			case CMap::tile_iron_d1:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 1.0f, 1.1f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_iron");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+1);
					}
				}
				return CMap::tile_iron_d2;
			}
			case CMap::tile_iron_d2:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 1.0f, 1.1f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_iron");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+1);
					}
				}
				return CMap::tile_iron_d3;
			}
			case CMap::tile_iron_d3:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 1.0f, 1.1f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_iron");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(2)+1);
					}
				}
				return CMap::tile_iron_d4;
			}
			case CMap::tile_iron_d4:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 1.0f, 1.1f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_iron");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(2)+1);
					}
				}
				return CMap::tile_iron_d5;
			}
			case CMap::tile_iron_d5: // iron finish
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("destroy_stone.ogg", pos, 1.0f, 1.1f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_iron");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(2)+1);
					}
				}
				return CMap::tile_ground_back;
			}
			case CMap::tile_chromium: // chromium start
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 0.85f, 1.05f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_chromium");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+2);
					}
				}
				return CMap::tile_chromium_d0;
			}
			case CMap::tile_chromium_d0:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 0.84f, 1.06f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_chromium");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+2);
					}
				}
				return CMap::tile_chromium_d1;
			}
			case CMap::tile_chromium_d1:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 0.85f, 1.05f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_chromium");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+1);
					}
				}
				return CMap::tile_chromium_d2;
			}
			case CMap::tile_chromium_d2:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 0.86f, 1.04f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_chromium");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+1);
					}
				}
				return CMap::tile_chromium_d3;
			}
			case CMap::tile_chromium_d3:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("destroy_stone.ogg", pos, 0.87f, 1.03f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_chromium");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+1);
					}
				}
				return CMap::tile_ground_back;
			}
			case CMap::tile_paladium: // paladium start
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 0.75f, 0.90f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_palladium");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+2);
					}
				}
				return CMap::tile_paladium_d0;
			}
			case CMap::tile_paladium_d0:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 0.75f, 0.93f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_palladium");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+2);
					}
				}
				return CMap::tile_paladium_d1;
			}
			case CMap::tile_paladium_d1:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 0.75f, 0.96f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_palladium");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+1);
					}
				}
				return CMap::tile_paladium_d2;
			}
			case CMap::tile_paladium_d2:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 0.75f, 0.99f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_palladium");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+1);
					}
				}
				return CMap::tile_paladium_d3;
			}
			case CMap::tile_paladium_d3:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("destroy_stone.ogg", pos, 0.75f, 1.02f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_palladium");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+1);
					}
				}
				return CMap::tile_inferno_ash_back;
			}
			case CMap::tile_platinum: // platinum start
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 0.95f, 1.07f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_platinum");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+2);
					}
				}
				return CMap::tile_platinum_d0;
			}
			case CMap::tile_platinum_d0:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 0.95f, 1.09f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_platinum");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+2);
					}
				}
				return CMap::tile_platinum_d1;
			}
			case CMap::tile_platinum_d1:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 0.95f, 1.11f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_platinum");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+1);
					}
				}
				return CMap::tile_platinum_d2;
			}
			case CMap::tile_platinum_d2:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 0.95f, 1.13f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_platinum");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+1);
					}
				}
				return CMap::tile_platinum_d3;
			}
			case CMap::tile_platinum_d3:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("destroy_stone.ogg", pos, 1.0f, 1.15f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_platinum");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+1);
					}
				}
				return CMap::tile_ground_back;
			}
			case CMap::tile_titanium: // titanium start
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 1.0f, 0.9f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_titanium");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+3);
					}
				}
				return CMap::tile_titanium_d0;
			}
			case CMap::tile_titanium_d0:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 1.0f, 0.88f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_titanium");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+2);
					}
				}
				return CMap::tile_titanium_d1;
			}
			case CMap::tile_titanium_d1:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 1.0f, 0.86f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_titanium");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+1);
					}
				}
				return CMap::tile_titanium_d2;
			}
			case CMap::tile_titanium_d2:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_stone.ogg", pos, 1.0f, 0.84f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_titanium");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+1);
					}
				}
				return CMap::tile_titanium_d3;
			}
			case CMap::tile_titanium_d3:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("destroy_stone.ogg", pos, 1.0f, 0.8f);
				}
				if (isServer()) 
				{
					CBlob@ iron = server_CreateBlobNoInit("mat_titanium");
					if (iron !is null)
					{
						iron.Tag("custom quantity");
						iron.Init();
						iron.setPosition(Vec2f(map.getTileWorldPosition(index)));
						iron.server_SetQuantity(XORRandom(3)+1);
					}
				}
				return CMap::tile_abyss_dirt_back;
			}
			case CMap::tile_inferno_ash: // ash start
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_dirt" + (1 + XORRandom(3)) + ".ogg", pos, 1.0f, 0.8f);
				}
				return CMap::tile_inferno_ash_d6;
			}
			case CMap::tile_inferno_ash_d0:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_dirt" + (1 + XORRandom(3)) + ".ogg", pos, 1.0f, 0.8f);
				}
				return CMap::tile_inferno_ash_d6;
			}
			case CMap::tile_inferno_ash_d1:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_dirt" + (1 + XORRandom(3)) + ".ogg", pos, 1.0f, 0.8f);
				}
				return CMap::tile_inferno_ash_d6;
			}
			case CMap::tile_inferno_ash_d2:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_dirt" + (1 + XORRandom(3)) + ".ogg", pos, 1.0f, 0.8f);
				}
				return CMap::tile_inferno_ash_d6;
			}
			case CMap::tile_inferno_ash_d3:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_dirt" + (1 + XORRandom(3)) + ".ogg", pos, 1.0f, 0.8f);
				}
				return CMap::tile_inferno_ash_d6;
			}
			case CMap::tile_inferno_ash_d6:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_dirt" + (1 + XORRandom(3)) + ".ogg", pos, 1.0f, 0.8f);
				}
				return CMap::tile_inferno_ash_d7;
			}
			case CMap::tile_inferno_ash_d7:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("dig_dirt" + (1 + XORRandom(3)) + ".ogg", pos, 1.0f, 0.8f);
				}
				return CMap::tile_inferno_ash_d8;
			}
			case CMap::tile_inferno_ash_d8: // ash finish
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("destroy_dirt.ogg", pos, 0.80f, 0.8f);
				}
				return CMap::tile_inferno_ash_back;
			}
			case CMap::tile_inferno_castle: // inferno stone start
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.8f);
				}
				if (isServer()) 
				{
					CBlob@ hstone = server_CreateBlobNoInit("mat_hellstone");
					if (hstone !is null)
					{
						hstone.Tag("custom quantity");
						hstone.Init();
						hstone.setPosition(Vec2f(map.getTileWorldPosition(index)));
						hstone.server_SetQuantity(XORRandom(2)+1);
					}
				}
				return CMap::tile_inferno_castle_d6;
			}
			case CMap::tile_inferno_castle_d0:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.8f);
				}
				if (isServer()) 
				{
					CBlob@ hstone = server_CreateBlobNoInit("mat_hellstone");
					if (hstone !is null)
					{
						hstone.Tag("custom quantity");
						hstone.Init();
						hstone.setPosition(Vec2f(map.getTileWorldPosition(index)));
						hstone.server_SetQuantity(XORRandom(2)+1);
					}
				}
				return CMap::tile_inferno_castle_d6;
			}
			case CMap::tile_inferno_castle_d1:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.8f);
				}
				if (isServer()) 
				{
					CBlob@ hstone = server_CreateBlobNoInit("mat_hellstone");
					if (hstone !is null)
					{
						hstone.Tag("custom quantity");
						hstone.Init();
						hstone.setPosition(Vec2f(map.getTileWorldPosition(index)));
						hstone.server_SetQuantity(XORRandom(2)+1);
					}
				}
				return CMap::tile_inferno_castle_d6;
			}
			case CMap::tile_inferno_castle_d2:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.8f);
				}
				if (isServer()) 
				{
					CBlob@ hstone = server_CreateBlobNoInit("mat_hellstone");
					if (hstone !is null)
					{
						hstone.Tag("custom quantity");
						hstone.Init();
						hstone.setPosition(Vec2f(map.getTileWorldPosition(index)));
						hstone.server_SetQuantity(XORRandom(2)+1);
					}
				}
				return CMap::tile_inferno_castle_d6;
			}
			case CMap::tile_inferno_castle_d3:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.8f);
				}
				if (isServer()) 
				{
					CBlob@ hstone = server_CreateBlobNoInit("mat_hellstone");
					if (hstone !is null)
					{
						hstone.Tag("custom quantity");
						hstone.Init();
						hstone.setPosition(Vec2f(map.getTileWorldPosition(index)));
						hstone.server_SetQuantity(XORRandom(2)+1);
					}
				}
				return CMap::tile_inferno_castle_d6;
			}
			case CMap::tile_inferno_castle_d4:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.8f);
				}
				if (isServer()) 
				{
					CBlob@ hstone = server_CreateBlobNoInit("mat_hellstone");
					if (hstone !is null)
					{
						hstone.Tag("custom quantity");
						hstone.Init();
						hstone.setPosition(Vec2f(map.getTileWorldPosition(index)));
						hstone.server_SetQuantity(XORRandom(2)+1);
					}
				}
				return CMap::tile_inferno_castle_d6;
			}
			case CMap::tile_inferno_castle_d5:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.8f);
				}
				if (isServer()) 
				{
					CBlob@ hstone = server_CreateBlobNoInit("mat_hellstone");
					if (hstone !is null)
					{
						hstone.Tag("custom quantity");
						hstone.Init();
						hstone.setPosition(Vec2f(map.getTileWorldPosition(index)));
						hstone.server_SetQuantity(XORRandom(2)+1);
					}
				}
				return CMap::tile_inferno_castle_d6;
			}
			case CMap::tile_inferno_castle_d6:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.8f);
				}
				if (isServer()) 
				{
					CBlob@ hstone = server_CreateBlobNoInit("mat_hellstone");
					if (hstone !is null)
					{
						hstone.Tag("custom quantity");
						hstone.Init();
						hstone.setPosition(Vec2f(map.getTileWorldPosition(index)));
						hstone.server_SetQuantity(XORRandom(1)+1);
					}
				}
				return CMap::tile_inferno_castle_d7;
			}
			case CMap::tile_inferno_castle_d7:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.8f);
				}
				if (isServer()) 
				{
					CBlob@ hstone = server_CreateBlobNoInit("mat_hellstone");
					if (hstone !is null)
					{
						hstone.Tag("custom quantity");
						hstone.Init();
						hstone.setPosition(Vec2f(map.getTileWorldPosition(index)));
						hstone.server_SetQuantity(XORRandom(1)+1);
					}
				}
				return CMap::tile_inferno_castle_d8;
			}
			case CMap::tile_inferno_castle_d8:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.8f);
				}
				if (isServer()) 
				{
					CBlob@ hstone = server_CreateBlobNoInit("mat_hellstone");
					if (hstone !is null)
					{
						hstone.Tag("custom quantity");
						hstone.Init();
						hstone.setPosition(Vec2f(map.getTileWorldPosition(index)));
						hstone.server_SetQuantity(XORRandom(1)+1);
					}
				}
				return CMap::tile_inferno_castle_d9;
			}
			case CMap::tile_inferno_castle_d9:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.8f);
				}
				if (isServer()) 
				{
					CBlob@ hstone = server_CreateBlobNoInit("mat_hellstone");
					if (hstone !is null)
					{
						hstone.Tag("custom quantity");
						hstone.Init();
						hstone.setPosition(Vec2f(map.getTileWorldPosition(index)));
						hstone.server_SetQuantity(XORRandom(1)+1);
					}
				}
				return CMap::tile_inferno_castle_d10;
			}
			case CMap::tile_inferno_castle_d10:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.8f);
				}
				if (isServer()) 
				{
					CBlob@ hstone = server_CreateBlobNoInit("mat_hellstone");
					if (hstone !is null)
					{
						hstone.Tag("custom quantity");
						hstone.Init();
						hstone.setPosition(Vec2f(map.getTileWorldPosition(index)));
						hstone.server_SetQuantity(1);
					}
				}
				return CMap::tile_inferno_castle_d11;
			}
			case CMap::tile_inferno_castle_d11:
			{ // inferno stone finish
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("destroy_wall.ogg", pos, 1.0f, 0.8);
				}
				if (isServer()) 
				{
					CBlob@ hstone = server_CreateBlobNoInit("mat_hellstone");
					if (hstone !is null)
					{
						hstone.Tag("custom quantity");
						hstone.Init();
						hstone.setPosition(Vec2f(map.getTileWorldPosition(index)));
						hstone.server_SetQuantity(1);
					}
				}
				map.AddTileFlag(index, Tile::LIGHT_PASSES);
				map.AddTileFlag(index, Tile::WATER_PASSES);
				return CMap::tile_inferno_castle_back;
			}
			case CMap::tile_inferno_castle_back:
			{ // hellstone wall back start
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.9f);
				}
				return CMap::tile_inferno_castle_back_d5;
			}
			case CMap::tile_inferno_castle_back_d0:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.9f);
				}
				return CMap::tile_inferno_castle_back_d5;
			}
			case CMap::tile_inferno_castle_back_d1:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.9f);
				}
				return CMap::tile_inferno_castle_back_d5;
			}
			case CMap::tile_inferno_castle_back_d2:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.9f);
				}
				return CMap::tile_inferno_castle_back_d5;
			}
			case CMap::tile_inferno_castle_back_d3:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.9f);
				}
				return CMap::tile_inferno_castle_back_d5;
			}
			case CMap::tile_inferno_castle_back_d4:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.9f);
				}
				return CMap::tile_inferno_castle_back_d5;
			}
			case CMap::tile_inferno_castle_back_d5:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.9f);
				}
				return CMap::tile_inferno_castle_back_d6;
			}
			case CMap::tile_inferno_castle_back_d6:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.9f);
				}
				return CMap::tile_inferno_castle_back_d7;
			}
			case CMap::tile_inferno_castle_back_d7:
			{
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.9f);
				}
				return CMap::tile_inferno_castle_back_d8;
			}
			case CMap::tile_inferno_castle_back_d8:
			{ // hellstone wall back finish
				if (isClient())
				{
					Vec2f pos = map.getTileWorldPosition(index);
					Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.8f);
				}
				map.AddTileFlag(index, Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				return CMap::tile_inferno_ash_back;
			}
			case CMap::tile_inferno_ash_back:
			{
				return CMap::tile_inferno_ash_back;
				break;
			}
			case CMap::tile_inferno_ash_back_d1:
			{
				return CMap::tile_inferno_ash_back_d1;
				break;
			}
			case CMap::tile_inferno_ash_back_d2:
			{
				return CMap::tile_inferno_ash_back_d2;
				break;
			}
			case CMap::tile_inferno_ash_back_d3:
			{
				return CMap::tile_inferno_ash_back_d3;
				break;
			}
			case CMap::tile_inferno_ash_back_d4:
			{
				return CMap::tile_inferno_ash_back_d4;
				break;
			}
			case CMap::tile_inferno_ash_back_d5:
			{
				return CMap::tile_inferno_ash_back_d5;
				break;
			}
			case CMap::tile_inferno_ash_back_d6:
			{
				return CMap::tile_inferno_ash_back_d6;
				break;
			}
			case CMap::tile_inferno_ash_back_d7:
			{
				return CMap::tile_inferno_ash_back_d7;
				break;
			}
			case CMap::tile_inferno_ash_back_d8:
			{
				return CMap::tile_inferno_ash_back_d8;
				break;
			}
		}
	}
	return CMap::tile_empty;
}

void DoLeftLavaUpdate(u16 index, CMap@ map)
{
	index -= 1;
	map.SetTile(index, CMap::tile_lava_d0);
	const TileType left = map.getTile(index - 1).type;
	if (left == CMap::tile_lava) DoLeftLavaUpdate(index, map);
}

TileType DoLavaUpdate(u16 index, TileType up, TileType down, TileType left, TileType right, CMap@ map)
{
	if (up == CMap::tile_empty
	|| up == CMap::tile_inferno_ash_back || up ==  CMap::tile_inferno_ash_back_d0 || up ==  CMap::tile_inferno_ash_back_d1
	|| up == CMap::tile_inferno_ash_back_d2 || up ==  CMap::tile_inferno_ash_back_d3 || up ==  CMap::tile_inferno_ash_back_d4
	|| up == CMap::tile_inferno_ash_back_d5 || up ==  CMap::tile_inferno_ash_back_d6 || up ==  CMap::tile_inferno_ash_back_d7
	|| up == CMap::tile_inferno_ash_back_d8
	|| left == CMap::tile_lava_d1
	|| right == CMap::tile_lava_d1)
	{
		return CMap::tile_lava_d1;
	}
	else if (up == CMap::tile_lava_d1 || left == CMap::tile_lava_d0 || right == CMap::tile_lava_d0)
	{
		return CMap::tile_lava_d0;
	}
	else return CMap::tile_lava;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	if (map.getTile(index).type > 383) //custom solids
	{
		map.SetTileSupport(index, 10);

		const TileType up = map.getTile(index - map.tilemapwidth).type;
		const TileType down = map.getTile(index + map.tilemapwidth).type;
		const TileType left = map.getTile(index - 1).type;
		const TileType right = map.getTile(index + 1).type;

		
		if (map.getTile(index).type > 463 && map.getTile(index).type < 477)
		{
			switch (tile_new)
			{
				case CMap::tile_lava:
				case CMap::tile_lava_d0:
				case CMap::tile_lava_d1:
				{
					//map.SetTile(index, CMap::tile_lava);
					map.SetTile(index, DoLavaUpdate(index, up, down, left, right, map));

					if (index == CMap::tile_lava
					&& left == CMap::tile_lava_d0) map.SetTile(index, CMap::tile_lava_d0);
					if (index == CMap::tile_lava
					&& right == CMap::tile_lava_d0) map.SetTile(index, CMap::tile_lava_d0);

					map.RemoveTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::WATER_PASSES);
					map.AddTileFlag(index, Tile::LIGHT_SOURCE);
					break;
				}
			}
		}
		else if (map.getTile(index).type > 511 && map.getTile(index).type < 517)
		{
			map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
			map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
			map.SetTileSupport(index, 255);
			//switch (XORRandom(4))
			//{
			//	case 0: break;
			//	case 1: map.AddTileFlag(index, Tile::ROTATE); break;
			//	case 2: map.AddTileFlag(index, Tile::FLIP); break;
			//	case 3: map.AddTileFlag(index, Tile::ROTATE); map.AddTileFlag(index, Tile::FLIP); break;
			//}
		}
		else if (map.getTile(index).type > 517 && map.getTile(index).type < 523)
		{
			map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
			map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
			map.SetTileSupport(index, 255);
			//switch (XORRandom(4))
			//{
			//	case 0: break;
			//	case 1: map.AddTileFlag(index, Tile::ROTATE); break;
			//	case 2: map.AddTileFlag(index, Tile::FLIP); break;
			//	case 3: map.AddTileFlag(index, Tile::ROTATE); map.AddTileFlag(index, Tile::FLIP); break;
			//}
		}
		else if (map.getTile(index).type > 523 && map.getTile(index).type < 529)
		{
			map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
			map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
			map.SetTileSupport(index, 255);
			//switch (XORRandom(4))
			//{
			//	case 0: break;
			//	case 1: map.AddTileFlag(index, Tile::ROTATE); break;
			//	case 2: map.AddTileFlag(index, Tile::FLIP); break;
			//	case 3: map.AddTileFlag(index, Tile::ROTATE); map.AddTileFlag(index, Tile::FLIP); break;
			//}
		}
		else if (map.getTile(index).type > 529 && map.getTile(index).type < 535)
		{
			map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
			map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
			map.SetTileSupport(index, 255);
			//switch (XORRandom(4))
			//{
			//	case 0: break;
			//	case 1: map.AddTileFlag(index, Tile::ROTATE); break;
			//	case 2: map.AddTileFlag(index, Tile::FLIP); break;
			//	case 3: map.AddTileFlag(index, Tile::ROTATE); map.AddTileFlag(index, Tile::FLIP); break;
			//}
		}
		else if (map.getTile(index).type > 481 && map.getTile(index).type < 492)
		{
			switch (tile_new)
			{
				case CMap::tile_abyss_dirt:
				{
					u8 rand = XORRandom(3);
					switch (rand)
					{
						case 0: map.SetTile(index, CMap::tile_abyss_dirt);      break;
						case 1: map.SetTile(index, CMap::tile_abyss_dirt_d0);	break;
						case 2: map.SetTile(index, CMap::tile_abyss_dirt_d1);	break;
					}
					map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
					map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
					break;
				}
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				break;
			}
		}
		else if (map.getTile(index).type > 495 && map.getTile(index).type < 507)
		{
			switch (tile_new)
			{
				case CMap::tile_abyss_dirt_back:
				{
					u8 rand = XORRandom(4);
					switch (rand)
					{
						case 0: map.SetTile(index, CMap::tile_abyss_dirt_back);     break;
						case 1: map.SetTile(index, CMap::tile_abyss_dirt_back_d0);	break;
						case 2: map.SetTile(index, CMap::tile_abyss_dirt_back_d1);	break;
						case 3: map.SetTile(index, CMap::tile_abyss_dirt_back_d2);	break;
					}
				}
				map.AddTileFlag(index, Tile::BACKGROUND);
				map.RemoveTileFlag(index, Tile::LIGHT_SOURCE);
				break;
			}
		}
		else if (map.getTile(index).type > 431 && map.getTile(index).type < 448)
		{
			switch (tile_new)
			{
				case CMap::tile_inferno_ash:
				{ // flags in basepngloaders
					//map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
					map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
					break;
				}
				case CMap::tile_inferno_ash_d6:
				case CMap::tile_inferno_ash_d7:
				case CMap::tile_inferno_ash_d8:
				{
					map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
					map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
					break;
				}
			}
		}
		else if (map.getTile(index).type > 383 && map.getTile(index).type < 393)
		{
			switch(tile_new)
			{
				case CMap::tile_iron:
				{
					u8 rand = XORRandom(10);

					if (rand < 5)
					{
						map.SetTile(index, CMap::tile_iron_d0);
					}

					map.SetTileSupport(index, 255);
					map.RemoveTileFlag( index, Tile::LIGHT_PASSES |Tile::LIGHT_SOURCE );
					map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
					break;
				}
				case CMap::tile_iron_d0:
				{
					map.SetTileSupport(index, 255);
					map.RemoveTileFlag( index, Tile::LIGHT_PASSES |Tile::LIGHT_SOURCE );
					map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
					break;
				}
				case CMap::tile_iron_d1:
				case CMap::tile_iron_d2:
				case CMap::tile_iron_d3:
				case CMap::tile_iron_d4:
				case CMap::tile_iron_d5:
				{
					map.SetTileSupport(index, 255);
					map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE );
					map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
					break;
				}
			}
		}
		else if (map.getTile(index).type > 399 && map.getTile(index).type < 416)
		{
			switch (tile_new)
			{
				case CMap::tile_inferno_castle:
				{
					if (right == CMap::tile_inferno_castle_back
					|| right == CMap::tile_inferno_castle_back_d0
					|| right == CMap::tile_inferno_castle_back_d1
					|| right == CMap::tile_inferno_castle_back_d2
					|| right == CMap::tile_inferno_castle_back_d3
					|| right == CMap::tile_inferno_castle_back_d4
					|| right == CMap::tile_inferno_castle_back_d5
					|| right == CMap::tile_inferno_castle_back_d6
					|| right == CMap::tile_inferno_castle_back_d7
					|| right == CMap::tile_inferno_castle_back_d8)
					{ // facing right
						map.SetTile(index, CMap::tile_inferno_castle_d1);
						map.AddTileFlag(index, Tile::ROTATE);
					}
					else if (down == CMap::tile_inferno_castle_back
					|| down == CMap::tile_inferno_castle_back_d0
					|| down == CMap::tile_inferno_castle_back_d1
					|| down == CMap::tile_inferno_castle_back_d2
					|| down == CMap::tile_inferno_castle_back_d3
					|| down == CMap::tile_inferno_castle_back_d4
					|| down == CMap::tile_inferno_castle_back_d5
					|| down == CMap::tile_inferno_castle_back_d6
					|| down == CMap::tile_inferno_castle_back_d7
					|| down == CMap::tile_inferno_castle_back_d8)
					{ // facing down
						map.SetTile(index, CMap::tile_inferno_castle_d2);
					}
					else if (left == CMap::tile_inferno_castle_back
					|| left == CMap::tile_inferno_castle_back_d0
					|| left == CMap::tile_inferno_castle_back_d1
					|| left == CMap::tile_inferno_castle_back_d2
					|| left == CMap::tile_inferno_castle_back_d3
					|| left == CMap::tile_inferno_castle_back_d4
					|| left == CMap::tile_inferno_castle_back_d5
					|| left == CMap::tile_inferno_castle_back_d6
					|| left == CMap::tile_inferno_castle_back_d7
					|| left == CMap::tile_inferno_castle_back_d8)
					{ // facing left
						map.SetTile(index, CMap::tile_inferno_castle_d2);
						map.AddTileFlag(index, Tile::ROTATE);
					}
					else
					{
						u8 rand = XORRandom(4);

						switch (rand)
						{
							case 1:
							{
								map.SetTile(index, CMap::tile_inferno_castle);
								break;
							}
							case 2:
							{
								map.SetTile(index, CMap::tile_inferno_castle_d0);
								break;
							}
							case 3:
							{
								map.SetTile(index, CMap::tile_inferno_castle_d4);
								break;
							}
							case 4:
							{
								map.SetTile(index, CMap::tile_inferno_castle_d5);
								break;
							}
						}	
					}

					map.RemoveTileFlag( index, Tile::LIGHT_PASSES |Tile::LIGHT_SOURCE );
					map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
					break;
				}
				case CMap::tile_inferno_castle_d0:
				case CMap::tile_inferno_castle_d1:
				case CMap::tile_inferno_castle_d2:
				case CMap::tile_inferno_castle_d3:
				case CMap::tile_inferno_castle_d4:
				case CMap::tile_inferno_castle_d5:
				case CMap::tile_inferno_castle_d6:
				case CMap::tile_inferno_castle_d7:
				case CMap::tile_inferno_castle_d8:
				case CMap::tile_inferno_castle_d9:
				case CMap::tile_inferno_castle_d10:
				case CMap::tile_inferno_castle_d11:
				{
					map.RemoveTileFlag( index, Tile::LIGHT_PASSES |Tile::LIGHT_SOURCE );
					map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
					break;
				}
			}
		}
		else if (map.getTile(index).type > 447 && map.getTile(index).type < 458)
		{
			switch (tile_new)
			{
				case CMap::tile_inferno_ash_back:
				{
					//u8 randashb = XORRandom(3);
					if (up == CMap::tile_empty || right == CMap::tile_empty || down == CMap::tile_empty || left == CMap::tile_empty)
					{   // sharp ones
						if (up == CMap::tile_empty && left == CMap::tile_empty && right == CMap::tile_empty && down != CMap::tile_empty)
						{ // facing up
							map.SetTile(index, CMap::tile_inferno_ash_back_d8);
						}
						else if (up == CMap::tile_empty && left != CMap::tile_empty && right == CMap::tile_empty && down == CMap::tile_empty)
						{ // facing right
							map.SetTile(index, CMap::tile_inferno_ash_back_d8);
							map.AddTileFlag(index, Tile::ROTATE);
						}
						else if (up != CMap::tile_empty && left == CMap::tile_empty && right == CMap::tile_empty && down == CMap::tile_empty)
						{ // facing down
							map.SetTile(index, CMap::tile_inferno_ash_back_d8);
							map.AddTileFlag(index, Tile::FLIP);
						}
						else if (up == CMap::tile_empty && left == CMap::tile_empty && right != CMap::tile_empty && down == CMap::tile_empty)
						{ // facing left
							map.SetTile(index, CMap::tile_inferno_ash_back_d8);
							map.AddTileFlag(index, Tile::ROTATE);
							map.AddTileFlag(index, Tile::MIRROR);
						} // waves at left & right
						else if (up != CMap::tile_empty && left == CMap::tile_empty && right == CMap::tile_empty && down != CMap::tile_empty)
						{
							map.SetTile(index, CMap::tile_inferno_ash_back_d7);
							map.AddTileFlag(index, Tile::ROTATE);
						}
						else if (up == CMap::tile_empty && left != CMap::tile_empty && right != CMap::tile_empty && down == CMap::tile_empty)
						{ // waves at up & down
							map.SetTile(index, CMap::tile_inferno_ash_back_d7);
						}
						else if (up == CMap::tile_empty && left == CMap::tile_empty && right != CMap::tile_empty && down != CMap::tile_empty)
						{ // stuck to side right, facing up
							map.SetTile(index, CMap::tile_inferno_ash_back_d5);
						}
						else if (up == CMap::tile_empty && left != CMap::tile_empty && right == CMap::tile_empty && down != CMap::tile_empty)
						{ // stuck to side left, facing up
							map.SetTile(index, CMap::tile_inferno_ash_back_d5);
							map.AddTileFlag(index, Tile::MIRROR);
						}
						else if (up != CMap::tile_empty && left == CMap::tile_empty && right != CMap::tile_empty && down == CMap::tile_empty)
						{ // stuck to side right, facing down
							map.SetTile(index, CMap::tile_inferno_ash_back_d5);
							map.AddTileFlag(index, Tile::FLIP);
						}
						else if (up != CMap::tile_empty && left != CMap::tile_empty && right == CMap::tile_empty && down == CMap::tile_empty)
						{ // stuck to side left, facing down
							map.SetTile(index, CMap::tile_inferno_ash_back_d5);
							map.AddTileFlag(index, Tile::FLIP);
							map.AddTileFlag(index, Tile::MIRROR);
						}
						else if (up == CMap::tile_empty && left != CMap::tile_empty && right != CMap::tile_empty && down != CMap::tile_empty)
						{ // waves to one side, facing up
							map.SetTile(index, CMap::tile_inferno_ash_back_d6);
						}
						else if (up != CMap::tile_empty && left != CMap::tile_empty && right == CMap::tile_empty && down != CMap::tile_empty)
						{ // waves to one side, facing right
							map.SetTile(index, CMap::tile_inferno_ash_back_d6);
							map.AddTileFlag(index, Tile::ROTATE);
						}
						else if (up != CMap::tile_empty && left != CMap::tile_empty && right != CMap::tile_empty && down == CMap::tile_empty)
						{ // waves to one side, facing down
							map.SetTile(index, CMap::tile_inferno_ash_back_d6);
							map.AddTileFlag(index, Tile::FLIP);
						}
						else if (up != CMap::tile_empty && left == CMap::tile_empty && right != CMap::tile_empty && down != CMap::tile_empty)
						{ // waves to one side, facing left
							map.SetTile(index, CMap::tile_inferno_ash_back_d6);
							map.AddTileFlag(index, Tile::ROTATE);
							map.AddTileFlag(index, Tile::MIRROR);
						}		
					}
					/*else
					{
						switch(randashb)
						{
							case 1: map.SetTile(index, CMap::tile_inferno_ash_back_d1);
							case 2: map.SetTile(index, CMap::tile_inferno_ash_back_d2);
						}
					}*/


					map.SetTileSupport(index, 255);
					map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
					map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
					break;
				}
				//case CMap::tile_inferno_ash_back_d0: // somehow causes duplicate switch-case
				case CMap::tile_inferno_ash_back_d1:
				case CMap::tile_inferno_ash_back_d2:
				case CMap::tile_inferno_ash_back_d3:
				case CMap::tile_inferno_ash_back_d4:
				case CMap::tile_inferno_ash_back_d5:
				case CMap::tile_inferno_ash_back_d6:
				case CMap::tile_inferno_ash_back_d7:
				case CMap::tile_inferno_ash_back_d8:
				{
					map.SetTileSupport(index, 255);
					map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
					map.AddTileFlag(index, Tile::WATER_PASSES);
					break;
				}
			}
		}
		else if (map.getTile(index).type > 415 && map.getTile(index).type < 432)
		{
			switch (tile_new)
			{
				case CMap::tile_inferno_castle_back:
				{
					map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
					u8 rand = XORRandom(6);
					switch (rand)
					{
						case 1:
						{
							map.SetTile(index, CMap::tile_inferno_castle_back);
							break;
						}
						case 2:
						{
							map.SetTile(index, CMap::tile_inferno_castle_back_d0);
							break;
						}
						case 3:
						{
							map.SetTile(index, CMap::tile_inferno_castle_back_d1);
							break;
						}
						case 4:
						{
							map.SetTile(index, CMap::tile_inferno_castle_back_d2);
							break;
						}
						case 5:
						{
							map.SetTile(index, CMap::tile_inferno_castle_back_d3);
							break;
						}
						case 6:
						{
							map.SetTile(index, CMap::tile_inferno_castle_back_d4);
							break;
						}
					}

					map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
					map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES);
					break;
				}
				case CMap::tile_inferno_castle_back_d0:
				case CMap::tile_inferno_castle_back_d1:
				case CMap::tile_inferno_castle_back_d2:
				case CMap::tile_inferno_castle_back_d3:
				case CMap::tile_inferno_castle_back_d4:
				case CMap::tile_inferno_castle_back_d5:
				case CMap::tile_inferno_castle_back_d6:
				case CMap::tile_inferno_castle_back_d7:
				case CMap::tile_inferno_castle_back_d8:
				{
					map.RemoveTileFlag( index, Tile::LIGHT_SOURCE );
					map.AddTileFlag(index, Tile::BACKGROUND | Tile::WATER_PASSES | Tile::LIGHT_PASSES);
					break;
				}
			}
		}
	}
	else if(isDummyTile(tile_new))
	{
		map.SetTileSupport(index, 10);

		switch(tile_new)
		{
			case Dummy::SOLID:
			case Dummy::OBSTRUCTOR:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
			case Dummy::BACKGROUND:
			case Dummy::OBSTRUCTOR_BACKGROUND:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				break;
			case Dummy::LADDER:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::LADDER | Tile::WATER_PASSES);
				break;
			case Dummy::PLATFORM:
				map.AddTileFlag(index, Tile::PLATFORM);
				break;
		}
	}
}