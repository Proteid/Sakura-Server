--狂気の茶会 ～ A Mad Tea-Party
Duel.LoadScript("c62015410.lua")
local cm,m=GetID()
function cm.initial_effect(c)
	aux.AddCodeList(c,38132796)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cm.bandtg)
	e1:SetOperation(cm.bandop)
	c:RegisterEffect(e1)
	--cannot disable summon & spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(cm.distg)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	c:RegisterEffect(e3)
end
function cm.bandfilter(c)
	return c:IsFaceup() and c:GetFlagEffect(m)==0 and c:IsOriginalCodeRule(38132796)
end
function cm.bandtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.bandfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.bandop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cm.bandfilter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(tc)
			e1:SetDescription(aux.Stringid(m,0))
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			tc:RegisterFlagEffect(m,RESET_EVENT+RESETS_STANDARD,0,1)
			tc=g:GetNext()
		end	
	end
end
function cm.distg(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x546)
end
