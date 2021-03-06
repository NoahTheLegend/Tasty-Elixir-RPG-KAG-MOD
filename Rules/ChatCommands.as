// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out
// By the way, in case you couldn't tell, "mat" stands for "material(s)"

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";
#include "SkillsCommon.as";

const bool chatCommandCooldown = false; // enable if you want cooldown on your server
const uint chatCommandDelay = 3 * 30; // Cooldown in seconds
const string[] blacklistedItems = {
	"hall",         // grief
	"shark",        // grief spam
	"bison",        // grief spam
	"necromancer",  // annoying/grief
	"greg",         // annoying/grief
	"ctf_flag",     // sound spam
	"flag_base"     // sound spam + bedrock grief
};

void onInit(CRules@ this)
{
	this.addCommandID("SendChatMessage");
}

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	//--------MAKING CUSTOM COMMANDS-------//
	// Making commands is easy - Here's a template:
	//
	// if (text_in == "!YourCommand")
	// {
	//	// what the command actually does here
	// }
	//
	// Switch out the "!YourCommand" with
	// your command's name (i.e., !cool)
	//
	// Then decide what you want to have
	// the command do
	//
	// Here are a few bits of code you can put in there
	// to make your command do something:
	//
	// blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 10.0f, 0);
	// Deals 10 damage to the player that used that command (20 hearts)
	//
	// CBlob@ b = server_CreateBlob('mat_wood', -1, pos);
	// insert your blob/the thing you want to spawn at 'mat_wood'
	//
	// player.server_setCoins(player.getCoins() + 100);
	// Adds 100 coins to the player's coins
	//-----------------END-----------------//

	// cannot do commands while dead

	if (player is null)
		return true;

	CBlob@ blob = player.getBlob(); // now, when the code references "blob," it means the player who called the command

	if (blob is null || text_in.substr(0, 1) != "!") // dont continue if its not a command
	{
		return true;
	}

	const Vec2f pos = blob.getPosition(); // grab player position (x, y)
	const int team = blob.getTeamNum(); // grab player team number (for i.e. making all flags you spawn be your team's flags)
	const bool isMod = player.isMod();
	const string gamemode = this.gamemode_name;
	bool wasCommandSuccessful = true; // assume command is successful 
	string errorMessage = ""; // so errors can be printed out of wasCommandSuccessful is false
	SColor errorColor = SColor(255,255,0,0); // ^

	if (!isMod && this.hasScript("Sandbox_Rules.as") || chatCommandCooldown) // chat command cooldown timer
	{
		uint lastChatTime = 0;
		if (blob.exists("chat_last_sent"))
		{
			lastChatTime = blob.get_u16("chat_last_sent");
			if (getGameTime() < lastChatTime)
			{
				return true;
			}
		}
	}
	
	// commands that don't rely on sv_test being on (sv_test = 1)

	if (isMod)
	{
		string[] args = text_in.split(" ");
		if (text_in == "!givespice")
		{
			CBlob@ blob1 = server_CreateBlob("burdockspice", 0, blob.getPosition());
			CBlob@ blob2 = server_CreateBlob("burnetspice", 0, blob.getPosition());
			CBlob@ blob3 = server_CreateBlob("equisetumspice", 0, blob.getPosition());
			CBlob@ blob4 = server_CreateBlob("mindwortspice", 0, blob.getPosition());
			CBlob@ blob5 = server_CreateBlob("poppyspice", 0, blob.getPosition());
			CBlob@ blob6 = server_CreateBlob("thymespice", 0, blob.getPosition());

			return true;
		}
		else if (args.length == 3 && args[0] == "!write")
		{
			if (args[1] == "f32")
			{
				printf(args[1]+" "+args[2]+" on server: "+blob.get_f32(args[2]));
			}
			else if (args[1] == "u16")
			{
				printf(args[1]+" "+args[2]+" on server: "+blob.get_u16(args[2]));
			}
			else if (args[1] == "bool")
			{
				printf(args[1]+" "+args[2]+" on server: "+blob.get_bool(args[2]));
			}
			else if (args[1] == "string")
			{
				printf(args[1]+" "+args[2]+" on server: "+blob.get_string(args[2]));
			}
		}
		else if (player.isMod() && (text_in == "!addxp" || (args.length == 2 && args[0] == "!addxp")))
		{
			if (args.length > 1)
			{
				player.set_u32("exp", player.get_u32("exp") + parseFloat(args[1]));
			}
			else player.set_u32("exp", player.get_u32("exp") + 100);
			printf("added xp");
		}
		else if (player.isMod() && args.length == 3 && args[0] == "!addskill")
		{
			u16 index = parseFloat(args[2]);
			string type = args[1];
			CBlob@ blob = player.getBlob();
			if (blob !is null)
			{
				giveSkill(blob, type, index);
			}
		}
		else if (text_in == "!resetskills")
		{
			CBlob@ blob = player.getBlob();
			if (player is null) return false;
			string name = blob.getName();
			player.set_u32("exp", 0);

			u16 klr1 = player.get_u16("knightlvlr1")-1;
			u16 klr2 = player.get_u16("knightlvlr2")-1;
			u16 alr1 = player.get_u16("archerlvlr1")-1;
			u16 alr2 = player.get_u16("archerlvlr2")-1;
			u16 rlr1 = player.get_u16("roguelvlr1")-1;
			u16 rlr2 = player.get_u16("roguelvlr2")-1;

			player.set_u16("skillpoints", klr1+klr2+alr1+alr2+rlr1+rlr2);
			if (player.get_u16("skillpoints") == 0) player.set_u16("skillpoints", 1);
			printf("reset");

			player.set_u16("knightlvlr1", 1);
			player.set_u16("knightlvlr2", 1);
			player.set_u16("archerlvlr1", 1);
			player.set_u16("archerlvlr2", 1);
			player.set_u16("roguelvlr1", 1);
			player.set_u16("roguelvlr2", 1);
			player.set_u16("level", 0);
			for (u8 i = 1; i <= 20; i++)
			{
				player.set_u16("hasskill"+i, 255);
			}
			player.Tag("resetTags");
		}
		else if (args.length == 2 && args[0] == "!takeskill")
		{
			u8 pos = parseFloat(args[1]);
			CBlob@ blob = player.getBlob();
			if (blob !is null)
			{
				takeSkill(blob, pos);
				CPlayer@ player = blob.getPlayer();
				if (player !is null) player.set_u16("skillpoints", player.get_u16("skillpoints") + 1);
			}
		}
		else if (args.length >= 2 && args[0] == "!set")
		{
			string alloy = args[1];

			CBlob@ blob1 = server_CreateBlob(alloy+"_boots", 0, blob.getPosition());
			CBlob@ blob2 = server_CreateBlob(alloy+"_gloves", 0, blob.getPosition());
			CBlob@ blob3 = server_CreateBlob(alloy+"_chestplate", 0, blob.getPosition());
			CBlob@ blob4 = server_CreateBlob(alloy+"_helmet", 0, blob.getPosition());

			if (args.length == 3 && args[2] == "wep")
			{
				CBlob@ blob5 = server_CreateBlob(alloy+"_sword", 0, blob.getPosition());
				CBlob@ blob6 = server_CreateBlob(alloy+"_shield", 0, blob.getPosition());
				CBlob@ blob7 = server_CreateBlob(alloy+"_dagger", 0, blob.getPosition());
				CBlob@ blob8 = server_CreateBlob(alloy+"_bow", 0, blob.getPosition());
			}
		}
		else if (text_in == "!poisonme")
		{
			CBitStream params;
			params.write_u16(2);
			params.write_u32(XORRandom(900)+900);
			blob.SendCommand(blob.getCommandID("receive_effect"), params);
		}
		else if (text_in == "!bleedme")
		{
			CBitStream params;
			params.write_u16(3);
			params.write_u32(XORRandom(300)+300);
			blob.SendCommand(blob.getCommandID("receive_effect"), params);
		}
		else if (text_in == "!glowness")
		{
			printf("glowness1");
			blob.SetLight(true);
			blob.SetLightColor(SColor(255, 255, 255, 0));
			blob.SetLightRadius(25.0f);
		}
		else if (text_in == "!glowness2")
		{
			printf("glowness2");
			blob.SetLight(true);
			blob.SetLightColor(SColor(255, 255, 255, 0));
			blob.SetLightRadius(50.0f);
		}
		else if (text_in == "!bot")
		{
			AddBot("Henry");
			return true;
		}
		else if (text_in == "!tp")
		{
			blob.set_bool("tp", true);
			blob.Sync("tp", true);
		}
		else if (text_in == "!notp")
		{
			blob.set_bool("tp", false);
			blob.Sync("tp", true);
		}
		else if (text_in == "!debug")
		{
			CBlob@[] all;
			getBlobs(@all);

			for (u32 i = 0; i < all.length; i++)
			{
				CBlob@ blob = all[i];
				print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");
			}
		}
		else if (text_in == "!endgame")
		{
			this.SetCurrentState(GAME_OVER); //go to map vote
			return true;
		}
		else if (text_in == "!startgame")
		{
			this.SetCurrentState(GAME);
			return true;
		}
	}

	// spawning things

	// these all require sv_test - no spawning without it
	// some also require the player to have mod status (!spawnwater)

	if (sv_test)
	{
		if (text_in == "!tree") // pine tree (seed)
		{
			server_MakeSeed(pos, "tree_pine", 600, 1, 16);
		}
		else if (text_in == "!btree") // bushy tree (seed)
		{
			server_MakeSeed(pos, "tree_bushy", 400, 2, 16);
		}
		else if (text_in == "!allarrows") // 30 normal arrows, 2 water arrows, 2 fire arrows, 1 bomb arrow (full inventory for archer)
		{
			server_CreateBlob('mat_arrows', -1, pos);
			server_CreateBlob('mat_waterarrows', -1, pos);
			server_CreateBlob('mat_firearrows', -1, pos);
			server_CreateBlob('mat_bombarrows', -1, pos);
		}
		else if (text_in == "!arrows") // 3 mats of 30 arrows (90 arrows)
		{
			for (int i = 0; i < 3; i++)
			{
				server_CreateBlob('mat_arrows', -1, pos);
			}
		}
		else if (text_in == "!allbombs") // 2 normal bombs, 1 water bomb
		{
			for (int i = 0; i < 2; i++)
			{
				server_CreateBlob('mat_bombs', -1, pos);
			}
			server_CreateBlob('mat_waterbombs', -1, pos);
		}
		else if (text_in == "!bombs") // 3 (unlit) bomb mats
		{
			for (int i = 0; i < 3; i++)
			{
				server_CreateBlob('mat_bombs', -1, pos);
			}
		}
		else if (text_in == "!spawnwater" && player.isMod())
		{
			getMap().server_setFloodWaterWorldspace(pos, true);
		}
		/*else if (text_in == "!drink") // removes 1 water tile roughly at the player's x, y, coordinates (I notice that it favors the bottom left of the player's sprite)
		{
			getMap().server_setFloodWaterWorldspace(pos, false);
		}*/
		else if (text_in == "!seed")
		{
			// crash prevention?
		}
		else if (text_in == "!crate")
		{
			client_AddToChat("usage: !crate BLOBNAME [DESCRIPTION]", SColor(255, 255, 0, 0)); //e.g., !crate shark Your Little Darling
			server_MakeCrate("", "", 0, team, Vec2f(pos.x, pos.y - 30.0f));
		}
		else if (text_in == "!coins") // adds 100 coins to the player's coins
		{
			player.server_setCoins(player.getCoins() + 100);
		}
		else if (text_in == "!coinoverload") // + 10000 coins
		{
			player.server_setCoins(player.getCoins() + 10000);
		}
		else if (text_in == "!fishyschool") // spawns 12 fishies
		{
			for (int i = 0; i < 12; i++)
			{
				server_CreateBlob('fishy', -1, pos);
			}
		}
		else if (text_in == "!chickenflock") // spawns 12 chickens
		{
			for (int i = 0; i < 12; i++)
			{
				server_CreateBlob('chicken', -1, pos);
			}
		}
		else if (text_in == "!allmats") // 500 wood, 500 stone, 100 gold
		{
			//wood
			CBlob@ wood = server_CreateBlob('mat_wood', -1, pos);
			wood.server_SetQuantity(500); // so I don't have to repeat the server_CreateBlob line again
			//stone
			CBlob@ stone = server_CreateBlob('mat_stone', -1, pos);
			stone.server_SetQuantity(500);
			//gold
			CBlob@ gold = server_CreateBlob('mat_gold', -1, pos);
			gold.server_SetQuantity(100);
		}
		else if (text_in == "!woodstone") // 250 wood, 500 stone
		{
			server_CreateBlob('mat_wood', -1, pos);

			for (int i = 0; i < 2; i++)
			{
				server_CreateBlob('mat_stone', -1, pos);
			}
		}
		else if (text_in == "!stonewood") // 500 wood, 250 stone
		{
			server_CreateBlob('mat_stone', -1, pos);

			for (int i = 0; i < 2; i++)
			{
				server_CreateBlob('mat_wood', -1, pos);
			}
		}
		else if (text_in == "!wood") // 250 wood
		{
			server_CreateBlob('mat_wood', -1, pos);
		}
		else if (text_in == "!stones" || text_in == "!stone") // 250 stone
		{
			server_CreateBlob('mat_stone', -1, pos);
		}
		else if (text_in == "!gold") // 200 gold
		{
			for (int i = 0; i < 4; i++)
			{
				server_CreateBlob('mat_gold', -1, pos);
			}
		}
		// removed/commented out since this can easily be abused...
		/*else if (text_in == "!sharkpit") // spawns 5 sharks, perfect for making shark pits
		{
			for (int i = 0; i < 5; i++)
			{
				CBlob@ b = server_CreateBlob('shark', -1, pos);
			}
		}
		else if (text_in == "!bisonherd") // spawns 5 bisons
		{
			for (int i = 0; i < 5; i++)
			{
				CBlob@ b = server_CreateBlob('bison', -1, pos);
			}
		}*/
		else
		{
			string[]@ tokens = text_in.split(" ");

			if (tokens.length > 1)
			{
				//(see above for crate parsing example)
				if (tokens[0] == "!crate")
				{
					string item = tokens[1];

					if (!isMod && isBlacklisted(item))
					{
						wasCommandSuccessful = false;
						errorMessage = "blob is currently blacklisted";
					}
					else
					{
						int frame = item == "catapult" ? 1 : 0;
						string description = tokens.length > 2 ? tokens[2] : item;
						server_MakeCrate(item, description, frame, -1, Vec2f(pos.x, pos.y));
					}
				}
				// eg. !team 2
				else if (tokens[0] == "!team")
				{
					// Picks team color from the TeamPalette.png (0 is blue, 1 is red, and so forth - if it runs out of colors, it uses the grey "neutral" color)
					int team = parseInt(tokens[1]);
					blob.server_setTeamNum(team);
					// We should consider if this should change the player team as well, or not.
				}
				else if (tokens[0] == "!scroll")
				{
					string s = tokens[1];
					for (uint i = 2; i < tokens.length; i++)
					{
						s += " " + tokens[i];
					}
					server_MakePredefinedScroll(pos, s);
				}
				else if(tokens[0] == "!coins")
				{
					int money = parseInt(tokens[1]);
					player.server_setCoins(money);
				}
			}
			else
			{
				string name = text_in.substr(1, text_in.size());
				if (!isMod && isBlacklisted(name))
				{
					wasCommandSuccessful = false;
					errorMessage = "blob is currently blacklisted";
				}
				else
				{
					CBlob@ newBlob = server_CreateBlob(name, team, Vec2f(0, -5) + pos); // currently any blob made will come back with a valid pointer

					if (newBlob !is null)
					{
						if (newBlob.getName() != name)  // invalid blobs will have 'broken' names
						{
							wasCommandSuccessful = false;
							errorMessage = "blob " + text_in + " not found";
						}
					}
				}
			}
		}
	}

	if (wasCommandSuccessful)
	{
		blob.set_u16("chat_last_sent", getGameTime() + chatCommandDelay);
	}
	else if(errorMessage != "") // send error message to client
	{
		CBitStream params;
		params.write_string(errorMessage);

		// List is reverse so we can read it correctly into SColor when reading
		params.write_u8(errorColor.getBlue());
		params.write_u8(errorColor.getGreen());
		params.write_u8(errorColor.getRed());
		params.write_u8(errorColor.getAlpha());

		this.SendCommand(this.getCommandID("SendChatMessage"), params, player);
	}

	return true;
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	string[]@ args = text_in.split(" ");
	if (text_in == "!commands")
	{
		if (isClient() && player.isMyPlayer()) client_AddToChat("!help for basic info\n!soundtracks to disable and enable soundtracks", SColor(255, 50, 50, 50));
		if (isClient() && player.isMyPlayer()) client_AddToChat("!showstats to disable and enable stats list\n!showstate to disable and enable state list", SColor(255, 50, 50, 50));
		if (isClient() && player.isMyPlayer()) client_AddToChat("!showhelp to disable and enable the help sheet", SColor(255, 50, 50, 50));
		if (isClient() && player.isMyPlayer()) client_AddToChat("!showall to disable and enable HUD", SColor(255, 50, 50, 50));
	}
	else if (args.length == 3 && args[0] == "!write")
	{
		CBlob@ blob = player.getBlob();
		if (blob is null) return false;
		if (args[1] == "f32")
		{
			printf(args[1]+" "+args[2]+" on client: "+blob.get_f32(args[2]));
		}
		else if (args[1] == "u16")
		{
			printf(args[1]+" "+args[2]+" on client: "+blob.get_u16(args[2]));
		}
		else if (args[1] == "bool")
		{
			printf(args[1]+" "+args[2]+" on client: "+blob.get_bool(args[2]));
		}
		else if (args[1] == "string")
		{
			printf(args[1]+" "+args[2]+" on client: "+blob.get_string(args[2]));
		}
	}
	else if (text_in == "!showstats")
	{
		string state;

		if (!player.hasTag("disablestats")) 
		{
			player.Tag("disablestats");
			state = "disabled";
		}
		else if (player.hasTag("disablestats"))
		{
			player.Untag("disablestats");
			state = "enabled";
		}

		if (isClient() && player.isMyPlayer()) 
		{
			client_AddToChat("Stats: "+state, SColor(255, 255, 0, 0));
		}
	}
	else if (text_in == "!showhelp")
	{
		string state;

		if (!player.hasTag("helpsheet")) 
		{
			player.Tag("helpsheet");
			state = "disabled";
		}
		else if (player.hasTag("helpsheet"))
		{
			player.Untag("helpsheet");
			state = "enabled";
		}

		if (isClient() && player.isMyPlayer()) 
		{
			client_AddToChat("Help sheet: "+state, SColor(255, 255, 0, 0));
		}
	}
	else if (text_in == "!showstate")
	{
		string state;

		if (!player.hasTag("disablestate")) 
		{
			player.Tag("disablestate");
			state = "disabled";
		}
		else if (player.hasTag("disablestate"))
		{
			player.Untag("disablestate");
			state = "enabled";
		}

		if (isClient() && player.isMyPlayer()) 
		{
			client_AddToChat("State: "+state, SColor(255, 255, 0, 0));
		}
	}
	else if (text_in == "!showall")
	{
		string state;

		if (!player.hasTag("disableall")) 
		{
			player.Tag("disablestats");
			player.Tag("disablestate");
			player.Tag("helpsheet");
			player.Tag("disableall");
			state = "disabled";
		}
		else if (player.hasTag("disableall"))
		{
			player.Untag("disablestats");
			player.Untag("disablestate");
			player.Untag("helpsheet");
			player.Untag("disableall");
			state = "enabled";
		}

		if (isClient() && player.isMyPlayer()) 
		{
			client_AddToChat("Everything: "+state, SColor(255, 255, 0, 0));
		}
	}
	else if (text_in == "!help")
	{
		if (isClient() && player.isMyPlayer()) client_AddToChat("This is non-necessary role-play gamemode.\nYou may follow RP speech on your own\n", SColor(255, 50, 50, 50));
		if (isClient() && player.isMyPlayer()) client_AddToChat("Rules:\n1. Do not grief or ruin fun of other people.\n2. If you found a bug, please, tell it to salty Snek.\n3. Respect and follow adequant asks of other.\n", SColor(255, 50, 50, 50));
		if (isClient() && player.isMyPlayer()) client_AddToChat("What do i do here?\n\nYou're in a rogue-like RPG game!\nFight mobs, bosses and loot dungeons!\nYou may also trade with NPC or other players to get some money\n", SColor(255, 50, 50, 50));
		if (isClient() && player.isMyPlayer()) client_AddToChat("Controls: WASD to move, left mouse button to attack, right mouse button to use secondary ability, E to interact with stuff\nYou might also have skills to use, check a button that activates it!\n", SColor(255, 50, 50, 50));
		if (isClient() && player.isMyPlayer()) client_AddToChat("To equip an armor or weapons hold it and press E button. To unequip, hold left control and press E button.\nYou can also scroll chat with SHIFT+ARROW_UP or SHIFT+ARROW_DOWN", SColor(255, 50, 50, 50));
		if (isClient() && player.isMyPlayer()) client_AddToChat("Skillset: G-H-J-K-L", SColor(255, 50, 50, 50));
		return true;
	}
	else if (text_in == "!soundtracks")
	{
		string state;

		if (!player.hasTag("disablesoundtracks")) 
		{
			player.Tag("disablesoundtracks");
			state = "disabled";
		}
		else if (player.hasTag("disablesoundtracks"))
		{
			player.Untag("disablesoundtracks");
			state = "enabled";
		}

		if (isClient() && player.isMyPlayer()) 
		{
			client_AddToChat("Soundtracks: "+state, SColor(255, 255, 0, 0));
		}
	}
	else if (text_in == "!debug" && !getNet().isServer())
	{
		// print all blobs
		CBlob@[] all;
		getBlobs(@all);

		for (u32 i = 0; i < all.length; i++)
		{
			CBlob@ blob = all[i];
			print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");

			if (blob.getShape() !is null)
			{
				CBlob@[] overlapping;
				if (blob.getOverlapping(@overlapping))
				{
					for (uint i = 0; i < overlapping.length; i++)
					{
						CBlob@ overlap = overlapping[i];
						print("       " + overlap.getName() + " " + overlap.isLadder());
					}
				}
			}
		}
	}
	/* //causes lag, fix later
	else if (text_in != "")
	{
		CBlob@[] signs;
		CMap@ map = blob.getMap();
		map.getBlobsInRadius(blob.getPosition(), 128.0f, signs);
		u16 signid;
		for (int i = 0; i < signs.length; i++)
		{
			if (signs[i] !is null)
			{
				if (signs[i].getName() == "smallsign") 
				{
					signid = signs[i].getNetworkID();
					break;
				}
			}
		}
		
		CBlob@ sign = getBlobByNetworkID(signid);
		if (sign !is null)
		{
			if (text_in == sign.get_string("key") && !sign.hasTag("guessed"))
			{
				sign.set_string("text", sign.get_string("text") + "\nAlready answered!");
				if (isClient()) client_AddToChat("It is correct answer!");
				sign.Tag("guessed");
			}
		}
	}
	*/
	return true;
}

void onCommand(CRules@ this, u8 cmd, CBitStream @para)
{
	if (cmd == this.getCommandID("SendChatMessage"))
	{
		string errorMessage = para.read_string();
		SColor col = SColor(para.read_u8(), para.read_u8(), para.read_u8(), para.read_u8());
		client_AddToChat(errorMessage, col);
	}
}

bool isBlacklisted(string name)
{
	return blacklistedItems.find(name) != -1;
}	