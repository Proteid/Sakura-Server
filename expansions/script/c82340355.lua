--电车难题
Duel.LoadScript("c62015410.lua")
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)>4
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),1-tp,LOCATION_MZONE,0,nil):GetCount()>0 and Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),1-tp,LOCATION_GRAVE,0,nil):GetCount()>4
		or Duel.GetMatchingGroup(Card.IsAbleToRemove,1-tp,LOCATION_MZONE,0,nil):GetCount()>0 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local off=1
	local ops={}
	local opval={}
    local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),1-tp,LOCATION_GRAVE,0,nil)
	if #g1>4 then
		ops[off]=aux.Stringid(id,0)
		opval[off-1]=1
		off=off+1
	end
    local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,1-tp,LOCATION_MZONE,0,nil)
	if #g2>0 then
		ops[off]=aux.Stringid(id,1)
		opval[off-1]=2
		off=off+1
	end
	if off==1 then return end
	local op=Duel.SelectOption(1-tp,table.unpack(ops))
	if opval[op]==1 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local rg=g1:FilterSelect(1-tp,Card.IsLocation,5,5,nil,LOCATION_GRAVE)
		Duel.HintSelection(rg)
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	elseif opval[op]==2 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local rg=g1:FilterSelect(1-tp,Card.IsLocation,1,1,nil,LOCATION_MZONE)
		Duel.HintSelection(rg)
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end
