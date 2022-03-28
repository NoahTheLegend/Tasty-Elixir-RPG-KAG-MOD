void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		sprite.SetEmitSound("TownAmbience.ogg");
		sprite.SetEmitSoundVolume(0.35f);
		sprite.SetEmitSoundPaused(false);
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return false;
}