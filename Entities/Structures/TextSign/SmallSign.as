
const string[] RIDDLE_SAMPLES = {
	"What do you throw out when you want to use it, but take in when you don’t want to use it?", //anchor
	"What’s greater than God, Eviler than the Devil, Rich People need it, Poor People have it, And you’ll die if you eat it?", //nothing
	"What a thing can you never eat for breakfast?", //dinner
	"I fly, yet I have no wings, I cry, yet I have no eyes, Darkness follows me, Lower light I never see. Who am i, tell me?", //cloud
	"I am always hungry, I must always be fed, The finger I touch, Will soon turn red", //fire
	"What is full of holes but still holds water?", //sponge
	"I’m tall when I’m young, and I’m short when I’m old. What am I?", //candle
	"What is always in front of you but can’t be seen?", //future
	"You walk into a room that contains a match, a kerosene lamp, a candle and a fireplace. What would you light first?", //a match, lmao
	"It can't speak, but will be replying when spoken. What's that?", //echo
	"The more of this there is, the less you see that. What's that?", //darkness
	"I have hands, but I cant clap. I have arrows, but I cant shoot. What am I?", //clocks
	"What is cut on a table, but is never eaten?", //cards
	"I am beautiful, up in the sky. I am magical, yet I cannot fly. To people I bring luck, to some people, riches.\nThe boy at my end does whatever he wishes. What am I?", //rainbow
	"They try to beat me, they try in vain. And when I win, I end the pain.", //death
	"A precious stone, as clear as diamond. Seek it out while the sun's near the horizon.\nThough you can walk on water with its power, try to grab it, and it'll vanish in an hour.", //ice
	"By Moon or by Sun, I shall be found. Yet I am undone, if there's no light around.", //shadow
	"Thirty men and ladies two, gathered for a festive do; Dressed quite formal, black and white; soon movement turned to nasty fight.", //chess
	"When it shines, its light is hazy. Makes the oceans swell like crazy. It makes moods seem more romantic, But it makes the ladies frantic." //moon
};

const string[] RIDDLE_KEYS = {
	"anchor",
	"nothing",
	"dinner",
	"cloud",
	"fire",
	"sponge",
	"candle",
	"future",
	"match",
	"echo",
	"darkness",
	"clocks",
	"cards",
	"rainbod",
	"death",
	"shadow",
	"chess",
	"moon"
};

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	u8 random = XORRandom(RIDDLE_SAMPLES.length - 1);
	this.set_string("text", RIDDLE_SAMPLES[random]);
	this.set_string("key", RIDDLE_KEYS[random]);
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Vec2f center = blob.getPosition();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	const f32 renderRadius = (blob.getRadius()) * 1.50f;
	bool mouseOnBlob = (mouseWorld - center).getLength() < renderRadius;

	if (blob is null) return;

	if (getHUD().menuState != 0) return;

	CBlob@ localBlob = getLocalPlayerBlob();
	Vec2f pos2d = blob.getScreenPos();

	if (localBlob is null) return;

	if (((localBlob.getPosition() - blob.getPosition()).Length() < 0.5f * (localBlob.getRadius() + blob.getRadius())) &&
	   (!getHUD().hasButtons()) || (mouseOnBlob))
	{
		// draw drop time progress bar
		int top = pos2d.y - 2.5f * blob.getHeight() + 0.0f; //y offset
		int left = 0.0f; //x offset
		if (blob.get_string("text").length >= 29) left = 150.0f; //set to side if string is too long
		int margin = 4;
		Vec2f dim;
		string label = getTranslatedString(blob.get_string("text"));
		label += "\n";
		GUI::SetFont("menu");
		GUI::GetTextDimensions(label , dim);
		dim.x = Maths::Min(dim.x, 200.0f);
		dim.x += margin;
		dim.y += margin;
		dim.y *= 1.0f;
		top += dim.y;
		Vec2f upperleft(pos2d.x - dim.x / 2 - left, top - Maths::Min(int(2 * dim.y), 250));
		Vec2f lowerright(pos2d.x + dim.x / 2 - left, top - dim.y);
		GUI::DrawText(label, Vec2f(upperleft.x + margin, upperleft.y + margin + margin),
		              Vec2f(upperleft.x + margin + dim.x, upperleft.y + margin + dim.y),
		              SColor(255, 0, 0, 0), false, false, true);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller is null) return;
	if (!this.isOverlapping(caller)) return;

	CBlob@ carried = caller.getCarriedBlob();
	if(carried !is null && carried.getName() == "paper")
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		params.write_u16(carried.getNetworkID());

		CButton@ buttonWrite = caller.CreateGenericButton("$icon_paper$", Vec2f(0, 0), this, this.getCommandID("write"), "Write something on the sign.", params);
		if (this.get_string("text") != "" && (this.get_string("text").length <= 1000))
		{
			CButton@ buttonWrite = caller.CreateGenericButton("$icon_paper$", Vec2f(0, -6), this, this.getCommandID("addwrite"), "Write another sentence.", params);
		}
	}
}
