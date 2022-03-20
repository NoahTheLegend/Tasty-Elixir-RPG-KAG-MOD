
/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */

namespace CMap
{
	enum CustomTiles
	{
		//pick tile indices from here - indices > 256 are advised.
		//tile_whatever = 300

		//tile_iron              = 0xFF977361, // ARGB(255, 151, 115,  97);
		tile_iron = 384,
		tile_iron_d0 = 385,
		tile_iron_d1 = 388,
		tile_iron_d2 = 389,
		tile_iron_d3 = 390,
		tile_iron_d4 = 391,
		tile_iron_d5 = 392,

		//tile_inferno_ash       = 0xFF4F423C, // ARGB(255,  79,  66,  60);
		tile_inferno_ash = 432,
		tile_inferno_ash_d0 = 433,
		tile_inferno_ash_d1 = 434,
		tile_inferno_ash_d2 = 435,
		tile_inferno_ash_d3 = 436,
		tile_inferno_ash_d4 = 437,
		tile_inferno_ash_d5 = 438,
		tile_inferno_ash_d6 = 445,
		tile_inferno_ash_d7 = 446,
		tile_inferno_ash_d8 = 447,

		//tile_inferno_ash_back  = 0xFF302926, // ARGB(255,  48,  41,  38);
		tile_inferno_ash_back = 448,
		tile_inferno_ash_back_d0 = 449, // dont use this, its broken and not necessary
		tile_inferno_ash_back_d1 = 450,
		tile_inferno_ash_back_d2 = 451,
		tile_inferno_ash_back_d3 = 452,
		tile_inferno_ash_back_d4 = 453,
		tile_inferno_ash_back_d5 = 454,
		tile_inferno_ash_back_d6 = 455,
		tile_inferno_ash_back_d7 = 456,
		tile_inferno_ash_back_d8 = 457,

		//tile_inferno_castle    = 0xFFFF503E, // ARGB(255, 255,  80,  62);
		tile_inferno_castle = 400,
		tile_inferno_castle_d0 = 401,
		tile_inferno_castle_d1 = 402,
		tile_inferno_castle_d2 = 403,
		tile_inferno_castle_d3 = 404,
		tile_inferno_castle_d4 = 405,
		tile_inferno_castle_d5 = 406,
		tile_inferno_castle_d6 = 410,
		tile_inferno_castle_d7 = 411,
		tile_inferno_castle_d8 = 412,
		tile_inferno_castle_d9 = 413,
		tile_inferno_castle_d10= 414,
		tile_inferno_castle_d11= 415,

		//tile_inferno_castle_back = 0xFFA72D23, // ARGB(255, 167,  45,  35);
		tile_inferno_castle_back = 416,
		tile_inferno_castle_back_d0 = 417,
		tile_inferno_castle_back_d1 = 418,
		tile_inferno_castle_back_d2 = 419,
		tile_inferno_castle_back_d3 = 420,
		tile_inferno_castle_back_d4 = 427,
		tile_inferno_castle_back_d5 = 428,
		tile_inferno_castle_back_d6 = 429,
		tile_inferno_castle_back_d7 = 430,
		tile_inferno_castle_back_d8 = 431,

		tile_lava = 464,
		tile_lava_d0 = 465,
		tile_lava_d1 = 466
	};
};

const SColor color_tile_iron(255,151,115,97);
const SColor color_tile_inferno_castle(255,255,80,62);
const SColor color_tile_inferno_castle_back(255,167,45,35);
const SColor color_tile_inferno_ash(255,79,66,60);
const SColor color_tile_inferno_ash_back(255,167,45,35);

const SColor color_nursery(255,0,159,60);
const SColor color_kitchenb(255,0,112,158);
const SColor color_tinkerstable(255,110,0,35);
const SColor color_spicetable(255,96,0,81);
const SColor color_potionstable(255,145,0,123);
const SColor color_blacksmith(255,122,119,0);
const SColor color_smallsign(255,199,144,185);
const SColor color_witchshack(255,103,8,123);

void HandleCustomTile( CMap@ map, int offset, SColor pixel )
{
	if (pixel == color_tile_iron)
	{
		map.SetTile(offset, CMap::tile_iron );
		map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION | Tile::FLIP);
	}
	else if (pixel == color_tile_inferno_ash)
	{
		map.SetTile(offset, CMap::tile_iron );
		map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION | Tile::FLIP);
	}
}
