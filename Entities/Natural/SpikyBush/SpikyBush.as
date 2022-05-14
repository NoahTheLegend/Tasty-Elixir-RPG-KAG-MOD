#include "MapFlags.as"
#include "Hitters.as"

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.getConsts().mapCollisions = true;
	shape.SetRotationsAllowed(false);
	shape.SetStatic(true);
	this.getSprite().getConsts().accurateLighting = false;
	this.getSprite().SetZ(-50); //background

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.server_setTeamNum(-1);

	this.getCurrentScript().tickFrequency = 30;
	this.set_u16("regrowth", 0);

	this.Tag("builder always hit");
	this.Tag("breakonce");

	CSprite@ sprite = this.getSprite();
 	Animation@ anim = sprite.addAnimation("anim", 0, false);
	int[] frames = {0, 1, 2, 3}; //put your frames here
	anim.AddFrames(frames);
	sprite.SetAnimation("anim");
}

void onTick(CBlob@ this)
{
	if (this.get_u16("regrowth") >= 1) this.set_u16("regrowth", this.get_u16("regrowth") - 1);
	if (this.getHealth() <= this.getInitialHealth()/2 && this.hasTag("breakonce"))
	{
		this.Untag("breakonce");
		this.set_u16("regrowth", 180);
		this.Tag("healonce");
	}

	this.get_u16("regrowth") > 90 ? this.SetVisible(false) : this.SetVisible(true);
	if (this.get_u16("regrowth") == 0 && this.hasTag("healonce"))
	{
		this.Untag("healonce");
		if (isServer()) this.server_SetHealth(this.getInitialHealth());
		this.Tag("breakonce");
	}

	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		if (this.get_u16("regrowth") > 60)
			sprite.SetFrameIndex(3);
		else if (this.get_u16("regrowth") <= 60 && this.get_u16("regrowth") > 30)
			sprite.SetFrameIndex(2);
		else if (this.get_u16("regrowth") <= 30 && this.get_u16("regrowth") > 0)
			sprite.SetFrameIndex(1);
		else sprite.SetFrameIndex(0);
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (this.get_u16("regrowth") > 0) return;
	if (blob !is null && blob.hasTag("flesh"))
	{
		if (isServer()) this.server_Hit(blob, this.getPosition(), blob.getVelocity() * -1, 0.25f, Hitters::spikes, true);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this.get_u16("regrowth") > 0) return 0;
	if (hitterBlob !is null && hitterBlob !is this && customData == Hitters::builder)
	{
		if (isServer()) this.server_Hit(hitterBlob, this.getPosition(), Vec2f(0, 0), 0.125f, Hitters::spikes, false);
	}

	return damage;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}
