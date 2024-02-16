--蜘蛛感应
Duel.LoadScript("c62015410.lua")
local cm,m=GetID()
function cm.initial_effect(c)
	local e1=Effect.CreateEffect(c)	
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,m)
	e1:SetCondition(cm.cecon)
	e1:SetTarget(cm.cetg)
	e1:SetOperation(cm.ceop)
	c:RegisterEffect(e1)
end
function cm.repop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.SelectMatchingCard(1-tp,cm.thfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if sg:GetCount()>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
function cm.cecon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsExistingMatchingCard(cm.tfilter,tp,LOCATION_MZONE,0,1,nil)
end
function cm.thfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsAbleToHand()
end
function cm.cetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,rp,0,LOCATION_MZONE,1,nil) end
end
function cm.ceop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,cm.repop)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(cm.actlimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function cm.actlimit(e,re,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not rc:IsRace(RACE_INSECT)
end
