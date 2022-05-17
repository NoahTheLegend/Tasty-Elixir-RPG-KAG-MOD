// LootCommon.as

const string LOOT = "loot_table";
const string DROP = "loot_dropped";
const string PURSE = "coins_carried";

const string TDM = "Team Deathmatch";
const string CTF = "CTF";

enum                Index
{
	MAT_ARROWS = 0,
	MAT_FIREARROWS,
	MAT_BOMBARROWS,
	MAT_WOOD,
	DRILL,
    IRONDRILL,
    STEELDRILL,
	MAT_BOMBS,
	HEART,
	FOOD,
    WATERSKIN,
    BURDOCKSPICE,
    BURNETSPICE,
    EQUISETUMSPICE,
    MINDWORTSPICE,
    POPPYSPICE,
    THYMESPICE
};

const string[]      NAME =
{
	"mat_arrows",
	"mat_firearrows",
	"mat_bombarrows",
	"mat_wood",
	"drill",
    "irondrill",
    "steeldrill",
	"mat_bombs",
	"heart",
	"food",
    "waterskin",
    "burdockspice",
    "burnetspice",
    "equisetumspice",
    "mindwortspice",
    "poppyspice",
    "burnetspice"
};

const u8[]          WEIGHT =
{
	40,                     // mat_arrows
	30,                     // mat_firearrows
	20,                     // mat_bombarrows
	20,                     // mat_wood
	25,                     // drill
    15,                     // irondrill
    5,                      // steeldrill
	45,                     // mat_bombs
	20,                     // heart
	20,                     // food
    25,                     // waterskin
    20,
    20,
    20,
    20,
    20,
    20,                     // spices
};

// pre-set 'CLASS' arrays
// ━━━━━━━━━━━━━━━━━
const u8[]          INDEX_ARCHER =
{
	MAT_ARROWS,
	MAT_FIREARROWS,
	MAT_BOMBARROWS,
    MAT_WOOD,
    DRILL,
    IRONDRILL,
    STEELDRILL,
    WATERSKIN,
    BURDOCKSPICE,
    BURNETSPICE,
    EQUISETUMSPICE,
    MINDWORTSPICE,
    POPPYSPICE,
    THYMESPICE
};

const u8[]          INDEX_ROGUE =
{
	MAT_WOOD,
	DRILL,
    IRONDRILL,
    STEELDRILL,
    WATERSKIN,
    BURDOCKSPICE,
    BURNETSPICE,
    EQUISETUMSPICE,
    MINDWORTSPICE,
    POPPYSPICE,
    THYMESPICE
};

const u8[]          INDEX_KNIGHT =
{
	MAT_BOMBS,
	MAT_WOOD,
	DRILL,
    IRONDRILL,
    STEELDRILL,
    WATERSKIN,
    BURDOCKSPICE,
    BURNETSPICE,
    EQUISETUMSPICE,
    MINDWORTSPICE,
    POPPYSPICE,
    THYMESPICE
};

const u8[]          INDEX_BUILDER =
{
	MAT_BOMBS,
};

// pre-set 'GAMEMODE' arrays
// ━━━━━━━━━━━━━━━━━
const u8[]          INDEX_RPG =
{
	MAT_ARROWS,
	MAT_FIREARROWS,
	MAT_BOMBARROWS,
	MAT_WOOD,
	DRILL,
    IRONDRILL,
    STEELDRILL,
	MAT_BOMBS,
	HEART,
	FOOD,
    WATERSKIN,
    BURDOCKSPICE,
    BURNETSPICE,
    EQUISETUMSPICE,
    MINDWORTSPICE,
    POPPYSPICE,
    THYMESPICE
};


// add a single piece of 'LOOT'
// ━━━━━━━━━━━━━━━━━
// addLoot(this, "mat_bombs");
void addLoot(CBlob@ this, const string &in NAME)
{
	if (!this.exists(LOOT))
	{
		string[] loot_table;
		this.set(LOOT, loot_table);
	}
	this.push(LOOT, NAME);
}

// add multiple pieces of 'LOOT'
// ━━━━━━━━━━━━━━━━━
// const u8[] INDEX = {0, 1, 2, 3};
// addLoot(this, INDEX);
// or
// addLoot(this, INDEX_ARCHER);
void addLoot(CBlob@ this, const u8[]&in INDEX)
{
	for(u8 i = 0; i < INDEX.length; i++)
	{
		addLoot(this, NAME[INDEX[i]]);
	}
}

// add 'count' pieces of 'LOOT' based on 'INDEX'
// ━━━━━━━━━━━━━━━━━
// const u8[] INDEX = {0, 1, 2, 3};
// addLoot(this, INDEX, 1, 0);
// or
// addLoot(this, INDEX_ARCHER, 1, 0);
void addLoot(CBlob@ this, const u8[]&in INDEX, u8 &in count, const u8 &in NONE)
{
    count += XORRandom(3);
	while(count > 0)
	{
		--count;
		const u16 RANDOM = XORRandom(getSumOfWeight(INDEX) + NONE);
		u16 total = 0;
		for(u8 i = 0; i < INDEX.length; i++)
		{
			total += WEIGHT[INDEX[i]];
			if (total > RANDOM)
			{
				addLoot(this, NAME[INDEX[i]]);
				break;
			}
		}
	}
}

// create coins from 'PURSE' and LOOT' from this
// ━━━━━━━━━━━━━━━━━
// createLoot(this, this.getPosition(), this.getTeamNum());
void server_CreateLoot(CBlob@ this, const Vec2f &in POSITION, const u8 &in TEAM)
{
	if (this.exists(DROP))
	{
		return;
	}

	if (this.exists(PURSE))
	{
		server_DropCoins(POSITION, this.get_u16(PURSE));
	}

	string[]@ loot;
	if (this.get(LOOT, @loot))
	{
		for(u8 i = 0; i < loot.length; i++)
		{
			CBlob@ item = server_CreateBlob(loot[i], TEAM, POSITION);
			if (item !is null)
			{
                if (item.getName() == "waterskin") item.Tag("nocollide"); // to prevent emptying it due to colliding
				const f32 ANGLE = XORRandom(300) * 0.1f - 15;
				Vec2f force = Vec2f(0, -1);
				force.RotateBy(ANGLE);
				force *= item.getMass() * 3.6f;
				item.AddForce(force);
			}
		}
	}
	this.Tag(DROP);
	this.Sync(DROP, true);
}

// add 'COUNT' coins to 'PURSE'
// ━━━━━━━━━━━━━━━━━
// addCoin(this, 100);
void addCoin(CBlob@ this, const u16 &in COUNT)
{
	if (!this.exists(PURSE))
	{
		this.set_u16(PURSE, COUNT);
		return;
	}
	this.set_u16(PURSE, this.get_u16(PURSE) + COUNT);
}

// get the 'sum' of 'WEIGHT'
// ━━━━━━━━━━━━━━━━━
// u16 sum = getSumOfWeight(WEIGHT);
u16 getSumOfWeight(const u8[]&in INDEX)
{
	u16 sum = 0;
	for(u8 i = 0; i < INDEX.length; i++)
	{
		sum += WEIGHT[INDEX[i]];
	}
	return sum;
}