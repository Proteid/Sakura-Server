--最后的了断
Duel.LoadScript("c62015410.lua")
local cm,m=GetID()
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_DRAW+CATEGORY_DAMAGE+CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
function cm.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP,tp)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(nil,tp,LOCATION_MZONE,0,nil)==1
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	if chk==0 then
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
		if #g==0 then return false end
		return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
    local dg=Duel.GetMatchingGroup(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,nil)
    if #dg>0 then
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_MZONE)
	end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)~=0 then
	    if Duel.Draw(1-tp,1,REASON_EFFECT)==0 then return end
	    local tc2=Duel.GetOperatedGroup():GetFirst()
	    Duel.ConfirmCards(tp,tc2)
	    if tc2:IsType(TYPE_MONSTER) then
	    	Duel.SendtoGrave(tc2,REASON_EFFECT)
            Duel.BreakEffect()
            Duel.Damage(1-tp,tc2:GetAttack(),REASON_EFFECT)
	    elseif tc2:IsType(TYPE_SPELL) then
		    Duel.SendtoGrave(tc2,REASON_EFFECT)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	        local g=Duel.SelectMatchingCard(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
		    if #g>0 then
		    	local tc3=g:GetFirst()
		    	Duel.NegateRelatedChain(tc3,RESET_TURN_SET)
		    	local e3=Effect.CreateEffect(c)
		    	e3:SetType(EFFECT_TYPE_SINGLE)
		    	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		        e3:SetCode(EFFECT_DISABLE)
		        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		    	tc3:RegisterEffect(e3)
		        local e4=Effect.CreateEffect(c)
		        e4:SetType(EFFECT_TYPE_SINGLE)
		        e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		        e4:SetCode(EFFECT_DISABLE_EFFECT)
		        e4:SetValue(RESET_TURN_SET)
		        e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		        tc3:RegisterEffect(e4)
            end
	    else
		    Duel.SendtoGrave(tc2,REASON_EFFECT)
            if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                local g=Duel.SelectMatchingCard(tp,cm.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
                if #g>0 then
                    Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
                end
            end
        end
	    Duel.ShuffleHand(1-tp)
    end
end
