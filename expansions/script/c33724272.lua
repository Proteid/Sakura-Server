--ライフ・ボンド
Duel.LoadScript("c62015410.lua")
local cm,m=GetID()
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(cm.condition)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetBattleDamage(tp)>Duel.GetLP(e:GetHandlerPlayer())
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local val=Duel.GetBattleDamage(tp)-Duel.GetLP(e:GetHandlerPlayer())
	Duel.Recover(tp,val,REASON_EFFECT)
end
