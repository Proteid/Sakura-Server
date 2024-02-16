--WR-『someplace』
Duel.LoadScript("c62015410.lua")
local cm,m=GetID()
function cm.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(cm.thtg)
	e2:SetOperation(cm.thop)
	c:RegisterEffect(e2)
	--draw
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(cm.drtg)
	e3:SetOperation(cm.drop)
	c:RegisterEffect(e3)
end
function cm.cfilter(c,code)
	return c:IsCode(code) and (c:IsFaceup() or not c:IsOnField())
end
function cm.thfilter(c,tp)
	return c:IsSetCard(0xf72) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
		and not Duel.IsExistingMatchingCard(cm.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cm.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function cm.drfilter(c,e)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0xf72) and c:IsType(TYPE_NORMAL)
	and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function cm.fselect(sg)
	return sg:GetClassCount(Card.GetCode)==3 or sg:GetClassCount(Card.GetCode)==6
end
function cm.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(cm.drfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and #g>=3 end
	local max=3
	if Duel.IsPlayerCanDraw(tp,2) then max=6 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:SelectSubGroup(tp,cm.fselect,false,3,max)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,sg:GetClassCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,sg:GetClassCount()//3)
end
function cm.drop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetClassCount()>0 then
		Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		if ct==0 then return end
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			local mg=Duel.GetDecktopGroup(tp,1)
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
		Duel.BreakEffect()
		Duel.Draw(tp,ct//3,REASON_EFFECT)
	end
end
