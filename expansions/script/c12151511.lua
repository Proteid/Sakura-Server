--LOOK
Duel.LoadScript("c62015410.lua")
local s,id,o=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,nil,1,1)
end
