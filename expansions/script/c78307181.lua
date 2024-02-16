--青い花飾りの少女
Duel.LoadScript("c62015410.lua")
local cm,m=GetID()
function cm.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
    --special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,m)
	e1:SetOperation(cm.operation)
	c:RegisterEffect(e1)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CARDTYPE)
	local op=Duel.AnnounceType(1-tp)
	Duel.ConfirmDecktop(tp,1)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if (op==0 and tc:IsType(TYPE_MONSTER)) or (op==1 and tc:IsType(TYPE_SPELL)) or (op==2 and tc:IsType(TYPE_TRAP)) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	else
		Duel.Draw(tp,1,REASON_EFFECT)
        Duel.Damage(1-tp,2000,REASON_EFFECT)
	end
end
