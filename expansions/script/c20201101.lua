--万圣节
Duel.LoadScript("c62015410.lua")
local cm,m=GetID()
function cm.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetOperation(cm.loop)
	e1:SetCode(EVENT_DISCARD)
	c:RegisterEffect(e1)
end
function cm.loop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(m,0))
	local c=Duel.CreateToken(tp,m)
	Duel.SendtoHand(c,nil,REASON_RULE)
	Duel.ConfirmCards(1-tp,c)
	Duel.ShuffleHand(tp)
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	Duel.Exile(e:GetHandler(),REASON_RULE)
end
