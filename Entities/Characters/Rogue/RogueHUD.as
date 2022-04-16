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
			getHUD().SetCursorImage("Entities/Characters/Rogue/KnightCursor.png", Vec2f(32, 32));
		}
	}
}

void DrawStats(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	if (this is null || blob is null) return;
	if (blob.getPlayer() is null) return;

	Vec2f myPos =  blob.getInterpolatedScreenPos();
	Vec2f cam_offset = getCamera().getInterpolationOffset();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	bool mouseOnBlob = (mouseWorld - blob.getPosition()).getLength() < blob.getRadius();
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
			GUI::DrawText("Damage reduction: " + blob.get_f32("damagereduction") + " hearts", Vec2f(20, height + -120), SColor(255, 50, 225, 100));
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
		}
	}
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


