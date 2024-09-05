--ライフ・ボンド
Duel.LoadScript("c62015410.lua")
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetBattleDamage(tp)>Duel.GetLP(e:GetHandlerPlayer())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local val=Duel.GetBattleDamage(tp)-Duel.GetLP(e:GetHandlerPlayer())
	Duel.Recover(tp,val,REASON_EFFECT)
end
