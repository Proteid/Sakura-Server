--ラクトアリス ～ 少女密室
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
end
function cm.bandfilter(c)
	return c:IsFaceup() and c:GetFlagEffect(m)==0 and c:IsOriginalCodeRule(38132796)
end
function cm.bandtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.bandfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function cm.bandop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(cm.bandfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(m,0))
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetTarget(cm.target)
		e1:SetOperation(cm.operation)
		tc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetCondition(cm.condition)
		tc:RegisterEffect(e2,true)
		tc:RegisterFlagEffect(m,RESET_EVENT+RESETS_STANDARD,0,1)
		tc=g:GetNext()
	end
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(71333509)~=0
end
function cm.filter(c)
	return c:IsFaceup() and c:GetFlagEffect(m+1)==0
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and cm.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cm.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,cm.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(m,1))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		tc:RegisterFlagEffect(m+1,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
