SakuraCore = SakuraCore or {} --Sakura Code
ClineHint = ClineHint or {}
Dream = Dream or {} --梦旅人
DamageCheck.{} --伤害检测

if not DAMAGECHECK_BATTLE then DAMAGECHECK_BATTLE=46878085 end
if not DAMAGECHECK_EFFECT then DAMAGECHECK_EFFECT=46878086 end
if not DAMAGECHECK_ALL then DAMAGECHECK_ALL=46878087 end
if not OUROBOROS_CODE then OUROBOROS_CODE=68419684 end
if not OUROBOROS then OUROBOROS=0 end

--【梦境】
function Dream.Dreamland(c,tp)
	if not Dream.GlobalCheck then
		Dream.GlobalCheck=true
		Dreamland={[0]=0,[1]=0}
		Dreamland[tp]=Dreamland[tp]+1
		--damage reduce
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(Dream.damval)
		e1:SetLabel(tp)
		Duel.RegisterEffect(e1,tp)
		--to hand
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetCountLimit(1)
		e2:SetCondition(Dream.thcon)
		e2:SetOperation(Dream.thop)
		Duel.RegisterEffect(e2,tp)
	else
		Dreamland[tp]=Dreamland[tp]+1
	end
	Dream.ClineHintEffect(c,tp)
end
function Dream.damfilter(c)
	return c:IsSetCard(0xd20) and c:IsFaceup()
end
function Dream.damval(e,re,val,r,rp,rc)
	local pl=e:GetLabel()
	if DREAMLAND>0 and val>=1000 and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		if Duel.IsExistingMatchingCard(Dream.damfilter,pl,LOCATION_MZONE,0,1,nil) then
			DREAMLAND=DREAMLAND-1

			Duel.SetFlagEffectLabel(pl,DREAMLAND_CODE,DREAMLAND)
			val=val-
			Dream.ClineHintEffect(e:GetHandler(),pl)
			return 0
		else
			local ct=math.floor(val/1000)
			DREAMLAND=DREAMLAND-ct
			Duel.SetFlagEffectLabel(pl,DREAMLAND_CODE,DREAMLAND)
			Dream.ClineHintEffect(e:GetHandler(),pl)
			return val
		end
	else return val end
end
function Dream.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffectLabel(tp,DREAMLAND)==10 and Duel.GetTurnPlayer()==tp
end
function Dream.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=Duel.CreateToken(tp,96531714)
	Duel.SendtoHand(c,nil,REASON_RULE)
	Duel.ConfirmCards(1-tp,c)
	Duel.ShuffleHand(tp)
end

--Cline Hint
function Dream.ClineHintEffect(c,tp)
	local sign=Dreamland[tp]
	if ClineHint[sign] then
		ClineHint[sign]:Reset()
	end
	ClineHint[sign]=Effect.CreateEffect(c)
	ClineHint[sign]:SetDescription(aux.Stringid(DREAMLAND_CODE,DREAMLAND))
	ClineHint[sign]:SetType(EFFECT_TYPE_FIELD)
	ClineHint[sign]:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	ClineHint[sign]:SetCode(DREAMLAND_CODE)
 	ClineHint[sign]:SetTargetRange(1,0)
 	Duel.RegisterEffect(ClineHint[sign],tp)
end

--伤害检测
function DamageCheck.BattleOnly(c)
	if not DamageCheck.global_check_battle then
		DamageCheck.global_check_battle=true
		DamageBattleTurn={[0]=0,[1]=0}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetCondition(DamageCheck.battlecon)
		ge1:SetOperation(DamageCheck.battleop)
		Duel.RegisterEffect(ge1,0)
	end
end
function DamageCheck.battlecon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0 and ev>0
end
function DamageCheck.battleop(e,tp,eg,ep,ev,re,r,rp)
	DamageBattleTurn[ep]=DamageBattleTurn[ep]+ev
end
function DamageCheck.EffectOnly(c)
	if not DamageCheck.global_check_effect then
		DamageCheck.global_check_effect=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetCondition(DamageCheck.effectcon)
		ge1:SetOperation(DamageCheck.effectop)
		Duel.RegisterEffect(ge1,0)
	end
end
function DamageCheck.effectcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and ev>0
end
function DamageCheck.effectop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(ep,DAMAGECHECK_EFFECT)<=0 then
		Duel.RegisterFlagEffect(ep,DAMAGECHECK_EFFECT,RESET_PHASE+PHASE_END,0,1,ev)
	else
		local prev=Duel.GetFlagEffectLabel(ep,DAMAGECHECK_EFFECT)
		Duel.SetFlagEffectLabel(ep,DAMAGECHECK_EFFECT,prev+ev)
	end
end
function DamageCheck.All(c)
	if not DamageCheck.global_check_all then
		DamageCheck.global_check_all=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetCondition(DamageCheck.allcon)
		ge1:SetOperation(DamageCheck.allop)
		Duel.RegisterEffect(ge1,0)
	end
end
function DamageCheck.allcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 and ev>0
end
function DamageCheck.allop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(ep,DAMAGECHECK_ALL)<=0 then
		Duel.RegisterFlagEffect(ep,DAMAGECHECK_ALL,RESET_PHASE+PHASE_END,0,1,ev)
	else
		local prev=Duel.GetFlagEffectLabel(ep,DAMAGECHECK_ALL)
		Duel.SetFlagEffectLabel(ep,DAMAGECHECK_ALL,prev+ev)
	end
end
