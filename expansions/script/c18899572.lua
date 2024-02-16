--WR-『Cr Reverse』
Duel.LoadScript("c62015410.lua")
local cm,m=GetID()
function cm.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xf72),aux.NonTuner(Card.IsSetCard,0xf72),1)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77075360,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(cm.spcon)
	e1:SetTarget(cm.sptg)
	e1:SetOperation(cm.spop)
	c:RegisterEffect(e1)
	--avoid damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetCondition(cm.damcon)
	e2:SetValue(cm.damval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e3)
	--setlp
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(cm.setcon)
	e4:SetOperation(cm.setop)
	c:RegisterEffect(e4)
	--change lp
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(cm.cgcon)
	e5:SetOperation(cm.cgop)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
function cm.filter(c,e,tp)
	return c:IsSetCard(0xf72) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cm.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	if ft<=0 or g:GetCount()==0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
	if sg and #sg>0 then
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE) end
end
function cm.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf72) and c:IsType(TYPE_NORMAL)
end
function cm.damcon(e)
	return Duel.IsExistingMatchingCard(cm.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function cm.damval(e,re,val,r,rp,rc)
	if val~=0 then return 0 else return val end
end
function cm.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function cm.setop(e,tp,eg,ep,ev,re,r,rp)
	local lp=Duel.GetLP(tp)
	e:SetLabel(lp)
end
function cm.cgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function cm.cgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	Duel.SetChainLimit(cm.chlimit)
end
function cm.cgop(e,tp,eg,ep,ev,re,r,rp)
	local lp=e:GetLabelObject():GetLabel()
	Duel.SetLP(tp,lp)
end
