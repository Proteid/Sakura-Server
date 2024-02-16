--夢幻泡影
Duel.LoadScript("c62015410.lua")
local cm,m=GetID()
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
    local se1=Effect.CreateEffect(c)
    se1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    se1:SetCode(EVENT_ADJUST)
    se1:SetCondition(cm.check)
    se1:SetOperation(cm.token)
    Duel.RegisterEffect(se1,tp)
end
function cm.filter(c,g)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(true)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingTarget(cm.filter,tp,0,LOCATION_ONFIELD,1,nil)
    local b2=cm.memory:GetActivateEffect():GetTarget()
    if chk==0 then return b1 or b2(e,tp,eg,ep,ev,re,r,rp,0,nil) end
    local sg=Group.CreateGroup()
    if b1 then
        sg:AddCard(Duel.CreateToken(tp,m))
    end
    if b2(e,tp,eg,ep,ev,re,r,rp,0,nil) then
        sg:AddCard(Duel.CreateToken(tp,10045474))
    end
    local opm
    if #sg==2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
        opm=sg:Select(tp,1,1,nil):GetFirst():GetOriginalCode()
    else
        opm=sg:GetFirst():GetOriginalCode()
    end
    e:SetLabel(opm)
    if opm==m then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		Duel.SelectTarget(tp,cm.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
    else
        b2(e,tp,eg,ep,ev,re,r,rp,1,nil)
        if bit.band(cm.memory:GetActivateEffect():GetProperty(),EFFECT_FLAG_CARD_TARGET)~=0 and bit.band(e:GetProperty(),EFFECT_FLAG_CARD_TARGET)==0 then
            cm.property=e:GetProperty()
            e:SetProperty(e:GetProperty()+EFFECT_FLAG_CARD_TARGET)
        end
        Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
    end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
    local opm=e:GetLabel()
	local c=e:GetHandler()
    if opm==m then
		local tc=Duel.GetFirstTarget()
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				local e3=e1:Clone()
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				tc:RegisterEffect(e3)
			end
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e4:SetCode(EVENT_CHAIN_SOLVED)
			e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e4:SetRange(LOCATION_ONFIELD)
			e4:SetOperation(cm.setop)
			tc:RegisterEffect(e4)
		end
    else
        local activate=cm.memory:CheckActivateEffect(true,true,false):GetOperation()
        activate(e,tp,eg,ep,ev,re,r,rp)
        if cm.property then
            e:SetProperty(cm.property)
            cm.property=nil
        end
    end
end
function cm.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsCanTurnSet() then
		c:CancelToGrave()
		Duel.ChangePosition(c,POS_FACEDOWN)
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
	e:Reset()
end
function cm.check(e,tp,eg,ep,ev,re,r,rp)
    return not cm.memory
end
function cm.token(e,tp,eg,ep,ev,re,r,rp)
    cm.memory=Duel.CreateToken(tp,10045474)
    e:Reset()
end
