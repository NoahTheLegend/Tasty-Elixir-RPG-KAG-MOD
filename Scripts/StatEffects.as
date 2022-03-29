#include "StatEffectsCommon.as";

void onInit(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob !is null)
    {   // index_name_variable`variable`...
        blob.set_string("eff1", "");
        blob.set_string("eff2", "");
        blob.set_string("eff3", "");
        blob.set_string("eff4", "");
        blob.set_string("eff5", "");
        blob.set_string("eff6", "");
        blob.set_string("eff7", "");
        blob.set_string("eff8", "");
        blob.set_string("eff9", "");
        blob.set_string("eff10", "");
    }
}

void onRender(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob is null || !blob.isMyPlayer()) return;
    
    u16 scrwidth = getDriver().getScreenWidth();
    u16 scrheight = getDriver().getScreenHeight();

    if (blob.get_u16("timer1") <= 0) blob.set_string("eff1", "");
    if (blob.get_u16("timer2") <= 0) blob.set_string("eff2", "");
    if (blob.get_u16("timer3") <= 0) blob.set_string("eff3", "");
    if (blob.get_u16("timer4") <= 0) blob.set_string("eff4", "");
    if (blob.get_u16("timer5") <= 0) blob.set_string("eff5", "");
    if (blob.get_u16("timer6") <= 0) blob.set_string("eff6", "");
    if (blob.get_u16("timer7") <= 0) blob.set_string("eff7", "");
    if (blob.get_u16("timer8") <= 0) blob.set_string("eff8", "");
    if (blob.get_u16("timer9") <= 0) blob.set_string("eff9", "");
    if (blob.get_u16("timer10") <= 0) blob.set_string("eff10", "");

    string[] spl1;
    string[] spl2;
    string[] spl3;
    string[] spl4;
    string[] spl5;
    string[] spl6;
    string[] spl7;
    string[] spl8;
    string[] spl9;
    string[] spl10;

    if (blob.get_string("eff1") != "") spl1 = blob.get_string("eff1").split("_");
    if (blob.get_string("eff2") != "") spl2 = blob.get_string("eff2").split("_");
    if (blob.get_string("eff3") != "") spl3 = blob.get_string("eff3").split("_");
    if (blob.get_string("eff4") != "") spl4 = blob.get_string("eff4").split("_");
    if (blob.get_string("eff5") != "") spl5 = blob.get_string("eff5").split("_");
    if (blob.get_string("eff6") != "") spl6 = blob.get_string("eff6").split("_");
    if (blob.get_string("eff7") != "") spl7 = blob.get_string("eff7").split("_");
    if (blob.get_string("eff8") != "") spl8 = blob.get_string("eff8").split("_");
    if (blob.get_string("eff9") != "") spl9 = blob.get_string("eff9").split("_");
    if (blob.get_string("eff10") != "") spl10 = blob.get_string("eff10").split("_");

    string[] spleff1;
    string[] spleff2;
    string[] spleff3;
    string[] spleff4;
    string[] spleff5;
    string[] spleff6;
    string[] spleff7;
    string[] spleff8;
    string[] spleff9;
    string[] spleff10;

    u16 gap = 64;

    GUI::SetFont("menu");
    if (spl1.length > 0 && blob.get_u16("timer1") > 0)
    {
        if (spl1.length == 3) spleff1 = spl1[2].split("`");
        GUI::DrawIcon(getEffectIcon(parseInt(spl1[0])), 0, Vec2f(32, 32), Vec2f(getDriver().getScreenWidth()-48,32), 0.5f);
    }
    if (spl2.length > 0 && blob.get_u16("timer2") > 0) 
    {
        if (spl2.length == 3) spleff2 = spl2[2].split("`");
        GUI::DrawIcon(getEffectIcon(parseInt(spl2[0])), 0, Vec2f(32, 32), Vec2f(getDriver().getScreenWidth()-48,32+gap), 0.5f);
    }
    if (spl3.length > 0 && blob.get_u16("timer3") > 0)
    {
        if (spl3.length == 3) spleff3 = spl3[2].split("`");
        GUI::DrawIcon(getEffectIcon(parseInt(spl3[0])), 0, Vec2f(32, 32), Vec2f(getDriver().getScreenWidth()-48,32+gap*2), 0.5f);
    }
    if (spl4.length > 0 && blob.get_u16("timer4") > 0)
    {
        if (spl4.length == 3) spleff4 = spl4[2].split("`");
        GUI::DrawIcon(getEffectIcon(parseInt(spl4[0])), 0, Vec2f(32, 32), Vec2f(getDriver().getScreenWidth()-48,32+gap*3), 0.5f);
    }
    if (spl5.length > 0 && blob.get_u16("timer5") > 0)
    {
        if (spl5.length == 3) spleff5 = spl5[2].split("`");
        GUI::DrawIcon(getEffectIcon(parseInt(spl5[0])), 0, Vec2f(32, 32), Vec2f(getDriver().getScreenWidth()-48,32+gap*4), 0.5f);
    }
    if (spl6.length > 0 && blob.get_u16("timer6") > 0)
    {
        if (spl6.length == 3) spleff6 = spl6[2].split("`");
        GUI::DrawIcon(getEffectIcon(parseInt(spl6[0])), 0, Vec2f(32, 32), Vec2f(getDriver().getScreenWidth()-48,32+gap*5), 0.5f);
    }
    if (spl7.length > 0 && blob.get_u16("timer7") > 0) 
    {
        if (spl7.length == 3) spleff7 = spl7[2].split("`");
        GUI::DrawIcon(getEffectIcon(parseInt(spl7[0])), 0, Vec2f(32, 32), Vec2f(getDriver().getScreenWidth()-48,32+gap*6), 0.5f);
    }
    if (spl8.length > 0 && blob.get_u16("timer8") > 0)
    {
        if (spl8.length == 3) spleff8 = spl8[2].split("`");
        GUI::DrawIcon(getEffectIcon(parseInt(spl8[0])), 0, Vec2f(32, 32), Vec2f(getDriver().getScreenWidth()-48,32+gap*7), 0.5f);
    }
    if (spl9.length > 0 && blob.get_u16("timer9") > 0)
    {
        if (spl9.length == 3) spleff9 = spl9[2].split("`");
        GUI::DrawIcon(getEffectIcon(parseInt(spl9[0])), 0, Vec2f(32, 32), Vec2f(getDriver().getScreenWidth()-48,32+gap*8), 0.5f);
    }
    if (spl10.length > 0 && blob.get_u16("timer10") > 0)
    {
        if (spl10.length == 3) spleff10 = spl10[2].split("`");
        GUI::DrawIcon(getEffectIcon(parseInt(spl10[0])), 0, Vec2f(32, 32), Vec2f(getDriver().getScreenWidth()-48,32+gap*9), 0.5f);
    }

    if (blob !is null)
    {
        Vec2f aimpos = blob.getAimPos();

        if (isMouseOverEffect(Vec2f(scrwidth-48, 32)) && spl1.length > 0) // 1
        {
            if (spl1.length > 1 && spl1[0] != "") 
            {   
                GUI::DrawText("Effect: \n\n"+getEffectDescription(parseInt(spl1[0]))+"\n\n"+"Lasts in: "+blob.get_u16("timer1")/30, Vec2f(scrwidth-48-224, 32), SColor(255, 255, 255, 255));
                if (spl1[1] == "potion" && spleff1.length > 0) 
                {
                    if (spleff1.length == 3) GUI::DrawText("Subeffects:\n\n"+spleff1[0]+"\n"+spleff1[1]+"\n"+spleff1[2], Vec2f(scrwidth-48-224, 128), SColor(255, 235, 235, 0));
                    else if (spleff1.length == 2) GUI::DrawText("Subeffects:\n\n"+spleff1[0]+"\n"+spleff1[1], Vec2f(scrwidth-48-224, 128), SColor(255, 235, 235, 0));
                    else GUI::DrawText("Subeffects:\n\n"+spleff1[0], Vec2f(scrwidth-48-224, 128), SColor(255, 235, 235, 0));
                }
                if (getEffectType(spl1[0]) == true) GUI::DrawText(getEffectName(parseInt(spl1[0])), Vec2f(scrwidth-48-174, 31), SColor(255, 255, 50, 10));
                else GUI::DrawText(getEffectName(parseInt(spl1[0])), Vec2f(scrwidth-48-174, 31), SColor(255, 10, 255, 50));
            }
        }
        else if (isMouseOverEffect(Vec2f(scrwidth-48, 32+gap)) && spl2.length > 0) // 2
        {
            if (spl2.length > 1 && spl2[0] != "") 
            { 
                GUI::DrawText("Effect: \n\n"+getEffectDescription(parseInt(spl2[0]))+"\n\n"+"Lasts in: "+blob.get_u16("timer2")/30, Vec2f(scrwidth-48-224, 32+gap), SColor(255, 255, 255, 255));
                if (spl2[1] == "potion" && spleff2.length > 0) 
                {
                    if (spleff2.length == 3) GUI::DrawText("Subeffects:\n\n"+spleff2[0]+"\n"+spleff2[1]+"\n"+spleff2[2], Vec2f(scrwidth-48-224, 128+gap), SColor(255, 235, 235, 0));
                    else if (spleff2.length == 2) GUI::DrawText("Subeffects:\n\n"+spleff2[0]+"\n"+spleff2[1], Vec2f(scrwidth-48-224, 128+gap), SColor(255, 235, 235, 0));
                    else GUI::DrawText("Subeffects:\n\n"+spleff2[0], Vec2f(scrwidth-48-224, 128+gap), SColor(255, 235, 235, 0));
                }
                if (getEffectType(spl2[0]) == true) GUI::DrawText(getEffectName(parseInt(spl2[0])), Vec2f(scrwidth-48-174, 31+gap), SColor(255, 255, 50, 10));
                else GUI::DrawText(getEffectName(parseInt(spl2[0])), Vec2f(scrwidth-48-174, 31+gap), SColor(255, 10, 255, 50));
            }
        }
        else if (isMouseOverEffect(Vec2f(scrwidth-48, 32+gap*2)) && spl3.length > 0) // 3
        {
            if (spl3.length > 1 && spl3[0] != "") 
            { 
                GUI::DrawText("Effect: \n\n"+getEffectDescription(parseInt(spl3[0]))+"\n\n"+"Lasts in: "+blob.get_u16("timer3")/30, Vec2f(scrwidth-48-224, 32+gap*2), SColor(255, 255, 255, 255));
                if (spl3[1] == "potion" && spleff3.length > 0) 
                {
                    if (spleff3.length == 3) GUI::DrawText("Subeffects:\n\n"+spleff3[0]+"\n"+spleff3[1]+"\n"+spleff3[2], Vec2f(scrwidth-48-224, 128+gap*2), SColor(255, 235, 235, 0));
                    else if (spleff3.length == 2) GUI::DrawText("Subeffects:\n\n"+spleff3[0]+"\n"+spleff3[1], Vec2f(scrwidth-48-224, 128+gap*2), SColor(255, 235, 235, 0));
                    else GUI::DrawText("Subeffects:\n\n"+spleff3[0], Vec2f(scrwidth-48-224, 128+gap*2), SColor(255, 235, 235, 0));
                }
                if (getEffectType(spl3[0]) == true) GUI::DrawText(getEffectName(parseInt(spl3[0])), Vec2f(scrwidth-48-174, 31+gap*2), SColor(255, 255, 50, 10));
                else GUI::DrawText(getEffectName(parseInt(spl3[0])), Vec2f(scrwidth-48-174, 31+gap*2), SColor(255, 10, 255, 50));
            }
        }
        else if (isMouseOverEffect(Vec2f(scrwidth-48, 32+gap*3)) && spl4.length > 0) // 4
        {
            if (spl4.length > 1 && spl4[0] != "") 
            { 
                GUI::DrawText("Effect: \n\n"+getEffectDescription(parseInt(spl4[0]))+"\n\n"+"Lasts in: "+blob.get_u16("timer4")/30, Vec2f(scrwidth-48-224, 32+gap*3), SColor(255, 255, 255, 255));
                if (spl4[1] == "potion" && spleff4.length > 0) 
                {
                    if (spleff4.length == 3) GUI::DrawText("Subeffects:\n\n"+spleff4[0]+"\n"+spleff4[1]+"\n"+spleff4[2], Vec2f(scrwidth-48-224, 128+gap*3), SColor(255, 235, 235, 0));
                    else if (spleff4.length == 2) GUI::DrawText("Subeffects:\n\n"+spleff4[0]+"\n"+spleff4[1], Vec2f(scrwidth-48-224, 128+gap*3), SColor(255, 235, 235, 0));
                    else GUI::DrawText("Subeffects:\n\n"+spleff4[0], Vec2f(scrwidth-48-224, 128+gap*3), SColor(255, 235, 235, 0));
                }
                if (getEffectType(spl4[0]) == true) GUI::DrawText(getEffectName(parseInt(spl4[0])), Vec2f(scrwidth-48-174, 31+gap*3), SColor(255, 255, 50, 10));
                else GUI::DrawText(getEffectName(parseInt(spl4[0])), Vec2f(scrwidth-48-174, 31+gap*3), SColor(255, 10, 255, 50));
            }
        }
        else if (isMouseOverEffect(Vec2f(scrwidth-48, 32+gap*4)) && spl5.length > 0) // 5
        {
            if (spl5.length > 1 && spl5[0] != "") 
            { 
                GUI::DrawText("Effect: \n\n"+getEffectDescription(parseInt(spl5[0]))+"\n\n"+"Lasts in: "+blob.get_u16("timer5")/30, Vec2f(scrwidth-48-224, 32+gap*4), SColor(255, 255, 255, 255));
                if (spl5[1] == "potion" && spleff5.length > 0) 
                {
                    if (spleff5.length == 3) GUI::DrawText("Subeffects:\n\n"+spleff5[0]+"\n"+spleff5[1]+"\n"+spleff5[2], Vec2f(scrwidth-48-224, 128+gap*4), SColor(255, 235, 235, 0));
                    else if (spleff5.length == 2) GUI::DrawText("Subeffects:\n\n"+spleff5[0]+"\n"+spleff5[1], Vec2f(scrwidth-48-224, 128+gap*4), SColor(255, 235, 235, 0));
                    else GUI::DrawText("Subeffects:\n\n"+spleff5[0], Vec2f(scrwidth-48-224, 128+gap*4), SColor(255, 235, 235, 0));
                }
                if (getEffectType(spl5[0]) == true) GUI::DrawText(getEffectName(parseInt(spl5[0])), Vec2f(scrwidth-48-174, 31+gap*4), SColor(255, 255, 50, 10));
                else GUI::DrawText(getEffectName(parseInt(spl5[0])), Vec2f(scrwidth-48-174, 31+gap*4), SColor(255, 10, 255, 50));
            }
        }
        else if (isMouseOverEffect(Vec2f(scrwidth-48, 32+gap*5)) && spl2.length > 0) // 6
        {
            if (spl6.length > 1 && spl6[0] != "") 
            {   
                GUI::DrawText("Effect: \n\n"+getEffectDescription(parseInt(spl6[0]))+"\n\n"+"Lasts in: "+blob.get_u16("timer1")/30, Vec2f(scrwidth-48-224, 32+gap*5), SColor(255, 255, 255, 255));
                if (spl6[1] == "potion" && spleff6.length > 0) 
                {
                    if (spleff6.length == 3) GUI::DrawText("Subeffects:\n\n"+spleff6[0]+"\n"+spleff6[1]+"\n"+spleff6[2], Vec2f(scrwidth-48-224, 128+gap*5), SColor(255, 235, 235, 0));
                    else if (spleff6.length == 2) GUI::DrawText("Subeffects:\n\n"+spleff6[0]+"\n"+spleff6[1], Vec2f(scrwidth-48-224, 128+gap*5), SColor(255, 235, 235, 0));
                    else GUI::DrawText("Subeffects:\n\n"+spleff6[0], Vec2f(scrwidth-48-224, 128+gap*5), SColor(255, 235, 235, 0));
                }
                if (getEffectType(spl6[0]) == true) GUI::DrawText(getEffectName(parseInt(spl6[0])), Vec2f(scrwidth-48-174, 31+gap*5), SColor(255, 255, 50, 10));
                else GUI::DrawText(getEffectName(parseInt(spl6[0])), Vec2f(scrwidth-48-174, 31+gap*5), SColor(255, 10, 255, 50));
            }
        }
        else if (isMouseOverEffect(Vec2f(scrwidth-48, 32+gap*6)) && spl2.length > 0) // 7
        {
            if (spl7.length > 1 && spl7[0] != "") 
            { 
                GUI::DrawText("Effect: \n\n"+getEffectDescription(parseInt(spl7[0]))+"\n\n"+"Lasts in: "+blob.get_u16("timer2")/30, Vec2f(scrwidth-48-224, 32+gap*6), SColor(255, 255, 255, 255));
                if (spl7[1] == "potion" && spleff7.length > 0) 
                {
                    if (spleff7.length == 3) GUI::DrawText("Subeffects:\n\n"+spleff7[0]+"\n"+spleff7[1]+"\n"+spleff7[2], Vec2f(scrwidth-48-224, 128+gap*6), SColor(255, 235, 235, 0));
                    else if (spleff7.length == 2) GUI::DrawText("Subeffects:\n\n"+spleff7[0]+"\n"+spleff7[1], Vec2f(scrwidth-48-224, 128+gap*6), SColor(255, 235, 235, 0));
                    else GUI::DrawText("Subeffects:\n\n"+spleff7[0], Vec2f(scrwidth-48-224, 128+gap*6), SColor(255, 235, 235, 0));
                }
                if (getEffectType(spl7[0]) == true) GUI::DrawText(getEffectName(parseInt(spl7[0])), Vec2f(scrwidth-48-174, 31+gap*6), SColor(255, 255, 50, 10));
                else GUI::DrawText(getEffectName(parseInt(spl7[0])), Vec2f(scrwidth-48-174, 31+gap*6), SColor(255, 10, 255, 50));
            }
        }
        else if (isMouseOverEffect(Vec2f(scrwidth-48, 32+gap*7)) && spl8.length > 0) // 8
        {
            if (spl8.length > 1 && spl8[0] != "") 
            { 
                GUI::DrawText("Effect: \n\n"+getEffectDescription(parseInt(spl8[0]))+"\n\n"+"Lasts in: "+blob.get_u16("timer3")/30, Vec2f(scrwidth-48-224, 32+gap*7), SColor(255, 255, 255, 255));
                if (spl8[1] == "potion" && spleff8.length > 0) 
                {
                    if (spleff8.length == 3) GUI::DrawText("Subeffects:\n\n"+spleff8[0]+"\n"+spleff8[1]+"\n"+spleff8[2], Vec2f(scrwidth-48-224, 128+gap*7), SColor(255, 235, 235, 0));
                    else if (spleff8.length == 2) GUI::DrawText("Subeffects:\n\n"+spleff8[0]+"\n"+spleff8[1], Vec2f(scrwidth-48-224, 128+gap*7), SColor(255, 235, 235, 0));
                    else GUI::DrawText("Subeffects:\n\n"+spleff8[0], Vec2f(scrwidth-48-224, 128+gap*7), SColor(255, 235, 235, 0));
                }
                if (getEffectType(spl8[0]) == true) GUI::DrawText(getEffectName(parseInt(spl8[0])), Vec2f(scrwidth-48-174, 31+gap*7), SColor(255, 255, 50, 10));
                else GUI::DrawText(getEffectName(parseInt(spl8[0])), Vec2f(scrwidth-48-174, 31+gap*7), SColor(255, 10, 255, 50));
            }
        }
        else if (isMouseOverEffect(Vec2f(scrwidth-48, 32+gap*8)) && spl9.length > 0) // 9
        {
            if (spl9.length > 1 && spl9[0] != "") 
            { 
                GUI::DrawText("Effect: \n\n"+getEffectDescription(parseInt(spl9[0]))+"\n\n"+"Lasts in: "+blob.get_u16("timer4")/30, Vec2f(scrwidth-48-224, 32+gap*8), SColor(255, 255, 255, 255));
                if (spl9[1] == "potion" && spleff9.length > 0) 
                {
                    if (spleff9.length == 3) GUI::DrawText("Subeffects:\n\n"+spleff9[0]+"\n"+spleff9[1]+"\n"+spleff9[2], Vec2f(scrwidth-48-224, 128+gap*8), SColor(255, 235, 235, 0));
                    else if (spleff9.length == 2) GUI::DrawText("Subeffects:\n\n"+spleff9[0]+"\n"+spleff9[1], Vec2f(scrwidth-48-224, 128+gap*8), SColor(255, 235, 235, 0));
                    else GUI::DrawText("Subeffects:\n\n"+spleff9[0], Vec2f(scrwidth-48-224, 128+gap*8), SColor(255, 235, 235, 0));
                }
                if (getEffectType(spl9[0]) == true) GUI::DrawText(getEffectName(parseInt(spl9[0])), Vec2f(scrwidth-48-174, 31+gap*8), SColor(255, 255, 50, 10));
                else GUI::DrawText(getEffectName(parseInt(spl9[0])), Vec2f(scrwidth-48-174, 31+gap*8), SColor(255, 10, 255, 50));
            }
        }
        else if (isMouseOverEffect(Vec2f(scrwidth-48, 32+gap*9)) && spl10.length > 0) // 10
        {
            if (spl10 .length > 1 && spl10 [0] != "") 
            { 
                GUI::DrawText("Effect: \n\n"+getEffectDescription(parseInt(spl10 [0]))+"\n\n"+"Lasts in: "+blob.get_u16("timer5")/30, Vec2f(scrwidth-48-224, 32+gap*9), SColor(255, 255, 255, 255));
                if (spl10 [1] == "potion" && spleff10.length > 0) 
                {
                    if (spleff10.length == 3) GUI::DrawText("Subeffects:\n\n"+spleff10[0]+"\n"+spleff10[1]+"\n"+spleff10[2], Vec2f(scrwidth-48-224, 128+gap*9), SColor(255, 235, 235, 0));
                    else if (spleff10.length == 2) GUI::DrawText("Subeffects:\n\n"+spleff10[0]+"\n"+spleff10[1], Vec2f(scrwidth-48-224, 128+gap*9), SColor(255, 235, 235, 0));
                    else GUI::DrawText("Subeffects:\n\n"+spleff10[0], Vec2f(scrwidth-48-224, 128+gap*9), SColor(255, 235, 235, 0));
                }
                if (getEffectType(spl10 [0]) == true) GUI::DrawText(getEffectName(parseInt(spl10 [0])), Vec2f(scrwidth-48-174, 31+gap*9), SColor(255, 255, 50, 10));
                else GUI::DrawText(getEffectName(parseInt(spl10 [0])), Vec2f(scrwidth-48-174, 31+gap*9), SColor(255, 10, 255, 50));
            }
        }
    }
}

bool isMouseOverEffect(Vec2f offset)
{
	Vec2f mousePos = getControls().getMouseScreenPos();
	Vec2f effectPos = offset;

    if (mousePos.x >= effectPos.x-16 && mousePos.x <= effectPos.x + 32+16
    && mousePos.y >= effectPos.y-24 && mousePos.y <= effectPos.y + 32+16) return true;
    else return false;
}