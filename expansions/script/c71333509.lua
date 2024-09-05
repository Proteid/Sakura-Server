--狂気の茶会 ～ A Mad Tea-Party
Duel.LoadScript("c62015410.lua")
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,38132796)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.bandtg)
	e1:SetOperation(s.bandop)
	c:RegisterEffect(e1)
	--cannot disable summon & spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.distg)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	c:RegisterEffect(e3)
end
function s.bandfilter(c)
	return c:IsFaceup() and c:GetFlagEffect(id)==0 and c:IsOriginalCodeRule(38132796)
end
function s.bandtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.bandfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.bandop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.bandfilter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(tc)
			e1:SetDescription(aux.Stringid(id,0))
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
			tc=g:GetNext()
		end	
	end
end
function s.distg(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x546)
end
