--[[--
	INIT
--]]--
----------------------------------------------------------------------------------------------------

local __addon, __private = ...;
local MT = {  }; __private.MT = MT;		--	method
local CT = {  }; __private.CT = CT;		--	constant
local VT = {  }; __private.VT = VT;		--	variables
local DT = {  }; __private.DT = DT;		--	data

-->
	local select = select;
	local tinsert, tremove = table.insert, table.remove;

	VT.IsCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC;		--	14
	VT.IsWrath = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC;			--	11
	VT.IsTBC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC;	--	5
	VT.IsVanilla = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC;				--	2
	VT.IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE;				--	1

	if not VT.IsCata and not VT.IsWrath and not VT.IsTBC and not VT.IsVanilla then
		VT.UnsupportedClient = true;
		return;
	end
	if select(4, GetBuildInfo()) >= 20000 then
		MT.UnitAura = UnitAura;
	else
		local LibClassicDurations = LibStub("LibClassicDurations");
		if LibClassicDurations then
			LibClassicDurations:Register(__addon);
			function MT.UnitAura(unit, index, filter)
				return LibClassicDurations:UnitAura(unit, index, filter);
			end
		else
			function MT.UnitAura(unit, index, filter)
				return nil;
			end
		end
	end

-->
	MT.CoverFrames = {  };
	MT.UnitFrames = {  };
	MT.CodeAfterCombat = {  };
-->

local function EventDispatcher(self, event, ...)
	if self[event] then
		return self[event](self, event, ...);
	end
end


local Driver = CreateFrame("FRAME");

function Driver.ADDON_LOADED(self, event, addon)
	if strlower(addon) ~= strlower(__addon) then
		return;
	end

	self:UnregisterEvent("ADDON_LOADED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");

	if alaUnitFrameSV and alaUnitFrameSV._ver ~= nil and alaUnitFrameSV._ver > 20241201.0 then
		if alaUnitFrameSV._ver < 20241202.0 then
			for _, k in next, { 'player', 'pet', 'target', 'targettarget', 'focus', 'focustarget', 'party', 'boss', } do
				local v = alaUnitFrameSV[k];
				if v and type(v) == 'table' then
					v.Class = v.class;
					v.Portrait3D = not VT.IsVanilla;
					v.HBarValue = v.hVal;
					v.PBarValue = v.pVal;
					v.HBarPercentage = v.hPer;
					v.PBarPercentage = v.pPer;
					v.BarTextAlpha = v.text_alpha;
					v.Scale = v.scale;
				end
			end
		end
	else
		_G.alaUnitFrameSV = CT.DefaultConfig;
	end
	alaUnitFrameSV._ver = 20241202.0;
	alaUnitFrameSV.__seen = alaUnitFrameSV.__seen or {  };
	alaUnitFrameSV.__seen[UnitGUID('player')] = true;

	alaUnitFrameSV.which = alaUnitFrameSV.which or "general";

	VT.DB = alaUnitFrameSV;
end
function Driver.PLAYER_ENTERING_WORLD(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD");

	MT.InitFrames();

	MT.InitConfigFrame();

end
function Driver.PLAYER_REGEN_ENABLED(self, event)
	while MT.CodeAfterCombat[1] do
		tremove(MT.CodeAfterCombat, 1)();
	end
end

Driver:SetScript("OnEvent", EventDispatcher);
Driver:RegisterEvent("ADDON_LOADED");
Driver:RegisterEvent("PLAYER_ENTERING_WORLD");


function MT.RegisterEvent(event, callback)
	Driver[event] = callback;
	return Driver:RegisterEvent(event);
end
function MT.RunAfterCombat(func)
	tinsert(MT.CodeAfterCombat, func);
end

function MT.FrameRegisterEvent(F, ...)
	for i = 1, select("#", ...) do
		local event = select(i, ...);
		F:RegisterEvent(event);
		if not F[event] then
			F[event] = _noop_;
		end
	end
	if not F:GetScript("OnEvent") then
		F:SetScript("OnEvent", EventDispatcher);
	end
end
function MT.FrameRegisterUnitEvent(F, unit, ...)
	for i = 1, select("#", ...) do
		local event = select(i, ...);
		F:RegisterUnitEvent(event, unit);
		if not F[event] then
			F[event] = _noop_;
		end
	end
	if not F:GetScript("OnEvent") then
		F:SetScript("OnEvent", EventDispatcher);
	end
end
function MT.FrameUnregisterEvent(F, ...)
	for i = 1, select("#", ...) do
		F:UnregisterEvent(select(i, ...));
	end
end
