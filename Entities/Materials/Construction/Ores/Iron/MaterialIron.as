
void onInit(CBlob@ this)
{
  this.maxQuantity = 150;

  this.getCurrentScript().runFlags |= Script::remove_after_this;
}
