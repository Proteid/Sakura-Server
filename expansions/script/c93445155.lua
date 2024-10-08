--数理の基
Duel.LoadScript("c62015410.lua")
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    local se1=Effect.CreateEffect(c)
    se1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    se1:SetCode(EVENT_ADJUST)
    se1:SetCondition(s.check)
    se1:SetOperation(s.token)
    Duel.RegisterEffect(se1,tp)
end
function s.filter1(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN) and not c:IsPublic()
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND,0,1,c,tp,c:GetOriginalCode())
end
function s.filter2(c,tp,code1)
	return c:IsAbleToRemove(tp,POS_FACEDOWN) and not c:IsPublic()
		and Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_DECK,0,1,c,tp,code1,c:GetOriginalCode())
end
function s.filter3(c,tp,code1,code2)
	return c:IsAbleToRemove(tp,POS_FACEDOWN) and c:GetOriginalCode()==math.abs(code1+code2)
    and Duel.IsExistingMatchingCard(s.filter4,tp,LOCATION_DECK,0,1,c,tp,code1,code2,c:GetOriginalCode())
end
function s.filter4(c,tp,code1,code2,code3)
	return c:IsAbleToRemove(tp,POS_FACEDOWN) and c:GetOriginalCode()==math.abs(code1-code2)
    and Duel.IsExistingMatchingCard(s.filter5,tp,LOCATION_DECK,0,1,c,tp,code3,c:GetOriginalCode())
end
function s.filter5(c,tp,code3,code4)
	return c:IsAbleToHand() and c:GetOriginalCode()==math.abs(code3-code4)
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_HAND,0,1,nil,tp)
    local b2=s.memory:CheckActivateEffect(false,true,false)
    if chk==0 then return b1 or b2 end
    local sg=Group.CreateGroup()
    if b1 then
        sg:AddCard(Duel.CreateToken(tp,id))
    end
    if b2 then
        sg:AddCard(Duel.CreateToken(tp,89558743))
    end
    local opm
    if #sg==2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
        opm=sg:Select(tp,1,1,nil):GetFirst():GetOriginalCode()
    else
        opm=sg:GetFirst():GetOriginalCode()
    end
    e:SetLabel(opm)
    if opm==id then
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,4,tp,LOCATION_HAND+LOCATION_DECK)
	    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    else
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
	    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    end
    if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(s.chlimit)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local opm=e:GetLabel()
    if opm==id then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	    local g1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_HAND,0,1,1,nil,tp)
        local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND,0,1,1,nil,tp,g1:GetFirst():GetOriginalCode())
	    if #g1==0 or #g2==0 then return end
        g1:Merge(g2)
	    Duel.ConfirmCards(1-tp,g1)
	    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	    local g3=Duel.SelectMatchingCard(tp,s.filter3,tp,LOCATION_DECK,0,1,1,nil,tp,g1:GetFirst():GetOriginalCode(),g2:GetFirst():GetOriginalCode())
        local g4=Duel.SelectMatchingCard(tp,s.filter4,tp,LOCATION_DECK,0,1,1,nil,tp,g1:GetFirst():GetOriginalCode(),g2:GetFirst():GetOriginalCode(),g3:GetFirst():GetOriginalCode())
        if #g3==0 or #g4==0 then return end
        g3:Merge(g4)
	    Duel.ConfirmCards(1-tp,g3)
	    if Duel.Remove(g1,POS_FACEDOWN,REASON_EFFECT)~=0 then
	    	Duel.BreakEffect()
	    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	    	local g5=Duel.SelectMatchingCard(tp,s.filter5,tp,LOCATION_DECK,0,1,1,nil,g3:GetFirst():GetOriginalCode(),g4:GetFirst():GetOriginalCode())
	    	if g5:GetCount()>0 then
	    		Duel.SendtoHand(g5,nil,REASON_EFFECT)
	    		Duel.ConfirmCards(1-tp,g5)
	    		Duel.Remove(g3,POS_FACEDOWN,REASON_EFFECT)
	    	end
	    end
    else
        local activate=s.memory:CheckActivateEffect(true,true,false):GetOperation()
        activate(e,tp,eg,ep,ev,re,r,rp)
    end
end
function s.check(e,tp,eg,ep,ev,re,r,rp)
    return not s.memory
end
function s.token(e,tp,eg,ep,ev,re,r,rp)
    s.memory=Duel.CreateToken(tp,89558743)
    e:Reset()
end
