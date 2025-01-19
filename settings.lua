--[[--
	SETTINGS
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
local menulib = __ala_meta__.__menulib;

local L = CT.L;


CT.DefaultConfig = {
	playerPlaced = false,
	pRelX = -280,
	pRelY = -80,
	tRelX = 280,
	tRelY = -80,
	dark = false,
	playerTexture = 0,
	castBar = false,
	ToTTarget = false,

	power_restoration = VT.IsTBC or VT.IsVanilla,
	power_restoration_full = VT.IsVanilla or VT.IsTBC,
	extra_power0 = true,

	partyAura = true,
	partyAura_size = 14;
	partyCast = true,
	partyTarget = true,
	-- partyTargetW = 80,
	-- partyTargetH = 24,
	TargetRetailStyle = false,

	ShiftFocus = VT.IsCata or VT.IsWrath or VT.IsTBC,

	which = 'general',
	configKeys = {  };
	general = {
		Class = true,
		Portrait3D = not VT.IsVanilla,
		HBarValue = true,
		HBarPercentage = true,
		PBarValue = true,
		PBarPercentage = true,
		HBColor = true,
		BarTextAlpha = 1.0,
		Scale = 1.0,
	},

};

local ConfigFrame = CreateFrame("FRAME");
ConfigFrame:SetSize(600, 400);
ConfigFrame.name = __addon;
ConfigFrame.subCheckBox = {  };
ConfigFrame.subSlider = {  };
ConfigFrame:Hide();
local col_width = 300;
local row_height = 32;

local function SliderOnValue(self, value)
	if self.key == "BarTextAlpha" or self.key == "Scale" then
		MT.SetConfigValue(VT.DB.which or 'general', self.key, value);
	end
end
local function SliderRefresh(self)
	if self.key == "BarTextAlpha" then
		local value = MT.GetConfig(VT.DB.which or 'general', self.key);
		self:SetValue(value);
		self.valueBox:SetText(value);
	elseif self.key == "Scale" then
		local value = MT.GetConfig(VT.DB.which or 'general', self.key);
		self:SetValue(value);
		self.valueBox:SetText(value);
	end
end
local function SliderOnValueChanged(self, value, userInput)
	local value = floor(value / self.stepSize + 0.5) * self.stepSize;
	if userInput then
		SliderOnValue(self, value);
	end
	self.valueBox:SetText(value);
end
local function SliderValueBoxOnEscapePressed(self)
	SliderRefresh(self);
	self:ClearFocus();
end
local function sliderValueBoxOnEnterPressed(self)
	local value = tonumber(self:GetText()) or 0.0;
	local parent = self.parent;
	value = floor(value / parent.stepSize + 0.5) * parent.stepSize;
	value = max(parent.minRange, min(parent.maxRange, value));
	parent:SetValue(value);
	SliderOnValue(parent, value);
	self:SetText(value);
	self:ClearFocus();
end
local function sliderValueBoxOnOnChar(self)
	self:SetText(self:GetText():gsub("[^%.0-9]+", ""):gsub("(%..*)%.", "%1"))
end

local function CreateSlider(specific, key, label_text, minRange, maxRange, stepSize, i, j)
	local texture = ConfigFrame:CreateTexture(nil, "ARTWORK");
	texture:SetSize(26, 26);
	texture:SetTexture("interface\\minimap\\dungeon");

	local label = ConfigFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	label:SetText(label_text);

	label:SetPoint("LEFT", texture, "RIGHT", 4, 0);

	local slider = CreateFrame("SLIDER", nil, ConfigFrame, "OptionsSliderTemplate");
	slider.specific = specific;
	slider.key = key;

	slider:ClearAllPoints();
	slider:SetPoint("LEFT", label, "RIGHT", 4, 0);
	slider:SetWidth(160);
	slider:SetHeight(20);

	slider:SetScript("OnShow", SliderRefresh);
	slider:HookScript("OnValueChanged", SliderOnValueChanged)
	slider.stepSize = stepSize;
	slider:SetValueStep(stepSize);
	slider:SetObeyStepOnDrag(true);

	slider:SetMinMaxValues(minRange, maxRange)
	slider.minRange = minRange;
	slider.maxRange = maxRange;
	-- slider.Low = _G[slider:GetName() .. "Low"];
	-- slider.High = _G[slider:GetName() .. "High"];
	-- slider.text = _G[slider:GetName() .. "Text"];
	slider.Low:SetText(minRange)
	slider.High:SetText(maxRange)

	local valueBox = CreateFrame("EDITBOX", nil, slider);
	valueBox:SetPoint("TOP", slider, "BOTTOM", 0, 0);
	valueBox:SetSize(60, 14);
	valueBox:SetFontObject(GameFontHighlightSmall);
	valueBox:SetAutoFocus(false);
	valueBox:SetJustifyH("CENTER");
	valueBox:SetScript("OnEscapePressed", SliderValueBoxOnEscapePressed);
	valueBox:SetScript("OnEnterPressed", sliderValueBoxOnEnterPressed);
	valueBox:SetScript("OnChar", sliderValueBoxOnOnChar);
	valueBox:SetMaxLetters(5)

	uireimp._SetBackdrop(valueBox, {
		bgFile = "Interface/ChatFrame/ChatFrameBackground",
		edgeFile = "Interface/ChatFrame/ChatFrameBackground",
		tile = true, edgeSize = 1, tileSize = 5,
	});
	uireimp._SetBackdropColor(valueBox, 0, 0, 0, 0.5);
	uireimp._SetBackdropBorderColor(valueBox, 0.3, 0.3, 0.3, 0.8);
	valueBox.parent = slider;

	slider.valueBox = valueBox

	texture:SetPoint("TOPLEFT", ConfigFrame, "TOPLEFT", (i - 1) * col_width + 4, - row_height * (j - 1) - 4);

	return slider;
end
local function DropOnClick(button, nil, param)
	local drop, key, value, desc = param[1], param[2], param[3], param[4];
	VT.DB[key] = value;
	drop.fontString:SetText(desc);
	if key == 'which' then
		for _, cb in next, ConfigFrame.subCheckBox do
			cb:SetChecked(VT.DB[value][cb.key] ~= false);
		end
		for _, s in next, ConfigFrame.subSlider do
			SliderRefresh(s);
		end
	elseif key == 'playerTexture' then
		VT.DB[key] = value;
		MT.SetUnitFrameBorder(MT.CoverFrames['player'], value);
	else
	end
end
local function CreateDrop(specific, key, labelText, i, j, data)
	local label = ConfigFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	label:SetText(labelText);

	local drop = CreateFrame("BUTTON", nil, ConfigFrame);
	drop.key = key;
	drop.specific = specific;
	drop:SetSize(28, 28)
	drop:EnableMouse(true);
	drop:SetNormalTexture("interface\\mainmenubar\\ui-mainmenu-scrolldownbutton-up")
	--drop:GetNormalTexture():SetTexCoord(0.0, 1.0, 0.0, 0.5);
	drop:SetPushedTexture("interface\\mainmenubar\\ui-mainmenu-scrolldownbutton-down")
	--drop:GetPushedTexture():SetTexCoord(0.0, 1.0, 0.0, 0.5);
	drop:SetHighlightTexture("Interface\\mainmenubar\\ui-mainmenu-scrolldownbutton-highlight");
	drop:SetPoint("LEFT", label, "RIGHT", 4, 0);

	local fs = ConfigFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	drop.fontString = fs;
	fs:SetPoint("LEFT", drop, "RIGHT", 0, 0);

	local menudef = {
		handler = DropOnClick,
	};
	for _, v in next, data do
		menudef[#menudef + 1] = {
			param = { drop, key, v[1], v[2], };
			text = v[2];
		};
		if v[1] == VT.DB[key] then
			fs:SetText(v[2]);
		end
	end

	drop:SetScript("OnClick", function(self) menulib.ShowMenu(self, "BOTTOMRIGHT", menudef); end);
	drop.label = label;

	label:SetPoint("LEFT", ConfigFrame, "TOPLEFT", (i - 1) * col_width + 4, - row_height * (j - 1) - 12);

	return drop;
end
local function CheckButtonOnClick(self)
	local on = self:GetChecked();
	local key = self.key;
	if key then
		if key == "playerPlaced" then
			VT.DB[key] = on;
			if on then
				MT.RunAfterCombat(MT._Secure_SetPlayerFramePosition);
				MT.RunAfterCombat(MT._Secure_SetTargetFramePosition);
			else
				MT.RunAfterCombat(MT._Secure_ResetPlayerFramePosition);
				MT.RunAfterCombat(MT._Secure_ResetTargetFramePosition);
			end
		elseif key == "dark" then
			VT.DB[key] = on;
			MT.SetUnitFrameBorder(MT.CoverFrames['player'], VT.DB.playerTexture);
			MT.CoverFrames['target']:PLAYER_TARGET_CHANGED();
			MT.SetUnitFrameBorder(MT.CoverFrames['pet'], 4);
			MT.SetUnitFrameBorder(MT.CoverFrames['targettarget'], 5);
			MT.SetUnitFrameBorder(MT.CoverFrames['party1'], 6);
			MT.SetUnitFrameBorder(MT.CoverFrames['party2'], 6);
			MT.SetUnitFrameBorder(MT.CoverFrames['party3'], 6);
			MT.SetUnitFrameBorder(MT.CoverFrames['party4'], 6);
		elseif key == "castBar" then
			if VT.IsCata or VT.IsWrath or VT.IsTBC then
				VT.DB[key] = on;
				if on then
					MT.AttachCastBar(PlayerFrame, CastingBarFrame, nil, 32, 20, 160, 32, "RIGHT");
					if IsAddOnLoaded("ClassicCastbars") then
						MT.AttachClassicCastBar(TargetFrame, nil, nil, - 32, 20, 160, 32, "LEFT");
					end
				else
					MT.ResetCastBar(CastingBarFrame);
					MT.ResetClassicCastBar();
					--MT.ResetCastBar(TargetFrameSpellBar);
				end
			end
		elseif key == "power_restoration" then
			VT.DB[key] = on;
			MT.TogglePowerRestoration();
		elseif key == "power_restoration_full" then
			VT.DB[key] = on;
			MT.TogglePowerRestorationFull();
		elseif key == "extra_power0" then
			VT.DB[key] = on;
			MT.ToggleExtraPower0();
		elseif key == "partyTarget" then
			VT.DB[key] = on;
			MT.RunAfterCombat(MT._Secure_TogglePartyTargetingFrame);
		elseif key == "TargetRetailStyle" then
			VT.DB[key] = on;
			MT.TogglePartyTargetingFrameStyle();
		elseif key == "partyAura" then
			VT.DB[key] = on;
			MT.TogglePartyAura();
		elseif key == "partyCast" then
			if VT.IsCata or VT.IsWrath or VT.IsTBC then
				VT.DB[key] = on;
				MT.TogglePartyCastingBar();
			end
		elseif key == "ToTTarget" then
			VT.DB[key] = on;
			MT.RunAfterCombat(MT._Secure_ToggleToTTarget);
		elseif key == "ShiftFocus" then
			VT.DB[key] = on;
			MT.RunAfterCombat(MT._Secure_ToggleShiftFocus);
		else
			MT.SetConfigBoolean(VT.DB.which or 'general', key, on);
		end
	end
end
local function CreateCheckBox(specific, key, label, i, j)

	local cb = CreateFrame("CHECKBUTTON", nil, ConfigFrame, "OptionsBaseCheckButtonTemplate");
	cb.key = key;
	cb.specific = specific;
	cb:ClearAllPoints();
	--cb:SetPoint("TOPLEFT", ConfigFrame, "TOPLEFT", 20, -40);
	cb:Show();
	cb:SetScript("OnClick", CheckButtonOnClick);

	local fs = ConfigFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	fs:SetText(label);
	cb.fontString = fs;
	fs:SetPoint("LEFT", cb, "RIGHT", 4, 0);

	if specific then
		cb:SetChecked(VT.DB[VT.DB.which][key] ~= false);
	else
		cb:SetChecked(VT.DB[key] ~= false);
	end

	cb:SetPoint("LEFT", ConfigFrame, "TOPLEFT", (i - 1) * col_width + 4, - row_height * (j - 1) - 12);

	return cb;
end
local function ValueBoxOnEscapePressed(self)
	local key = self.key;
	if key and VT.DB[key] then
		self:SetText(VT.DB[key]);
	end
	self:ClearFocus();
end
local function ValueBoxOnEnterPressed(self)
	local key = self.key;
	if key and VT.DB[key] then
		local value = tonumber(self:GetText()) or 0.0;
		VT.DB[key] = value;
		MT.RunAfterCombat(MT._Secure_SetPlayerFramePosition);
		MT.RunAfterCombat(MT._Secure_SetTargetFramePosition);
	end
	self:ClearFocus();
end
local function ValueBoxOnOnChar(self)
	self:SetText(self:GetText():gsub("[^%.0-9%-]+", ""):gsub("(%..*)%.", "%1"):gsub("(%-.*)%-", "%1"));
end
local function CreateValueBox(specific, key, label, i, j)

	local valueBox = CreateFrame("EDITBOX", nil, ConfigFrame);
	valueBox.key = key;
	valueBox.specific = specific;
	valueBox:ClearAllPoints();
	--valueBox:SetPoint("TOP", ConfigFrame, "BOTTOM", 0, 0);
	valueBox:SetSize(60, 18);
	valueBox:SetFontObject(GameFontHighlightSmall);
	valueBox:SetAutoFocus(false);
	valueBox:SetJustifyH("CENTER");
	valueBox:SetScript("OnEscapePressed", ValueBoxOnEscapePressed);
	valueBox:SetScript("OnEnterPressed", ValueBoxOnEnterPressed);
	valueBox:SetScript("OnChar", ValueBoxOnOnChar);
	valueBox:SetMaxLetters(5);

	uireimp._SetBackdrop(valueBox, {
		bgFile = "Interface/ChatFrame/ChatFrameBackground",
		edgeFile = "Interface/ChatFrame/ChatFrameBackground",
		tile = true,
		edgeSize = 1,
		tileSize = 5,
	});
	uireimp._SetBackdropColor(valueBox, 0.0, 0.0, 0.0, 0.5);
	uireimp._SetBackdropBorderColor(valueBox, 0.3, 0.3, 0.3, 0.8);

	local fs = ConfigFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	fs:SetText(label);
	fs:SetPoint("LEFT", valueBox, "RIGHT", 4, 0);
	valueBox.fontString = fs;

	-- valueBox:SetText(VT.DB[key]);
	valueBox:SetPoint("LEFT", ConfigFrame, "TOPLEFT", (i - 1) * col_width + 8, - row_height * (j - 1) - 12);
	valueBox:SetScript("OnShow", function()
		valueBox:SetText(VT.DB[key]);
	end);

	return valueBox;
end

function MT.InitConfigFrame()
	CreateCheckBox(false, "playerPlaced", L["user_placed"], 1, 1);
	CreateValueBox(false, "pRelX", L["x_offset_of_PlayerFrame"], 1, 2);
	CreateValueBox(false, "pRelY", L["y_offset_of_PlayerFrame"], 2, 2);
	CreateValueBox(false, "tRelX", L["x_offset_of_TargetFrame"], 1, 3);
	CreateValueBox(false, "tRelY", L["y_offset_of_TargetFrame"], 2, 3);

	CreateCheckBox(false, "dark", L["dark_portraid_texture"], 1, 4);
	CreateDrop(false, "playerTexture", L["playerTexture"], 2, 4, {
		{ 0, L["playerTexture_0"], },
		{ 1, L["playerTexture_1"], },
		{ 2, L["playerTexture_2"], },
		{ 3, L["playerTexture_3"], },
	});
	CreateCheckBox(false, "castBar", L["move_castbar_to_top_of_portrait"], 1, 5);
	CreateCheckBox(false, "ToTTarget", L["ToTTarget"], 2, 5);

	if VT.IsVanilla or VT.IsTBC then
		CreateCheckBox(false, "power_restoration", L["mana_and_energy_regen_indicator"], 1, 6);
		CreateCheckBox(false, "power_restoration_full", L["mana_and_energy_regen_indicator_full"], 2, 6);
	end
	CreateCheckBox(false, "extra_power0", L["mana_for_druid"], 1, 7);
	CreateCheckBox(false, "partyTarget", L["target_of_party_member"], 1, 8);
	CreateCheckBox(false, "TargetRetailStyle", L["target_is_retail_style"], 2, 8);

	CreateCheckBox(false, "partyAura", L["party_aura"], 1, 9);
	if VT.IsCata or VT.IsWrath or VT.IsTBC then
		CreateCheckBox(false, "partyCast", L["party_cast"], 2, 9);
	end
	if VT.IsCata or VT.IsWrath or VT.IsTBC then
		CreateCheckBox(false, "ShiftFocus", L["ShiftFocus"], 1, 10);
	end

	local sub_menu_start = 11;
	CreateDrop(false, "which", L["which_frame"], 1, sub_menu_start, {
		{ 'general', L["General"], },
		{ 'player', L["PlayerFrame"], },
		{ 'target', L["TargetFrame"], },
		{ 'pet', L["PetFrame"], },
		{ 'targettarget', L["TargetToT"], },
		{ 'party', L["Party"], },
		-- { 'boss', L["BOSS"], },
	});
	tinsert(ConfigFrame.subCheckBox, CreateCheckBox(true, "Class", L["class_icon"], 1, sub_menu_start + 1));
	tinsert(ConfigFrame.subCheckBox, CreateCheckBox(true, "Portrait3D", L["Portrait3D"], 2, sub_menu_start + 1));
	tinsert(ConfigFrame.subCheckBox, CreateCheckBox(true, "HBarValue", L["health_text"], 1, sub_menu_start + 2));
	tinsert(ConfigFrame.subCheckBox, CreateCheckBox(true, "HBarPercentage", L["health_percent"], 2, sub_menu_start + 2));
	tinsert(ConfigFrame.subCheckBox, CreateCheckBox(true, "HBColor", L["color_health_bar_by_health_percent"], 1, sub_menu_start + 3));
	tinsert(ConfigFrame.subCheckBox, CreateCheckBox(true, "PBarValue", L["power_text"], 1, sub_menu_start + 4));
	tinsert(ConfigFrame.subCheckBox, CreateCheckBox(true, "PBarPercentage", L["power_percent"], 2, sub_menu_start + 4));
	tinsert(ConfigFrame.subSlider, CreateSlider(true, "BarTextAlpha", L["BarTextAlpha"], 0.0, 1.0, 0.05, 1, sub_menu_start + 5));
	tinsert(ConfigFrame.subSlider, CreateSlider(true, "Scale", L["Scale"], 0.5, 2.0, 0.05, 1, sub_menu_start + 6));

	InterfaceOptions_AddCategory(ConfigFrame);
end
