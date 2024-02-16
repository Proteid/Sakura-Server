--終末の蛇＝インフィニティ
Duel.LoadScript("c62015410.lua")
local cm,m=GetID()
function cm.initial_effect(c)
	c:SetUniqueOnField(1,1,m)
	if not cm.ouroboros then
		cm.ouroboros=true
		Ouroboros={[0]=0,[1]=0}
		local ge1=Effect.GlobalEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetCondition(cm.condition)
		ge1:SetOperation(cm.operation)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		Duel.RegisterEffect(ge2,0)
	end
	--cannot link material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--base atk/def
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(cm.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e3)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(cm.spcon)
	e4:SetTarget(cm.sptg)
	e4:SetOperation(cm.spop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e5)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsFaceup() and tc:IsOriginalCodeRule(m)
end
function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	local p=eg:GetFirst():GetSummonPlayer()
	Ouroboros[p]=Ouroboros[p]+1
end
function cm.atkval(e,c)
	return Ouroboros[c:GetControler()]*1000
end
function cm.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetReasonPlayer()==1-tp and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
function cm.fselect(g,tp,atk)
	if Duel.GetMZoneCount(tp,g)>0 then
		return g:CheckWithSumGreater(Card.GetAttack,atk)
	else return false end
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=Duel.GetReleaseGroup(tp,true,REASON_EFFECT):Filter(Card.IsReleasable,nil)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and mg:GetCount()>0 and mg:CheckWithSumGreater(Card.GetAttack,Ouroboros[c:GetControler()]*1000) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local mg=Duel.GetReleaseGroup(tp,true,REASON_EFFECT):Filter(Card.IsReleasable,nil)
	if mg:GetCount()==0 then return end
	if c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g=mg:SelectSubGroup(tp,cm.fselect,false,1,Ouroboros[c:GetControler()],tp,Ouroboros[c:GetControler()]*1000)
		if g and g:GetCount()>0 then
			if Duel.Release(g,REASON_EFFECT)~=0 then
				Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
