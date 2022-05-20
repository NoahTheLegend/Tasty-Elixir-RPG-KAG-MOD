//knight HUD

#include "ActorHUDStartPos.as";
#include "CustomBlocks.as";

const string iconsFilename = "Entities/Characters/Rogue/RogueIcons.png";
const int slotsSize = 6;

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
	this.getBlob().set_u8("gui_HUD_slots_width", slotsSize);
}

void ManageCursors(CBlob@ this)
{
	if (getHUD().hasButtons())
	{
		getHUD().SetDefaultCursor();
	}
	else
	{
		if (this.isAttached() && this.isAttachedToPoint("GUNNER"))
		{
			getHUD().SetCursorImage("Entities/Characters/Archer/ArcherCursor.png", Vec2f(32, 32));
			getHUD().SetCursorOffset(Vec2f(-32, -32));
		}
		else
		{
			getHUD().SetCursorImage("Entities/Characters/Knight/KnightCursor.png", Vec2f(32, 32));
			getHUD().SetCursorOffset(Vec2f(-22, -22));
		}
	}
}

const f32 offsetx = 200;
const f32 offsety = 300;
const f32 scale = 0.5f;
const Vec2f dim = Vec2f(48,48);
const f32 gap = getDriver().getScreenWidth()/15;

void DrawStats(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	if (this is null || blob is null) return;
	if (blob.getPlayer() is null) return;

	Vec2f myPos =  blob.getInterpolatedScreenPos();
	Vec2f cam_offset = getCamera().getInterpolationOffset();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	bool mouseOnBlob = (mouseWorld - blob.getPosition()).getLength() < blob.getRadius();
	u32 width = getDriver().getScreenWidth();
	u32 height = getDriver().getScreenHeight();
	CPlayer@ player = blob.getPlayer();
	if (player is null) return;
	GUI::SetFont("menu"); 

	if (player.isMyPlayer() && isClient())
	{
		if (!player.hasTag("disablestats"))
		{
			//if (mouseOnBlob) // debuff show layout
			//	GUI::DrawText("test", myPos + cam_offset + Vec2f(-10, 50), myPos + cam_offset + Vec2f(-10, 50), color_white, false, false, false);
			GUI::DrawText("Mana / stamina: " + blob.get_u16("mana")+"/"+ blob.get_u16("maxmana"), Vec2f(20, height + -35), SColor(255, 130, 130, 255)); // stats show layout
			GUI::DrawText("Current health: " + blob.getHealth() * 2, Vec2f(20, height + -50), SColor(255, 255, 100, 125));
			if (blob.get_f32("velocity") > 0)
				GUI::DrawText("Agility: " + blob.get_f32("velocity"), Vec2f(20, height + -75), SColor(255, 50, 225, 100));
			else
				GUI::DrawText("Agility: " + 2.5, Vec2f(20, height + -75), SColor(255, 50, 225, 100));
						GUI::DrawText("Lightness: " + blob.get_f32("gravityresist"), Vec2f(20, height + -90), SColor(255, 50, 225, 100));
			GUI::DrawText("Dodge chance: " + blob.get_f32("dodgechance") + "%", Vec2f(20, height + -105), SColor(255, 50, 225, 100));
			GUI::DrawText("Dmg. reduction: " + blob.get_f32("damagereduction") + " HP", Vec2f(20, height + -120), SColor(255, 50, 225, 100));
			GUI::DrawText("Attack speed: " + blob.get_f32("attackspeed"), Vec2f(20, height + -145), SColor(255,  255, 195, 0));
			GUI::DrawText("Additional damage: " + blob.get_f32("damagebuff"), Vec2f(20, height + -160), SColor(255, 255, 195, 0));
			GUI::DrawText("Crit chance: " + blob.get_f32("critchance") + "%", Vec2f(20, height + -175), SColor(255, 255, 195, 0));
			GUI::DrawText("Vampirism: " + blob.get_f32("vampirism")*100 + "%", Vec2f(20, height + -200), SColor(255, 255, 50, 255));
			GUI::DrawText("Penetration: " + blob.get_f32("penetration")*100 + "%", Vec2f(20, height + -215), SColor(255, 255, 50, 255));
			GUI::DrawText("Bash: " + blob.get_f32("bashchance") + "%", Vec2f(20, height + -230), SColor(255, 255, 50, 255));
			GUI::DrawText("Mana regen: " + blob.get_u16("manaregtimer")/30 + " sec. Amount: "  + blob.get_u16("manareg"), Vec2f(20, height + -255), SColor(255, 90, 90, 255));
			GUI::DrawText("HP regen: " + blob.get_u16("hpregtimer")/30 + " sec. Amount: 0.25 HP", Vec2f(20, height + -270), SColor(255, 255, 75, 85));
			if (blob.get_bool("regen")) GUI::DrawText(" + 0.25 HP", Vec2f(254, height + -270), SColor(255, 255, 75, 85));
		}
		if (!player.hasTag("disablestate"))
		{
			GUI::DrawText("Last dealt damage: " + blob.get_f32("dealtdamage") + " HP", Vec2f(15, 15), SColor(255, 222, 222, 16));
			GUI::DrawText("Thirst: " + blob.get_u8("thirst")+"%", Vec2f(15, 45), SColor(255, 11, 146, 202));
			GUI::DrawText("Hunger: " + blob.get_u8("hunger")+"%", Vec2f(15, 60), SColor(255, 255, 140, 4));
			u32 numseconds = (60-((getGameTime()/30)%60));
			string seconds = ""+numseconds;
			if (numseconds < 10) seconds = "0"+numseconds;
			GUI::DrawTextCentered("Time before lying items get removed: "+(((getRules().get_u32("clearFrequency")-getGameTime())/30)/60+":"+seconds), Vec2f(width/2, 15), SColor(255, 255, 100, 0));
			GUI::DrawText("Level: "+player.get_u16("level"), Vec2f(15, 85), SColor(255, 180, 255, 180));
			GUI::DrawText("EXP", Vec2f(27.5, 120), SColor(255, 180, 255, 180));

			float current = player.get_u32("exp");
        	float step = player.get_u32("progressionstep");
			u16 level = player.get_u16("level");
        	f32 res;
			//if (getGameTime()%30==0) printf(""+player.get_u32("exp"));
			if (step > 0) res = current/step*1.0f;
			//if (getGameTime()%10==0) printf("res="+res);
			GUI::DrawProgressBar(Vec2f(15, 105), Vec2f(70, 117.5), res);

			//button that opens skillmenu
			Vec2f mousePos = getControls().getMouseScreenPos();
			bool isOnBtn;
			bool l1 = blob.isKeyPressed(key_action1);
			bool rl1 = blob.isKeyJustReleased(key_action1);
			if (mousePos.x >= 14 && mousePos.y >= 139 && mousePos.x <= 69 && mousePos.y <= 164)
				isOnBtn = true;
			else
				isOnBtn = false;
			if (blob.get_u8("delay")>3) blob.set_u8("delay", blob.get_u8("delay")-1);
			if (isOnBtn) 
			{
				if (rl1) // draw skills button
				{
					if (!blob.hasTag("openWindow") && blob.get_u8("delay") <= 3) 
					{
						blob.Tag("openWindow");
						blob.set_u8("delay", 30);
					}
					else if (blob.get_u8("delay") <= 3)
					{
						blob.Untag("openWindow");
						blob.set_u8("delay", 30);
					}
				}
				if (l1) GUI::DrawButtonPressed(Vec2f(15, 140), Vec2f(70, 165));
				else GUI::DrawButtonHover(Vec2f(15, 140), Vec2f(70, 165));
			}
			else GUI::DrawButton(Vec2f(15, 140), Vec2f(70, 165));

			if (blob.hasTag("openWindow"))
			{
				GUI::DrawWindow(Vec2f(offsetx, offsety), Vec2f(width-offsetx, height-offsety));
				player.set_u8("skillpoints", 15);
				player.set_u8("lvlr1", 10);
				player.set_u8("lvlr2", 10);
				
				Draw1RowSkills(blob);
				Draw2RowSkills(blob);
				Draw3RowSkills(blob);
			}

			GUI::DrawText("Skills", Vec2f(22, 143), SColor(255, 210, 225, 210));
		}
		if (!player.hasTag("helpsheet"))
		{
			GUI::DrawText("E to drink, use, equip armor. CTRL + E to unequip armor", Vec2f(width - 400, 15), SColor(255, 255, 255, 255));
			GUI::DrawText("!help, !commands to see needed info", Vec2f(width - 271, 35), SColor(255, 255, 255, 255));
			GUI::DrawText("You can move skills (drag them to free slots)", Vec2f(width - 320, 55), SColor(255, 255, 255, 255));
		}
	}
}

bool mouseOverIcon(CBlob@ this, Vec2f pos, f32 scale)
{
	f32 size = 64;

	CControls@ controls = this.getControls();
	if (controls is null) return false;
	Vec2f mpos = controls.getMouseScreenPos();

	if (mpos.x >= pos.x && mpos.y >= pos.y
	&& mpos.x <= pos.x+size && mpos.y <= pos.y+size) return true;
	return false;
}

bool canResearchSkill(CBlob@ this, u8 index, u8 row)
{
	CPlayer@ player = this.getPlayer();
	if (player !is null)
	{
		if (player.get_u8("skillpoints") == 0) return false;
		else if (index == 0) return true;
		return hasSkill(player, index, row);
	}
	return false;
}

bool hasSkill(CPlayer@ player, u8 index, u8 row)
{
	if (player.get_u8("lvlr"+row) <= index) return false;
	return true;
}

void onRender(CSprite@ this)
{
	DrawStats(this);

	if (g_videorecording)
		return;

	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();

	CMap@ map = getMap();
	Tile tile = map.getTile(blob.getPosition());

	if (getGameTime() % 30 == 0
	&& tile.type == CMap::tile_abyss_dirt_back
	|| tile.type == CMap::tile_abyss_dirt_back_d0
	|| tile.type == CMap::tile_abyss_dirt_back_d1
	|| tile.type == CMap::tile_abyss_dirt_back_d2)
	{
		if (blob.isMyPlayer()) SetScreenFlash(100, 0, 0, 0, 5.0f);
	}

	ManageCursors(blob);

	// draw inventory

	Vec2f tl = getActorHUDStartPosition(blob, slotsSize);
	DrawInventoryOnHUD(blob, tl);

	u8 type = blob.get_u8("bomb type");
	u8 frame = 1;
	if (type == 0)
	{
		frame = 0;
	}
	else if (type < 255)
	{
		frame = 1 + type;
	}

	// draw coins

	const int coins = player !is null ? player.getCoins() : 0;
	DrawCoinsOnHUD(blob, coins, tl, slotsSize - 2);

	// draw class icon

	if (player is null) return;

	GUI::DrawIcon(iconsFilename, frame, Vec2f(16, 32), tl + Vec2f(8 + (slotsSize - 1) * 40, -16), 1.0f);
}


void Draw1RowSkills(CBlob@ blob)
{
	DrawSkill(blob, "DodgeIcon.png", 0, 1, false, 0, 0);
	DrawSkill(blob, "AmbushIcon.png", 1, 1, true, gap, 0);
	DrawSkill(blob, "DoublestabIcon.png", 2, 1, true, gap*2, 0);
	DrawSkill(blob, "ForesightIcon.png", 3, 1, true, gap*3, 0);
	DrawSkill(blob, "RudeshockIcon.png", 4, 1, true, gap*4, 0);
	DrawSkill(blob, "TendonundercutIcon.png", 5, 1, true, gap*5, 0);
	DrawSkill(blob, "SpikeballsIcon.png", 6, 1, true, gap*6, 0);
	DrawSkill(blob, "ThrowingknivesIcon.png", 7, 1, true, gap*7, 0);
	DrawSkill(blob, "DeflectIcon.png", 8, 1, true, gap*8, 0);
	DrawSkill(blob, "FlurryIcon.png", 9, 1, true, gap*9, 0);
}

void Draw2RowSkills(CBlob@ blob)
{
	const u8 gapy = 86;
	DrawSkill(blob, "PrickinghitIcon.png", 0, 2, false, 0, gapy);
	DrawSkill(blob, "PoisonedhitIcon.png", 1, 2, true, gap, gapy);
	DrawSkill(blob, "BloodlustIcon.png", 2, 2, true, gap*2, gapy);
	DrawSkill(blob, "ParalysisdartIcon.png", 3, 2, true, gap*3, gapy);
	DrawSkill(blob, "PoisoncloudIcon.png", 4, 2, true, gap*4, gapy);
	DrawSkill(blob, "IlluminationIcon.png", 5, 2, true, gap*5, gapy);
	DrawSkill(blob, "InternalinstabilityIcon.png", 6, 2, true, gap*6, gapy);
	DrawSkill(blob, "FlawIcon.png", 7, 2, true, gap*7, gapy);
	DrawSkill(blob, "ShadowdaggersIcon.png", 8, 2, true, gap*8, gapy);
	DrawSkill(blob, "ShadowessenceIcon.png", 9, 2, true, gap*9, gapy);
}

void Draw3RowSkills(CBlob@ blob)
{
	const u8 gapy = 86*2;
	DrawSkill(blob, "Indevelopment.png", 0, 3, false, 0, gapy);
	DrawSkill(blob, "Indevelopment.png", 1, 3, true, gap, gapy);
	DrawSkill(blob, "Indevelopment.png", 2, 3, true, gap*2, gapy);
	DrawSkill(blob, "Indevelopment.png", 3, 3, true, gap*3, gapy);
	DrawSkill(blob, "Indevelopment.png", 4, 3, true, gap*4, gapy);
	DrawSkill(blob, "Indevelopment.png", 5, 3, true, gap*5, gapy);
	DrawSkill(blob, "Indevelopment.png", 6, 3, true, gap*6, gapy);
	DrawSkill(blob, "Indevelopment.png", 7, 3, true, gap*7, gapy);
	DrawSkill(blob, "Indevelopment.png", 8, 3, true, gap*8, gapy);
	DrawSkill(blob, "Indevelopment.png", 9, 3, true, gap*9, gapy);
}

void DrawSkill(CBlob@ blob, string filename, u8 lvl, u8 row, bool hasArrow, u16 gapx, u8 gapy)
{
	GUI::DrawIcon(filename, 0, dim, Vec2f(offsetx+32+gapx, offsety+32+gapy), scale);
	if (hasArrow && canResearchSkill(blob, lvl, row)) GUI::DrawArrow2D(Vec2f(offsetx+32+50+gapx-gap, offsety+32+24+gapy), Vec2f(offsetx+32+gapx-2, offsety+32+24+gapy), SColor(255,0,0,0));
	if (!canResearchSkill(blob, lvl, row))
		GUI::DrawRectangle(Vec2f(offsetx+32+gapx, offsety+32+gapy), Vec2f(offsetx+32+48+gapx, offsety+32+48+gapy), SColor(150, 0, 0, 0));
	else if (mouseOverIcon(blob, Vec2f(offsetx+32+gapx, offsety+32+gapy), scale))
		GUI::DrawRectangle(Vec2f(offsetx+32+gapx, offsety+32+gapy), Vec2f(offsetx+32+48+gapx, offsety+32+48+gapy), SColor(100, 255, 255, 255));
}