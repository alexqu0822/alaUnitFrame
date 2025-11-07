--[[--
	MAIN
--]]--
----------------------------------------------------------------------------------------------------

local __addon, __private = ...;
local MT = __private.MT;
local CT = __private.CT;
local VT = __private.VT;
local DT = __private.DT;

if VT.UnsupportedClient then
	return;
end

local __ala_meta__ = _G.__ala_meta__;
local uireimp = __ala_meta__.uireimp;

----------------------------------------------------------------------------------------------------upvalue
	local select, next = select, next;
	local type, tonumber = type, tonumber;
	local pcall = pcall;
	local abs, min = math.abs, math.min;
	local format, strmatch = string.format, string.match;
	local GetTime = GetTime;
	local GetTickTime = GetTickTime;
	local After = C_Timer.After;
	local InCombatLockdown = InCombatLockdown;
	local UnitName = UnitName;
	local UnitIsPlayer = UnitIsPlayer;
	local UnitExists = UnitExists;
	local UnitClassBase = UnitClassBase;
	local UnitIsGhost = UnitIsGhost;
	local UnitIsConnected = UnitIsConnected;
	local UnitIsVisible = UnitIsVisible;
	local UnitLevel = UnitLevel;
	local UnitIsEnemy = UnitIsEnemy;
	local UnitPlayerControlled = UnitPlayerControlled;
	local UnitIsDead = UnitIsDead;
	local UnitStat = UnitStat;
	local UnitDetailedThreatSituation = UnitDetailedThreatSituation;
	local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax;
	local UnitPowerType = UnitPowerType;
	local UnitPower, UnitPowerMax = UnitPower, UnitPowerMax;
	local UnitClassification = UnitClassification;
	local UnitChannelInfo = UnitChannelInfo;
	local UnitCastingInfo = UnitCastingInfo;
	local GetPowerRegen = GetPowerRegen;
	local IsInRaid, IsInGroup = IsInRaid, IsInGroup;
	local GetNumGroupMembers = GetNumGroupMembers;
	local GetRaidTargetIndex = GetRaidTargetIndex;

	local _ = nil;
	local _G = _G;
	local RegisterUnitWatch = RegisterUnitWatch;
	local UnregisterUnitWatch = UnregisterUnitWatch;
	local GameTooltip = GameTooltip
	local TargetFrame = TargetFrame;
	local PlayerFrame = PlayerFrame;
	local SetRaidTargetIconTexture = SetRaidTargetIconTexture;
	local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS;
	local RAID_CLASS_COLORS = RAID_CLASS_COLORS;
	local PowerBarColor = PowerBarColor;
	local LE_PARTY_CATEGORY_HOME, LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_HOME, LE_PARTY_CATEGORY_INSTANCE;
----------------------------------------------------------------------------------------------------

local POWER_RESTORATION_UPDATE_INTERVAL = 0.03;
local TARGET_UPDATE_INTERVAL = 0.10;
local THREAT_UPDATE_INTERVAL = 0.25;

local TEXTURE_UNK = "Interface\\Icons\\inv_misc_questionmark";
local BORDER_TEXTURE_LIST = {
	"Interface\\TargetingFrame\\UI-TargetingFrame",
	"Interface\\TargetingFrame\\UI-TargetingFrame-Rare",
	"Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite",
	"Interface\\TargetingFrame\\UI-TargetingFrame-Elite",
	"Interface\\TargetingFrame\\UI-SmallTargetingFrame",
	"Interface\\TargetingFrame\\UI-TargetofTargetFrame",
	"Interface\\TargetingFrame\\UI-PartyFrame",
	--
	"Interface\\AddOns\\alaUnitFrame\\ARTWORK\\UI-TargetingFrame",
	"Interface\\AddOns\\alaUnitFrame\\ARTWORK\\UI-TargetingFrame-Rare",
	"Interface\\AddOns\\alaUnitFrame\\ARTWORK\\UI-TargetingFrame-Rare-Elite",
	"Interface\\AddOns\\alaUnitFrame\\ARTWORK\\UI-TargetingFrame-Elite",
	"Interface\\AddOns\\alaUnitFrame\\ARTWORK\\UI-SmallTargetingFrame",
	"Interface\\AddOns\\alaUnitFrame\\ARTWORK\\UI-TargetofTargetFrame",
	"Interface\\AddOns\\alaUnitFrame\\ARTWORK\\UI-PartyFrame",
};


local function _noop_(...)
	return true;
end
local _VirtualWidget = {
	Show = _noop_,
	Hide = _noop_,
	ClearAllPoints = _noop_,
	SetPoint = _noop_,
	SetAlpha = _noop_,
	SetScale = _noop_,
	SetText = _noop_,
	SetTextColor = _noop_,
	SetVertexColor = _noop_,
	SetTexture = _noop_,
	SetTexCoord = _noop_,
};



function MT.GetConfig(configKey, key)
	return VT.DB[configKey or "general"][key];
end
function MT.BuildConfig(configKey)
	VT.DB[configKey] = VT.DB[configKey] or {  };
	for k, v in next, VT.DB.general do
		if VT.DB[configKey][k] == nil then
			VT.DB[configKey][k] = v;
		end
	end
end
function MT.SetConfigValue(configKey, key, v)
	VT.DB[configKey][key] = v;
	if configKey == 'general' then
		for unit, CoverFrame in next, MT.CoverFrames do
			VT.DB[CoverFrame.configKey][key] = v;
			if CoverFrame[key] then
				if v then
					CoverFrame[key](CoverFrame, v);
				else
					CoverFrame[key](CoverFrame, v);
				end
				CoverFrame:UpdatePowerType();
				CoverFrame:UpdateHealth();
				CoverFrame:UpdatePower();
				CoverFrame:Update3DPortrait();
				CoverFrame:UpdateClass();
			end
		end
	else
		local CoverFrame = MT.CoverFrames[configKey];
		if CoverFrame and CoverFrame[key] then
			if v then
				CoverFrame[key](CoverFrame, v);
			else
				CoverFrame[key](CoverFrame, v);
			end
		else
			for unit, CoverFrame in next, MT.CoverFrames do
				if CoverFrame.configKey == configKey and CoverFrame[key] then
					if v then
						CoverFrame[key](CoverFrame, v);
					else
						CoverFrame[key](CoverFrame, v);
					end
					CoverFrame:UpdatePowerType();
					CoverFrame:UpdateHealth();
					CoverFrame:UpdatePower();
					CoverFrame:Update3DPortrait();
					CoverFrame:UpdateClass();
				end
			end
		end
	end
end
function MT.SetConfigBoolean(configKey, key, v)
	VT.DB[configKey][key] = v;
	if configKey == 'general' then
		for unit, CoverFrame in next, MT.CoverFrames do
			VT.DB[CoverFrame.configKey][key] = v;
			if CoverFrame[key] then
				if v then
					CoverFrame[key]:Show();
				else
					CoverFrame[key]:Hide();
				end
				CoverFrame:UpdatePowerType();
				CoverFrame:UpdateHealth();
				CoverFrame:UpdatePower();
				CoverFrame:Update3DPortrait();
				CoverFrame:UpdateClass();
			end
		end
	else
		local CoverFrame = MT.CoverFrames[configKey];
		if CoverFrame and CoverFrame[key] then
			if v then
				CoverFrame[key]:Show();
			else
				CoverFrame[key]:Hide();
			end
		else
			for unit, CoverFrame in next, MT.CoverFrames do
				if CoverFrame.configKey == configKey and CoverFrame[key] then
					if v then
						CoverFrame[key]:Show();
					else
						CoverFrame[key]:Hide();
					end
					CoverFrame:UpdatePowerType();
					CoverFrame:UpdateHealth();
					CoverFrame:UpdatePower();
					CoverFrame:Update3DPortrait();
					CoverFrame:UpdateClass();
				end
			end
		end
	end
end


function MT.GetPercentageText(value, maxVal)
	if maxVal ~= 0 then
		return format("%.1f%%", 100 * value / maxVal);
	else
		return "";
	end
end
function MT.GetHealthColor(val, maxVal)
	local p = val / maxVal;
	local r = 0.0;
	local g = 0.0;
	if p > 0.5 then
		r = (1.0 - p) * 2.0;
		g = 1.0;
	else
		r = 1.0;
		g = p;
	end
	return r, g, 0.0;
end

function MT.AttachClassicCastBar(UnitFrame, castBar, hPos, vOfs, hOfs, width, height, iconPos)
	if VT.DB.castBar then
	-- if IsAddOnLoaded("ClassicCastbars") then
		_G.ClassicCastbarsDB = _G.ClassicCastbarsDB or {  };
		VT.DB.ClassicCastbarsDB = VT.DB.ClassicCastbarsDB or _G.ClassicCastbarsDB["target"];
		_G.ClassicCastbarsDB["target"] = {
			["castFontSize"] = 15,
			["autoPosition"] = false,
			["iconPositionX"] = 0,
			["textPositionX"] = 0,
			["hideIconBorder"] = false,
			["castStatusBar"] = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
			["borderColor"] = {
				1,
				1,
				1,
				1,
			},
			["iconSize"] = height,
			["enabled"] = true,
			["showIcon"] = true,
			["frameLevel"] = 10,
			["castBorder"] = "",
			["castFont"] = "Fonts\\ARKai_T.ttf",
			["textPositionY"] = 0,
			["showCastInfoOnly"] = false,
			["width"] = width,
			["showTimer"] = true,
			["statusColor"] = {
				1,
				0.7,
				0,
				1,
			},
			["statusColorChannel"] = {
				0,
				1,
				0,
				1,
			},
			["position"] = {
				"CENTER",
				vOfs,
				UnitFrame:GetHeight() / 2 + height / 2 + hOfs,
			},
			["height"] = height,
			["statusBackgroundColor"] = {
				0,
				0,
				0,
				0.535,
			},
			["iconPositionY"] = 0,
			["textColor"] = {
				1,
				1,
				1,
				1,
			},
		};
	end
	-- end
end
function MT.ResetClassicCastBar()
	if not VT.DB.castBar then
		if VT.DB.ClassicCastbarsDB and ClassicCastbarsDB then
			ClassicCastbarsDB["target"] = VT.DB.ClassicCastbarsDB;
			VT.DB.ClassicCastbarsDB = nil;
		end
	end
end
function MT.AttachCastBar(UnitFrame, CastBar, hPos, vOfs, hOfs, width, height, iconPos)
	local name = CastBar:GetName();
	if not VT.DB[name] then
		VT.DB[name] = {  };
		VT.DB[name].size = { CastBar:GetSize() };
		VT.DB[name].pos = { CastBar:GetPoint() };
		for i = 1, #VT.DB[name].pos do
			if type(VT.DB[name][i]) == 'table' then
				VT.DB[name][i] = VT.DB[name][i]:GetName();
			end
		end
	end
	CastBar:SetSize(width, height);
	CastBar.Icon:SetSize(height, height);
	CastBar.Icon:ClearAllPoints();
	if iconPos == "LEFT" then
		CastBar.Icon:SetPoint("RIGHT", CastBar, "LEFT", -4, 0);
	elseif iconPos== "RIGHT" then
		CastBar.Icon:SetPoint("LEFT", CastBar, "RIGHT", 4, 0);
	end
	CastBar.Icon:Show();

	-- CastBar.Border:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border-Small");
	-- CastBar.Border:SetSize(0, 49);
	-- CastBar.Border:ClearAllPoints();
	-- CastBar.Border:SetPoint("TOPLEFT", -23, 20);
	-- CastBar.Border:SetPoint("TOPRIGHT", 23, 20);
	CastBar.Border:Hide();
	CastBar.BorderShield:SetSize(0, 49);
	CastBar.BorderShield:ClearAllPoints();
	CastBar.BorderShield:SetPoint("TOPLEFT", -28, 20);
	CastBar.BorderShield:SetPoint("TOPRIGHT", 18, 20);

	CastBar.Text:SetSize(0, 24);
	CastBar.Text:ClearAllPoints();
	--CastBar.Text:SetPoint("TOPLEFT", 0, 4);
	--CastBar.Text:SetPoint("TOPRIGHT", 0, 4);
	CastBar.Text:SetPoint("CENTER");

	-- CastBar.Flash:SetTexture("Interface\\CastingBar\\UI-CastingBar-Flash-Small");
	-- CastBar.Flash:SetSize(0, 49);
	-- CastBar.Flash:ClearAllPoints();
	-- CastBar.Flash:SetPoint("TOPLEFT", -23, 20);
	-- CastBar.Flash:SetPoint("TOPRIGHT", 23, 20);
	CastBar.Flash._Show = CastBar.Flash.Show;
	CastBar.Flash.Show = function()end;
	CastBar.Flash:Hide();
	CastBar._ClearAllPoints = CastBar.ClearAllPoints;
	CastBar.ClearAllPoints = function()end;
	CastBar._SetPoint = CastBar.SetPoint
	CastBar.SetPoint = function()end;
	CastBar:_ClearAllPoints();
	-- CastBar.Spark:SetTexCoord(0.0, 1.0, 11 / 32, 20 / 32);
	-- if hPos == "TOP" then
		CastBar:_SetPoint("BOTTOM", UnitFrame, "TOP", vOfs, hOfs);
		--CastBar:_SetPoint("BOTTOMRIGHT", UnitFrame, "TOPRIGHT", 0, hOfs);
	-- elseif hPos == "DOWN" then
	-- 	CastBar:_SetPoint("TOPLEFT", UnitFrame, "BOTTOMLEFT", 0, -hOfs);
	-- 	CastBar:_SetPoint("TOPRIGHT", UnitFrame, "BOTTOMRIGHT", 0, -hOfs);
	-- end
end
function MT.ResetCastBar(CastBar)
	local name = CastBar:GetName();
	if VT.DB[name] and type(VT.DB[name]) == 'table' then
		local size = VT.DB[name].size;
		if size and type(size) == 'table' then
			CastBar:SetSize(size[1], size[2]);
		end
		local pos = VT.DB[name].pos;
		if pos and type(pos) == 'table' then
			CastBar:ClearAllPoints();
			CastBar:SetPoint(pos[1], pos[2], pos[3], pos[4], pos[5]);
		end
	end
end


function MT.CreateExtraPower0(CoverFrame, unit, PortraitPosition)
	-- if true then return; end
	if CoverFrame.CLASS ~= "DRUID" then
		return;
	end
	local UnitFrame = CoverFrame.UnitFrame;
	local UnitFrameName = UnitFrame:GetName();
	local _PBar = UnitFrame.manabar or (UnitFrameName and _G[UnitFrameName .. "ManaBar"]);
	local configKey = CoverFrame.configKey;
	if _PBar then
		-- CoverFrame.extra_power0_frame = CreateFrame("FRAME", nil, CoverFrame);
		local ExtraPower0 = CreateFrame("STATUSBAR", nil, CoverFrame);
		ExtraPower0:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
		ExtraPower0:SetStatusBarColor(0.0, 0.0, 1.0, 1.0);
		ExtraPower0:SetHeight(_PBar:GetHeight());
		uireimp._SetBackdrop(ExtraPower0, {
			bgFile = "Interface/ChatFrame/ChatFrameBackground",
			edgeFile = "Interface/ChatFrame/ChatFrameBackground",
			tile = true,
			edgeSize = 1,
			tileSize = 5,
		});
		uireimp._SetBackdropColor(ExtraPower0, 0.0, 0.0, 0.0, 0.0);
		uireimp._SetBackdropBorderColor(ExtraPower0, 0.0, 0.0, 0.0, 1.0);
		ExtraPower0:SetPoint("TOPLEFT", _PBar, "BOTTOMLEFT", 0, -4);
		ExtraPower0:SetPoint("TOPRIGHT", _PBar, "BOTTOMRIGHT", 0, -4);
		ExtraPower0:Hide();
		ExtraPower0.Value = ExtraPower0:CreateFontString(nil, "OVERLAY", "TextStatusBarText");
		ExtraPower0.Value:ClearAllPoints();
		ExtraPower0.Value:Show();
		ExtraPower0.Percentage = ExtraPower0:CreateFontString(nil, "OVERLAY", "TextStatusBarText");
		ExtraPower0.Percentage:ClearAllPoints();
		ExtraPower0.Value:SetPoint("CENTER", ExtraPower0);
		if PortraitPosition == "LEFT" then
			ExtraPower0.Percentage:SetPoint("LEFT", ExtraPower0, "RIGHT", 4, 0);
		else
			ExtraPower0.Percentage:SetPoint("RIGHT", ExtraPower0, "LEFT", -4, 0);
		end
		if VT.IsVanilla or VT.IsTBC then
			ExtraPower0.RestorationSpark = ExtraPower0:CreateTexture(nil, "OVERLAY", nil, 7);
			ExtraPower0.RestorationSpark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark");
			ExtraPower0.RestorationSpark:SetPoint("CENTER", ExtraPower0, "LEFT");
			ExtraPower0.RestorationSpark:SetWidth(10);
			ExtraPower0.RestorationSpark:SetBlendMode("ADD");
			ExtraPower0.RestorationSpark:Hide();
			ExtraPower0.RestorationDelay5Spark = CoverFrame:CreateTexture(nil, "OVERLAY", nil, 7);
			ExtraPower0.RestorationDelay5Spark:SetTexture("Interface\\CastingBar\\ui-castingbar-sparkred");
			ExtraPower0.RestorationDelay5Spark:SetPoint("CENTER", CoverFrame._PBar, "LEFT");
			ExtraPower0.RestorationDelay5Spark:SetWidth(15);
			ExtraPower0.RestorationDelay5Spark:SetBlendMode("ADD");
			ExtraPower0.RestorationDelay5Spark:Hide();
			ExtraPower0:SetScript("OnUpdate", function(self)
				if ExtraPower0.RestorationSpark:IsShown() then
					local now = GetTime();
					if CoverFrame.power_restoration_wait_timer then
						ExtraPower0.RestorationDelay5Spark:Show();
						ExtraPower0.RestorationDelay5Spark:ClearAllPoints();
						ExtraPower0.RestorationDelay5Spark:SetPoint("CENTER", self, "LEFT", self:GetWidth() * (CoverFrame.power_restoration_wait_timer - now) / 5.0, 0);
					else
						ExtraPower0.RestorationDelay5Spark:Hide();
					end
					if CoverFrame.power_restoration_time_timer then
						ExtraPower0.RestorationSpark:ClearAllPoints();
						ExtraPower0.RestorationSpark:SetPoint("CENTER", self, "RIGHT", - self:GetWidth() * (CoverFrame.power_restoration_time_timer - now) / CoverFrame.power_restoration_time, 0);
					end
				end
			end);
			if CoverFrame.LEVEL < 10 then
				-- ExtraPower0.RestorationSpark:SetAlpha(0.0);
			end
		end
		function ExtraPower0:UpdatePower()
			local unit = UnitFrame.unit or unit;
			local pv, pmv = UnitPower(unit, 0), UnitPowerMax(unit, 0);
			self:SetMinMaxValues(0, pmv);
			self:SetValue(pv);
			if VT.IsVanilla or VT.IsTBC then
				if VT.DB.power_restoration and (VT.DB.power_restoration_full or pv < pmv) then
					ExtraPower0.RestorationSpark:Show();
				else
					ExtraPower0.RestorationSpark:Hide();
				end
				if VT.DB.power_restoration and CoverFrame.power_restoration_wait_timer then
					ExtraPower0.RestorationDelay5Spark:Show();
				else
					ExtraPower0.RestorationDelay5Spark:Hide();
				end
			end
			if MT.GetConfig(configKey, "PBarValue") then
				ExtraPower0.Value:SetText(pv .. " / " .. pmv);
				ExtraPower0.Value:Show();
			else
				ExtraPower0.Value:Hide();
			end
			if MT.GetConfig(configKey, "PBarPercentage") then
				ExtraPower0.Percentage:SetText(MT.GetPercentageText(pv, pmv));
				ExtraPower0.Percentage:Show();
			else
				ExtraPower0.Percentage:Hide();
			end
		end
		function ExtraPower0:UpdatePowerMax()
			return self:UpdatePower();
		end
		function ExtraPower0:UPDATE_SHAPESHIFT_FORM(event)
			local unit = UnitFrame.unit or unit;
			local powerType, powerToken = UnitPowerType(unit);
			if powerType == 0 then
				self:Hide();
			elseif VT.DB.ExtraPower0 then
				self:Show();
				return self:UpdatePowerMax();
			end
		end
		function ExtraPower0:UNIT_DISPLAYPOWER(event, unitID)
			local unit = UnitFrame.unit or unit;
			if unit == unitID then
				local powerType, powerToken = UnitPowerType(unit);
				if powerType == 0 then
					self:Hide();
				elseif VT.DB.ExtraPower0 then
					self:Show();
					return self:UpdatePowerMax();
				end
			end
		end
		function ExtraPower0:UNIT_MAXPOWER(event, unitID, powerToken)
			local unit = UnitFrame.unit or unit;
			if unit == unitID then
				if powerToken == 'MANA' then
					self:SetMinMaxValues(0, UnitPowerMax(unit, 0));
					return self:UpdatePower();
				end
			end
		end
		function ExtraPower0:UNIT_POWER_UPDATE(event, unitID, powerToken)
			local unit = UnitFrame.unit or unit;
			if unit == unitID then
				if powerToken == 'MANA' then
					return self:UpdatePower();
				end
			end
		end
		function ExtraPower0:UNIT_POWER_FREQUENT(event, unitID, powerToken)
			local unit = UnitFrame.unit or unit;
			if unit == unitID then
				if powerToken == 'MANA' then
					return self:UpdatePower();
				end
			end
		end
		MT.FrameRegisterEvent(ExtraPower0, "UPDATE_SHAPESHIFT_FORM");
		MT.FrameRegisterEvent(ExtraPower0, "UNIT_DISPLAYPOWER", "UNIT_MAXPOWER", "UNIT_POWER_UPDATE", "UNIT_POWER_FREQUENT");
		ExtraPower0:UPDATE_SHAPESHIFT_FORM("UPDATE_SHAPESHIFT_FORM");
		CoverFrame.ExtraPower0 = ExtraPower0;
	end
end
function MT.ToggleExtraPower0()
	-- if true then return; end
	local CoverFrame = MT.CoverFrames.player;
	if CoverFrame.CLASS ~= "DRUID" then
		return;
	end
	if VT.DB.ExtraPower0 then
		CoverFrame.ExtraPower0:UPDATE_SHAPESHIFT_FORM("UPDATE_SHAPESHIFT_FORM");
	else
		CoverFrame.ExtraPower0:Hide();
	end
end

if VT.IsVanilla then		-- get_mana_regen_tick_from_gear
	local GetInventoryItemID = GetInventoryItemID;
	local mp5_gear = {
		[9448] = 3,
		[10659] = 5,
		[11634] = 3,
		[12637] = 4,
		[13141] = 3,
		[13178] = 5,
		[13179] = 3,
		[13216] = 6,
		[13244] = 4,
		[13383] = 10,
		[13386] = 4,
		[14141] = 8,
		[14142] = 6,
		[14143] = 6,
		[14144] = 8,
		[14154] = 6,
		[14545] = 6,
		[14620] = 4,
		[14621] = 6,
		[14622] = 4,
		[14623] = 5,
		[14624] = 5,
		[16472] = 6,
		[16473] = 5,
		[16474] = 5,
		[16476] = 6,
		[16573] =  5,
		[16797] = 4,
		[16799] = 3,
		[16801] = 4,
		[16812] = 6,
		[16814] = 6,
		[16817] = 4,
		[16819] = 2,
		[16828] = 4,
		[16829] = 3,
		[16833] = 3,
		[16835] = 4,
		[16836] = 4,
		[16838] = 4,
		[16842] = 6,
		[16843] = 6,
		[16844] = 4,
		[16854] = 4,
		[16855] = 3,
		[16857] = 4,
		[16859] = 2,
		[16900] = 6,
		[16901] = 6,
		[16902] = 4,
		[16903] = 4,
		[16914] = 4,
		[16917] = 4,
		[16918] = 4,
		[16922] = 7,
		[16943] = 6,
		[16948] = 6,
		[16953] = 5,
		[16954] = 4,
		[16956] = 6,
		[16958] = 5,
		[17064] = 16,
		[17070] = 4,
		[17105] = 5,
		[17106] = 9,
		[17110] = 3,
		[17113] = 12,
		[17602] = 4,
		[17603] = 4,
		[17605] = 4,
		[17623] = 4,
		[17624] = 4,
		[17625] = 4,
		[17710] = 2,
		[17718] = 4,
		[17741] = 8,
		[17743] = 8,
		[18103] = 5,
		[18104] = 8,
		[18263] = 9,
		[18308] = 7,
		[18311] = 8,
		[18312] = 5,
		[18314] = 6,
		[18327] = 6,
		[18371] = 11,
		[18386] = 6,
		[18468] = 8,
		[18469] = 4,
		[18477] = 8,
		[18483] = 4,
		[18491] = 3,
		[18532] = 10,
		[18536] = 6,
		[18609] = 7,
		[18697] = 4,
		[18726] = 4,
		[18730] = 5,
		[18739] = 5,
		[18743] = 6,
		[18757] = 8,
		[18800] = 12,
		[18803] = 9,
		[18872] = 14,
		[18875] = 9,
		[19038] = 4,
		[19047] = 4,
		[19050] = 6,
		[19096] = 4,
		[19098] = 4,
		[19123] = 4,
		[19131] = 5,
		[19303] = 6,
		[19308] = 3,
		[19312] = 3,
		[19347] = 4,
		[19371] = 9,
		[19373] = 9,
		[19390] = 6,
		[19391] = 12,
		[19395] = 9,
		[19397] = 9,
		[19400] = 5,
		[19430] = 6,
		[19435] = 5,
		[19518] = 4,
		[19519] = 4,
		[19520] = 3,
		[19521] = 2,
		[19522] = 4,
		[19523] = 4,
		[19524] = 3,
		[19525] = 2,
		[19566] = 8,
		[19567] = 7,
		[19568] = 6,
		[19569] = 4,
		[19570] = 8,
		[19571] = 7,
		[19572] = 6,
		[19573] = 4,
		[19831] = 4,
		[19833] = 4,
		[19884] = 14,
		[19903] = 6,
		[19905] = 4,
		[19920] = 6,
		[19923] = 3,
		[19964] = 6,
		[19965] = 6,
		[19967] = 5,
		[19999] = 9,
		[20056] = 4,
		[20061] = 4,
		[20083] = 5,
		[20176] = 4,
		[20203] = 4,
		[20217] = 7,
		[20218] = 6,
		[20257] = 7,
		[20262] = 5,
		[20264] = 4,
		[20265] = 6,
		[20266] = 7,
		[20278] = 2,
		[20325] = 4,
		[20327] = 8,
		[20329] = 8,
		[20331] = 8,
		[20332] = 4,
		[20333] = 4,
		[20334] = 5,
		[20335] = 2,
		[20336] = 4,
		[20380] = 4,
		[20425] = 3,
		[20426] = 2,
		[20431] = 2,
		[20434] = 3,
		[20479] = 6,
		[20480] = 5,
		[20481] = 4,
		[20537] = 4,
		[20538] = 6,
		[20539] = 3,
		[20581] = 11,
		[20618] = 5,
		[20621] = 3,
		[20628] = 8,
		[20631] = 10,
		[20647] = 4,
		[20648] = 3,
		[20685] = 8,
		[20698] = 3,
		[20714] = 4,
		[21179] = 3,
		[21185] = 8,
		[21206] = 3,
		[21207] = 3,
		[21208] = 4,
		[21209] = 4,
		[21210] = 5,
		[21275] = 15,
		[21311] = 6,
		[21344] = 4,
		[21345] = 4,
		[21346] = 5,
		[21348] = 7,
		[21349] = 3,
		[21350] = 3,
		[21352] = 6,
		[21354] = 3,
		[21355] = 4,
		[21356] = 4,
		[21373] = 4,
		[21375] = 4,
		[21376] = 3,
		[21388] = 4,
		[21390] = 4,
		[21391] = 3,
		[21395] = 4,
		[21397] = 5,
		[21401] = 3,
		[21408] = 5,
		[21410] = 4,
		[21411] = 5,
		[21458] = 4,
		[21462] = 5,
		[21481] = 4,
		[21482] = 4,
		[21483] = 3,
		[21496] = 4,
		[21500] = 4,
		[21507] = 6,
		[21517] = 9,
		[21582] = 7,
		[21583] = 8,
		[21587] = 4,
		[21588] = 6,
		[21607] = 5,
		[21610] = 6,
		[21612] = 5,
		[21615] = 11,
		[21619] = 10,
		[21620] = 5,
		[21663] = 7,
		[21666] = 5,
		[21681] = 8,
		[21690] = 6,
		[21696] = 7,
		[21698] = 6,
		[21712] = 6,
		[21801] = 3,
		[21806] = 6,
		[21839] = 3,
		[22079] = 2,
		[22080] = 6,
		[22083] = 6,
		[22084] = 7,
		[22085] = 6,
		[22086] = 4,
		[22087] = 4,
		[22093] = 4,
		[22096] = 4,
		[22098] = 4,
		[22099] = 4,
		[22107] = 2,
		[22112] = 2,
		[22113] = 4,
		[22234] = 3,
		[22254] = 2,
		[22271] = 5,
		[22319] = 4,
		[22326] = 3,
		[22424] = 4,
		[22425] = 10,
		[22426] = 8,
		[22427] = 8,
		[22428] = 8,
		[22429] = 4,
		[22430] = 5,
		[22431] = 5,
		[22436] = 4,
		[22437] = 6,
		[22438] = 3,
		[22441] = 4,
		[22442] = 3,
		[22458] = 7,
		[22464] = 12,
		[22465] = 9,
		[22466] = 8,
		[22467] = 6,
		[22468] = 6,
		[22469] = 6,
		[22470] = 7,
		[22471] = 4,
		[22488] = 8,
		[22489] = 8,
		[22491] = 5,
		[22492] = 5,
		[22494] = 4,
		[22495] = 5,
		[22512] = 5,
		[22514] = 5,
		[22515] = 3,
		[22516] = 6,
		[22517] = 4,
		[22676] = 6,
		[22681] = 4,
		[22713] = 4,
		[22801] = 10,
		[22809] = 8,
		[22819] = 6,
		[22882] = 6,
		[22885] = 6,
		[22947] = 7,
		[22960] = 5,
		[22988] = 5,
		[22994] = 10,
		[23027] = 10,
		[23037] = 10,
		[23048] = 4,
		[23056] = 8,
		[23058] = 6,
		[23065] = 6,
		[23066] = 6,
		[23067] = 6,
		[23075] = 4,
		[23261] = 6,
		[23262] = 6,
		[23302] = 6,
		[23303] = 6,
		[23316] = 6,
		[23317] = 6,
		[23454] = 6,
		[23455] = 7,
		[23464] = 6,
		[23465] = 7,
		[23663] = 5,
		[23666] = 7,
		[23667] = 4,
	};
	local mp5_gear_set_value = {
		3,
		12,
		4,
		4,
		4,
	};
	local mp5_gear_set = {
		[15045] = { 1, 2, 3, },
		[15046] = { 1, 2, 3, },
		[20296] = { 1, 2, 3, },

		[19690] = { 2, 3, 12, },
		[19691] = { 2, 3, 12, },
		[19692] = { 2, 3, 12, },

		[19588] = { 3, 2, 4, },
		[19825] = { 3, 2, 4, },
		[19826] = { 3, 2, 4, },
		[19827] = { 3, 2, 4, },
		[19952] = { 3, 2, 4, },

		[19609] = { 4, 2, 4, },
		[19828] = { 4, 2, 4, },
		[19829] = { 4, 2, 4, },
		[19830] = { 4, 2, 4, },
		[19956] = { 4, 2, 4, },

		[19613] = { 5, 2, 4, },
		[19838] = { 5, 2, 4, },
		[19839] = { 5, 2, 4, },
		[19840] = { 5, 2, 4, },
		[19955] = { 5, 2, 4, },
	};
	-- TODO: enchant & aura
	local mp5_enc = {
		-- 护腕 法力回复 290 +4
		-- 头腿 ZUG 预言的光环 +4
		-- 肩 NAXX 天灾的活力 +5
	};
	local mp5_aura = {
		[24363] = 12,
		[25694] = 3,
		[25941] = 6,
		[16609] = 10,
	};
	function MT.GetGearMP5(unit)
		local MP5 = 0;
		local set = {  };
		for slot = 1, 18 do
			if slot ~= 4 then
				-- local itemLink = GetInventoryItemLink(unit, slot);
				-- if itemLink then
				-- 	local stats = GetItemStats(itemLink);
				-- 	if stats then
				-- 		local mp5 = stats["ITEM_MOD_POWER_REGEN0_SHORT"];
				-- 		if mp5 then
				-- 			MP5 = MP5 + mp5 + 1;
				-- 		end
				-- 	end
				-- end
				local id = GetInventoryItemID(unit, slot);
				if id then
					if mp5_gear[id] then
						MP5 = MP5 + mp5_gear[id];
					end
					if mp5_gear_set[id] then
						set[mp5_gear_set[id][1]] = set[mp5_gear_set[id][1]] and (set[mp5_gear_set[id][1]] - 1) or mp5_gear_set[id][2];
					end
				end
			end
		end
		for i = 1, #mp5_gear_set_value do
			if set[i] and set[i] <= 0 then
				MP5 = MP5 + mp5_gear_set_value[i];
			end
		end
		return MP5;
	end
else
	function MT.GetGearMP5()
		return 0;
	end
end
-- VERIFIED		PRIEST MAGE
-- MAYBE RIGHT	DRUID PALADIN HUNTER
-- TODO			WARLOCK  - SHAMAN 
function MT.EstimateMP5(CoverFrame)
	--[[
		Druid (feral), Hunter, Paladin, Warlock: Spirit/5 + 15
		Mage, Priest: Spirit/4 + 12.5
		Shaman: Spirit/5 + 17
		GetPowerRegen()
		GetManaRegen()

		LOW LEVEL = spirit / 2 + 0
	]]
	if CoverFrame.CLASS then
		local class = CoverFrame.CLASS;
		local unit = CoverFrame.unit;
		if class == 'PRIEST' or class == 'MAGE' then		-- VERIFIED
			-- spirit / 4 + 12.5 = spirit / 2	-- breakpoint = 50
			local spirit = UnitStat(unit, 5);
			local mp5 = MT.GetGearMP5(unit);
			if spirit > 50 then
				return spirit / 4 + 12.5 + mp5 * 2 / 5, spirit, mp5;
			else
				return spirit / 2, spirit, mp5;
			end
		elseif class == 'HUNTER' or class == 'DRUID' or class == 'PALADIN' or class == 'WARLOCK' then		-- VERIFIED
			-- spirit / 5 + 15 = spirit / 2	-- breakpoint = 50
			local spirit = UnitStat(unit, 5);
			local mp5 = MT.GetGearMP5(unit);
			if spirit > 50 then
				return spirit / 5 + 15 + mp5 * 2 / 5, spirit, mp5;
			else
				return spirit / 2, spirit, mp5;
			end
		elseif class == 'SHAMAN' then
			-- spirit / 5 + 17 = spirit / 2	-- breakpoint = 56.67
			local spirit = UnitStat(unit, 5);
			local mp5 = MT.GetGearMP5(unit);
			if spirit > 56.67 then
				return spirit / 5 + 17 + mp5 * 2 / 5, spirit, mp5;
			else
				return spirit / 2, spirit, mp5;
			end
		end
	end
	return 0.0, 0.0, 0.0;
end
function MT.IsMP5Restoration(CoverFrame, interval, diff)
	diff = diff * 2 / interval;
	local tick, spirit, mp5;
	-- if CoverFrame.powerType == 0 then
		-- tick = GetPowerRegen() * CoverFrame.power_restoration_time;
	-- else
		tick, spirit, mp5 = MT.EstimateMP5(CoverFrame);
	-- end
	-- print(tick, diff, mp5 * 2 / 5, tick + mp5 * 2 / 5)
	if diff >= tick - 1 then
	-- if abs(diff - tick) / tick < 0.1 or abs(diff - tick) < 5.0 or diff / tick > 1.25 then
		return true;
	end
	return false;
end
function MT.CreatePowerRestoration(CoverFrame, unit)	-- TODO timer for different power type		-- DONE
	-- if true then return; end
	if not (VT.IsVanilla or VT.IsTBC) then
		return;
	end
	if CoverFrame.CLASS ~= 'DRUID' and CoverFrame.CLASS ~= 'ROGUE' and CoverFrame.CLASS ~= 'HUNTER' and CoverFrame.CLASS ~= 'PALADIN' and CoverFrame.CLASS ~= 'WARLOCK' and CoverFrame.CLASS ~= 'MAGE' and CoverFrame.CLASS ~= 'PRIEST' and CoverFrame.CLASS ~= 'SHAMAN' then
		return;
	end
	local UnitFrame = CoverFrame.UnitFrame;
	local curPowers = {  };
	local maxPowers = {  };
	for powerType = 0, 3 do
		curPowers[powerType] = UnitPower(UnitFrame.unit or unit, powerType);
		maxPowers[powerType] = UnitPowerMax(UnitFrame.unit or unit, powerType);
	end
	-- CoverFrame.power = { MANA = { wait = 5.0, cycle = 2.0, }, ENERGY = { wait = nil, cycle = 2.0, }, };
	local power0_restoration_wait = 5.0;
	local power_restoration_spark = CoverFrame:CreateTexture(nil, "OVERLAY", nil, 7);
	power_restoration_spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark");
	power_restoration_spark:SetPoint("CENTER", CoverFrame._PBar, "LEFT");
	power_restoration_spark:SetWidth(10);
	power_restoration_spark:SetBlendMode("ADD");
	power_restoration_spark:Hide();
	local power_restoration_delay5_spark = CoverFrame:CreateTexture(nil, "OVERLAY", nil, 7);
	power_restoration_delay5_spark:SetTexture("Interface\\CastingBar\\ui-castingbar-sparkred");
	power_restoration_delay5_spark:SetPoint("CENTER", CoverFrame._PBar, "LEFT");
	power_restoration_delay5_spark:SetWidth(15);
	power_restoration_delay5_spark:SetBlendMode("ADD");
	power_restoration_delay5_spark:Hide();
	local update_timer = GetTime() + POWER_RESTORATION_UPDATE_INTERVAL;
	CoverFrame:HookScript("OnUpdate", function(self)
		local now = GetTime();
		if now < update_timer then
			return;
		end
		update_timer = now + POWER_RESTORATION_UPDATE_INTERVAL;
		if self.power_restoration_wait_timer then
			if now >= self.power_restoration_wait_timer then
				self.power_restoration_wait_timer = nil;
			end
		end
		if now >= self.power_restoration_time_timer then
			self.power_restoration_time_timer = self.power_restoration_time_timer + self.power_restoration_time;
		end
		if power_restoration_delay5_spark:IsShown() then
			if self.powerType == 0 and self.power_restoration_wait_timer then
				power_restoration_delay5_spark:ClearAllPoints();
				power_restoration_delay5_spark:SetPoint("CENTER", self._PBar, "LEFT", self._PBar:GetWidth() * (self.power_restoration_wait_timer - now) / power0_restoration_wait, 0);
			else
				power_restoration_delay5_spark:Hide();
			end
		end
		if power_restoration_spark:IsShown() then
			--[[if self.powerType == 0 and self.power_restoration_wait_timer then
				power_restoration_spark:ClearAllPoints();
				power_restoration_spark:SetPoint("CENTER", self._PBar, "LEFT", self._PBar:GetWidth() * (self.power_restoration_wait_timer - now) / power0_restoration_wait, 0);
			else]]if self.power_restoration_time_timer then
				power_restoration_spark:ClearAllPoints();
				power_restoration_spark:SetPoint("CENTER", self._PBar, "RIGHT", - self._PBar:GetWidth() * (self.power_restoration_time_timer - now) / self.power_restoration_time, 0);
			end
		end
	end);
	function CoverFrame:UPDATE_SHAPESHIFT_FORM(event)
		local unit = UnitFrame.unit or unit;
		-- UnitPowerType(unit)
		-- _1	     0,      1,       2,        3,
		-- _2	'MANA', 'RAGE', 'FOCUS', 'ENERGY',
		local powerType, powerToken = UnitPowerType(unit);
		if powerType == self.powerType then
			return;
		end
		self.powerType = powerType;
		if powerType == 0 then			-- 'MANA'
			self.power_restoration_exec = true;
			self.power_restoration_time = 2.0;
		elseif powerType == 1 then		-- 'RAGE'
			self.power_restoration_exec = nil;
			self.power_restoration_time = 2.0;
		-- elseif powerType == 2 then		-- 'FOCUS'
		elseif powerType == 3 then		-- 'ENERGY'
			self.power_restoration_exec = true;
			self.power_restoration_time = 2.0;
		else
			self.power_restoration_exec = nil;
			self.power_restoration_time = 2.0;
		end
		curPowers[powerType] = UnitPower(unit, powerType);
		maxPowers[powerType] = UnitPowerMax(unit, powerType);
		if self.power_restoration_exec and VT.DB.power_restoration and (VT.DB.power_restoration_full or (curPowers[powerType] < maxPowers[powerType])) then
			power_restoration_spark:Show();
		else
			power_restoration_spark:Hide();
		end
		if VT.DB.power_restoration and self.power_restoration_wait_timer then
			power_restoration_delay5_spark:Show();
		else
			power_restoration_delay5_spark:Hide();
		end
	end
	function CoverFrame:UNIT_SPELLCAST_SUCCEEDED(event, unitID, ...)
		local unit = UnitFrame.unit or unit;
		if unit == unitID then
			local curPower0 = UnitPower(unit, 0);
			if curPower0 < curPowers[0] then
				self.power_restoration_wait_timer = GetTime() + power0_restoration_wait;
				if self.powerType == 0 and VT.DB.power_restoration then
					power_restoration_spark:Show();
					power_restoration_delay5_spark:Show();
				end
			end
			curPowers[0] = curPower0;
			local curPower3 = UnitPower(unit);
			if self.powerType == 3 and VT.DB.power_restoration and curPower3 < maxPowers[3] then
				power_restoration_spark:Show();
			end
			curPowers[3] = curPower3;
		end
	end
	function CoverFrame:UNIT_MAXPOWER(event, unitID, powerToken)
		local unit = UnitFrame.unit or unit;
		if unit == unitID then
			local powerType = powerToken == 'MANA' and 0 or powerToken == 'ENERGY' and 3;
			if not powerType then
				return;
			end
			local maxPower = UnitPowerMax(unit, powerType);
			local curPower = UnitPower(unit, powerType);
			if maxPower ~= maxPowers[powerType] then
				if VT.DB.power_restoration and (VT.DB.power_restoration_full or (self.power_restoration_exec and curPower < maxPower)) then
					power_restoration_spark:Show();
				else
					power_restoration_spark:Hide();
				end
				maxPowers[powerType] = maxPower;
				After(GetTickTime(), function() curPowers[powerType] = UnitPower(unit, powerType); end);
			end
		end
	end
	function CoverFrame:UNIT_POWER_FREQUENT(event, unitID, powerToken)
		local unit = UnitFrame.unit or unit;
		if unit == unitID then
			if powerToken == 'MANA' then
				local curPower = UnitPower(unit, 0);
				if curPower > curPowers[0] then
					local now =  GetTime();
					if not self.power_restoration_wait_timer and MT.IsMP5Restoration(self, self.prev_restoration_time ~= nil and min(2, now - self.prev_restoration_time) or 2, curPower - curPowers[0]) then
						self.power_restoration_time_timer = now + self.power_restoration_time;
						self.prev_restoration_time = now;
					elseif curPower >= maxPowers[0] and abs(now - self.power_restoration_time_timer) < 0.1 then
						self.power_restoration_time_timer = now + self.power_restoration_time;
						self.prev_restoration_time = now;
					end
					if self.powerType == 0 and curPower >= maxPowers[0] and not VT.DB.power_restoration_full then
						power_restoration_spark:Hide();
					end
					curPowers[0] = curPower;
				elseif curPower < curPowers[0] then
					After(GetTickTime(), function() curPowers[0] = UnitPower(unit, 0); end);
					if VT.DB.power_restoration and curPower < maxPowers[0] then
						if self.powerType == 0 and not power_restoration_spark:IsShown() then
							power_restoration_spark:Show();
							-- curPowers[0] = curPower;
						end
					end
				end
			-- elseif powerToken == 'RAGE' then
			elseif powerToken == 'ENERGY' then
				local curPower = UnitPower(unit, 3);
				if curPower > curPowers[3] then
					if self.powerType == 3 then
						if abs((curPower - curPowers[3]) - GetPowerRegen() * self.power_restoration_time) < 0.5 then
							self.power_restoration_time_timer = GetTime() + self.power_restoration_time;
						end
						if curPower >= maxPowers[3] and not VT.DB.power_restoration_full then
							power_restoration_spark:Hide();
						end
					end
					curPowers[3] = curPower;
				end
			else
			end
		end
	end
	if CoverFrame.CLASS == "DRUID" then
		MT.FrameRegisterEvent(CoverFrame, "UPDATE_SHAPESHIFT_FORM");
		MT.FrameRegisterEvent(CoverFrame, "UNIT_MAXPOWER", "UNIT_POWER_FREQUENT", "UNIT_SPELLCAST_SUCCEEDED");
	-- 	MT.FrameRegisterEvent(CoverFrame, "UPDATE_STEALTH");
	-- elseif CoverFrame.CLASS == "ROGUE" then
	-- 	MT.FrameRegisterEvent(CoverFrame, "UPDATE_STEALTH");
	else
		MT.FrameRegisterEvent(CoverFrame, "UNIT_MAXPOWER", "UNIT_POWER_FREQUENT", "UNIT_SPELLCAST_SUCCEEDED");
	end
	CoverFrame:UPDATE_SHAPESHIFT_FORM("UPDATE_SHAPESHIFT_FORM");
	CoverFrame.power_restoration_time_timer = GetTime() + CoverFrame.power_restoration_time;
	CoverFrame:UNIT_SPELLCAST_SUCCEEDED("UNIT_SPELLCAST_SUCCEEDED");
	CoverFrame.curPowers = curPowers;
	CoverFrame.maxPowers = maxPowers;
	CoverFrame.power_restoration_spark = power_restoration_spark;
	CoverFrame.power_restoration_delay5_spark = power_restoration_delay5_spark;
	if CoverFrame.LEVEL < 20 then
		-- power_restoration_spark:SetAlpha(0.0);
	end
end
function MT.TogglePowerRestoration()
	-- if true then return; end
	if not (VT.IsVanilla or VT.IsTBC) then
		return;
	end
	local CoverFrame = MT.CoverFrames.player;
	if CoverFrame.CLASS == 'WARRIOR' or CoverFrame.CLASS == 'DEATHKNIGHT' then
	-- if CoverFrame.CLASS ~= 'DRUID' and CoverFrame.CLASS ~= 'ROGUE' and CoverFrame.CLASS ~= 'HUNTER' and CoverFrame.CLASS ~= 'PALADIN' and CoverFrame.CLASS ~= 'WARLOCK' and CoverFrame.CLASS ~= 'MAGE' and CoverFrame.CLASS ~= 'PRIEST' and CoverFrame.CLASS ~= 'SHAMAN' then
		return;
	end
	if VT.DB.power_restoration then
		CoverFrame.powerType = nil;
		CoverFrame:UPDATE_SHAPESHIFT_FORM("UPDATE_SHAPESHIFT_FORM");
		if CoverFrame.ExtraPower0 then
			CoverFrame.ExtraPower0:UPDATE_SHAPESHIFT_FORM("UPDATE_SHAPESHIFT_FORM");
		end
	else
		CoverFrame.power_restoration_spark:Hide();
		CoverFrame.power_restoration_delay5_spark:Hide();
		if CoverFrame.ExtraPower0 then
			CoverFrame.ExtraPower0.RestorationSpark:Hide();
			CoverFrame.ExtraPower0.RestorationDelay5Spark:Hide();
		end
	end
end
function MT.TogglePowerRestorationFull()
	-- if true then return; end
	if not (VT.IsVanilla or VT.IsTBC) then
		return;
	end
	local CoverFrame = MT.CoverFrames.player;
	if CoverFrame.CLASS == 'WARRIOR' or CoverFrame.CLASS == 'DEATHKNIGHT' then
	-- if CoverFrame.CLASS ~= 'DRUID' and CoverFrame.CLASS ~= 'ROGUE' and CoverFrame.CLASS ~= 'HUNTER' and CoverFrame.CLASS ~= 'PALADIN' and CoverFrame.CLASS ~= 'WARLOCK' and CoverFrame.CLASS ~= 'MAGE' and CoverFrame.CLASS ~= 'PRIEST' and CoverFrame.CLASS ~= 'SHAMAN' then
		return;
	end
	CoverFrame.powerType = nil;
	CoverFrame:UPDATE_SHAPESHIFT_FORM("UPDATE_SHAPESHIFT_FORM");
	if CoverFrame.ExtraPower0 then
		CoverFrame.ExtraPower0:UPDATE_SHAPESHIFT_FORM("UPDATE_SHAPESHIFT_FORM");
	end
end

function MT.CreatePartyAura(CoverFrame, unit)
	local n_icon_per_row = 32;
	local inter = 1;
	local ofs_x = 48;
	local ofs_y = -31;

	local buffs = {  };
	local n_shown_buffs = 0;
	function CoverFrame:CreateAura(filter, index)
		local aura = CreateFrame("FRAME", nil, self);
		aura:SetSize(VT.DB.partyAura_size, VT.DB.partyAura_size);
		local cd = CreateFrame("COOLDOWN", nil, aura, "CooldownFrameTemplate");
		-- cd:SetSwipeColor(1.0, 1.0, 1.0, 1.0);
		cd:SetReverse(true);
		cd:SetHideCountdownNumbers(true);
		local icon = aura:CreateTexture(nil, "BACKGROUND");
		icon:SetAllPoints();
		function aura:SetIcon(texture)
			icon:SetTexture(texture);
		end
		function aura:SetCooldown(start, dur, modRate)
			cd:SetCooldown(start, dur, modRage);
		end
		aura:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:SetUnitAura(unit, index, filter);
			GameTooltip:Show();
		end);
		aura:SetScript("OnLeave", function(self)
			if GameTooltip:IsOwned(self) then
				GameTooltip:Hide();
			end
		end);
		aura.id = index;
		aura.cd = cd;
		aura.icon = icon;
		return aura;
	end
	function CoverFrame:CreateBuff(index)
		if buffs[index] then
			return buffs[index];
		else
			local aura = self:CreateAura("HELPFUL", index);
			buffs[#buffs + 1] = aura;
			if index == 1 then
				aura:SetPoint("TOPLEFT", self, "TOPLEFT", ofs_x, ofs_y);
			else
				if (index - 1) % n_icon_per_row == 0 then
					aura:SetPoint("TOPLEFT", buffs[index - n_icon_per_row], "BOTTOMLEFT", 0, - inter);
				else
					aura:SetPoint("TOPLEFT", buffs[index - 1], "TOPRIGHT", inter, 0);
				end
			end
			return aura;
		end
	end
	function CoverFrame:Buff(index)
		local name, texture, count, debuffType, duration, expirationTime, _, _, _, spellId, _, _, _, _, timeMod = MT.UnitAura(unit, index, "HELPFUL");
		if name then
			local aura = buffs[index] or self:CreateBuff(index);
			aura:SetIcon(texture or TEXTURE_UNK);
			aura:SetCooldown(expirationTime - duration, duration, timeMod);
			aura:Show();
			return true;
		end
	end

	local debuffs = {  };
	local n_shown_debuffs = 0;
	function CoverFrame:CreateDebuff(index)
		if debuffs[index] then
			return debuffs[index];
		else
			local aura = self:CreateAura("HARMFUL", index);
			debuffs[#debuffs + 1] = aura;
			if index == 1 then
				-- debuffs[1]:SetPoint("TOPLEFT", buffs[1], "BOTTOMLEFT", 0, - inter);
			else
				if (index - 1) % n_icon_per_row == 0 then
					aura:SetPoint("TOPLEFT", debuffs[index - n_icon_per_row], "BOTTOMLEFT", 0, - inter);
				else
					aura:SetPoint("TOPLEFT", debuffs[index - 1], "TOPRIGHT", inter, 0);
				end
			end
			return aura;
		end
	end
	function CoverFrame:Debuff(index)
		local name, texture, count, debuffType, duration, expirationTime, _, _, _, spellId, _, _, _, _, timeMod = MT.UnitAura(unit, index, "HARMFUL");
		if name then
			local aura = debuffs[index] or self:CreateDebuff(index);
			aura:SetIcon(texture or TEXTURE_UNK);
			aura:SetCooldown(expirationTime - duration, duration, timeMod);
			aura:Show();
			return true;
		end
	end

	-- CoverFrame:CreateBuff(1);
	-- CoverFrame:CreateDebuff(1);
	function CoverFrame:UpdateAura()
		local n_prev_shown_buffs = n_shown_buffs;
		n_shown_buffs = 1;
		while self:Buff(n_shown_buffs) do
			n_shown_buffs = n_shown_buffs + 1;
		end
		for i = n_shown_buffs, n_prev_shown_buffs do
			buffs[i]:Hide();
		end
		n_shown_buffs = n_shown_buffs - 1;

		local n_prev_show_debuffs = n_shown_debuffs;
		n_shown_debuffs = 1;
		while self:Debuff(n_shown_debuffs) do
			n_shown_debuffs = n_shown_debuffs + 1;
		end
		for i = n_shown_debuffs, n_prev_show_debuffs do
			debuffs[i]:Hide();
		end
		n_shown_debuffs = n_shown_debuffs - 1;

		if n_shown_debuffs > 0 then
			if n_shown_buffs > 0 then
				local y = (n_shown_buffs - 1) / n_icon_per_row;
				y = y - y % 1.0;
				debuffs[1]:ClearAllPoints();
				debuffs[1]:SetPoint("TOPLEFT", buffs[y * n_icon_per_row + 1], "BOTTOMLEFT", 0, - inter);
			else
				debuffs[1]:ClearAllPoints();
				debuffs[1]:SetPoint("TOPLEFT", self, "TOPLEFT", ofs_x, ofs_y);
			end
			if VT.IsCata or VT.IsWrath or VT.IsTBC then
				self.CastingBar:SetPoint("TOP", debuffs[1], "BOTTOM", 0, -2);
			end
		elseif buffs[1] ~= nil then
			if VT.IsCata or VT.IsWrath or VT.IsTBC then
				self.CastingBar:SetPoint("TOP", buffs[1], "BOTTOM", 0, -2);
			end
		else
		end
	end
	function CoverFrame:UNIT_AURA(event, unitID)
		return self:UpdateAura();
	end
	function CoverFrame:HidePartyAura()
		for i = 1, n_shown_buffs do
			buffs[i]:Hide();
		end
		for i = 1, n_shown_debuffs do
			debuffs[i]:Hide();
		end
	end
	MT.FrameRegisterUnitEvent(CoverFrame, unit, "UNIT_AURA");
end
function MT.TogglePartyAura()
	if VT.DB.partyAura then
		for i = 1, 4 do
			for j = 1, 4 do
				local icon = _G["PartyMemberFrame" .. i .. "Debuff" .. j];
				icon:EnableMouse(false);
				icon:SetAlpha(0.0);
			end
		end
	else
		for i = 1, 4 do
			MT.CoverFrames['party' .. i]:HidePartyAura();
		end
		PartyMemberBuffTooltip:SetAlpha(1.0);
		for i = 1, 4 do
			for j = 1, 4 do
				local icon = _G["PartyMemberFrame" .. i .. "Debuff" .. j];
				icon:EnableMouse(true);
				icon:SetAlpha(1.0);
			end
		end
	end
end
function MT.TogglePartyCastingBar()
	if VT.DB.partyCast then
		for i = 1, 4 do
			local CastingBar = MT.CoverFrames['party' .. i].CastingBar;
			CastingBar:SetScript("OnEvent", CastingBar.OnEvent);
			CastingBar:OnEvent("GROUP_ROSTER_UPDATE");
		end
	else
		for i = 1, 4 do
			local CastingBar = MT.CoverFrames['party' .. i].CastingBar;
			CastingBar:SetScript("OnEvent", nil);
			CastingBar:Hide();
		end
	end
end

function MT.CreatePartyTargetingFrame(CoverFrame, unit, TargetingFramePosition, Offset)
	-- if true then return; end
	-- local w, h = VT.DB.partyTargetW, VT.DB.partyTargetH;
	local w, h = 80, 16;
	local T = CreateFrame("BUTTON", nil, CoverFrame, "SecureUnitButtonTemplate");
	T:SetSize(w, h);
	uireimp._SetBackdrop(T, {
		bgFile = "Interface/ChatFrame/ChatFrameBackground",
		edgeFile = "Interface/ChatFrame/ChatFrameBackground",
		tile = true,
		edgeSize = 1,
		tileSize = 5,
	});
	uireimp._SetBackdropColor(T, 0.0, 0.0, 0.0, 1.0);
	uireimp._SetBackdropBorderColor(T, 0.0, 0.0, 0.0, 1.0);
	local target = unit .. 'target';
	T:SetAttribute("unit", target);
	RegisterUnitWatch(T);
	T:RegisterForClicks("AnyUp")
	T:SetAttribute("*type1", "target");
	T:SetAttribute("*type2", "togglemenu");
	local UnitFrameName = CoverFrame.UnitFrame:GetName();
	if TargetingFramePosition == "LEFT" then
		if CoverFrame._HBar and CoverFrame._PBar then
			T:SetPoint("TOPRIGHT", CoverFrame._HBar, "TOPLEFT", -Offset, 0);
			T:SetPoint("BOTTOMRIGHT", CoverFrame._PBar, "BOTTOMLEFT", -Offset, 0);
		else
			T:SetPoint("RIGHT", CoverFrame, "LEFT", -Offset, 0);
		end
	else
		if CoverFrame._HBar and CoverFrame._PBar then
			T:SetPoint("TOPLEFT", CoverFrame._HBar, "TOPRIGHT", Offset, 0);
			T:SetPoint("BOTTOMLEFT", CoverFrame._PBar, "BOTTOMRIGHT", Offset, 0);
		else
			T:SetPoint("LEFT", CoverFrame, "RIGHT", Offset, 0);
		end
	end
	T.watch_unit = unit;

	local Name = T:CreateFontString(nil, "OVERLAY");
	Name:SetFont(GameFontNormal:GetFont(), 13, "OUTLINE");
	Name:SetPoint("BOTTOM", T, "TOP", 0, 2);
	T.Name = Name;
	local PBarHeight = h * 0.33;
	PBarHeight = PBarHeight - PBarHeight % 1.0;
	local HBarHeight = h - PBarHeight;
	local HBar = CreateFrame("STATUSBAR", nil, T);
	HBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
	HBar:ClearAllPoints();
	HBar:SetPoint("TOP", T);
	HBar:SetSize(w, HBarHeight);
	HBar:SetMinMaxValues(0, 1);
	T.HBar = HBar;
	local PBar = CreateFrame("STATUSBAR", nil, T);
	PBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
	PBar:ClearAllPoints();
	PBar:SetPoint("BOTTOM", T);
	PBar:SetSize(w, PBarHeight);
	PBar:SetMinMaxValues(0, 1);
	T.PBar = PBar;
	local BackGround = T:CreateTexture(nil, "BACKGROUND");
	BackGround:SetSize(w + 12, h + 12);
	BackGround:SetPoint("CENTER");
	BackGround:SetAlpha(0.5);
	T.BackGround = BackGround;
	local Border = T:CreateTexture(nil, "BORDER");
	Border:SetSize(w + 4, h + 4);
	Border:SetPoint("CENTER");
	Border:SetColorTexture(0.0, 0.0, 0.0, 1.0);
	T.Border = Border;

	local isRetailStyle = false;
	function T:UpdateName()
		Name:SetText(UnitName(target));
	end
	function T:UpdatePowerType()
		local powerType, powerToken = UnitPowerType(target);
		local color = PowerBarColor[powerType];
		PBar:SetStatusBarColor(color.r, color.g, color.b, 1.0);
	end
	function T:UpdateHealth()
		local hv, hmv = UnitHealth(unit), UnitHealthMax(unit);
		-- local hv, hmv = UnitHealth(target), UnitHealthMax(target);
		HBar:SetMinMaxValues(0, hmv);
		HBar:SetValue(hv);
		if not isRetailStyle then
			local r, g, b = MT.GetHealthColor(hv, hmv);
			HBar:SetStatusBarColor(r, g, b);
		end
		-- HBarPercentage:SetText(MT.GetPercentageText(hv, hmv));
	end
	function T:UpdatePower()
		local pmv = UnitPowerMax(target);
		if pmv > 0 then
			PBar:SetMinMaxValues(0, pmv);
			PBar:SetValue(UnitPower(target));
			-- PBarPercentage:SetText(MT.GetPercentageText(hv, hmv));
		else
			PBar:SetValue(0);
			-- PBarPercentage:SetText("");
		end
	end
	function T:Update()
		if UnitExists(target) then
			self:UpdateName();
			self:UpdatePowerType();
			self:UpdateHealth();
			self:UpdatePower();
			if UnitIsPlayer(target) then
				local class = UnitClassBase(target);
				local color = class and RAID_CLASS_COLORS[class];
				if color then
					Name:SetTextColor(color.r, color.g, color.b, 1.0);
				else
					Name:SetTextColor(1.0, 1.0, 1.0, 1.0);
				end
			else
				Name:SetTextColor(1.0, 1.0, 1.0, 1.0);
			end
			if isRetailStyle then
				local r, g, b = UnitSelectionColor(target);
				HBar:SetStatusBarColor(r, g + b, 0);
			else
				BackGround:SetColorTexture(UnitSelectionColor(target));
			end
		end
	end

	function T:UNIT_TARGET(event, unitID)
		if unit == unitID and VT.DB.partyTarget then
			return self:Update();
		end
	end

	if not T:GetScript("OnUpdate") then
		T:SetScript("OnUpdate", _noop_);
	end
	T.update_timer = 0.0;
	T:HookScript("OnUpdate", function(self, elasped)
		self.update_timer = self.update_timer + elasped;
		if self.update_timer >= TARGET_UPDATE_INTERVAL then
			self.update_timer = 0.0;
			if UnitExists(target) then
				return self:Update();
			end
		end
	end);
	if not T:GetScript("OnShow") then
		T:SetScript("OnShow", _noop_);
	end
	T:HookScript("OnShow", function(self)
		return self:Update();
	end);

	MT.FrameRegisterUnitEvent(T, unit, "UNIT_TARGET");
	T:UNIT_TARGET("UNIT_TARGET", unit);

	function T:SetRetailStyle(val)
		isRetailStyle = val;
		if val then
			BackGround:Hide();
			PBar:Hide();
			HBar:SetSize(w, h);
			HBar:SetStatusBarTexture("Interface\\AddOns\\alaUnitFrame\\ARTWORK\\StatusBar");
		else
			BackGround:Show();
			PBar:Show();
			HBar:SetSize(w, HBarHeight);
			HBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
		end
		return self:Update();
	end

	return T;
end
function MT.TogglePartyTargetingFrameStyle()
	local isRetailStyle = VT.DB.TargetRetailStyle;
	MT.CoverFrames['targettarget'].target:SetRetailStyle(isRetailStyle);
	MT.CoverFrames['party1'].target:SetRetailStyle(isRetailStyle);
	MT.CoverFrames['party2'].target:SetRetailStyle(isRetailStyle);
	MT.CoverFrames['party3'].target:SetRetailStyle(isRetailStyle);
	MT.CoverFrames['party4'].target:SetRetailStyle(isRetailStyle);
end
function MT._Secure_TogglePartyTargetingFrame()
	if VT.DB.partyTarget then
		for i = 1, 4 do
			local T = MT.CoverFrames['party' .. i].target;
			RegisterUnitWatch(T);
		end
	else
		for i = 1, 4 do
			local T = MT.CoverFrames['party' .. i].target;
			UnregisterUnitWatch(T);
			T:Hide();
		end
	end
end
function MT._Secure_ToggleToTTarget()
	local T = MT.CoverFrames['targettarget'].target;
	if VT.DB.ToTTarget then
		RegisterUnitWatch(T);
	else
		UnregisterUnitWatch(T);
		T:Hide();
	end
end
function MT._Secure_ToggleShiftFocus()
	--	modifier .. "-type" .. mouse
	--	modifier	= shift, alt or ctrl,
	--	mouse		= 1 = left, 2 = right, 3 = middle, 4 and 5 = thumb buttons
	if VT.DB.ShiftFocus then
		PlayerFrame:SetAttribute("shift-type1", "focus");
		TargetFrame:SetAttribute("shift-type1", "focus");
		TargetFrameToT:SetAttribute("shift-type1", "focus");
		MT.CoverFrames['targettarget'].target:SetAttribute("shift-type1", "focus");
		-- if FocusFrame ~= nil then
		-- 	FocusFrame:SetAttribute("shift-type1", "focus");
		-- end
		PartyMemberFrame1:SetAttribute("shift-type1", "focus");
		PartyMemberFrame2:SetAttribute("shift-type1", "focus");
		PartyMemberFrame3:SetAttribute("shift-type1", "focus");
		PartyMemberFrame4:SetAttribute("shift-type1", "focus");
		MT.CoverFrames['party1'].target:SetAttribute("shift-type1", "focus");
		MT.CoverFrames['party2'].target:SetAttribute("shift-type1", "focus");
		MT.CoverFrames['party3'].target:SetAttribute("shift-type1", "focus");
		MT.CoverFrames['party4'].target:SetAttribute("shift-type1", "focus");
	else
		PlayerFrame:SetAttribute("shift-type1", nil);
		TargetFrame:SetAttribute("shift-type1", nil);
		TargetFrameToT:SetAttribute("shift-type1", nil);
		MT.CoverFrames['targettarget'].target:SetAttribute("shift-type1", nil);
		-- if FocusFrame ~= nil then
		-- 	FocusFrame:SetAttribute("shift-type1", nil);
		-- end
		PartyMemberFrame1:SetAttribute("shift-type1", nil);
		PartyMemberFrame2:SetAttribute("shift-type1", nil);
		PartyMemberFrame3:SetAttribute("shift-type1", nil);
		PartyMemberFrame4:SetAttribute("shift-type1", nil);
		MT.CoverFrames['party1'].target:SetAttribute("shift-type1", nil);
		MT.CoverFrames['party2'].target:SetAttribute("shift-type1", nil);
		MT.CoverFrames['party3'].target:SetAttribute("shift-type1", nil);
		MT.CoverFrames['party4'].target:SetAttribute("shift-type1", nil);
	end
end

local LightAlive = { omnidirectional = false, point = CreateVector3D(0, 0, 0), ambientIntensity = 1.0, ambientColor = CreateColor(1, 1, 1), };
local LightDead = { omnidirectional = false, point = CreateVector3D(0, 0, 0), ambientIntensity = 1.0, ambientColor = CreateColor(1, 0.3, 0.3), };
local LightGhost = { omnidirectional = false, point = CreateVector3D(0, 0, 0), ambientIntensity = 1.0, ambientColor = CreateColor(0.25, 0.25, 0.25), };
function MT.HookUnitFrame(UnitFrame, unit, FrameDef)
	local configKey = strmatch(unit, "^([^0-9]+)%d*");
	if not configKey then
		return;
	end
	MT.BuildConfig(configKey);

	local CoverFrame = CreateFrame("FRAME", nil, UnitFrame);
	CoverFrame:ClearAllPoints();
	CoverFrame:SetPoint("TOPLEFT", UnitFrame, 0, 0);
	CoverFrame:SetPoint("BOTTOMRIGHT", UnitFrame, 0, 0);
	CoverFrame:SetFrameLevel(UnitFrame:GetFrameLevel() + 128);
	CoverFrame:EnableMouse(false);
	CoverFrame:SetFrameStrata(UnitFrame:GetFrameStrata());
	CoverFrame:Show();
	CoverFrame.UnitFrame = UnitFrame;
	CoverFrame.unit = unit;
	CoverFrame.configKey = configKey;

	local PortraitPosition = FrameDef.PortraitPosition;
	local SubLayerLevelOffset = FrameDef.SubLayerLevelOffset or 0;

	local UnitFrameName = UnitFrame:GetName();
	local UnitFrameTexture = UnitFrame.texture or (UnitFrameName and _G[UnitFrameName .. "Texture"]);
	if not UnitFrameTexture then
		local UnitFrameTextureFrame = UnitFrame.textureFrame or (UnitFrameName and _G[UnitFrameName .. "TextureFrame"]);
		if UnitFrameTextureFrame then
			UnitFrameTexture = UnitFrameTextureFrame.texture or _G[UnitFrameTextureFrame:GetName() .. "Texture"];
		end
	end
	if UnitFrameTexture and UnitFrameTexture:GetObjectType() == "Texture" then
		local FrameTextureCoord = FrameDef.FrameTextureCoord;
		local CoverFrameTexture = CoverFrame:CreateTexture(nil, "ARTWORK", nil, 4 + SubLayerLevelOffset);
		CoverFrameTexture:SetTexture(UnitFrameTexture:GetTexture());
		--[=[local w = UnitFrame:GetWidth() * ratio;
		w = w - w % 1.0;
		if PortraitPosition == "LEFT" then
			CoverFrameTexture:SetPoint("TOPRIGHT", UnitFrameTexture);
			CoverFrameTexture:SetPoint("BOTTOMRIGHT", UnitFrameTexture);
			CoverFrameTexture:SetWidth(w);
			CoverFrameTexture:SetTexCoord(FrameTextureCoord[1] + (FrameTextureCoord[2] - FrameTextureCoord[1]) * (1 - w / UnitFrame:GetWidth()), FrameTextureCoord[2], FrameTextureCoord[3], FrameTextureCoord[4]);
		else
			CoverFrameTexture:SetPoint("TOPLEFT", UnitFrameTexture);
			CoverFrameTexture:SetPoint("BOTTOMLEFT", UnitFrameTexture);
			CoverFrameTexture:SetWidth(w);
			CoverFrameTexture:SetTexCoord(FrameTextureCoord[1], FrameTextureCoord[2] - (FrameTextureCoord[2] - FrameTextureCoord[1]) * (1 - w / UnitFrame:GetWidth()), FrameTextureCoord[3], FrameTextureCoord[4]);
		end--]=]
		CoverFrameTexture:SetPoint("CENTER", UnitFrameTexture);
		CoverFrameTexture:SetSize(UnitFrameTexture:GetSize());
		if type(FrameTextureCoord) == 'table' then
			CoverFrameTexture:SetTexCoord(
							type(FrameTextureCoord[1]) == 'number' and FrameTextureCoord[1] or 0.0,
							type(FrameTextureCoord[2]) == 'number' and FrameTextureCoord[2] or 1.0,
							type(FrameTextureCoord[3]) == 'number' and FrameTextureCoord[3] or 0.0,
							type(FrameTextureCoord[4]) == 'number' and FrameTextureCoord[4] or 1.0
						);
		else
			CoverFrameTexture:SetTexCoord(0.0, 1.0, 0.0, 1.0);
		end
		CoverFrame.CoverFrameTexture = CoverFrameTexture;
		CoverFrame.UnitFrameTexture = UnitFrameTexture;

		function CoverFrame:SetCoverBorderTexutre(Texture)
			CoverFrameTexture:SetTexture(Texture);
		end
		function CoverFrame:CopyBorderTexture()
			CoverFrameTexture:SetTexture(UnitFrameTexture:GetTexture());
		end
		function CoverFrame:HideCoverTexture()
			CoverFrameTexture:SetTexture(nil);
		end
	else
		function CoverFrame:SetCoverBorderTexutre(Texture)
		end
		function CoverFrame:CopyBorderTexture()
		end
		function CoverFrame:HideCoverTexture()
		end
	end

	-- BELOW		name of object must be equal to its config key

	local _HBar = UnitFrame.healthbar or (UnitFrameName and _G[UnitFrameName .. "HealthBar"]);
	local _PBar = UnitFrame.manabar or (UnitFrameName and _G[UnitFrameName .. "ManaBar"]);

	if _HBar and _PBar then
		local HBarTexture, PBarTexture, HBarValue, PBarValue, HBarPercentage, PBarPercentage = _VirtualWidget, _VirtualWidget, _VirtualWidget, _VirtualWidget, _VirtualWidget, _VirtualWidget;

		if FrameDef.BarCoverTexture then
			local _HBarTexture = _HBar:GetStatusBarTexture();
			HBarTexture = CoverFrame:CreateTexture(nil, "ARTWORK", nil, 3 + SubLayerLevelOffset);
			HBarTexture:SetTexture("Interface\\TargetingFrame\\UI-StatusBar");
			HBarTexture:ClearAllPoints();
			HBarTexture:SetPoint("TOPLEFT", _HBarTexture, "TOPLEFT", 0, 0);
			HBarTexture:SetPoint("BOTTOMRIGHT", _HBarTexture, "BOTTOMRIGHT", 0, 0);
			HBarTexture:SetVertexColor(1, 0, 0);
			HBarTexture:Show();
			local _PBarTexture = _PBar:GetStatusBarTexture();
			PBarTexture = CoverFrame:CreateTexture(nil, "ARTWORK", nil, 3 + SubLayerLevelOffset);
			PBarTexture:SetTexture("Interface\\TargetingFrame\\UI-StatusBar");
			PBarTexture:ClearAllPoints();
			PBarTexture:SetPoint("TOPLEFT", _PBarTexture, "TOPLEFT", 0, 0);
			PBarTexture:SetPoint("BOTTOMRIGHT", _PBarTexture, "BOTTOMRIGHT", 0, 0);
			PBarTexture:SetVertexColor(_PBar:GetStatusBarColor());
			PBarTexture:Show();
			function HBarTexture:Show()
				CoverFrame:UpdateHealth();
			end
			function HBarTexture:Hide()
				HBarTexture:SetVertexColor(0.0, 1.0, 0.0, 1.0);
				HBarPercentage:SetVertexColor(0.0, 1.0, 0.0, 1.0);
			end
			function PBarTexture:Show()
			end
			function PBarTexture:Hide()
			end
			function CoverFrame:UpdatePowerType()
				PBarTexture:SetVertexColor(_PBar:GetStatusBarColor());
			end
			if FrameDef.BarEventDriven then
				function CoverFrame:UNIT_DISPLAYPOWER(event, unitID)
					local unit = UnitFrame.unit or unit;
					if unit == unitID then
						self:UpdatePowerType();
					end
				end
				MT.FrameRegisterEvent(CoverFrame, "UNIT_DISPLAYPOWER");
			elseif FrameDef.BarEventDriven == false then
				-- hooksecurefunc(_PBarTexture, "SetVertexColor", function(_, ...)
				-- 	PBarTexture:SetVertexColor(...);
				-- end);
				hooksecurefunc(_PBar, "SetStatusBarColor", function(_, ...)
					PBarTexture:SetVertexColor(...);
				end);
			end
		else
			function CoverFrame:UpdatePowerType()
			end
		end

		if FrameDef.BarCreateValue then
			local BarTextFontSize = FrameDef.BarTextFontSize or 12;
			local BarTextFontScale = FrameDef.BarTextFontScale or 1.0;
			local BarValuePosition = tonumber(FrameDef.BarValuePosition);
			HBarValue = CoverFrame:CreateFontString(nil, "OVERLAY", nil, 7);
			HBarValue:SetFont(TextStatusBarText:GetFont(), BarTextFontSize, "OUTLINE");
			HBarValue:SetScale(BarTextFontScale);
			HBarValue:ClearAllPoints();
			HBarValue:Show();
			PBarValue = CoverFrame:CreateFontString(nil, "OVERLAY", nil, 7);
			PBarValue:SetFont(TextStatusBarText:GetFont(), BarTextFontSize, "OUTLINE");
			PBarValue:SetScale(BarTextFontScale);
			PBarValue:ClearAllPoints();
			PBarValue:Show();
			if BarValuePosition then
				if PortraitPosition == "LEFT" then
					HBarValue:SetPoint("LEFT", _HBar, "RIGHT", BarValuePosition, 0);
					PBarValue:SetPoint("LEFT", _PBar, "RIGHT", BarValuePosition, 0);
				else
					HBarValue:SetPoint("RIGHT", _HBar, "LEFT", - BarValuePosition, 0);
					PBarValue:SetPoint("RIGHT", _PBar, "LEFT", - BarValuePosition, 0);
				end
				HBarValue:SetTextColor(0.0, 1.0, 0.0);
			else
				HBarValue:SetPoint("CENTER", _HBar);
				PBarValue:SetPoint("CENTER", _PBar);
			end
		end

		if FrameDef.BarCreatePercentage then
			local BarTextFontSize = FrameDef.BarTextFontSize or 12;
			local BarTextFontScale = FrameDef.BarTextFontScale or 1.0;
			local BarPercentagePosition = tonumber(FrameDef.BarPercentagePosition) or 0;
			HBarPercentage = CoverFrame:CreateFontString(nil, "OVERLAY", nil, 7);
			HBarPercentage:SetFont(TextStatusBarText:GetFont(), BarTextFontSize, "OUTLINE");
			HBarPercentage:SetScale(BarTextFontScale);
			HBarPercentage:Show();
			PBarPercentage = CoverFrame:CreateFontString(nil, "OVERLAY", nil, 7);
			PBarPercentage:SetFont(TextStatusBarText:GetFont(), BarTextFontSize, "OUTLINE");
			PBarPercentage:SetScale(BarTextFontScale);
			PBarPercentage:Show();
			HBarPercentage:ClearAllPoints();
			PBarPercentage:ClearAllPoints();
			if PortraitPosition == "LEFT" then
				HBarPercentage:SetPoint("LEFT", _HBar, "RIGHT", BarPercentagePosition + 4, 0);
				PBarPercentage:SetPoint("LEFT", _PBar, "RIGHT", BarPercentagePosition + 4, 0);
			else
				HBarPercentage:SetPoint("RIGHT", _HBar, "LEFT", - BarPercentagePosition - 4, 0);
				PBarPercentage:SetPoint("RIGHT", _PBar, "LEFT", - BarPercentagePosition - 4, 0);
			end
		end

		if FrameDef.BarCoverTexture or FrameDef.BarCreateValue or FrameDef.BarCreatePercentage then
			function CoverFrame:UpdateHealth()
				local unit = UnitFrame.unit or unit;
				local hv, hmv = UnitHealth(unit), UnitHealthMax(unit);
				if hmv > 0 then
					if MT.GetConfig(configKey, "HBarValue") then
						HBarValue:SetText(hv .. " / " .. hmv);
						HBarValue:Show();
					else
						HBarValue:Hide();
					end
					if MT.GetConfig(configKey, "HBarPercentage") then
						HBarPercentage:SetText(MT.GetPercentageText(hv, hmv));
						HBarPercentage:Show();
					else
						HBarPercentage:Hide();
					end
					if MT.GetConfig(configKey, "HBColor") then
						local r, g, b = MT.GetHealthColor(hv, hmv);
						HBarTexture:SetVertexColor(r, g, b, 1.0);
						HBarPercentage:SetVertexColor(r, g, b);
					end
				else
					HBarTexture:SetVertexColor(0.0, 1.0, 0.0, 1.0);
					HBarPercentage:SetVertexColor(0.0, 1.0, 0.0, 1.0);
					HBarValue:Hide();
					HBarPercentage:Hide();
				end
			end
			function CoverFrame:UpdatePower()
				local pv = _PBar:GetValue();
				local _, pmv = _PBar:GetMinMaxValues();
				if pmv > 0 then
					PBarTexture:SetVertexColor(_PBar:GetStatusBarColor());
					if MT.GetConfig(configKey, "PBarValue") then
						PBarValue:SetText(pv .. " / " .. pmv);
						PBarValue:Show();
					else
						PBarValue:Hide();
					end
					if MT.GetConfig(configKey, "PBarPercentage") then
						PBarPercentage:SetText(MT.GetPercentageText(pv, pmv));
						PBarPercentage:Show();
					else
						PBarPercentage:Hide();
					end
				else
					PBarTexture:SetVertexColor(1.0, 1.0, 1.0, 0.0);
					PBarValue:Hide();
					PBarPercentage:Hide();
				end
			end

			if FrameDef.BarEventDriven then
				function CoverFrame:UNIT_HEALTH(event, unitID)
					local unit = UnitFrame.unit or unit;
					if unit == unitID then
						return self:UpdateHealth();
					end
				end
				function CoverFrame:UNIT_MAXHEALTH(event, unitID)
					local unit = UnitFrame.unit or unit;
					if unit == unitID then
						return self:UpdateHealth();
					end
				end
				function CoverFrame:UNIT_POWER_UPDATE(event, unitID)
					local unit = UnitFrame.unit or unit;
					if unit == unitID then
						return self:UpdatePower();
					end
				end
				if pcall(MT.FrameRegisterEvent, CoverFrame, "UNIT_HEALTH_FREQUENT") then
					CoverFrame.UNIT_HEALTH_FREQUENT = CoverFrame.UNIT_HEALTH;
				else
					MT.FrameRegisterEvent(CoverFrame, "UNIT_HEALTH");
				end
				MT.FrameRegisterEvent(CoverFrame, "UNIT_MAXHEALTH");
				MT.FrameRegisterEvent(CoverFrame, "UNIT_POWER_UPDATE");
			elseif FrameDef.BarEventDriven == false then
				hooksecurefunc(_HBar, "SetValue", function(self, val)
					return CoverFrame:UpdateHealth();
				end);
				--hooksecurefunc(_HBar, "SetMinMaxValues", function(self, minV, maxV)end);
				hooksecurefunc(_PBar, "SetValue", function(self, val)
					return CoverFrame:UpdatePower();
				end);
			end

			CoverFrame:UpdateHealth();
			CoverFrame:UpdatePower();
		else
			function CoverFrame:UpdateHealth()
			end
			function CoverFrame:UpdatePower()
			end
		end

		function CoverFrame:BarTextAlpha(v)
			HBarValue:SetAlpha(v);
			PBarValue:SetAlpha(v);
			HBarPercentage:SetAlpha(v);
			PBarPercentage:SetAlpha(v);
		end

		CoverFrame.HBarTexture = HBarTexture;
		CoverFrame.PBarTexture = PBarTexture;
		CoverFrame.HBarValue = HBarValue;
		CoverFrame.PBarValue = PBarValue;
		CoverFrame.HBarPercentage = HBarPercentage;
		CoverFrame.PBarPercentage = PBarPercentage;
		CoverFrame._HBar = _HBar;
		CoverFrame._PBar = _PBar;
		CoverFrame.HBColor = HBarTexture;
	else
		function CoverFrame:UpdatePowerType()
		end
		function CoverFrame:UpdateHealth()
		end
		function CoverFrame:UpdatePower()
		end
		function CoverFrame:BarTextAlpha(v)
		end
		CoverFrame.HBarTexture = _VirtualWidget;
		CoverFrame.PBarTexture = _VirtualWidget;
		CoverFrame.HBarValue = _VirtualWidget;
		CoverFrame.PBarValue = _VirtualWidget;
		CoverFrame.HBarPercentage = _VirtualWidget;
		CoverFrame.PBarPercentage = _VirtualWidget;
		CoverFrame._HBar = _HBar;
		CoverFrame._PBar = _PBar;
		-- CoverFrame.HBColor = _VirtualWidget;
	end

	local Portrait2D = UnitFrame.portrait or _G[UnitFrameName .. "Portrait"];
	if FrameDef.Create3DPortrait and Portrait2D then
		local w, h = Portrait2D:GetSize();
		local Portrait3D = CreateFrame("PLAYERMODEL", nil, CoverFrame);
		Portrait3D:SetWidth(w * 0.75);
		Portrait3D:SetHeight(h * 0.75);
		Portrait3D:SetFrameLevel(UnitFrame:GetFrameLevel() + 16);
		Portrait3D:ClearAllPoints();
		Portrait3D:SetPoint("CENTER", Portrait2D, "CENTER", 0, -1);
		Portrait3D.bg = Portrait3D:CreateTexture(nil, "BACKGROUND", nil, 7);
		Portrait3D.bg:SetTexture("Interface\\AddOns\\alaUnitFrame\\ARTWORK\\Portrait3D");
		Portrait3D.bg:SetSize(w, h);
		Portrait3D.bg:ClearAllPoints();
		Portrait3D.bg:SetPoint("CENTER", Portrait3D, "CENTER", 0, 0);
		function CoverFrame:Update3DPortrait()
			if MT.GetConfig(configKey, "Portrait3D") then
				local unit = UnitFrame.unit or unit;
				if (not UnitIsConnected(unit)) or (not UnitIsVisible(unit)) then
					-- if not Portrait3D:GetModelFileID() then
						Portrait3D:Hide();
						-- Portrait3D:SetPortraitZoom(0.0);
						-- Portrait3D:SetCamDistanceScale(0.25);
						-- Portrait3D:SetPosition(0.0, 0.0, 0.5);
						-- Portrait3D:ClearModel();
						-- Portrait3D:SetModel("Interface\\Buttons\\TalkToMeQuestionMark.M2");
					-- end
				else
					Portrait3D:Show();
					Portrait3D:SetPortraitZoom(1.0);
					Portrait3D:SetCamDistanceScale(1.0);
					Portrait3D:SetPosition(0.0, 0.0, 0.0);
					Portrait3D:ClearModel();
					Portrait3D:SetUnit(unit);
				end
				if UnitIsGhost(unit) then
					Portrait3D:SetLight(true, LightGhost);
				elseif UnitIsDead(unit) then
					Portrait3D:SetLight(true, LightDead);
				else
					Portrait3D:SetLight(true, LightAlive);
				end
				-- Portrait3D:SetLight(true, LightAlive);
			end
		end
		function CoverFrame:UNIT_MODEL_CHANGED(event, unitID)
			local unit = UnitFrame.unit or unit;
			if unit == unitID then
				self:Update3DPortrait();
			end
		end
		MT.FrameRegisterEvent(CoverFrame, "UNIT_MODEL_CHANGED");
		CoverFrame.Portrait3D = Portrait3D;
	else
		function CoverFrame:Update3DPortrait()
		end
		-- CoverFrame.Portrait3D = _VirtualWidget;
	end

	if FrameDef.CreateClass then
		local Class = CreateFrame("FRAME", nil, CoverFrame);
		Class:SetSize(24, 24);
		Class:ClearAllPoints();
		if PortraitPosition == "LEFT" then
			Class:SetPoint("TOPRIGHT", -116, -12);
		else
			Class:SetPoint("TOPLEFT", 116, -12);
		end
		Class:SetFrameLevel(CoverFrame:GetFrameLevel() + 1);
		Class.BackGround = Class:CreateTexture(nil, "BACKGROUND", nil, SubLayerLevelOffset);
		Class.BackGround:SetTexture("Interface\\Minimap\\UI-Minimap-Background");
		Class.BackGround:SetWidth(20);
		Class.BackGround:SetHeight(20);
		Class.BackGround:SetPoint("CENTER");
		Class.BackGround:SetVertexColor(0, 0, 0, 0.7);
		Class.Border = Class:CreateTexture(nil, "OVERLAY", nil, SubLayerLevelOffset);
		Class.Border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder");
		Class.Border:SetWidth(54);
		Class.Border:SetHeight(54);
		Class.Border:SetPoint("CENTER", 11, -12);
		Class.Icon = Class:CreateTexture(nil, "ARTWORK", nil, SubLayerLevelOffset);
		Class.Icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes");
		Class.Icon:SetAllPoints();
		function CoverFrame:UpdateClass()
			self._CLASS = UnitClassBase(unit);
			local unit = UnitFrame.unit or unit;
			if UnitIsPlayer(unit) then
				self.CLASS = UnitClassBase(unit);
			else
				self.CLASS = nil;
			end
			if self.CLASS and MT.GetConfig(configKey, "Class") then
				local coord = CLASS_ICON_TCOORDS[self.CLASS];
				if coord then
					Class.Icon:SetTexCoord(coord[1], coord[2], coord[3], coord[4]);
					Class:Show();
				else
					Class:Hide();
				end
			else
				Class:Hide();
			end
		end
		CoverFrame:UpdateClass();

		CoverFrame.Class = Class;
	else
		function CoverFrame:UpdateClass()
			self._CLASS = UnitClassBase(unit);
			local unit = UnitFrame.unit or unit;
			if UnitIsPlayer(unit) then
				self.CLASS = UnitClassBase(unit);
			else
				self.CLASS = nil;
			end
		end

		-- CoverFrame.Class = _VirtualWidget;
	end

	-- ABOVE		name of object must be equal to its config key

	MT.UnitFrames[unit] = UnitFrame;
	MT.CoverFrames[unit] = CoverFrame;

	function CoverFrame:UpdateLevel()
		local unit = UnitFrame.unit or unit;
		self.LEVEL = UnitLevel(unit);
		if self.LevelText then
			self.LevelText:SetText(self.LEVEL);
		end
	end

	if configKey == 'party' then
		local font, fontsize, fontflag = GameFontNormalSmall:GetFont();
		_G[UnitFrameName .. "Name"]:SetFont(font, fontsize * 0.8, fontflag);
	end
	function CoverFrame:ApplyScale()
		local v = MT.GetConfig(configKey, 'Scale');
		UnitFrame:SetScale(v);
	end
	function CoverFrame:Scale()
		MT.RunAfterCombat(self.ApplyScale);
	end

	CoverFrame:UpdateClass();

	return CoverFrame;
end
function MT.CoverTexture(CoverFrame, Covered, LayerLevel, SubLayerLevel)
	if not Covered or type(Covered) ~= 'table' then
		return;
	end
	local origLevel, origSubLevel = Covered:GetDrawLayer();
	local CoverTexture = CoverFrame:CreateTexture(nil, LayerLevel or origLevel or "OVERLAY", nil, SubLayerLevel or origSubLevel or 7);
	CoverTexture:SetTexture(Covered:GetTexture());
	CoverTexture:SetTexCoord(Covered:GetTexCoord());
	CoverTexture:SetVertexColor(Covered:GetVertexColor());
	CoverTexture:SetSize(Covered:GetSize());
	CoverTexture:SetPoint("CENTER", Covered);
	if Covered:IsShown() then
		CoverTexture:Show();
	else
		CoverTexture:Hide();
	end
	hooksecurefunc(Covered, "SetTexture", function(_, ...) CoverTexture:SetTexture(...); end);
	hooksecurefunc(Covered, "SetTexCoord", function(_, ...) CoverTexture:SetTexCoord(...); end);
	hooksecurefunc(Covered, "SetVertexColor", function(_, ...) CoverTexture:SetVertexColor(...); end);
	hooksecurefunc(Covered, "SetSize", function(_, ...) CoverTexture:SetSize(...); end);
	hooksecurefunc(Covered, "SetWidth", function(_, ...) CoverTexture:SetWidth(...); end);
	hooksecurefunc(Covered, "SetHeight", function(_, ...) CoverTexture:SetHeight(...); end);
	hooksecurefunc(Covered, "SetAlpha", function(_, ...) CoverTexture:SetAlpha(...); end);
	hooksecurefunc(Covered, "Show", function(_) CoverTexture:Show(); end);
	hooksecurefunc(Covered, "Hide", function(_) CoverTexture:Hide(); end);
	return CoverTexture;
end
function MT.CoverFontString(CoverFrame, Covered, LayerLevel, SubLayerLevel, nofont, notext, nocolor, noheight, noalpha, noshow)
	if not Covered or type(Covered) ~= 'table' then
		return;
	end
	local origLevel, origSubLevel = Covered:GetDrawLayer();
	local CoverFontString = CoverFrame:CreateFontString(nil, LayerLevel or origLevel or "OVERLAY", nil, SubLayerLevel or origSubLevel or 7);
	CoverFontString:SetFont(Covered:GetFont());
	CoverFontString:SetText(Covered:GetText());
	CoverFontString:SetTextColor(Covered:GetTextColor());
	CoverFontString:SetPoint("CENTER", Covered);
	if Covered:IsShown() then
		CoverFontString:Show();
	else
		CoverFontString:Hide();
	end
	if nofont ~= false then
		hooksecurefunc(Covered, "SetFont", function(_, ...) CoverFontString:SetFont(...); end);
	end
	if notext ~= false then
		hooksecurefunc(Covered, "SetText", function(_, ...) CoverFontString:SetText(...); end);
	end
	if nocolor ~= false then
		hooksecurefunc(Covered, "SetTextColor", function(_, ...) CoverFontString:SetTextColor(...); end);
		hooksecurefunc(Covered, "SetVertexColor", function(_, ...) CoverFontString:SetVertexColor(...); end);
	end
	if noheight ~= false then
		hooksecurefunc(Covered, "SetTextHeight", function(_, ...) CoverFontString:SetTextHeight(...); end);
	end
	if noalpha ~= false then
		hooksecurefunc(Covered, "SetAlpha", function(_, ...) CoverFontString:SetAlpha(...); end);
	end
	if noshow ~= false then
		hooksecurefunc(Covered, "Show", function(_) CoverFontString:Show(); end);
		hooksecurefunc(Covered, "Hide", function(_) CoverFontString:Hide(); end);
	end
	return CoverFontString;
end
function MT.SecureHideLayer(Widget)
	Widget:SetAlpha(0.0);
end
function MT.CreateThreatBar(CoverFrame, ppos, point, relPoint, x, y)
	local Threat = CreateFrame("FRAME", nil, CoverFrame);
	Threat:SetSize(32, 16);
	Threat:SetPoint(point, CoverFrame, relPoint, x, y);
	Threat.unit = CoverFrame.unit;
	local Value = Threat:CreateFontString(nil, "OVERLAY");
	Value:SetFont(TextStatusBarText:GetFont(), 13, "OUTLINE");
	Value:SetPoint(ppos);
	Threat.Value = Value;
	Threat.update_timer = THREAT_UPDATE_INTERVAL;
	Threat:SetScript("OnUpdate", function(self, elasped)
		self.update_timer = self.update_timer + elasped;
		if self.__update or self.update_timer >= THREAT_UPDATE_INTERVAL then
			self.__update = nil;
			self.update_timer = 0.0;
			local unit = self.unit;
			if UnitExists(unit) and not UnitIsDead(unit) and UnitIsEnemy('player', unit) and not UnitPlayerControlled(unit) then
				local maxThreat = -1;
				if IsInRaid() then
					local num = GetNumGroupMembers();
					if num > 0 then
						for index = 1, num do
							local member = 'raid' .. index;
							if not UnitIsUnit(member, 'player') then
								local isTanking, status, scaledPercentage, rawPercentage, threatValue = UnitDetailedThreatSituation(member, unit);
								if threatValue ~= nil and threatValue >= maxThreat then
									maxThreat = threatValue;
								end
							end
						end
					end
				elseif IsInGroup() then
					local num = GetNumGroupMembers();
					if num > 0 then
						for index = 1, num do
							local member = 'party' .. index;
							local isTanking, status, scaledPercentage, rawPercentage, threatValue = UnitDetailedThreatSituation(member, unit);
							if threatValue ~= nil and threatValue >= maxThreat then
								maxThreat = threatValue;
							end
						end
					end
				end
				if UnitExists('targettarget') then
					local isTanking, status, scaledPercentage, rawPercentage, threatValue = UnitDetailedThreatSituation('targettarget', unit);
					if threatValue ~= nil and threatValue >= maxThreat then
						maxThreat = threatValue;
					end
				end
				local isTanking, threatStatus, threatPercent, rawThreatPercent, threatValue = UnitDetailedThreatSituation('player', unit);
				if maxThreat == 0 or threatValue == 0 or threatValue == nil then
					threatPercent = 0;
				elseif maxThreat == -1 then
					threatPercent = 100;
				else
					threatPercent = threatValue / maxThreat * 100;
				end
				if threatPercent then
					self.Value:SetText(format(isTanking and "%d%%" or "*%d%%", threatPercent));
					threatPercent = threatPercent * 0.01;
					if threatPercent < 1.0 then
						self.Value:SetVertexColor(1.0 - threatPercent, 1.0, 0.0);
					elseif threatPercent < 2.0 then
						self.Value:SetVertexColor(1.0, 2.0 - threatPercent, 0.0);
					else
						self.Value:SetVertexColor(1.0, 0.0, 0.0);
					end
				else
					self.Value:SetText(nil);
					-- self.Value:SetVertexColor(0.0, 1.0, 0.0);
				end
			else
				self.Value:SetText(nil);
			end
		end
	end);
	Threat:SetScript("OnHide", function(self)
		self.update_timer = THREAT_UPDATE_INTERVAL;
	end);
	Threat:SetScript("OnEvent", function(self, event)
		self.__update = true;
	end);
	Threat:RegisterEvent("UNIT_THREAT_LIST_UPDATE");
	return Threat;
end


function MT._Secure_SetUnitFramesDefaultPosition()
	if not TargetFrame:IsUserPlaced() then
		TargetFrame:SetUserPlaced(true);
		TargetFrame:ClearAllPoints();
		TargetFrame:SetPoint("LEFT", PlayerFrame, "RIGHT", 100, 0);
	end
end
function MT._Secure_SetPlayerFramePosition()
	PlayerFrame:SetUserPlaced(true);
	PlayerFrame:ClearAllPoints();
	PlayerFrame:SetPoint("CENTER", UIParent, "CENTER", VT.DB.pRelX, VT.DB.pRelY);
end
function MT._Secure_ResetPlayerFramePosition()
	PlayerFrame:ClearAllPoints();
	PlayerFrame_ResetUserPlacedPosition();
end
function MT._Secure_SetTargetFramePosition()
	TargetFrame:SetUserPlaced(true);
	TargetFrame:ClearAllPoints();
	TargetFrame:SetPoint("CENTER", UIParent, "CENTER", VT.DB.tRelX, VT.DB.tRelY);
end
function MT._Secure_ResetTargetFramePosition()
	TargetFrame:ClearAllPoints();
	TargetFrame_ResetUserPlacedPosition();
	MT._Secure_SetUnitFramesDefaultPosition();
end

function MT.SetUnitFrameBorder(CoverFrame, index)
	if VT.DB.dark then
		CoverFrame:SetCoverBorderTexutre(BORDER_TEXTURE_LIST[index + 8]);
	else
		CoverFrame:SetCoverBorderTexutre(BORDER_TEXTURE_LIST[index + 1]);
	end
end


function MT.InitPlayerFrame()
	local FrameDef = {
		PortraitPosition = "LEFT",
		FrameTextureCoord = { 1.0, 0.09375, 0.0, 0.78125, },
		BarCoverTexture = true,
		BarCreateValue = true,
		BarCreatePercentage = true,
		BarValuePosition = nil,
		BarPercentagePosition = nil,
		BarEventDriven = false,
		BarTextFontSize = nil,
		Create3DPortrait = true,
		CreateClass = true,
		SubLayerLevelOffset = nil,
	};
	local CoverFrame = MT.HookUnitFrame(PlayerFrame, 'player', FrameDef);
	function CoverFrame:PLAYER_LEVEL_CHANGED(event, old, new)
		self:UpdateLevel();
	end
	MT.FrameRegisterEvent(CoverFrame, "PLAYER_LEVEL_CHANGED");
	function CoverFrame:UNIT_ENTERED_VEHICLE(event, unitID)
		CoverFrame:UpdatePowerType();
		CoverFrame:UpdateHealth();
		CoverFrame:UpdatePower();
		CoverFrame:Update3DPortrait();
		CoverFrame:UpdateClass();
		CoverFrame:UpdateLevel();
		CoverFrame:HideCoverTexture();
	end
	function CoverFrame:UNIT_EXITED_VEHICLE(event, unitID)
		CoverFrame:UpdatePowerType();
		CoverFrame:UpdateHealth();
		CoverFrame:UpdatePower();
		CoverFrame:Update3DPortrait();
		CoverFrame:UpdateClass();
		CoverFrame:UpdateLevel();
		MT.SetUnitFrameBorder(self, VT.DB.playerTexture);
	end
	MT.FrameRegisterUnitEvent(CoverFrame, 'player', "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE");
	if UnitInVehicle('player') then
		CoverFrame:UNIT_ENTERED_VEHICLE("UNIT_ENTERED_VEHICLE", 'player');
	end
	function CoverFrame:PLAYER_DEAD()
		self.Portrait3D:SetLight(true, LightDead);
	end
	function CoverFrame:PLAYER_ALIVE()
		local unit = UnitFrame.unit or unit;
		if UnitIsGhost(unit) then
			self.Portrait3D:SetLight(true, LightGhost);
		else
			self.Portrait3D:SetLight(true, LightAlive);
		end
	end
	function CoverFrame:PLAYER_UNGHOST()
		self.Portrait3D:SetLight(true, LightAlive);
	end
	CoverFrame.LevelText = MT.CoverFontString(CoverFrame, PlayerLevelText, "ARTWORK", 1);
	CoverFrame.HitIndicator = MT.CoverFontString(CoverFrame, PlayerHitIndicator, "OVERLAY", 2);
	CoverFrame.PVPIcon = MT.CoverTexture(CoverFrame, PlayerPVPIcon, "OVERLAY", 3);
	CoverFrame.LeaderIcon = MT.CoverTexture(CoverFrame, PlayerLeaderIcon, "OVERLAY", 4);
	CoverFrame.MasterIcon = MT.CoverTexture(CoverFrame, PlayerMasterIcon, "OVERLAY", 4);
	CoverFrame.RestIcon = MT.CoverTexture(CoverFrame, PlayerRestIcon, "OVERLAY", 5);
	CoverFrame.AttackIcon = MT.CoverTexture(CoverFrame, PlayerAttackIcon, "OVERLAY", 7);
	CoverFrame.AttackBackground = MT.CoverTexture(CoverFrame, PlayerAttackBackground, "OVERLAY", 6);
	--CoverFrame.StatusTexture = MT.CoverTexture(CoverFrame, PlayerStatusTexture, "OVERLAY");
	CoverFrame:UpdateLevel();
	MT.CreatePowerRestoration(CoverFrame, 'player');
	MT.CreateExtraPower0(CoverFrame, 'player', 'LEFT');
	MT.SecureHideLayer(PlayerFrameHealthBarText);
	MT.SecureHideLayer(PlayerFrameHealthBarTextLeft);
	MT.SecureHideLayer(PlayerFrameHealthBarTextRight);
	MT.SecureHideLayer(PlayerFrameManaBarText);
	MT.SecureHideLayer(PlayerFrameManaBarTextLeft);
	MT.SecureHideLayer(PlayerFrameManaBarTextRight);
	MT.SecureHideLayer(PlayerFrameTexture);
	CoverFrame.CombatStatus = CoverFrame:CreateTexture(nil, "BACKGROUND");
	CoverFrame.CombatStatus:SetSize(PlayerFrameTexture:GetSize());
	CoverFrame.CombatStatus:SetPoint("CENTER", PlayerFrameTexture);
	CoverFrame.CombatStatus:SetTexture("interface\\targetingframe\\ui-targetingframe-flash");
	CoverFrame.CombatStatus:SetTexCoord(1.0, 0.09375, 0.0, 0.78125 / 4);
	CoverFrame.CombatStatus:Hide();
	CoverFrame.CombatStatus:SetVertexColor(1.0, 0.0, 0.0, 1.0);
	if InCombatLockdown() then
		CoverFrame.CombatStatus:Show();
	else
		CoverFrame.CombatStatus:Hide();
	end
	function CoverFrame:PLAYER_REGEN_ENABLED()
		self.CombatStatus:Hide();
	end
	function CoverFrame:PLAYER_REGEN_DISABLED()
		self.CombatStatus:Show();
	end
	CoverFrame.HomePartyIcon = CoverFrame:CreateTexture(nil, "OVERLAY");
	CoverFrame.HomePartyIcon:SetTexture("Interface\\FriendsFrame\\UI-Toast-FriendOnlineIcon");
	CoverFrame.HomePartyIcon:SetPoint("TOPLEFT", 53, 6);
	CoverFrame.InstancePartyIcon = CoverFrame:CreateTexture(nil, "OVERLAY");
	CoverFrame.InstancePartyIcon:SetTexture("Interface\\FriendsFrame\\UI-Toast-FriendOnlineIcon");
	CoverFrame.InstancePartyIcon:SetPoint("TOPLEFT", 49, 2);
	function CoverFrame:GROUP_ROSTER_UPDATE()
		if IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			self.HomePartyIcon:Show();
			self.InstancePartyIcon:Show();
		else
			self.HomePartyIcon:Hide();
			self.InstancePartyIcon:Hide();
		end
	end
	function CoverFrame:UPDATE_CHAT_COLOR()
		local public = ChatTypeInfo["INSTANCE_CHAT"];
		local private = ChatTypeInfo["PARTY"];
		self.HomePartyIcon:SetVertexColor(private.r, private.g, private.b);
		self.InstancePartyIcon:SetVertexColor(public.r, public.g, public.b);
	end
	CoverFrame.RaidTarget = CoverFrame:CreateTexture(nil, "OVERLAY");
	CoverFrame.RaidTarget:SetSize(26, 26);
	CoverFrame.RaidTarget:SetPoint("CENTER", CoverFrame, "TOPLEFT", 73, -14);
	CoverFrame.RaidTarget:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]]);
	function CoverFrame:RAID_TARGET_UPDATE()
		local unit = CoverFrame.unit or 'player';
		local index = GetRaidTargetIndex(unit);
		if index == nil then
			self.RaidTarget:Hide();
		else
			SetRaidTargetIconTexture(self.RaidTarget, index);
			self.RaidTarget:Show();
		end
	end
	CoverFrame:RAID_TARGET_UPDATE();
	CoverFrame:UPDATE_CHAT_COLOR();
	CoverFrame:GROUP_ROSTER_UPDATE();
	MT.FrameRegisterEvent(CoverFrame, "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED", "GROUP_ROSTER_UPDATE", "UPDATE_CHAT_COLOR", "RAID_TARGET_UPDATE");
end
function MT.InitPetFrame()
	local FrameDef = {
		PortraitPosition = "LEFT",
		FrameTextureCoord = nil,
		BarCoverTexture = true,
		BarCreateValue = true,
		BarCreatePercentage = false,
		BarValuePosition = nil,
		BarPercentagePosition = nil,
		BarEventDriven = false,
		BarTextFontSize = nil,
		Create3DPortrait = nil,
		CreateClass = false,
		SubLayerLevelOffset = nil,
	};
	local CoverFrame = MT.HookUnitFrame(PetFrame, 'pet', FrameDef);
	CoverFrame.PBarTexture:Hide();
	if VT.IsCata or VT.IsWrath or VT.IsTBC then
		MT.SecureHideLayer(PetFrameHealthBarText);
		MT.SecureHideLayer(PetFrameHealthBarTextLeft);
		MT.SecureHideLayer(PetFrameHealthBarTextRight);
		MT.SecureHideLayer(PetFrameManaBarText);
		MT.SecureHideLayer(PetFrameManaBarTextLeft);
		MT.SecureHideLayer(PetFrameManaBarTextRight);
	end
end
function MT.InitTargetFrame()
	local FrameDef = {
		PortraitPosition = "RIGHT",
		FrameTextureCoord = { 0.09375, 1.0, 0.0, 0.78125, },
		BarCoverTexture = true,
		BarCreateValue = true,
		BarCreatePercentage = true,
		BarValuePosition = nil,
		BarPercentagePosition = nil,
		BarEventDriven = false,
		BarTextFontSize = nil,
		Create3DPortrait = true,
		CreateClass = true,
		SubLayerLevelOffset = nil,
	};
	local CoverFrame = MT.HookUnitFrame(TargetFrame, 'target', FrameDef);
	MT.FrameRegisterEvent(CoverFrame, "PLAYER_TARGET_CHANGED");
	function CoverFrame:PLAYER_TARGET_CHANGED(event)
		if UnitExists('target') then
			self:UpdateClass();
			self:UpdateLevel();
			self:UpdateHealth();
			self:UpdatePower();
			local classification = UnitClassification('target');
			if classification == "elite" or classification == "worldboss" then
				MT.SetUnitFrameBorder(self, 3);
			elseif classification == "rareelite" then
				MT.SetUnitFrameBorder(self, 2);
			elseif classification == "rare" then
				MT.SetUnitFrameBorder(self, 1);
			else	--	"normal", "trivial", or "minus"
				MT.SetUnitFrameBorder(self, 0);
			end
			self:Update3DPortrait();
		end
	end
	function CoverFrame:UNIT_LEVEL(event, unitID)
		self:UpdateLevel();
	end
	MT.FrameRegisterUnitEvent(CoverFrame, 'target', "UNIT_LEVEL");
	CoverFrame.LevelText = MT.CoverFontString(CoverFrame, TargetFrameTextureFrameLevelText, "OVERLAY", 6);
	CoverFrame.HighLevelTexture = MT.CoverTexture(CoverFrame, TargetFrameTextureFrameHighLevelTexture, "OVERLAY", 7);
	CoverFrame.PVPIcon = MT.CoverTexture(CoverFrame, TargetFrameTextureFramePVPIcon, "OVERLAY");
	CoverFrame.LeaderIcon = MT.CoverTexture(CoverFrame, TargetFrameTextureFrameLeaderIcon, "OVERLAY");
	CoverFrame.RaidTargetIcon = MT.CoverTexture(CoverFrame, TargetFrameTextureFrameRaidTargetIcon, "OVERLAY");
	if VT.IsCata or VT.IsWrath or VT.IsTBC then
		MT.SecureHideLayer(TargetFrameTextureFrame.HealthBarText);
		MT.SecureHideLayer(TargetFrameTextureFrame.HealthBarTextLeft);
		MT.SecureHideLayer(TargetFrameTextureFrame.HealthBarTextRight);
		MT.SecureHideLayer(TargetFrameTextureFrame.ManaBarText);
		MT.SecureHideLayer(TargetFrameTextureFrame.ManaBarTextLeft);
		MT.SecureHideLayer(TargetFrameTextureFrame.ManaBarTextRight);
	end
	MT.SecureHideLayer(TargetFrameTextureFrameDeadText);
	MT.SecureHideLayer(TargetFrameTextureFrameUnconsciousText);
	MT.SecureHideLayer(TargetFrameTextureFrameTexture);
	MT.CreateThreatBar(CoverFrame, "LEFT", "TOPLEFT", "TOPLEFT", 5, -5);
	CoverFrame:PLAYER_TARGET_CHANGED();
end
function MT.InitToTFrame()
	local FrameDef = {
		PortraitPosition = "LEFT",
		FrameTextureCoord = { 0.015625, 0.7265625, 0.0, 0.703125, },
		BarCoverTexture = true,
		BarCreateValue = true,
		BarCreatePercentage = false,
		BarValuePosition = 0,
		BarPercentagePosition = nil,
		BarEventDriven = nil,
		BarTextFontSize = nil,
		Create3DPortrait = nil,
		CreateClass = false,
		SubLayerLevelOffset = 2,
	};
	local CoverFrame = MT.HookUnitFrame(TargetFrameToT, 'targettarget', FrameDef);
	CoverFrame.target = MT.CreatePartyTargetingFrame(CoverFrame, 'targettarget', "RIGHT", 90);
	CoverFrame.update_timer = 0.0;
	CoverFrame:SetScript("OnUpdate", function(self, elasped)
		self.update_timer = self.update_timer + elasped;
		if self.update_timer >= TARGET_UPDATE_INTERVAL then
			self.update_timer = self.update_timer - TARGET_UPDATE_INTERVAL;
			if UnitExists('targettarget') then
				self:UpdatePowerType();
				self:UpdateHealth();
				self:UpdatePower();
			end
		end
	end);
	CoverFrame:SetScript("OnShow", function(self)
		self:UpdatePowerType();
		self:UpdateHealth();
		self:UpdatePower();
	end);
	function CoverFrame:UNIT_TARGET(event, unitID)
		self:UpdatePowerType();
	end
	MT.FrameRegisterUnitEvent(CoverFrame, 'target', "UNIT_TARGET");

	CoverFrame:SetFrameStrata("HIGH");
	CoverFrame:SetFrameLevel(MT.CoverFrames['target']:GetFrameLevel() + 128);

	MT.RunAfterCombat(function()
		TargetFrameToT:ClearAllPoints();
		-- TargetFrameToT:SetPoint("RIGHT", TargetFrame, "RIGHT", 50, 0);
		TargetFrameToT:SetPoint("BOTTOMRIGHT", TargetFrame, "BOTTOMRIGHT", -15, -20);
	end);
end
function MT.InitFocusFrame()
	local FrameDef = {
		PortraitPosition = "RIGHT",
		FrameTextureCoord = { 0.09375, 1.0, 0.0, 0.78125, },
		BarCoverTexture = true,
		BarCreateValue = true,
		BarCreatePercentage = true,
		BarValuePosition = nil,
		BarPercentagePosition = nil,
		BarEventDriven = false,
		BarTextFontSize = nil,
		Create3DPortrait = true,
		CreateClass = true,
		SubLayerLevelOffset = nil,
	};
	local CoverFrame = MT.HookUnitFrame(FocusFrame, 'focus', FrameDef);
	MT.FrameRegisterEvent(CoverFrame, "PLAYER_FOCUS_CHANGED");
	function CoverFrame:PLAYER_FOCUS_CHANGED(event)
		if UnitExists('focus') then
			self:UpdateClass();
			self:UpdateLevel();
			self:UpdateHealth();
			self:UpdatePower();
			local classification = UnitClassification('focus');
			if classification == "elite" or classification == "worldboss" then
				MT.SetUnitFrameBorder(self, 3);
			elseif classification == "rareelite" then
				MT.SetUnitFrameBorder(self, 2);
			elseif classification == "rare" then
				MT.SetUnitFrameBorder(self, 1);
			else	--	"normal", "trivial", or "minus"
				MT.SetUnitFrameBorder(self, 0);
			end
			self:Update3DPortrait();
		end
	end
	function CoverFrame:UNIT_LEVEL(event, unitID)
		self:UpdateLevel();
	end
	MT.FrameRegisterUnitEvent(CoverFrame, 'focus', "UNIT_LEVEL");
	CoverFrame.LevelText = MT.CoverFontString(CoverFrame, FocusFrameTextureFrameLevelText, "OVERLAY", 6);
	CoverFrame.HighLevelTexture = MT.CoverTexture(CoverFrame, FocusFrameTextureFrameHighLevelTexture, "OVERLAY", 7);
	CoverFrame.PVPIcon = MT.CoverTexture(CoverFrame, FocusFrameTextureFramePVPIcon, "OVERLAY");
	CoverFrame.LeaderIcon = MT.CoverTexture(CoverFrame, FocusFrameTextureFrameLeaderIcon, "OVERLAY");
	CoverFrame.RaidTargetIcon = MT.CoverTexture(CoverFrame, FocusFrameTextureFrameRaidTargetIcon, "OVERLAY");
	MT.SecureHideLayer(FocusFrameTextureFrame.HealthBarText);
	MT.SecureHideLayer(FocusFrameTextureFrame.HealthBarTextLeft);
	MT.SecureHideLayer(FocusFrameTextureFrame.HealthBarTextRight);
	MT.SecureHideLayer(FocusFrameTextureFrame.ManaBarText);
	MT.SecureHideLayer(FocusFrameTextureFrame.ManaBarTextLeft);
	MT.SecureHideLayer(FocusFrameTextureFrame.ManaBarTextRight);
	MT.SecureHideLayer(FocusFrameTextureFrameDeadText);
	MT.SecureHideLayer(FocusFrameTextureFrameUnconsciousText);
	MT.SecureHideLayer(FocusFrameTextureFrameTexture);
	MT.CreateThreatBar(CoverFrame, "LEFT", "TOPLEFT", "TOPLEFT", 5, -5);
	CoverFrame:PLAYER_FOCUS_CHANGED();
end
function MT.InitToFFrame()
	local FrameDef = {
		PortraitPosition = "LEFT",
		FrameTextureCoord = { 0.015625, 0.7265625, 0.0, 0.703125, },
		BarCoverTexture = true,
		BarCreateValue = true,
		BarCreatePercentage = false,
		BarValuePosition = 0,
		BarPercentagePosition = nil,
		BarEventDriven = nil,
		BarTextFontSize = nil,
		Create3DPortrait = nil,
		CreateClass = false,
		SubLayerLevelOffset = 2,
	};
	local CoverFrame = MT.HookUnitFrame(FocusFrameToT, 'focustarget', FrameDef);
	CoverFrame.update_timer = 0.0;
	CoverFrame:SetScript("OnUpdate", function(self, elasped)
		self.update_timer = self.update_timer + elasped;
		if self.update_timer >= TARGET_UPDATE_INTERVAL then
			self.update_timer = self.update_timer - TARGET_UPDATE_INTERVAL;
			if UnitExists('focustarget') then
				self:UpdatePowerType();
				self:UpdateHealth();
				self:UpdatePower();
			end
		end
	end);
	CoverFrame:SetScript("OnShow", function(self)
		self:UpdatePowerType();
		self:UpdateHealth();
		self:UpdatePower();
	end);
	function CoverFrame:UNIT_TARGET(event, unitID)
		self:UpdatePowerType();
	end
	MT.FrameRegisterUnitEvent(CoverFrame, 'focus', "UNIT_TARGET");

	CoverFrame:SetFrameStrata("HIGH");
	CoverFrame:SetFrameLevel(CoverFrame:GetFrameLevel() + 128);

	-- MT.RunAfterCombat(function()
	-- 	FocusFrameToT:ClearAllPoints();
	-- 	FocusFrameToT:SetPoint("RIGHT", FocusFrame, "RIGHT", 50, 0);
	-- end);
end
function MT.InitPartyFrames()
	local FrameDef = {
		PortraitPosition = "LEFT",
		FrameTextureCoord = nil,
		BarCoverTexture = true,
		BarCreateValue = true,
		BarCreatePercentage = true,
		BarValuePosition = nil,
		BarPercentagePosition = nil,
		BarEventDriven = false,
		BarTextFontSize = 10,
		BarTextFontScale = 1.0,
		Create3DPortrait = true,
		CreateClass = true,
		SubLayerLevelOffset = nil,
	};
	local function GROUP_ROSTER_UPDATE(self, event, ...)
		After(0.1, function()
			self:UpdatePowerType();
			self:UpdateHealth();
			self:UpdatePower();
			self:Update3DPortrait();
			self:UpdateClass();
			self:UpdateLevel();
			self:UpdateAura();
			self:RAID_TARGET_UPDATE();
		end);
	end
	local function UNIT_LEVEL(self, event, unit)
		self:UpdateLevel();
	end
	local function UNIT_NAME_UPDATE(self, event, unit)
		self:UpdateClass();
	end
	local function RAID_TARGET_UPDATE(self, event)
		local index = GetRaidTargetIndex(self.unit);
		if index == nil then
			self.RaidTarget:Hide();
		else
			SetRaidTargetIconTexture(self.RaidTarget, index);
			self.RaidTarget:Show();
		end
	end
	local function CastOnEvent(self, event, ...)
		if (event == "GROUP_ROSTER_UPDATE" and not IsInRaid()) or (event == "PARTY_MEMBER_ENABLE") or (event == "PARTY_MEMBER_DISABLE") or (event == "PARTY_LEADER_CHANGED") then
			local unit = self.unit;
			if UnitChannelInfo(unit) ~= nil then
				return CastingBarFrame_OnEvent(self, "UNIT_SPELLCAST_CHANNEL_START", unit);
			elseif UnitCastingInfo(unit) ~= nil then
				return CastingBarFrame_OnEvent(self, "UNIT_SPELLCAST_START", unit);
			else
				self.casting = nil;
				self.channeling = nil;
				self:SetMinMaxValues(0, 0);
				self:SetValue(0);
				self:Hide();
				return;
			end
		end
		return CastingBarFrame_OnEvent(self, event, ...);
	end
	for i = 1, 4 do
		local unit = 'party' .. i;
		local CoverFrame = MT.HookUnitFrame(_G["PartyMemberFrame" .. i], unit, FrameDef);
		CoverFrame.target = MT.CreatePartyTargetingFrame(CoverFrame, unit, "RIGHT", 50);
		MT.CreatePartyAura(CoverFrame, unit);
		CoverFrame.Class:SetScale(0.7);
		CoverFrame.Class:ClearAllPoints();
		CoverFrame.Class:SetPoint("TOPLEFT", 40, 2);
		CoverFrame.GROUP_ROSTER_UPDATE = GROUP_ROSTER_UPDATE;
		CoverFrame.UNIT_LEVEL = UNIT_LEVEL;
		CoverFrame.UNIT_NAME_UPDATE = UNIT_NAME_UPDATE;
		CoverFrame.RAID_TARGET_UPDATE = RAID_TARGET_UPDATE;
		MT.FrameRegisterEvent(CoverFrame, "GROUP_ROSTER_UPDATE");
		MT.FrameRegisterUnitEvent(CoverFrame, unit, "UNIT_LEVEL");
		MT.FrameRegisterUnitEvent(CoverFrame, unit, "UNIT_NAME_UPDATE");
		MT.FrameRegisterEvent(CoverFrame, "RAID_TARGET_UPDATE");
		CoverFrame.Name = MT.CoverFontString(CoverFrame, _G["PartyMemberFrame" .. i .. "Name"], "OVERLAY", 6, nil, nil, false, nil, false, false);
		CoverFrame.NameBG = CoverFrame:CreateTexture(nil, "BACKGROUND");
		CoverFrame.NameBG:SetPoint("TOPLEFT", CoverFrame.Name, "TOPLEFT", -2, 0);
		CoverFrame.NameBG:SetPoint("BOTTOMRIGHT", CoverFrame.Name, "BOTTOMRIGHT", 2, 0);
		CoverFrame.NameBG:SetColorTexture(0.0, 0.0, 0.0, 0.35);
		MT.SecureHideLayer(_G["PartyMemberFrame" .. i .. "Name"]);
		local _UpdateClass = CoverFrame.UpdateClass;
		function CoverFrame:UpdateClass()
			_UpdateClass(self);
			local color = RAID_CLASS_COLORS[self.CLASS];
			if color ~= nil then
				self.Name:SetTextColor(color.r, color.g, color.b);
			else
				self.Name:SetTextColor(1.0, 1.0, 1.0);
			end
		end
		CoverFrame.LevelText = CoverFrame:CreateFontString(nil, "OVERLAY");
		CoverFrame.LevelText:SetFont(GameFontNormal:GetFont(), 11, "OUTLINE");
		CoverFrame.LevelText:SetPoint("CENTER", CoverFrame, "BOTTOMLEFT", 10, 10);
		CoverFrame.LevelText:Show();
		CoverFrame.RaidTarget = CoverFrame:CreateTexture(nil, "OVERLAY");
		CoverFrame.RaidTarget:SetSize(18, 18);
		CoverFrame.RaidTarget:SetPoint("TOP", CoverFrame, "TOPLEFT", 26, 4);
		CoverFrame.RaidTarget:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]]);
		CoverFrame:RAID_TARGET_UPDATE();
		CoverFrame:GROUP_ROSTER_UPDATE();
		CoverFrame.PVPIcon = MT.CoverTexture(CoverFrame, _G["PartyMemberFrame" .. i .. "PVPIcon"], "OVERLAY");
		CoverFrame.LeaderIcon = MT.CoverTexture(CoverFrame, _G["PartyMemberFrame" .. i .. "LeaderIcon"], "OVERLAY");
		CoverFrame.MasterIcon = MT.CoverTexture(CoverFrame, _G["PartyMemberFrame" .. i .. "MasterIcon"], "OVERLAY");

		if VT.IsCata or VT.IsWrath or VT.IsTBC then
			local Cast = CreateFrame('STATUSBAR', "PartyMemberFrame" .. i .. "CastingBar", CoverFrame, "SmallCastingBarFrameTemplate");
			Cast:SetScale(0.8);
			Cast:SetPoint("LEFT", CoverFrame, "LEFT", 20, 0);
			Cast:SetPoint("TOP", _G["PartyMemberFrame" .. i .. "Debuff1"], "BOTTOM", 0, -2);
			CastingBarFrame_OnLoad(Cast, unit, true, true);
			Cast:RegisterEvent("GROUP_ROSTER_UPDATE");
			Cast:RegisterEvent("PARTY_MEMBER_ENABLE");
			Cast:RegisterEvent("PARTY_MEMBER_DISABLE");
			Cast:RegisterEvent("PARTY_LEADER_CHANGED");
			Cast:SetScript("OnEvent", CastOnEvent);
			Cast.OnEvent = CastOnEvent;
			CoverFrame.CastingBar = Cast;
		end

		CoverFrame:UNIT_AURA();
	end

	MT.RunAfterCombat(function()
		for i = 2, 4 do
			local UnitFrame = _G["PartyMemberFrame" .. i];
			UnitFrame:ClearAllPoints();
			UnitFrame:SetPoint("TOPLEFT", _G["PartyMemberFrame" .. (i - 1) .. "PetFrame"], "BOTTOMLEFT", -23, -22);
		end
	end);
end
function MT.ApplyFrameSettings()
	for unit, CoverFrame in next, MT.CoverFrames do
		CoverFrame:Scale();
	end
	MT.SetUnitFrameBorder(MT.CoverFrames['player'], VT.DB.playerTexture);
	MT.SetUnitFrameBorder(MT.CoverFrames['pet'], 4);
	MT.SetUnitFrameBorder(MT.CoverFrames['targettarget'], 5);
	MT.SetUnitFrameBorder(MT.CoverFrames['party1'], 6);
	MT.SetUnitFrameBorder(MT.CoverFrames['party2'], 6);
	MT.SetUnitFrameBorder(MT.CoverFrames['party3'], 6);
	MT.SetUnitFrameBorder(MT.CoverFrames['party4'], 6);
	if VT.IsCata or VT.IsWrath or VT.IsTBC then
		if VT.DB.castBar then
			MT.AttachCastBar(PlayerFrame, CastingBarFrame, nil, 32, 20, 160, 32, "RIGHT");
			--MT.AttachCastBar(TargetFrame, TargetFrameSpellBar, nil, 0, 32, 180, 24, "LEFT");
			if IsAddOnLoaded("ClassicCastbars") then
				MT.AttachClassicCastBar(TargetFrame, nil, nil, - 32, 20, 160, 32, "LEFT");
			end
		end
	end
	if not IsAddOnLoaded("ClassicCastbars") then
		MT.RegisterEvent("ADDON_LOADED", function(self, addon)
			if addon == "ClassicCastbars" then
				MT.AttachClassicCastBar(TargetFrame, nil, nil, - 32, 20, 160, 32, "LEFT");
				MT.ResetClassicCastBar();
			end
		end)
	end
	MT.TogglePowerRestoration();
	MT.TogglePowerRestorationFull();
	MT.ToggleExtraPower0();
	MT.RunAfterCombat(MT._Secure_TogglePartyTargetingFrame);
	MT.TogglePartyTargetingFrameStyle();
	MT.TogglePartyAura();
	if VT.IsCata or VT.IsWrath or VT.IsTBC then
		MT.TogglePartyCastingBar();
	end
	MT.RunAfterCombat(MT._Secure_ToggleToTTarget);
	if VT.DB.playerPlaced then
		MT.RunAfterCombat(MT._Secure_SetPlayerFramePosition);
		MT.RunAfterCombat(MT._Secure_SetTargetFramePosition);
	-- else
	-- 	MT.RunAfterCombat(MT._Secure_ResetPlayerFramePosition);
	-- 	MT.RunAfterCombat(MT._Secure_ResetTargetFramePosition);
	end
	if (VT.IsCata or VT.IsWrath or VT.IsTBC) and VT.DB.ShiftFocus then
		MT.RunAfterCombat(MT._Secure_ToggleShiftFocus);
	end

	for unit, CoverFrame in next, MT.CoverFrames do
		local configKey = CoverFrame.configKey;
		if CoverFrame.Class then
			if MT.GetConfig(configKey, "Class") then
				CoverFrame.Class:Show();
			else
				CoverFrame.Class:Hide();
			end
		end
		if CoverFrame.Portrait3D then
			if MT.GetConfig(configKey, "Portrait3D") then
				CoverFrame:Update3DPortrait();
			else
				CoverFrame.Portrait3D:Hide();
			end
		end
		if CoverFrame.HBarValue then
			if MT.GetConfig(configKey, "HBarValue") then
				CoverFrame.HBarValue:Show();
			else
				CoverFrame.HBarValue:Hide();
			end
		end
		if CoverFrame.HBarPercentage then
			if MT.GetConfig(configKey, "HBarPercentage") then
				CoverFrame.HBarPercentage:Show();
			else
				CoverFrame.HBarPercentage:Hide();
			end
		end
		if CoverFrame.PBarValue then
			if MT.GetConfig(configKey, "PBarValue") then
				CoverFrame.PBarValue:Show();
			else
				CoverFrame.PBarValue:Hide();
			end
		end
		if CoverFrame.PBarPercentage then
			if MT.GetConfig(configKey, "PBarPercentage") then
				CoverFrame.PBarPercentage:Show();
			else
				CoverFrame.PBarPercentage:Hide();
			end
		end
		if CoverFrame.HBarTexture then
			if MT.GetConfig(configKey, "HBColor") then
				CoverFrame.HBarTexture:Show();
			else
				CoverFrame.HBarTexture:Hide();
			end
		end
		CoverFrame:BarTextAlpha(MT.GetConfig(configKey, "BarTextAlpha"));
	end

	SetCVar("statusTextDisplay", "NONE");
	SetCVar("statusText", "0");
end

function MT.InitFrames()
	MT.InitPlayerFrame();
	MT.InitPetFrame();
	MT.InitTargetFrame();
	MT.InitToTFrame();
	if FocusFrame ~= nil then
		MT.InitFocusFrame();
		MT.InitToFFrame();
	end
	MT.InitPartyFrames();

	MT.ApplyFrameSettings();
end
