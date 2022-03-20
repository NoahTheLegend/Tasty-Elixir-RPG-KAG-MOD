//Auto-mining quarry
//converts wood into ores

#include "GenericButtonCommon.as"

void onInit(CSprite@ this)
{
	CSpriteLayer@ belt = this.addSpriteLayer("belt", "QuarryBelt.png", 32, 32);
	if (belt !is null)
	{
		//default anim
		{
			Animation@ anim = belt.addAnimation("default", 0, true);
			int[] frames = {
				0, 1, 2, 3,
				4, 5, 6, 7,
				8, 9, 10, 11,
				12, 13
			};
			anim.AddFrames(frames);
		}
		//belt setup
		belt.SetOffset(Vec2f(-7.0f, -4.0f));
		belt.SetRelativeZ(1);
		belt.SetVisible(true);
	}

	CSpriteLayer@ wood = this.addSpriteLayer("wood", "Quarry.png", 16, 16);
	if (wood !is null)
	{
		wood.SetOffset(Vec2f(8.0f, -1.0f));
		wood.SetVisible(false);
		wood.SetRelativeZ(1);
	}

	this.SetEmitSound("/Quarry.ogg");
	this.SetEmitSoundPaused(true);
}

void onInit(CBlob@ this)
{
	//building properties
	this.getSprite().SetZ(-50);
	this.getShape().getConsts().mapCollisions = false;
	this.set_u8("rand", XORRandom(100));
}

void onTick(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	if (sprite.getEmitSoundPaused())
	{
		if (true)
		{
			sprite.SetEmitSoundPaused(false);
		}
	}

	//update sprite based on modified or synced properties
	updateWoodLayer(this.getSprite());
	if (getGameTime() % (getTicksASecond()/2) == 0 &&  this.getTickSinceCreated() > this.get_u8("rand")) animateBelt(this, true);
}

void updateWoodLayer(CSprite@ this)
{
	CSpriteLayer@ layer = this.getSpriteLayer("wood");

	if (layer is null) return;

	layer.SetVisible(true);
	int frame = 5;
	layer.SetFrameIndex(frame);
}

void animateBelt(CBlob@ this, bool isActive)
{
	//safely fetch the animation to modify
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;
	CSpriteLayer@ belt = sprite.getSpriteLayer("belt");
	if (belt is null) return;
	Animation@ anim = belt.getAnimation("default");
	if (anim is null) return;

	//modify it based on activity
	if (isActive)
	{
		// slowly start animation
		if (anim.time == 0) anim.time = 6;
		if (anim.time > 3) anim.time--;
	}
	else
	{
		//(not tossing stone)
		if (anim.frame < 2 || anim.frame > 8)
		{
			// slowly stop animation
			if (anim.time == 6) anim.time = 0;
			if (anim.time > 0 && anim.time < 6) anim.time++;
		}
	}
}