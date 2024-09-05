--トリック・ハウス
Duel.LoadScript("c62015410.lua")
local s,id,o=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(s.setop1)
	c:RegisterEffect(e2)
    --set
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1,id+1)
    e3:SetCondition(s.setcon)
    e3:SetTarget(s.settg)
	e3:SetOperation(s.setop2)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsMSetable(true,nil)
end
function s.chfilter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsCanChangePosition()
end
function s.tgfilter(c)
	return c:IsType(TYPE_FLIP)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil)
	if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=g:Select(tp,1,1,nil)
        Duel.MSet(tp,sg:GetFirst(),true,nil)
        if not c:IsStatus(STATUS_ACT_FROM_HAND) and c:IsLocation(LOCATION_FZONE) then
            local e1=Effect.CreateEffect(e:GetHandler())
	        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	        e1:SetCode(EVENT_MSET)
            e1:SetRange(LOCATION_FZONE)
            e1:SetTargetRange(1,0)
	        e1:SetOperation(s.setop)
	        e:GetHandler():RegisterEffect(e1)
        end
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.chfilter,tp,LOCATION_MZONE,0,nil)
	if #g then
		Duel.ChangePosition(g,POS_FACEUP_ATTACK)
	end
    local tgg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,0,nil)
	if #tgg>0 then
		Duel.BreakEffect()
		Duel.SendtoGrave(tgg,REASON_EFFECT)
	end
    e:Reset()
end
function s.setop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsCanTurnSet() then
		Duel.ChangePosition(c,POS_FACEDOWN)
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
function s.setfilter(c)
	return c:IsType(TYPE_TRAP) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSSetable()
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsPosition,tp,LOCATION_MZONE,0,2,nil,POS_FACEDOWN_DEFENSE)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
end
function s.setop2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=g:Select(tp,1,1,nil)
		Duel.SSet(tp,sg)
	end
end
