--連合軍
Duel.LoadScript("c62015410.lua")
local cm,m=GetID()
function cm.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_TOMAIN_KOISHI)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(cm.val)
	e1:SetTargetRange(LOCATION_EXTRA,0)
	c:RegisterEffect(e1)
	--change effect type
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(m)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(1163)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC_G)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(cm.PendConditionExtratoMain())
	e3:SetOperation(cm.PendOperationExtratoMain())
	e3:SetValue(SUMMON_TYPE_PENDULUM)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_PZONE)
	e4:SetTargetRange(LOCATION_SZONE,0)
	e4:SetTarget(cm.eftg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
function cm.eftg(e,c)
	local seq=c:GetSequence()
	return c:IsLocation(LOCATION_PZONE)
end
function cm.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR+RACE_SPELLCASTER)
end
function cm.val(e,c,sump,sumtype,sumpos,targetp,se)
	return  c:IsSetCard(0xfff) and c:IsType(TYPE_PENDULUM) and bit.band(c:GetSummonType(),SUMMON_TYPE_PENDULUM)>0
end
function cm.PendConditionExtratoMain()
	return  function(e,c,og)
				if c==nil then return true end
				local tp=c:GetControler()
				local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)}
				if Auxiliary.PendulumChecklist&(0x1<<tp)~=0 and #eset==0 then return false end
				local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
				if rpz==nil or c==rpz then return false end
				local lscale=c:GetLeftScale()
				local rscale=rpz:GetRightScale()
				if lscale>rscale then lscale,rscale=rscale,lscale end
				local loc=0
				if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
				if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)>0 then loc=loc+LOCATION_EXTRA end
				if loc==0 then return false end
				local g=nil
				if og then
					g=og:Filter(Card.IsLocation,nil,loc)
				else
					g=Duel.GetFieldGroup(tp,loc,0)
				end
				local p_check=g:IsExists(Auxiliary.PConditionFilter,1,nil,e,tp,lscale,rscale,eset)
				if p_check then return false end
				if loc&LOCATION_EXTRA==0 then
					loc=loc+LOCATION_EXTRA
				end
				if og then
					g=og:Filter(Card.IsLocation,nil,loc)
				else
					g=Duel.GetFieldGroup(tp,loc,0)
				end
				return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:IsExists(Auxiliary.PConditionFilter,1,nil,e,tp,lscale,rscale,eset)
			end
end
function cm.PendOperationCheckExtratoMain(ft1,ft2,ft)
	return  function(g)
				local exg=g:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
				local mg=g-exg
				return #g<=ft and ((#exg<=ft2 and #mg<=ft1) or Duel.IsPlayerAffectedByEffect(tp,m))
			end
end
function cm.PendOperationExtratoMain()
	return  function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
				local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
				local lscale=c:GetLeftScale()
				local rscale=rpz:GetRightScale()
				if lscale>rscale then lscale,rscale=rscale,lscale end
				local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)}
				local tg=nil
				local loc=0
				local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
				local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
				local ft=Duel.GetUsableMZoneCount(tp)
				local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
				if ect and ect<ft2 then ft2=ect end
				if Duel.IsPlayerAffectedByEffect(tp,59822133) then
					if ft1>0 then ft1=1 end
					if ft2>0 then ft2=1 end
					ft=1
				end
				if ft1>0 then loc=loc|LOCATION_HAND end
				if ft2>0 or Duel.IsPlayerAffectedByEffect(tp,m) then loc=loc|LOCATION_EXTRA end
				if og then
					tg=og:Filter(Card.IsLocation,nil,loc):Filter(Auxiliary.PConditionFilter,nil,e,tp,lscale,rscale,eset)
				else
					tg=Duel.GetMatchingGroup(Auxiliary.PConditionFilter,tp,loc,0,nil,e,tp,lscale,rscale,eset)
				end
				local ce=nil
				local b1=Auxiliary.PendulumChecklist&(0x1<<tp)==0
				local b2=#eset>0
				if b1 and b2 then
					local options={1163}
					for _,te in ipairs(eset) do
						table.insert(options,te:GetDescription())
					end
					local op=Duel.SelectOption(tp,table.unpack(options))
					if op>0 then
						ce=eset[op]
					end
				elseif b2 and not b1 then
					local options={}
					for _,te in ipairs(eset) do
						table.insert(options,te:GetDescription())
					end
					local op=Duel.SelectOption(tp,table.unpack(options))
					ce=eset[op+1]
				end
				if ce then
					tg=tg:Filter(Auxiliary.PConditionExtraFilterSpecific,nil,e,tp,lscale,rscale,ce)
				end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				Auxiliary.GCheckAdditional=cm.PendOperationCheckExtratoMain(ft1,ft2,ft)
				local g=tg:SelectSubGroup(tp,Auxiliary.TRUE,true,1,math.min(#tg,ft))
				Auxiliary.GCheckAdditional=nil
				if not g then return end
				if ce then
					Duel.Hint(HINT_CARD,0,ce:GetOwner():GetOriginalCode())
					ce:UseCountLimit(tp)
				else
					Auxiliary.PendulumChecklist=Auxiliary.PendulumChecklist|(0x1<<tp)
				end
				sg:Merge(g)
				Duel.HintSelection(Group.FromCards(c))
				Duel.HintSelection(Group.FromCards(rpz))
			end
end