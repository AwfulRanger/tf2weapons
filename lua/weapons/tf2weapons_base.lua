AddCSLuaFile()

AddCSLuaFile( "tf2weapons.lua" )
include( "tf2weapons.lua" )

SWEP.Weight = 5

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true

SWEP.Slot = 0
SWEP.SlotPos = 0

SWEP.BobScale = 1
SWEP.SwayScale = 0
SWEP.BounceWeaponIcon = false
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.Crosshair = Material( "sprites/tf2weapons_crosshairs" )
SWEP.CrosshairType = TF2Weapons.Crosshair.DEFAULT
SWEP.KillIcon = Material( "hud/dneg_images_v2" )
SWEP.KillIconColor = Color( 255, 255, 255, 255 )
SWEP.KillIconX = 0
SWEP.KillIconY = 32
SWEP.KillIconW = 96
SWEP.KillIconH = 32

SWEP.PrintName = "TF2Weapons Base"
SWEP.HUDName = nil
SWEP.Author = "AwfulRanger"
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.Description = ""
SWEP.Category = "Team Fortress 2"
SWEP.Level = 101
SWEP.Type = "Weapon Base"
SWEP.Base = "weapon_base"
SWEP.Classes = { TF2Weapons.Class.NONE }
SWEP.Quality = TF2Weapons.Quality.DEVELOPER

SWEP.Spawnable = false
SWEP.AdminOnly = false

--SWEP.ViewModel = "models/weapons/c_models/c_ttg_max_gun/c_ttg_max_gun.mdl"
SWEP.ViewModel = "models/weapons/c_models/c_pistol/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/c_models/c_pistol/c_pistol.mdl"
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 54
SWEP.UseHands = false
SWEP.HandModel = "models/weapons/c_models/c_scout_arms.mdl"
SWEP.HoldType = "pistol"
function SWEP:GetAnimations()
	
	return "p"
	
end
function SWEP:GetInspect()
	
	return "secondary"
	
end
SWEP.MuzzleParticle = ""
SWEP.MuzzleParticleCrit = nil

SWEP.SkinRED = 0
SWEP.SkinBLU = 1

SWEP.DeployTime = 0.5
SWEP.SingleReload = false
SWEP.Attributes = {}
SWEP.AttributeClass = {}

SWEP.MinDistance = 0 --Distance for maximum damage rampup
SWEP.NormalDistance = 512 --Distance for no damage rampup or falloff
SWEP.MaxDistance = 1024 --Distance for maximum damage falloff

SWEP.DamageRampup = 1.5 --Maximum damage rampup
SWEP.DamageNormal = 1 --No damage rampup or falloff
SWEP.DamageFalloff = 0.5 --Maximum damage falloff

SWEP.Primary.ClipSize = 12
SWEP.Primary.DefaultClip = 48
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "tf2weapons_pistol"
SWEP.Primary.Damage = 15
SWEP.Primary.Shots = 1
SWEP.Primary.Spread = 0.025
SWEP.Primary.SpreadRecovery = 1.25
SWEP.Primary.Force = 10
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.Delay = 0.15

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.CritChance = 0.025
SWEP.CritMultiplier = 3

SWEP.CritStream = false
SWEP.CritStreamCheck = 1 --How often (in seconds) to check for crit streams
SWEP.CritStreamTime = 2 --How long (in seconds) crit streams last

--[[
	Name:	SWEP:SetVariables()
	
	Desc:	If you've got any variables that should be able to have different types, define them here.
			
			For example, SWEP:PlaySound() can take either a string or a table as the first argument, so if you
			want SWEP.ShootSound to be a string in this weapon, but allow it to be a table for weapons using
			this as a base without lua getting upset, define it here.
]]--
function SWEP:SetVariables()
	
	self.ShootSound = Sound( "weapons/pistol_shoot.wav" )
	self.ShootSoundCrit = Sound( "weapons/pistol_shoot_crit.wav" )
	self.EmptySound = Sound( "weapons/shotgun_empty.wav" )
	
end

SWEP.CreatedNetworkVars = {
	
	String = 0,
	Bool = 0,
	Float = 0,
	Int = 0,
	Vector = 0,
	Angle = 0,
	Entity = 0,
	
}

--[[
	Name:	SWEP:TFNetworkVar()
	
	Desc:	Helper function for creating NetworkVars
	
	Arg1:	Variable type
	
	Arg2:	Variable name (this is automatically prefixed with "TF")
	
	Arg3:	Default value. If unspecified, this won't be set
	
	Arg4:	Slot. If unspecified, this will be set to self.CreatedNetworkVars[ vartype ]
	
	Arg5:	Extended settings
	
	Ret1:	NetworkVar value
]]--
function SWEP:TFNetworkVar( vartype, varname, default, slot, extended )
	
	if self.CreatedNetworkVars[ vartype ] == nil then
		
		self.CreatedNetworkVars[ vartype ] = 0
		
	else
		
		self.CreatedNetworkVars[ vartype ] = self.CreatedNetworkVars[ vartype ] + 1
		
	end
	if slot != nil then self.CreatedNetworkVars[ vartype ] = slot end
	slot = self.CreatedNetworkVars[ vartype ]
	
	self:NetworkVar( vartype, slot, "TF" .. varname, extended )
	if default != nil then self[ "SetTF" .. varname ]( self, default ) end
	
	return self[ "GetTF" .. varname ]( self )
	
end

--[[
	Name:	SWEP:BaseDataTables()
	
	Desc:	Creates the default networked variables
	
	Ret1:	A table of unused IDs for each type
]]--
function SWEP:BaseDataTables()
	
	--[[
	self:NetworkVar( "Bool", 0, "TFInspecting" )
	self:NetworkVar( "Bool", 1, "TFInspectLoop" )
	self:NetworkVar( "Bool", 2, "TFPreventInspect" )
	self:NetworkVar( "Bool", 3, "TFReloading" )
	
	self:NetworkVar( "Float", 0, "TFNextInspect" )
	self:NetworkVar( "Float", 1, "TFNextIdle" )
	self:NetworkVar( "Float", 2, "TFPrimaryLastShot" )
	self:NetworkVar( "Float", 3, "TFReloadTime" )
	
	self:NetworkVar( "Int", 0, "TFReloads" )
	self:NetworkVar( "Int", 1, "TFReloadAmmo" )
	
	self:NetworkVar( "Entity", 0, "TFLastOwner" )
	
	self:SetTFInspecting( false )
	self:SetTFInspectLoop( false )
	self:SetTFPreventInspect( false )
	self:SetTFReloading( false )
	
	self:SetTFNextInspect( 0 )
	self:SetTFNextIdle( 0 )
	self:SetTFPrimaryLastShot( 0 )
	self:SetTFReloadTime( 0 )
	
	self:SetTFReloads( 0 )
	self:SetTFReloadAmmo( 0 )
	
	self:SetTFLastOwner( nil )
	
	return {
		
		String = 0,
		Bool = 4,
		Float = 4,
		Int = 2,
		Vector = 0,
		Angle = 0,
		Entity = 1,
		
	}
	]]--
	
	self:TFNetworkVar( "Bool", "Inspecting", false )
	self:TFNetworkVar( "Bool", "InspectLoop", false )
	self:TFNetworkVar( "Bool", "PreventInspect", false )
	self:TFNetworkVar( "Bool", "Reloading", false )
	self:TFNetworkVar( "Bool", "CritStreamActive", false )
	
	self:TFNetworkVar( "Float", "NextInspect", 0 )
	self:TFNetworkVar( "Float", "NextIdle", 0 )
	self:TFNetworkVar( "Float", "PrimaryLastShot", 0 )
	self:TFNetworkVar( "Float", "ReloadTime", 0 )
	self:TFNetworkVar( "Float", "CritStreamEnd", 0 )
	self:TFNetworkVar( "Float", "CritStreamNextCheck", 0 )
	
	self:TFNetworkVar( "Int", "Reloads", 0 )
	self:TFNetworkVar( "Int", "ReloadAmmo", 0 )
	
	self:TFNetworkVar( "Entity", "LastOwner", nil )
	
	return self.CreatedNetworkVars
	
end

--[[
	Name:	SWEP:SetupDataTables()
	
	Desc:	Create your own networked variables here
			Run SWEP:BaseDataTables() here to include the default ones
]]--
function SWEP:SetupDataTables()
	
	self:BaseDataTables()
	
end

--[[
	Name:	SWEP:GetViewModels()
	
	Desc:	Returns hands viewmodel and weapon viewmodel
	
	Ret1:	Hands viewmodel
	
	Ret2:	Weapon viewmodel
]]--
function SWEP:GetViewModels( owner )
	
	if owner == nil then owner = self:GetOwner() end
	if IsValid( owner ) != true then return end
	
	--return owner:GetViewModel( 0 ), owner:GetViewModel( 1 )
	return owner:GetViewModel( 1 ), owner:GetViewModel( 0 )
	
end

--[[
	Name:	SWEP:AttributesMod()
	
	Desc:	Modify the weapon based on attributes
	
	Arg1:	Attributes. If unspecified, will use SWEP.Attributes
	
	Arg2:	Attribute classes. If unspecified, will use SWEP.AttributeClass
]]--
function SWEP:AttributesMod( attributes, attributeclass )
end

--[[
	Name:	SWEP:DoAttributes()
	
	Desc:	Modify the weapon based on attributes
			Run SWEP:AttributesMod() here to include custom weapon modifications
	
	Arg1:	Attributes. If unspecified, will use SWEP.Attributes
	
	Arg2:	Attribute classes. If unspecified, will use SWEP.AttributeClass
]]--
function SWEP:DoAttributes( attributes, attributeclass )
	
	if self.Primary != nil then self.Primary.DefaultClipSize = self.Primary.ClipSize end
	if self.Secondary != nil then self.Secondary.DefaultClipSize = self.Secondary.ClipSize end
	
	if attributes == nil then attributes = self.Attributes end
	if attributes == nil then return end
	if attributeclass == nil then attributeclass = self.AttributeClass end
	
	for _, v in pairs( attributes ) do
		
		local attribute = TF2Weapons.Attributes[ _ ]
		local value
		if attribute != nil and attribute.func != nil then
			
			value = attribute.func( self, v )
			
		end
		
		if attributeclass != nil and value != nil then
			
			local class = { 1 }
			if attributeclass[ attribute.class ] != nil then class = attributeclass[ attribute.class ] end
			
			if attribute.type == "percentage" or attribute.type == "inverted_percentage" then
				
				for i = 1, #class do
					
					class[ i ] = class[ i ] * value[ i ]
					
				end
				
			else
				
				for i = 1, #class do
					
					class[ i ] = value[ i ]
					
				end
				
			end
			
			attributeclass[ attribute.class ] = class
			
		end
		
	end
	
	self:AttributesMod( attributes, attributeclass )
	
end

--[[
	Name:	SWEP:GetTeam()
	
	Desc:	Returns team to use for the weapon based on a color
	
	Arg1:	Player to check. If unspecified, will use the owner
	
	Arg2:	Color to check. If unspecified, will use the player's team color
	
	Ret1:	False if RED team, true if BLU team
]]--
function SWEP:GetTeam( ply, color )
	
	//if true then return true end
	
	if ply == nil then ply = self:GetOwner() end
	
	if color != nil then return color.b > color.r end
	
	if IsValid( ply ) == true then
		
		return team.GetColor( ply:Team() ).b > team.GetColor( ply:Team() ).r
		
	else
		
		return false
		
	end
	
	
end

--[[
	Name:	SWEP:DoTeamSet()
	
	Desc:	Default function to set team related values, like skins, models, particles, etc.
	
	Arg1:	If on BLU team
]]--
function SWEP:DoTeamSet( blu )
	
	local hands, weapon = self:GetViewModels()
	
	local skin
	
	if blu != true then
		
		skin = self.SkinRED
		
	else
		
		skin = self.SkinBLU
		
	end
	
	if IsValid( self:GetOwner() ) == true then
		
		self:SetSkin( skin )
		hands:SetSkin( skin )
		weapon:SetSkin( skin )
		
	end
	
end

--[[
	Name:	SWEP:TeamSet()
	
	Desc:	Basic function to set team related values, like skins, models, particles, etc.
			Run SWEP:DoTeamSet() here to include the default team set
	
	Arg1:	If on BLU team
]]--
function SWEP:TeamSet( blu )
	
	self:DoTeamSet( blu )
	
end

SWEP.BuildBonePositionsAdded = false

--[[
	Name:	SWEP:DoInitialize()
	
	Desc:	Default functions to initialize the weapon
]]--
function SWEP:DoInitialize()
	
	if CLIENT then self:AddKillIcon( self.KillIcon, self.KillIconColor, self.KillIconX, self.KillIconY, self.KillIconW, self.KillIconH ) end
	self:SetHoldType( self.HoldType )
	if self.HUDName == nil then self.HUDName = self.PrintName end
	timer.Simple( 0, function() if IsValid( self ) == true and IsValid( self:GetOwner() ) == true and IsValid( self:GetOwner():GetActiveWeapon() ) == true and self:GetOwner():GetActiveWeapon() == self then self:Deploy() self:AddHands() end end )
	self:SetVariables()
	self:DoAttributes()
	
	if self.BuildBonePositionsAdded != true then
		
		self:AddCallback( "BuildBonePositions", function( ent, count )
			
			self:BuildWorldModelBones( ent, count )
			
		end )
		
		self.BuildBonePositionsAdded = true
		
	end
	
end

--[[
	Name:	SWEP:Initialize()
	
	Desc:	Basic functions to initialize the weapon
			Run SWEP:DoInitialize() here to include the default initialization
]]--
function SWEP:Initialize()
	
	self:DoInitialize()
	
	self:PrecacheParticles( self.MuzzleParticle )
	
end

SWEP.Crosshairs = {
	
	[ TF2Weapons.Crosshair.ALL ] = { 0, 0, 1, 1 },
	[ TF2Weapons.Crosshair.DEFAULT ] = { 0, 0, 0.25, 0.25 },
	[ TF2Weapons.Crosshair.CIRCLE ] = { 0.25, 0.25, 0.5, 0.5 },
	[ TF2Weapons.Crosshair.BIGCIRCLE ] = { 0.5, 0.5, 1, 1 },
	[ TF2Weapons.Crosshair.PLUS ] = { 0.5, 0, 0.75, 0.25 },
	[ TF2Weapons.Crosshair.BIGPLUS ] = { 0, 0.5, 0.25, 0.75 },
	
}

--[[
	Name:	SWEP:DrawMeter()
	
	Desc:	Draws a meter
	
	Arg1:	Percentage of the meter to fill (0 for none, 1 for all)
	
	Arg2:	Display text of the percentage or not
	
	Arg3:	X position to draw at. If unspecified, will use ScrW() * 0.5
	
	Arg4:	Y position to draw at. If unspecified, will use ScrH() * 0.5
	
	Arg5:	Width of the meter. If unspecified, will use ScrW() * 0.05
	
	Arg6:	Height of the meter. If unspecified, will use ScrH() * 0.015
	
	Arg7:	Color of the background. If unspecified, will use 200, 200, 200, 200
	
	Arg8:	Color of the foreground. If unspecified, will use 255, 255, 255, 255
]]--
function SWEP:DrawMeter( percent, text, x, y, w, h, bg, fg )
	
	if percent == nil then percent = 0 end
	if percent < 0 then percent = 0 end
	if percent > 1 then percent = 1 end
	
	local xpos = x or ScrW() * 0.5
	local ypos = y or ScrH() * 0.5
	local wide = w or ScrW() * 0.05
	local tall = h or ScrH() * 0.015
	local back = bg or Color( 200, 200, 200, 200 )
	local fore = fg or Color( 255, 255, 255, 255 )
	
	surface.SetDrawColor( back )
	surface.DrawRect( xpos - wide, ypos + ( tall * 5 ), wide * 2, tall )
	
	surface.SetDrawColor( fore )
	surface.DrawRect( xpos - wide, ypos + ( tall * 5 ), ( wide * 2 ) * percent, tall )
	
end

--[[
	Name:	SWEP:OnDrawCrosshair()
	
	Desc:	Default function for drawing the crosshair
	
	Arg1:	X position to draw crosshair at
	
	Arg2:	Y position to draw crosshair at
]]--
function SWEP:OnDrawCrosshair( x, y )
	
	if self.DrawCrosshair != true then return end
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( self.Crosshair )
	local tw = self.Crosshair:Width()
	local th = self.Crosshair:Height()
	if self.Crosshairs[ self.CrosshairType ] != nil then
		
		local crosshair = self.Crosshairs[ self.CrosshairType ]
		
		local uw = math.max( crosshair[ 1 ], crosshair[ 3 ] ) - math.min( crosshair[ 1 ], crosshair[ 3 ] )
		local uh = math.max( crosshair[ 2 ], crosshair[ 4 ] ) - math.min( crosshair[ 2 ], crosshair[ 4 ] )
		
		local w = tw * uw
		local h = th * uh
		
		surface.DrawTexturedRectUV( x - ( w * 0.5 ), y - ( h * 0.5 ), w, h, crosshair[ 1 ], crosshair[ 2 ], crosshair[ 3 ], crosshair[ 4 ] )
		
	else
		
		surface.DrawTexturedRect( x - size, y - size, size * 2, size * 2 )
		
	end
	
end

--[[
	Name:	SWEP:DoDrawCrosshair()
	
	Desc:	Draw the crosshair
	
	Arg1:	X position to draw crosshair at
	
	Arg2:	Y position to draw crosshair at
	
	Ret1:	Return true to prevent drawing the default crosshair
]]--
function SWEP:DoDrawCrosshair( x, y )
	
	self:OnDrawCrosshair( x, y )
	
	return true
	
end

--[[
	Name:	SWEP:GetAttribute()
	
	Desc:	Returns an attribute value
	
	Arg1:	Attribute ID to get
	
	Arg2:	Attribute slot to get. If unspecified, will use slot 1
	
	Arg3:	If true, returns a percentage based string
	
	Ret1:	Attribute value
]]--
function SWEP:GetAttribute( id, slot, pretty )
	
	local value = -1
	if slot == nil then slot = 1 end
	if self.Attributes[ id ][ slot ] == nil then return value end
	if self.Attributes[ id ] != nil then value = self.Attributes[ id ][ slot ] end
	
	if pretty == true then
		
		local attribute = TF2Weapons.Attributes[ id ]
		if attribute == nil then
			
			return value
			
		elseif attribute.type == "percentage" then
			
			value = tostring( ( self.Attributes[ id ][ slot ] - 1 ) * 100 )
			
		elseif attribute.type == "inverted_percentage" then
			
			value = tostring( ( 1 - self.Attributes[ id ][ slot ] ) * 100 )
			
		else
			
			value = tostring( self.Attributes[ id ][ slot ] )
			
		end
		
	end
	
	return value
	
end

--[[
	Name:	SWEP:Markup()
	
	Desc:	Returns text for markup
	
	Arg1:	Text to change
	
	Arg2:	Color value. If specified, will color Arg1
	
	Arg3:	Font name. If specified, will change Arg1 font
]]--
function SWEP:Markup( text, color, font )
	
	if text == nil then text = "" end
	if color != nil then text = "<color=" .. color.r .. "," .. color.g .. "," .. color.b .. "," .. color.a .. ">" .. text .. "</color>" end
	if font != nil then text = "<font=" .. font .. ">" .. text .. "</font>" end
	
	return text
	
end

--[[
	Name:	SWEP:PrintWeaponInfo()
	
	Desc:	Draw the weapon info that appears when selecting this weapon through default weapon selection
	
	Arg1:	X position to draw info at
	
	Arg2:	Y position to draw info at
	
	Arg3:	Alpha color value
]]--
function SWEP:PrintWeaponInfo( x, y, a )
	
	if self.DrawWeaponInfoBox == false then return end
	
	local name = self.HUDName
	local prefix = TF2Weapons.QualityPrefix[ self.Quality ]
	if prefix != nil and prefix != "" then name = prefix .. " " .. name end
	
	local markuptable = {
		
		self:Markup( name, TF2Weapons.QualityColor[ self.Quality ], "TF2Weapons_InfoPrimary" ),
		self:Markup( "Level " .. self.Level .. " " .. self.Type, TF2Weapons.Color.LEVEL, "TF2Weapons_InfoSecondary" ),
		
	}
	
	local text = ""
	
	for i = 1, #markuptable do
		
		text = text .. "\n" .. markuptable[ i ]
		
	end
	
	for _, v in pairs( self.Attributes ) do
		
		if isnumber( _ ) == true then
			
			local attribute = self:Markup( TF2Weapons.Attributes[ _ ].desc, TF2Weapons.Attributes[ _ ].color, "TF2Weapons_InfoSecondary" )
			attribute = string.Replace( attribute, "%s1", self:GetAttribute( _, 1, true ) )
			attribute = string.Replace( attribute, "%s2", self:GetAttribute( _, 2, true ) )
			
			text = text .. "\n" .. attribute
			
		end
		
	end
	
	if self.Description != nil and self.Description != "" then text = text .. "\n\n" .. self:Markup( self.Description, TF2Weapons.Color.NEUTRAL, "TF2Weapons_InfoSecondary" ) end
	
	local parsed = markup.Parse( text, ScrW() )
	
	surface.SetDrawColor( 60, 54, 47, 255 )
	surface.DrawRect( x, y, parsed:GetWidth() + ( 20 * ( ScrH() / 480 ) ), parsed:GetHeight() + ( 20 * ( ScrH() / 480 ) ) )
	
	parsed:Draw( x + ( 10 * ( ScrH() / 480 ) ), y + ( 10 * ( ScrH() / 480 ) ), nil, nil, 255 )
	
end

--[[
	Name:	SWEP:AddKillIcon()
	
	Desc:	Add a UV kill icon to the weapon
	
	Arg1:	Material with the kill icon
	
	Arg2:	Color for the kill icon
	
	Arg3:	X position of the material to use for kill icon
	
	Arg4:	Y position of the material to use for kill icon
	
	Arg5:	Width of the UV
	
	Arg6:	Height of the UV
]]--
function SWEP:AddKillIcon( icon, color, x, y, w, h )
	
	if killicon.AddUV == nil then return end
	
	local tw, th = surface.GetTextureSize( surface.GetTextureID( icon:GetName() ) )
	
	x = x / tw
	y = y / th
	w = x + ( w / tw )
	h = y + ( h / th )
	
	killicon.AddUV( self.ClassName, icon, color, x, y, w, h )
	
end

--[[
	Name:	SWEP:GetHandAnim()
	
	Desc:	Returns a sequence name based on the weapon animations and a keyword
	
	Arg1:	Keyword to look for
	
	Ret1:	Sequence name
]]--
function SWEP:GetHandAnim( key )
	
	math.randomseed( CurTime() )
	
	local anim
	
	local key_ = key
	
	if key == "swing" then
		
		local rand = math.random( 0, 1 )
		
		if rand == 0 then
			
			key_ = "swing_a"
			
		else
			
			key_ = "swing_b"
			
		end
		
	elseif key == "crit" then
		
		key_ = "swing_c"
		
	end
	
	if istable( self:GetAnimations() ) == true then
		
		if istable( self:GetAnimations()[ key ] ) == true then
			
			anim = self:GetAnimations()[ key ][ math.random( 1, #self:GetAnimations()[ key ] ) ]
			
		else
			
			anim = self:GetAnimations()[ key ]
			
		end
		
	elseif self:GetAnimations() == "" or self:GetAnimations() == nil then
		
		anim = key_
		
	else
		
		anim = self:GetAnimations() .. "_" .. key_
		
	end
	
	return anim
	
end

--[[
	Name:	SWEP:GetInspectAnim()
	
	Desc:	Returns a sequence name based on the inspect animations and a keyword
	
	Arg1:	Keyword to look for
	
	Ret1:	Sequence name
]]--
function SWEP:GetInspectAnim( key )
	
	local anim
	
	if istable( self:GetInspect() ) == true then
		
		if istable( self:GetInspect()[ key ] ) == true then
			
			anim = self:GetInspect()[ key ][ math.random( 1, #self:GetAnimations()[ key ] ) ]
			
		else
			
			anim = self:GetInspect()[ key ]
			
		end
		
	elseif self:GetInspect() == "" or self:GetInspect() == nil then
		
		anim = key
		
	else
		
		anim = self:GetInspect() .. "_" .. key
		
	end
	
	return anim
	
end

SWEP.DefaultRate = 1

--[[
	Name:	SWEP:SetVMAnimation()
	
	Desc:	Sets the animation of the viewmodel hands
	
	Arg1:	Sequence name
	
	Arg2:	Playback rate
]]--
function SWEP:SetVMAnimation( seq, rate )
	
	if IsValid( self:GetOwner() ) == false then return end
	
	local hands, weapon = self:GetViewModels()
	
	local id, dur
	
	if IsValid( hands ) == true then
		
		id, dur = hands:LookupSequence( seq )
		if id == -1 or dur == 0 then return id, dur end
		if rate == nil then rate = self.DefaultRate end
		
		dur = dur / rate
		self:SetTFNextIdle( CurTime() + dur )
		hands:SendViewModelMatchingSequence( id )
		hands:SetPlaybackRate( rate )
		
	end
	
	return id, dur
	
end

--[[
	Name:	SWEP:GetVMAnimation()
	
	Desc:	Returns the index of the hands' active sequence
	
	Ret1:	Sequence index
]]--
function SWEP:GetVMAnimation()
	
	if IsValid( self:GetOwner() ) == false then return -1 end
	
	local hands, weapon = self:GetViewModels()
	
	return hands:GetSequence()
	
end

--[[
	Name:	SWEP:AddHands()
	
	Desc:	Creates and initializes weapon and hands viewmodels
	
	Arg1:	Player to create viewmodels for, will use owner if this is unspecified
]]--
function SWEP:AddHands( owner )
	
	if owner == nil then owner = self:GetOwner() end
	if IsValid( owner ) == false then return end
	
	local hands, weapon = self:GetViewModels( owner )
	
	if IsValid( hands ) == true and self.HandModel != nil and self.HandModel != "" then
		
		hands:SetWeaponModel( self.HandModel, self )
		
		hands:SetNoDraw( false )
		
	end
	
	if IsValid( weapon ) == true and self.ViewModel != nil and self.ViewModel != "" then
		
		weapon:SetWeaponModel( self.ViewModel, self )
		if IsValid( hands ) == true and self.HandModel != nil and self.HandModel != "" then
			
			weapon:SetParent( hands )
			weapon:AddEffects( EF_BONEMERGE )
			
		end
		
		weapon:SetNoDraw( false )
		
	end
	
end

--[[
	Name:	SWEP:RemoveHands()
	
	Desc:	Removes weapon and hands viewmodels
	
	Arg1:	Player to remove viewmodels for. If this is unspecified, this will be the owner
]]--
function SWEP:RemoveHands( owner )
	
	if owner == nil then owner = self:GetOwner() end
	if IsValid( owner ) == false then return end
	
	local hands, weapon = self:GetViewModels( owner )
	
	if IsValid( hands ) == true then
		
		hands:SetWeaponModel( self.HandModel, nil )
		
	end
	
	if IsValid( weapon ) == true then
		
		weapon:SetParent( nil )
		weapon:RemoveEffects( EF_BONEMERGE )
		weapon:SetWeaponModel( self.ViewModel, nil )
		
	end
	
end

--[[
	Name:	SWEP:CheckHands()
	
	Desc:	Checks if viewmodels are not properly set up and if not, fixes them
]]--
function SWEP:CheckHands( owner )
	
	if owner == nil then owner = self:GetOwner() end
	if IsValid( owner ) == false then return end
	
	local hands, weapon = self:GetViewModels( owner )
	
	if IsValid( weapon ) == false or IsValid( hands ) == false or weapon:GetParent() != hands or weapon:IsEffectActive( EF_BONEMERGE ) == false or hands:GetModel() != self.HandModel or weapon:GetModel() != self.ViewModel then
		
		self:AddHands()
		
	end
	
end

--[[
	Name:	SWEP:PlaySound()
	
	Desc:	Plays a sound from the weapon
	
	Arg1:	Sound to play, can be either a string or a table
	
	Arg2:	If Arg1 is a table, this is the index of the table to play. If unspecified, this will be a random
			number from the table.
	
	Arg3:	Entity to play the sound from. If unspecified, this will be self
	
	Ret1:	Sound name
	
	Ret2:	Sound duration
]]--
function SWEP:PlaySound( sound, num, ent )
	
	if sound == nil then return end
	local _sound
	
	if istable( sound ) == true then
		
		if num == nil then num = math.random( #sound ) end
		_sound = sound[ num ]
		
	else
		
		_sound = sound
		
	end
	
	local dur = SoundDuration( _sound )
	if SERVER then dur = dur * 0.5 end --SoundDuration returns double the actual value on the server for some reason
	
	if ent == nil then ent = self end
	
	ent:EmitSound( _sound )
	return _sound, dur
	
end

--[[
	Name:	SWEP:PrecacheParticles()
	
	Desc:	Precaches particles
	
	Arg1:	Particles to precache, can be either a string or a table
]]--
function SWEP:PrecacheParticles( particles )
	
	if istable( particles ) == true then
		
		for _, v in pairs( particles ) do
			
			if isstring( v ) == true then PrecacheParticleSystem( v ) end
			
		end
		
	else
		
		PrecacheParticleSystem( particles )
		
	end
	
end

SWEP.CreatedParticles = {}

--[[
	Name:	SWEP:AddParticle()
	
	Desc:	Attaches particles to the weapon
	
	Arg1:	Particle to attach to the weapon
	
	Arg2:	Attachment to parent the particle to
	
	Arg3:	Entity to attach the particle to. If unspecified, this will be the weapon
	
	Arg4:	PATTACH enum to use for the particle
	
	Arg5:	Table containing tables with control point options. Example:
			{
				
				--Control point 0
				{
					
					ent = self,
					pattach = PATTACH_POINT_FOLLOW,
					attach = 0,
					offset = Vector( 0, 0, 0 ),
					
				},
				
				--Create more tables in here for each control point
				
			}
			
]]--
function SWEP:AddParticle( particle, attachment, ent, pattach, options )
	
	if particle == nil or particle == "" then return end
	if ent == nil then ent = self end
	
	if ent:LookupAttachment( attachment ) != nil then
		
		if pattach == nil then pattach = PATTACH_POINT_FOLLOW end
		attachment = ent:LookupAttachment( attachment )
		
	else
		
		if pattach == nil then pattach = PATTACH_ABSORIGIN_FOLLOW end
		attachment = -1
		
	end
	
	if options != nil then
		
		if SERVER then
			
			net.Start( "tf2weapons_addparticle" )
				
				net.WriteEntity( self )
				net.WriteEntity( ent )
				net.WriteString( particle )
				net.WriteInt( attachment, 32 )
				net.WriteInt( pattach, 32 )
				
				net.WriteInt( #options, 32 )
				if #options > 0 then
					
					for i = 1, #options do
						
						net.WriteType( options[ i ].entity )
						net.WriteType( options[ i ].attachtype )
						net.WriteType( options[ i ].attachment )
						net.WriteType( options[ i ].position )
						
					end
					
				end
				
			net.Broadcast()
			
		else
			
			local hands, weapon = self:GetViewModels()
			
			local newparticle = ent:CreateParticleEffect( particle, attachment )
			
			if IsValid( newparticle ) == true and istable( options ) == true then
				
				for i = 0, #options - 1 do
					
					local option = options[ i + 1 ]
					
					newparticle:AddControlPoint( i, option.entity, option.attachtype, option.attachment, option.position )
					
				end
				
			end
			
		end
		
	else
		
		if self:LookupAttachment( attachment ) != nil then
			
			ParticleEffectAttach( particle, pattach, ent, attachment )
			
		else
			
			ParticleEffectAttach( particle, pattach, ent, -1 )
			
		end
		
	end
	
	--[[
	if particle == nil or particle == "" then return end
	if ent == nil then ent = self end
	
	local pattach = options
	
	if pattach == nil then
		
		if self:LookupAttachment( attachment ) != nil then
			
			ParticleEffectAttach( particle, PATTACH_POINT_FOLLOW, ent, ent:LookupAttachment( attachment ) )
			
		else
			
			ParticleEffectAttach( particle, PATTACH_ABSORIGIN_FOLLOW, ent, -1 )
			
		end
		
	else
		
		if self:LookupAttachment( attachment ) != nil then
			
			ParticleEffectAttach( particle, pattach, ent, ent:LookupAttachment( attachment ) )
			
		else
			
			ParticleEffectAttach( particle, pattach, ent, -1 )
			
		end
		
	end
	]]--
	
end

--[[
	Name:	SWEP:Inspect()
	
	Desc:	Weapon inspection
]]--
function SWEP:Inspect()
	
	if self:GetTFPreventInspect() == true or IsValid( self:GetOwner() ) == false or self:GetInspect() == nil or self:GetInspect() == "" then return end
	
	local hands, weapon = self:GetViewModels()
	
	if self:GetOwner().TF2Weapons_Inspecting == nil then
		
		self:GetOwner().TF2Weapons_Inspecting = false
		
	elseif self:GetOwner().TF2Weapons_Inspecting == true or hands:GetSequence() == hands:LookupSequence( self:GetInspectAnim( "inspect_start" ) ) then
		
		self:SetTFReloading( false )
		
		if CurTime() > self:GetTFNextInspect() then
			
			self:SetTFInspecting( true )
			
			if self:GetTFInspectLoop() == true then
				
				self:SetVMAnimation( self:GetInspectAnim( "inspect_idle" ) )
				self:SetTFNextInspect( CurTime() + hands:SequenceDuration( self:GetInspectAnim( "inspect_idle" ) ) )
				
				self:SetTFNextIdle( -1 )
				
			elseif self:GetTFInspectLoop() != true then
				
				self:SetVMAnimation( self:GetInspectAnim( "inspect_start" ) )
				self:SetTFNextInspect( CurTime() + hands:SequenceDuration( self:GetInspectAnim( "inspect_start" ) ) )
				
				self:SetTFInspectLoop( true )
				
				self:SetTFNextIdle( -1 )
				
			end
			
		end
		
	elseif self:GetTFInspecting() == true and hands:GetSequence() != hands:LookupSequence( self:GetInspectAnim( "inspect_start" ) ) then
		
		self:SetVMAnimation( self:GetInspectAnim( "inspect_end" ) )
		self:SetTFNextInspect( CurTime() + hands:SequenceDuration( self:GetInspectAnim( "inspect_end" ) ) )
		self:SetTFInspecting( false )
		self:SetTFInspectLoop( false )
		self:SetTFReloading( false )
		
	end
	
end

--[[
	Name:	SWEP:Idle()
	
	Desc:	Weapon idle
]]--
function SWEP:Idle()
	
	if game.SinglePlayer() == false and self:GetTFNextIdle() != -1 and CurTime() > self:GetTFNextIdle() then
		
		local hands, weapon = self:GetViewModels()
		
		local idle = self:GetHandAnim( "idle" )
		
		hands:SetSequence( idle )
		hands:SetPlaybackRate( self.DefaultRate )
		
		self:SetTFNextIdle( CurTime() + hands:SequenceDuration( idle ) )
		
	end
	
end

--[[
	Name:	SWEP:HandleCritStreams()
	
	Desc:	Handle crit streams
]]--
function SWEP:HandleCritStreams()
	
	if self.CritStream != true then return end
	
	if CurTime() > self:GetTFCritStreamNextCheck() then
		
		if self:ShouldCrit( nil, true ) == true then
			
			self:SetTFCritStreamActive( true )
			self:SetTFCritStreamEnd( CurTime() + self.CritStreamTime )
			
		end
		
		self:SetTFCritStreamNextCheck( CurTime() + self.CritStreamCheck )
		
	end
	
	if self:GetTFCritStreamActive() == true and CurTime() > self:GetTFCritStreamEnd() then
		
		self:SetTFCritStreamActive( false )
		self:SetTFCritStreamEnd( 0 )
		
	end
	
end

--[[
	Name:	SWEP:Think()
	
	Desc:	Ran each tick/frame
]]--
function SWEP:Think()
	
	if IsValid( self:GetOwner() ) == false then return end
	
	self:SetTFLastOwner( self:GetOwner() )
	
	self:CheckHands()
	
	self:DoReload()
	
	self:Idle()
	
	self:HandleCritStreams()
	
	self:Inspect()
	
end

SWEP.ReloadSpeed = 1
SWEP.ReloadAddAmmo = 1
SWEP.ReloadTakeAmmo = 1

--[[
	Name:	SWEP:DoReload()
	
	Desc:	Weapon reloading
]]--
function SWEP:DoReload()
	
	local hands, weapon = self:GetViewModels()
	
	if self:GetTFReloading() == true then
		
		local reload_end = self:GetHandAnim( "reload_end" )
		
		self:SetTFPreventInspect( true )
		self:SetTFInspecting( false )
		self:SetTFInspectLoop( false )
		
		if CurTime() > self:GetTFReloadTime() then
			
			if ( self:GetNextPrimaryFire() > CurTime() and self:Clip1() > 0 ) or self:Clip1() >= self:GetMaxClip1() or self:Ammo1() <= 0 then
				
				self:SetTFPreventInspect( false )
				self:SetTFReloading( false )
				if self.SingleReload == true then self:SetVMAnimation( reload_end, self.ReloadSpeed ) end
				
				return
				
			end
			
			if self.SingleReload == true then
				
				local reload_start = self:GetHandAnim( "reload_start" )
				
				if self:GetTFReloads() != 0 then
					
					self:GetOwner():RemoveAmmo( self.ReloadTakeAmmo, self:GetPrimaryAmmoType() )
					self:SetClip1( self:Clip1() + self.ReloadAddAmmo )
					
				end
				
				local reload_loop = self:GetHandAnim( "reload_loop" )
				
				if self:GetTFReloads() >= self:GetMaxClip1() - self:GetTFReloadAmmo() then
					
					self:SetTFPreventInspect( false )
					self:SetTFReloading( false )
					self:SetVMAnimation( reload_end, self.ReloadSpeed )
					
				elseif self:Ammo1() <= 0 then
					
					self:SetTFPreventInspect( false )
					self:SetTFReloading( false )
					if self.SingleReload == true then self:SetVMAnimation( reload_end, self.ReloadSpeed ) end
					
					return
					
				else
					
					self:GetOwner():SetAnimation( PLAYER_RELOAD )
					local id, dur = self:SetVMAnimation( reload_loop, self.ReloadSpeed )
					self:SetTFReloadTime( CurTime() + dur )
					
				end
				
				self:SetTFReloads( self:GetTFReloads() + self.ReloadAddAmmo )
				
			else
				
				local removeammo = ( self:GetMaxClip1() - self:Clip1() ) * self.ReloadTakeAmmo
				if self:Clip1() + self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() ) < self:GetMaxClip1() then
					
					self:SetClip1( self:Clip1() + self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() ) )
					
				else
					
					self:SetClip1( self:GetMaxClip1() )
					
				end
				self:GetOwner():RemoveAmmo( removeammo, self:GetPrimaryAmmoType() )
				
			end
			
		end
		
	elseif CurTime() > self:GetNextPrimaryFire() and self.Primary.ClipSize > 0 and self:Clip1() <= 0 then
		
		self:Reload()
		
	end
	
end

--[[
	Name:	SWEP:DoDeploy()
	
	Desc:	Default weapon deploy
]]--
function SWEP:DoDeploy()
	
	if IsValid( self:GetOwner() ) == false then return end
	
	self:SetTFLastOwner( self:GetOwner() )
	
	if self:GetOwner():HasWeapon( "tf_weapon_robot_arm" ) == true and self.HandModel == "models/weapons/c_models/c_engineer_arms.mdl" then
		
		self.HandModel = "models/weapons/c_models/c_engineer_gunslinger.mdl"
		
	elseif self:GetOwner():HasWeapon( "tf_weapon_robot_arm" ) != true and self.HandModel == "models/weapons/c_models/c_engineer_gunslinger.mdl" then
		
		self.HandModel = "models/weapons/c_models/c_engineer_arms.mdl"
		
	end
	
	self:CheckHands()
	
	if CurTime() > self:GetNextPrimaryFire() - self.DeployTime then self:SetNextPrimaryFire( CurTime() + self.DeployTime ) end
	if CurTime() > self:GetNextSecondaryFire() - self.DeployTime then self:SetNextSecondaryFire( CurTime() + self.DeployTime ) end
	
	local draw = self:GetHandAnim( "draw" )
	
	self:SetVMAnimation( draw, 0.67 / self.DeployTime )
	
	self:TeamSet( self:GetTeam() )
	
end

--[[
	Name:	SWEP:Deploy()
	
	Desc:	Called when the weapon attempts to deploy
			Run SWEP:DoDeploy() here to include the default deploy
	
	Ret1:	Return true to allow switching to this weapon using the lastinv console command
]]--
function SWEP:Deploy()
	
	if IsValid( self:GetOwner() ) == false then return end
	
	self:DoDeploy()
	
	return true
	
end

--[[
	Name:	SWEP:DoHolster()
	
	Desc:	Default weapon holster
]]--
function SWEP:DoHolster()
	
	self:RemoveHands()
	self:SetTFReloading( false )
	self:SetTFInspecting( false )
	self:SetTFInspectLoop( false )
	self:SetTFPreventInspect( false )
	
end

--[[
	Name:	SWEP:Holster()
	
	Desc:	Called when the weapon attempts to holster
			Run SWEP:DoHolster() here to include the default holster
	
	Ret1:	Return true to allow the weapon to holster
]]--
function SWEP:Holster()
	
	self:DoHolster()
	
	return true
	
end

--[[
	Name:	SWEP:OnDrop()
	
	Desc:	Called when the weapon is dropped
]]--
function SWEP:OnDrop()
	
	self:Holster()
	self:RemoveHands( self.LastOwner )
	
end

--[[
	Name:	SWEP:OnRemove()
	
	Desc:	Called when the weapon is removed
]]--
function SWEP:OnRemove()
	
	self:Holster()
	self:RemoveHands( self.LastOwner )
	
end

--[[
	Name:	SWEP:OwnerChanged()
	
	Desc:	Called when weapon is dropped or picked up
]]--
function SWEP:OwnerChanged()
	
	self:Holster()
	self:RemoveHands( self.LastOwner )
	
end

--[[
	Name:	SWEP:CanPrimaryAttack()
	
	Desc:	Returns if the weapon can primary attack or not
	
	Ret1:	True if the weapon can primary attack, false otherwise
]]--
function SWEP:CanPrimaryAttack()
	
	if self.Primary.ClipSize >= 0 and self:Clip1() <= 0 then
		
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		self:Reload()
		return false
		
	elseif self.Primary.ClipSize < 0 and self:Ammo1() <= 0 then
		
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		self:PlaySound( self.EmptySound )
		return false
		
	elseif CurTime() < self:GetNextPrimaryFire() then
		
		return false
		
	end
	
	return true
	
end

--[[
	Name:	SWEP:CanSecondaryAttack()
	
	Desc:	Returns if the weapon can secondary attack or not
	
	Ret1:	True if the weapon can secondary attack, false otherwise
]]--
function SWEP:CanSecondaryAttack()
	
	if self.Secondary.ClipSize >= 0 and self:Clip2() <= 0 then
		
		self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
		self:Reload()
		return false
		
	elseif self.Secondary.ClipSize < 0 and self:Ammo2() <= 0 then
		
		self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
		self:PlaySound( self.EmptySound )
		return false
		
	elseif CurTime() < self:GetNextSecondaryFire() then
		
		return false
		
	end
	
	return true
	
end

SWEP.HitDecals = {
	
	[ MAT_ALIENFLESH ] = "impact.antlion",
	[ MAT_ANTLION ] = "impact.antlion",
	[ MAT_FLESH ] = "impact.flesh",
	[ MAT_GLASS ] = "impact.glass",
	[ MAT_SAND ] = "impact.sand",
	[ MAT_WOOD ] = "impact.wood",
	
}

--[[
	Name:	SWEP:DoPrimaryAttack()
	
	Desc:	Effects for primary attacking
	
	Arg1:	Fires as a bullet if specified
	
	Arg2:	Force crit effects
]]--
function SWEP:DoPrimaryAttack( bullet, crit )
	
	self:SetTFReloading( false )
	self:SetTFInspecting( false )
	self:SetTFInspectLoop( false )
	self:SetTFPreventInspect( false )
	
	self:SetTFPrimaryLastShot( CurTime() )
	
	local crit = self:DoCrit()
		
	if bullet != nil then self:GetOwner():FireBullets( bullet ) end
	
	local fire = self:GetHandAnim( "fire" )
	self:SetVMAnimation( fire )
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
	
	local muzzle = self.MuzzleParticle
	if crit == true and self.MuzzleParticleCrit != nil then muzzle = self.MuzzleParticleCrit end
	
	if self.ViewModelParticles == true then
		
		local hands, weapon = self:GetViewModels()
		self:AddParticle( muzzle, "muzzle", weapon )
		
	else
		
		self:AddParticle( muzzle, "muzzle" )
		
	end
	
	local sound = self.ShootSound
	if crit == true and self.ShootSoundCrit != nil then sound = self.ShootSoundCrit end
	
	self:PlaySound( sound )
	
	self:TakePrimaryAmmo( self.Primary.TakeAmmo )
	
end

SWEP.BulletCallbacks = {}

--[[
	Name:	SWEP:PrimaryAttack()
	
	Desc:	Called when the owner runs the +attack console command
			Run SWEP:DoPrimaryAttack() here to include the default primary attack effects
]]--
function SWEP:PrimaryAttack()
	
	if self:CanPrimaryAttack() == false then return end
	
	local crit = self:DoCrit()
	
	local spread = self.Primary.Spread
	if self.Primary.SpreadRecovery != nil and self.Primary.SpreadRecovery != -1 and CurTime() - self.Primary.SpreadRecovery > self:GetTFPrimaryLastShot() then spread = 0 end
	
	local bullet = {}
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Tracer = 0
	bullet.AmmoType = self.Primary.Ammo
	bullet.Damage = self.Primary.Damage
	bullet.Num = self.Primary.Shots
	bullet.Spread = Vector( spread, spread )
	bullet.Force = self.Primary.Force
	bullet.Callback = function( attacker, tr, dmg )
		
		for i = 1, #self.BulletCallbacks do
			
			self.BulletCallback[ i ]( attacker, tr, dmg )
			
		end
		
		if SERVER and dmg != nil and IsValid( tr.Entity ) == true then
			
			local modifier = self.DamageNormal
			
			if IsValid( attacker ) == true then
				
				local distance = attacker:GetPos():Distance( tr.HitPos )
				
				if distance < self.NormalDistance then
					
					if distance < self.MinDistance then distance = self.MinDistance end
					
				else
					
					if distance > self.MaxDistance then distance = self.MaxDistance end
					
				end
				
				modifier = ( distance / self.MaxDistance ) - ( self.DamageRampup - self.DamageNormal )
				
			end
			
			dmg:SetDamage( self:GetDamageMods( dmg:GetDamage(), math.ceil( dmg:GetDamage() - ( dmg:GetDamage() * modifier ) ) ) )
			
			tr.Entity:TakeDamageInfo( dmg )
			dmg:SetAttacker( game.GetWorld() )
			dmg:SetInflictor( game.GetWorld() )
			dmg:SetDamage( 0 )
			
		end
		
	end
	
	self:DoPrimaryAttack( bullet, crit )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
end

--[[
	Name:	SWEP:SecondaryAttack()
	
	Desc:	Called when the owner runs the +attack2 console command
]]--
function SWEP:SecondaryAttack()
end

--[[
	Name:	SWEP:Reload()
	
	Desc:	Called when the owner runs the +reload console command
]]--
function SWEP:Reload()
	
	if self.SingleReload == true then
		
		if self:GetTFReloading() == true or ( self:GetNextPrimaryFire() > CurTime() and self:Clip1() > 0 ) or self:Clip1() >= self:GetMaxClip1() or self:Ammo1() <= 0 then return end
		
		local reload_start = self:GetHandAnim( "reload_start" )
		
		self:SetTFReloads( 0 )
		self:SetTFReloadAmmo( self:Clip1() )
		local id, dur = self:SetVMAnimation( reload_start, self.ReloadSpeed )
		self:SetTFReloadTime( CurTime() + dur )
		self:SetTFReloading( true )
		self:SetTFInspecting( false )
		self:SetTFInspectLoop( false )
		
	else
		
		if self:GetTFReloading() == true or ( self:GetNextPrimaryFire() > CurTime() and self:Clip1() > 0 ) or self:Clip1() >= self:GetMaxClip1() or self:Ammo1() <= 0 then return end
		
		local reload = self:GetHandAnim( "reload" )
		
		local id, dur = self:SetVMAnimation( reload, self.ReloadSpeed )
		self:GetOwner():SetAnimation( PLAYER_RELOAD )
		self:SetTFReloadTime( CurTime() + dur )
		self:SetTFReloading( true )
		self:SetTFInspecting( false )
		self:SetTFInspectLoop( false )
		
	end
	
end

--[[
	Name:	SWEP:PreDrawViewModel()
	
	Desc:	Called before the viewmodel is drawn
	
	Arg1:	Viewmodel
	
	Arg2:	Weapon
	
	Arg3:	Viewmodel owner
]]--
function SWEP:PreDrawViewModel( vm, weapon, ply )
	
	if weapon.CheckHands != nil then weapon:CheckHands() end
	
end

--[[
	Name:	SWEP:DoBuildWorldModelBones()
	
	Desc:	Default function for building worldmodel bones
	
	Arg1:	Entity building bones
	
	Arg2:	Number of bones
]]--
function SWEP:DoBuildWorldModelBones( ent, count )
	
	--try to make normal playermodels hold it properly
	if IsValid( self:GetOwner() ) == true and self:GetOwner():LookupBone( "weapon_bone" ) == nil then
		
		local weaponbone = self:LookupBone( "weapon_bone" )
		local rhandbone = self:GetOwner():LookupBone( "valvebiped.bip01_r_hand" )
		
		if weaponbone == nil or rhandbone == nil then return end
		
		local pos, ang = self:GetOwner():GetBonePosition( rhandbone )
		
		if self:GetOwner():LookupAttachment( "anim_attachment_rh" ) != 0 then pos = self:GetOwner():GetAttachment( self:GetOwner():LookupAttachment( "anim_attachment_rh" ) ).Pos end
		
		ang:RotateAroundAxis( ang:Right(), -90 )
		ang:RotateAroundAxis( ang:Up(), -90 )
		
		local wpos, wang = self:GetBonePosition( weaponbone )
		
		for i = 0, self:GetBoneCount() - 1 do
			
			if i != weaponbone and string.lower( self:GetBoneName( i ) ) != "__invalidbone__" then
				
				local cpos, cang = self:GetBonePosition( i )
				
				local localpos, localang = WorldToLocal( cpos, cang, wpos, wang )
				local childpos, childang = LocalToWorld( localpos, localang, pos, ang )
				
				self:SetBonePosition( i, childpos, childang )
				
			end
			
		end
		
		self:SetBonePosition( weaponbone, pos, ang )
		
	end
	
end

--[[
	Name:	SWEP:BuildWorldModelBones()
	
	Desc:	Called when building worldmodel bones
			Run SWEP:DoBuildWorldModelBones() here to include the default worldmodel bones
	
	Arg1:	Entity building bones
	
	Arg2:	Number of bones
]]--
function SWEP:BuildWorldModelBones( ent, count )
	
	self:DoBuildWorldModelBones( ent, count )
	
end

--[[
	Name:	SWEP:GetCritChance()
	
	Desc:	Returns crit chance
	
	Ret1:	Crit chance
]]--
function SWEP:GetCritChance()
	
	return TF2Weapons:GetCritChance( self:GetOwner(), self )
	
end

--[[
	Name:	SWEP:ShouldCrit()
	
	Desc:	Returns if the weapon should crit or not
	
	Arg1:	Crit chance. If unspecified, will use SWEP:GetCritChance()
	
	Arg2:	If this is being called to check if a stream should activate
	
	Ret1:	If the weapon should crit or not
]]--
function SWEP:ShouldCrit( chance, stream )
	
	if GetConVar( "tf2weapons_criticals" ):GetBool() != true then return false end
	
	if self.CritStream == true and stream != true then
		
		return self:GetTFCritStreamActive()
		
	end
	
	if chance == nil then chance = self:GetCritChance() end
	
	return TF2Weapons:ShouldCrit( self:GetOwner(), self, chance )
	
end

--[[
	Name:	SWEP:OnCrit()
	
	Desc:	Runs when the weapon crits
	
	Ret1:	Return false to prevent the crit
]]--
function SWEP:OnCrit()
	
	return TF2Weapons:OnCrit( self:GetOwner(), self )
	
end

function SWEP:DoCrit()
	
	local crit = self:ShouldCrit()
	if crit == true then
		
		local oncrit = self:OnCrit()
		if oncrit == true then crit = oncrit end
		
	end
	
	return crit
	
end

--[[
	Name:	SWEP:GetDamageMods()
	
	Desc:	Returns damage amount with crits and other damage modifiers in effect
	
	Arg1:	Base damage. If unspecified, will use SWEP.Primary.Damage
	
	Arg2:	Damage to return if not modified here
	
	Ret1:	Modified damage
]]--
function SWEP:GetDamageMods( damage, mod )
	
	if damage == nil then damage = self.Primary.Damage end
	
	if self:ShouldCrit() == true then
		
		damage = damage * self.CritMultiplier
		
	elseif mod != nil then
		
		damage = mod
		
	end
	
	return damage
	
end

SWEP.ViewModelParticles = false

--[[
	Name:	SWEP:ViewModelDrawn()
	
	Desc:	Called after the viewmodel is drawn
	
	Arg1:	Viewmodel entity
]]--
function SWEP:ViewModelDrawn( vm )
	
	self.ViewModelParticles = true
	
end

--[[
	Name:	SWEP:DrawWorldModel()
	
	Desc:	Called to draw the worldmodel
]]--
function SWEP:DrawWorldModel()
	
	self:DrawModel()
	
	self.ViewModelParticles = false
	
end