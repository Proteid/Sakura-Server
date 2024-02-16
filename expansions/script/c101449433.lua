--月見ひかり
Duel.LoadScript("c62015410.lua")
local cm,m=GetID()
function cm.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--special summon rule
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(cm.sprcon)
	e2:SetOperation(cm.sprop)
	c:RegisterEffect(e2)
	--copy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0x3c0)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,m)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return not Duel.CheckEvent(EVENT_CHAINING)
	end)
	e3:SetCost(cm.CopyCost)
	e3:SetTarget(cm.CopySpellNormalTarget)
	e3:SetOperation(cm.CopyOperation)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(aux.TRUE)
	c:RegisterEffect(e4)
	--search
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCountLimit(1,m+1)
	e5:SetCondition(cm.thcon)
	e5:SetTarget(cm.thtg)
	e5:SetOperation(cm.thop)
	c:RegisterEffect(e5)
end
function cm.sprfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
	and c:IsLevel(3) and c:IsType(TYPE_TUNER)
	and c:IsAttack(0) and c:IsDefense(1800)
	and c:IsAbleToGraveAsCost() and not c:IsCode(m)
end
function cm.sprcon(e,c)
	if c==nil then return true end
	return Duel.IsExistingMatchingCard(cm.sprfilter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetControler())
end
function cm.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cm.sprfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function cm.CopyCost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function cm.GetHandEffect(c)
	cm.effect_cache=cm.effect_cache or {}
	local code=c:GetOriginalCode()
	if cm.effect_cache[code] then return cm.effect_cache[code] end
	local eset={}
	local temp=Card.RegisterEffect
	Card.RegisterEffect=function(tc,e,f)
		if (e:GetRange()&LOCATION_HAND)>0 and e:IsHasType(0x7e0) then
			table.insert(eset,e:Clone())
		end
		return temp(tc,e,f)
	end
	Duel.DisableActionCheck(true)
	Duel.CreateToken(c:GetControler(),code)
	Duel.DisableActionCheck(false)
	Card.RegisterEffect=temp
	cm.effect_cache[code]=eset
	return eset
end
function cm.CheckHandEffect(c,sec,e,tp,eg,ep,ev,re,r,rp)
	local eset=cm.GetHandEffect(c)
	if #eset==0 then return false end
	local teg,tep,tev,tre,tr,trp
	local ee={}
	for _,te in ipairs(eset) do
		local tres=false
		local code=te:GetCode()
		if code~=EVENT_CHAINING and code~=EVENT_FREE_CHAIN then
			tres,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(code,true)
		elseif sec or code==EVENT_FREE_CHAIN then
			tres=true
			teg,tep,tev,tre,tr,trp=eg,ep,ev,re,r,rp
		end
		if tres then
			local con=te:GetCondition()
			local tg=te:GetTarget()
			if (not con or con(e,tp,teg,tep,tev,tre,tr,trp)) and (not tg or tg(e,tp,teg,tep,tev,tre,tr,trp,0)) then
				ee[#ee+1]=te
			end
		end
	end
	if #ee>0 then
		return true,ee,teg,tep,tev,tre,tr,trp
	else
		return false
	end
end
function cm.CopySpellNormalFilter(c,sec,e,tp,eg,ep,ev,re,r,rp)
	local te=cm.GetHandEffect(c)
	return c:IsType(TYPE_TUNER) and c:IsAttack(0) and c:IsDefense(1800) and c:IsLevel(3)
		and c:IsAbleToGraveAsCost() and c:IsRace(RACE_ZOMBIE) and cm.CheckHandEffect(c,sec,e,tp,eg,ep,ev,re,r,rp)
end
function cm.CopySpellNormalTarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,chkc))
	end
	local og=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	local sec=(e:GetCode()==EVENT_CHAINING)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return og:IsExists(cm.CopySpellNormalFilter,1,nil,sec,e,tp,eg,ep,ev,re,r,rp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=og:FilterSelect(tp,cm.CopySpellNormalFilter,1,1,nil,sec,e,tp,eg,ep,ev,re,r,rp)
	local _,te,ceg,cep,cev,cre,cr,crp=cm.CheckHandEffect(g:GetFirst(),sec,e,tp,eg,ep,ev,re,r,rp)
	local op = 1
	if #te>1 then
		table_des={}
		for k,v in ipairs(te) do
			table_des[#table_des+1]=v:GetDescription()
		end
		op = Duel.SelectOption(tp,table.unpack(table_des))+1
	end
	te=te[op]
	Duel.SendtoGrave(g,REASON_COST)
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te)
	local tg=te:GetTarget()
	if tg then
		tg(e,tp,ceg,cep,cev,cre,cr,crp,1)
	end
	Duel.ClearOperationInfo(0)
end
function cm.CopyOperation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if te:IsHasType(EFFECT_TYPE_ACTIVATE) then
		e:GetHandler():ReleaseEffectRelation(e)
	end
	op(e,tp,eg,ep,ev,re,r,rp)
end
function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD) and not c:IsStatus(STATUS_SPSUMMON_TURN)
end
function cm.filter(c)
	return c:IsAttack(0) and c:IsDefense(1800) and c:IsLevel(3) and c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_TUNER) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end