SakuraCore = SakuraCore or {} --Sakura Code
SignData=SignData or {}
ClineHint = ClineHint or {}
Dream = Dream or {} --梦旅人
DamageCheck = DamageCheck or {} --伤害检测

DamageCheck.Type={TypeBattle,TypeEffect,TypeAll,TypeBattleT,TypeEffectT,TypeAllT}

function SakuraCore.Start()
	if not SakuraCore.SpecialRule then
		SakuraCore.SpecialRule=true
		DamageCheck.Load()
		for i=1,#SignData.Type do
			Load("SignData."..SignData.Type[i].."={[0]=0,[1]=0}")()
		end
	end
end

--【梦境】
function Dream.Dreamland(c,tp)
	if not Dream.GlobalCheck_Dreamland then
		Dream.GlobalCheck_Dreamland=true
		Dreamland={[0]=0,[1]=0}
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
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e3:SetCountLimit(1)
		e3:SetCondition(Dream.thcon)
		e3:SetOperation(Dream.thop)
		Duel.RegisterEffect(e3,tp)
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
	if Dreamland[tp]>0 and val>=1000 and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		if Duel.IsExistingMatchingCard(Dream.damfilter,pl,LOCATION_MZONE,0,1,nil) then
			repeat
				Dreamland[tp]=Dreamland[tp]-1
				val=val-1000
			until (Dreamland[tp]<1 or val<1000)
			local ct=math.min(Dreamland[tp],val//1000)
			val=val-ct*1000
			Dreamland[p]=Dreamland[p]-ct
			Dream.ClineHintEffect(e:GetHandler(),pl)
			return val
		else
			Ouroboros[p]=Ouroboros[p]-val//1000
			Duel.SetFlagEffectLabel(pl,DREAMLAND_CODE,DREAMLAND)
			Dream.ClientHintDreamland(e:GetHandler(),pl)
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

--【夜魇】
function Dream.Nightmare(c,tp)
	if not Dream.GlobalCheck_Nightmare then
		Dream.GlobalCheck_Nightmare=true
		Nightmare={[0]=0,[1]=0}
	end
	Dream.ClientHintNightmare(c,tp)
end

--阿卡迪亚回手专用函数
function SakuraCore.EnableArcadiaReturn(c,event1,...)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(event1)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(SakuraCore.ArcadiaReturnReg)
	c:RegisterEffect(e1)
	for i,event in ipairs{...} do
		local e2=e1:Clone()
		e2:SetCode(event)
		c:RegisterEffect(e2)
	end
end
function SakuraCore.ArcadiaReturnReg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetDescription(1104)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	if c:IsHasEffect(EFFECT_SPIRIT_DONOT_RETURN) then
		e1:SetReset(RESET_EVENT+0xd7e0000+RESET_PHASE+PHASE_END,2)
	else
		e1:SetReset(RESET_EVENT+0xd7e0000+RESET_PHASE+PHASE_END)
	end
	e1:SetCondition(SakuraCore.ArcadiaReturnConditionForced)
	e1:SetTarget(SakuraCore.ArcadiaReturnTargetForced)
	e1:SetOperation(SakuraCore.ArcadiaReturnOperation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCondition(SakuraCore.ArcadiaReturnConditionOptional)
	e2:SetTarget(SakuraCore.ArcadiaReturnTargetOptional)
	c:RegisterEffect(e2)
end
function SakuraCore.ArcadiaReturnConditionForced(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsHasEffect(EFFECT_SPIRIT_DONOT_RETURN) and not c:IsHasEffect(EFFECT_SPIRIT_MAYNOT_RETURN)
end
function SakuraCore.ArcadiaReturnTargetForced(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function SakuraCore.ArcadiaReturnConditionOptional(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsHasEffect(EFFECT_SPIRIT_DONOT_RETURN) and c:IsHasEffect(EFFECT_SPIRIT_MAYNOT_RETURN)
end
function SakuraCore.ArcadiaReturnTargetOptional(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function SakuraCore.ArcadiaReturnOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_PUBLIC)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			tc:RegisterEffect(e1)
		end
	end
end

--Cline Hint
function Dream.ClientHintDreamland(c,tp)
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
function Dream.ClientHintNightmare(c,tp)
	local sign=Nightmare[tp]
	if ClineHint[sign] then
		ClineHint[sign]:Reset()
	end
	ClineHint[sign]=Effect.CreateEffect(c)
	ClineHint[sign]:SetDescription(aux.Stringid(DREAMLAND_CODE,Nightmare[tp]))
	ClineHint[sign]:SetType(EFFECT_TYPE_FIELD)
	ClineHint[sign]:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	ClineHint[sign]:SetCode(DREAMLAND_CODE)
 	ClineHint[sign]:SetTargetRange(1,0)
 	Duel.RegisterEffect(ClineHint[sign],tp)
end

--伤害检测
function DamageCheck.Load()
	if not DamageCheck.global_check then
		for i=1,#DamageCheck.Type do
			Load("DamageCheck."..DamageCheck.Type[i].."={[0]=0,[1]=0}")()
		end
		local e0=GlobalEffect()
		e0:SetType(EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		e0:SetCountLimit(1)
		e0:SetOperation(DamageCheck.TurnReset)
		Duel.RegisterEffect(e0,0)
		local e1=GlobalEffect()
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_DAMAGE)
		e1:SetCondition(DamageCheck.battlecon)
		e1:SetOperation(DamageCheck.battleop)
		Duel.RegisterEffect(e1,0)
		local e2=Effect.CreateEffect()
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_DAMAGE)
		e2:SetCondition(DamageCheck.effectcon)
		e2:SetOperation(DamageCheck.effectop)
		Duel.RegisterEffect(e2,0)
		local e3=Effect.CreateEffect()
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_DAMAGE)
		e3:SetCondition(DamageCheck.effectcon)
		e3:SetOperation(DamageCheck.effectop)
		Duel.RegisterEffect(e3,0)
	end
end
function DamageCheck.TurnReset(e,tp,eg,ep,ev,re,r,rp)
	for i=1,#DamageCheck.Type do
		if string.sub(DamageCheck.Type[i],-1,-1)=="T" then
			Load("DamageCheck."..DamageCheck.Type[i].."={[0]=0,[1]=0}")()
		end
	end
end
function DamageCheck.battlecon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0 and ev>0
end
function DamageCheck.battleop(e,tp,eg,ep,ev,re,r,rp)
	DamageCheck.TypeBattle[ep]=DamageCheck.TypeBattle[ep]+ev
	DamageCheck.TypeBattleT[ep]=DamageCheck.TypeBattleT[ep]+ev
end
function DamageCheck.effectcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and ev>0
end
function DamageCheck.effectop(e,tp,eg,ep,ev,re,r,rp)
	DamageCheck.TypeEffect[ep]=DamageCheck.TypeEffect[ep]+ev
	DamageCheck.TypeEffectT[ep]=DamageCheck.TypeEffectT[ep]+ev
end
function DamageCheck.allcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 and ev>0
end
function DamageCheck.allop(e,tp,eg,ep,ev,re,r,rp)
	DamageCheck.TypeAll[ep]=DamageCheck.TypeAll[ep]+ev
	DamageCheck.TypeAllT[ep]=DamageCheck.TypeAllT[ep]+ev
end
