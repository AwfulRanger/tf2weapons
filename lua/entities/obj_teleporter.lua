AddCSLuaFile()

if CLIENT then
	
	game.AddParticles( "particles/teleport_status.pcf" )
	
end

CreateConVar( "tf2weapons_teleporter_teammates", 0, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED }, "0 to allow teleporter to teleport teammates and prevent it from teleporting enemies, 1 for inverted" )

ENT.Base = "obj_base"
ENT.Type = "anim"
ENT.PrintName = "Teleporter"
ENT.Category = "Team Fortress 2"
ENT.Author = "AwfulRanger"
ENT.Spawnable = false
ENT.AdminOnly = false

ENT.BuildMins = Vector( -24, -24, 0 )
ENT.BuildMaxs = Vector( 24, 24, 12 )

ENT.ExplodeSound = Sound( "weapons/teleporter_explode.wav" )

ENT.TeleportNonPlayers = false
ENT.SendSound = Sound( "weapons/teleporter_send.wav" )
ENT.ReceiveSound = Sound( "weapons/teleporter_receive.wav" )
ENT.ReadySound = Sound( "weapons/teleporter_ready.wav" )
ENT.TeleportDelay = 0.5

ENT.Levels = {
	
	--level 1
	{
		
		Health = 150,
		UpgradeCost = 200,
		Model = "models/buildables/teleporter_light.mdl",
		BuildModel = "models/buildables/teleporter.mdl",
		BuildAnim = "build",
		BuildTime = 20,
		
		Idle = "ref",
		
		Bodygroups = "000",
		BuildBodygroups = "000",
		
		Gibs = {
			
			{
				
				Model = "models/buildables/gibs/teleporter_gib1.mdl",
				Scrap = 6,
				
			},
			
			{
				
				Model = "models/buildables/gibs/teleporter_gib2.mdl",
				Scrap = 6,
				
			},
			
			{
				
				Model = "models/buildables/gibs/teleporter_gib3.mdl",
				Scrap = 6,
				
			},
			
			{
				
				Model = "models/buildables/gibs/teleporter_gib4.mdl",
				Scrap = 7,
				
			},
			
		},
		
		SpinSound = Sound( "weapons/teleporter_spin.wav" ),
		
		RechargeTime = 10,
		
		ReadyAnim = "running",
		
		ChargedParticle = "teleporter_red_charged_level1",
		EntranceParticle = "teleporter_red_entrance_level1",
		ExitParticle = "teleporter_red_exit_level1",
		
	},
	
	--level 2
	{
		
		Health = 180,
		UpgradeCost = 200,
		Model = "models/buildables/teleporter_light.mdl",
		BuildModel = "models/buildables/teleporter_light.mdl",
		BuildAnim = "upgrade",
		BuildTime = 2,
		
		Idle = "ref",
		
		Bodygroups = "000",
		BuildBodygroups = "000",
		
		Gibs = {
			
			{
				
				Model = "models/buildables/gibs/teleporter_gib1.mdl",
				Scrap = 6,
				
			},
			
			{
				
				Model = "models/buildables/gibs/teleporter_gib2.mdl",
				Scrap = 6,
				
			},
			
			{
				
				Model = "models/buildables/gibs/teleporter_gib3.mdl",
				Scrap = 6,
				
			},
			
			{
				
				Model = "models/buildables/gibs/teleporter_gib4.mdl",
				Scrap = 7,
				
			},
			
		},
		
		SpinSound = Sound( "weapons/teleporter_spin2.wav" ),
		
		RechargeTime = 5,
		
		ReadyAnim = "running",
		
		ChargedParticle = "teleporter_red_charged_level2",
		EntranceParticle = "teleporter_red_entrance_level2",
		ExitParticle = "teleporter_red_exit_level2",
		
	},
	
	--level 3
	{
		
		Health = 216,
		UpgradeCost = -1,
		Model = "models/buildables/teleporter_light.mdl",
		BuildModel = "models/buildables/teleporter_light.mdl",
		BuildAnim = "upgrade",
		BuildTime = 2,
		
		Idle = "ref",
		
		Bodygroups = "000",
		BuildBodygroups = "000",
		
		Gibs = {
			
			{
				
				Model = "models/buildables/gibs/teleporter_gib1.mdl",
				Scrap = 6,
				
			},
			
			{
				
				Model = "models/buildables/gibs/teleporter_gib2.mdl",
				Scrap = 6,
				
			},
			
			{
				
				Model = "models/buildables/gibs/teleporter_gib3.mdl",
				Scrap = 6,
				
			},
			
			{
				
				Model = "models/buildables/gibs/teleporter_gib4.mdl",
				Scrap = 7,
				
			},
			
		},
		
		SpinSound = Sound( "weapons/teleporter_spin3.wav" ),
		
		RechargeTime = 3,
		
		ReadyAnim = "running",
		
		ChargedParticle = "teleporter_red_charged_level3",
		EntranceParticle = "teleporter_red_entrance_level3",
		ExitParticle = "teleporter_red_exit_level3",
		
	},
	
}

function ENT:SetupDataTables()
	
	self:BaseDataTables()
	
	self:TFNetworkVar( "Bool", "Exit", false )
	self:TFNetworkVar( "Bool", "TwoWay", false )
	self:TFNetworkVar( "Bool", "Ready", false )
	self:TFNetworkVar( "Bool", "Teleported", true )
	self:TFNetworkVar( "Bool", "EffectsActive", false )
	
	self:TFNetworkVar( "Float", "LastTeleport", 0 )
	self:TFNetworkVar( "Float", "NextTeleport", 0 )
	self:TFNetworkVar( "Float", "TeleportTime", 0 )
	
	self:TFNetworkVar( "Entity", "Link", nil )
	self:TFNetworkVar( "Entity", "TeleportTarget", nil )
	
end

function ENT:GetBuildNum()
	
	if self:GetTFExit() == true then return TF2Weapons.Building.EXIT end
	
	return TF2Weapons.Building.ENTRANCE
	
end

function ENT:SetBuildAlt( alt )
	
	if SERVER then self:SetTFExit( alt ) end
	
end

function ENT:Initialize()
	
	if SERVER then self:SetTrigger( true ) end
	
	for i = 1, #self.Levels do
		
		local level = self.Levels[ i ]
		if level.ChargedParticle != nil then PrecacheParticleSystem( level.ChargedParticle ) end
		if level.EntranceParticle != nil then PrecacheParticleSystem( level.EntranceParticle ) end
		if level.ExitParticle != nil then PrecacheParticleSystem( level.ExitParticle ) end
		
	end
	
end

function ENT:SetLevel( level )
	
	self:SetTFUpgrade( 0 )
	self:SetTFLevel( level )
	self:SetTFUpgrading( true )
	self:SetTFLastUpgrade( CurTime() )
	self:SetTFUpgradeAmount( 0 )
	self:SetLevelModel( level, true )
	self:SetTFUpgradeRemoveHealth( 0 )
	
	local stats = self.Levels[ level ]
	if stats == nil then return end
	
	if SERVER then
		
		net.Start( "tf2weapons_building_upgrade" )
			
			net.WriteEntity( self )
			net.WriteInt( level, 32 )
			
		net.Broadcast()
		
		self:SetMaxHealth( stats.Health )
		if self:Health() < 1 then self:SetHealth( 1 ) end
		
		self:SetTFUpgradeHealth( self:Health() )
		
	end
	
	self:EmitSound( stats.SpinSound, nil, nil, nil, CHAN_WEAPON )
	
end

function ENT:GetLink()
	
	if IsValid( self:GetTFLink() ) == true then return self:GetTFLink() end
	
	local owner = self:GetTFOwner()
	
	if IsValid( owner ) != true then return end
	
	local plybuildings = owner.TF2Weapons_Buildings
	
	if plybuildings == nil then return end
	
	local build = TF2Weapons.Building.EXIT
	if self:GetTFExit() == true then build = TF2Weapons.Building.ENTRANCE end
	
	if plybuildings[ build ] != nil and plybuildings[ build ][ self:GetTFBuildID() ] != nil then
		
		self:SetTFLink( plybuildings[ build ][ self:GetTFBuildID() ] )
		return plybuildings[ build ][ self:GetTFBuildID() ]
		
	end
	
end

function ENT:CanSend( ent )
	
	if self:GetTFTwoWay() != true and self:GetTFExit() == true then return false end
	if IsValid( self:GetLink() ) != true then return false end
	if CurTime() < self:GetTFNextTeleport() then return false end
	if self:GetActive() != true then return false end
	if self:GetLink():GetActive() != true then return false end
	
	if ent != nil then
		
		if IsValid( ent ) != true then return false end
		if self.TeleportNonPlayers != true and ent:IsPlayer() != true then return false end
		if ent:GetAbsVelocity():Length() >= 5 then return false end
		
		local friendly = true
		
		if GetConVar( "tf2weapons_teleporter_teammates" ):GetBool() == true then
			
			if ent:IsNPC() == true and ent:Disposition( self:GetTFOwner() ) != D_HT then friendly = false end
			if ent:IsNPC() != true and hook.Call( "PlayerShouldTakeDamage", GAMEMODE, self:GetTFOwner(), ent ) != true then friendly = false end
			
		else
			
			if ent:IsNPC() == true and ent:Disposition( self:GetTFOwner() ) == D_HT then friendly = false end
			if ent:IsNPC() != true and hook.Call( "PlayerShouldTakeDamage", GAMEMODE, self:GetTFOwner(), ent ) == true then friendly = false end
			
		end
		
		if ent == self:GetTFOwner() then friendly = true end
		
		if friendly != true then return false end
		
	end
	
	return true
	
end

function ENT:OnSend( ent )
	
	self:EmitSound( self.SendSound, nil, nil, nil, CHAN_ITEM )
	
end

function ENT:OnReceive( ent )
	
	self:EmitSound( self.ReceiveSound, nil, nil, nil, CHAN_ITEM )
	
end

function ENT:GetReceivePos()
	
	return self:GetPos() + ( self:GetAngles():Up() * ( self.BuildMaxs.z + 1 ) )
	
end

function ENT:GetReceiveAngles()
	
	return Angle( 0, self:GetAngles().y, 0 )
	
end

function ENT:Touch( ent )
	
	if CurTime() < self:GetTFNextTeleport() or self:CanSend( ent ) != true or self:GetTFTeleported() != true then return end
	
	self:SetTFTeleportTarget( ent )
	self:SetTFTeleportTime( CurTime() + self.TeleportDelay )
	self:SetTFTeleported( false )
	
end

function ENT:EndTouch( ent )
	
	if ent == self:GetTFTeleportTarget() then self:SetTFTeleportTarget( nil ) end
	
end

function ENT:GetActive()
	
	if self:GetTFBuilding() == true then return false end
	if self:GetTFUpgrading() == true then return false end
	if CurTime() < self:GetTFNextTeleport() then return false end
	if IsValid( self:GetLink() ) != true then return false end
	if self:GetLink():GetTFBuilding() == true then return false end
	if self:GetLink():GetTFUpgrading() == true then return false end
	
	return true
	
end

function ENT:Teleport( ent, exit )
	
	if CLIENT then return end
	
	local pos = exit:GetPos()
	if exit.GetReceivePos != nil then pos = exit:GetReceivePos() end
	local ang = exit:GetAngles()
	if exit.GetReceiveAngles != nil then ang = exit:GetReceiveAngles() end
	
	ent:SetPos( pos )
	ent:SetAngles( ang )
	if ent:IsPlayer() == true then ent:SetEyeAngles( ang ) end
	
	self:OnSend( ent )
	exit:OnReceive( ent )
	
	local stats = self.Levels[ self:GetTFLevel() ]
	if stats != nil then
		
		self:SetTFLastTeleport( CurTime() )
		exit:SetTFLastTeleport( CurTime() )
		self:SetTFNextTeleport( CurTime() + stats.RechargeTime )
		exit:SetTFNextTeleport( CurTime() + stats.RechargeTime )
		
	end
	
end

function ENT:HandleLinkUpgrade()
	
	local link = self:GetLink()
	if IsValid( link ) != true then return end
	
	if link:GetTFBuilding() != true and self:GetTFLevel() > link:GetTFLevel() then
		
		link:SetLevel( self:GetTFLevel() )
		link:SetTFUpgrade( self:GetTFUpgrade() )
		
	elseif self:GetTFBuilding() != true and link:GetTFLevel() > self:GetTFLevel() then
		
		self:SetLevel( link:GetTFLevel() )
		self:SetTFUpgrade( link:GetTFUpgrade() )
		
	end
	
	if link:GetTFBuilding() != true and self:GetTFUpgrade() > link:GetTFUpgrade() then
		
		link:SetTFUpgrade( self:GetTFUpgrade() )
		
	elseif self:GetTFBuilding() != true and link:GetTFUpgrade() > self:GetTFUpgrade() then
		
		self:SetTFUpgrade( link:GetTFUpgrade() )
		
	end
	
end

ENT.SpinSpeed = 0
ENT.SpinCycle = 0

function ENT:HandleAnim()
	
	local stats = self.Levels[ self:GetTFLevel() ]
	if stats == nil then return end
	
	if self:GetTFUpgrading() == true then
		
		if self:GetTFEffectsActive() == true then
			
			self:EmitSound( "null.wav", nil, nil, nil, CHAN_WEAPON )
			self:StopParticles()
			
			self:SetTFEffectsActive( false )
			
		end
		
		return
		
	end
	
	if self:GetActive() == true then
		
		if self:GetTFReady() != true then
			
			self:EmitSound( self.ReadySound )
			self:EmitSound( stats.SpinSound, nil, nil, nil, CHAN_WEAPON )
			
			ParticleEffectAttach( stats.ChargedParticle, PATTACH_ABSORIGIN_FOLLOW , self, -1 )
			
			if self:GetTFExit() == true then
				
				ParticleEffectAttach( stats.ExitParticle, PATTACH_ABSORIGIN_FOLLOW , self, -1 )
				
			else
				
				ParticleEffectAttach( stats.EntranceParticle, PATTACH_ABSORIGIN_FOLLOW , self, -1 )
				
			end
			
		end
		
		self:SetTFEffectsActive( true )
		
		self:SetTFReady( true )
		
	else
		
		if self:GetTFReady() == true then
			
			self:EmitSound( "null.wav", nil, nil, nil, CHAN_WEAPON )
			self:StopParticles()
			
		end
		
		self:SetTFEffectsActive( false )
		
		self:SetTFReady( false )
		
	end
	
	if self:GetTFBuilding() != true and CurTime() < self:GetTFNextTeleport() then
		
		local endtime = self:GetTFNextTeleport() - self:GetTFLastTeleport()
		local time = CurTime() - self:GetTFLastTeleport()
		
		local mult = time / endtime
		if mult < 0 then mult = 0 end
		if mult > 1 then mult = 1 end
		
		if mult < 0.25 then
			
			self.SpinSpeed = 1 - ( mult * 4 )
			
		else
			
			self.SpinSpeed = ( mult - 0.25 ) * ( 1 / 0.75 )
			
		end
		
	elseif self:GetActive() == true then
		
		self.SpinSpeed = math.Approach( self.SpinSpeed, 1, 0.5 * FrameTime() )
		
	else
		
		self.SpinSpeed = math.Approach( self.SpinSpeed, 0, 0.25 * FrameTime() )
		
	end
	
	if self:GetTFBuilding() != true then
		
		self:SetSequence( stats.ReadyAnim )
		self:SetSequence( self:LookupSequence( "running" ) )
		self.SpinCycle = self.SpinCycle + ( self.SpinSpeed * FrameTime() )
		if self.SpinCycle > 1 then self.SpinCycle = self.SpinCycle - 1 end
		if self.SpinCycle < 0 then self.SpinCycle = self.SpinCycle + 1 end
		self:SetCycle( self.SpinCycle )
		
		if self:FindBodygroupByName( "teleporter_blur" ) != -1 then
			
			local blur = ( self.SpinSpeed >= 1 and 1 ) or 0
			self:SetBodygroup( self:FindBodygroupByName( "teleporter_blur" ), blur )
			
		end
		
		if self:FindBodygroupByName( "teleporter_direction" ) != -1 then
			
			local direction = 0
			if self:CanSend() == true then direction = 1 end
			self:SetBodygroup( self:FindBodygroupByName( "teleporter_direction" ), direction )
			
			if CLIENT and IsValid( self:GetLink() ) == true and self:LookupBone( "direction" ) != nil then
				
				local ang = self:GetAngles().y - ( self:GetLink():GetPos() - self:GetPos() ):Angle().y
				self:ManipulateBoneAngles( self:LookupBone( "direction" ), Angle( -ang, 0, 0 ) )
				
			end
			
		end
		
	end
	
end

function ENT:HandleTeleport()
	
	if self:CanSend( self:GetTFTeleportTarget() ) == true then
		
		self:Teleport( self:GetTFTeleportTarget(), self:GetLink() )
		
		self:SetTFTeleportTarget( nil )
		self:SetTFTeleportTime( 0 )
		self:SetTFTeleported( true )
		
	elseif self:GetActive() != true then
		
		self:SetTFTeleportTarget( nil )
		self:SetTFTeleportTime( 0 )
		self:SetTFTeleported( true )
		
	end
	
end

function ENT:Think()
	
	self:HandleLevel()
	
	self:HandleUpgrade()
	
	self:HandleUpgradeHealth()
	
	self:HandleLinkUpgrade()
	
	self:HandleAnim()
	
	self:HandleTeleport()
	
	--keep updating it because for some reason the client doesn't want to believe this is an exit
	if SERVER then self:SetTFExit( self:GetTFExit() ) end
	
	self:NextThink( CurTime() + 0.05 )
	return true
	
end

function ENT:OnRemove()
	
	self:EmitSound( "null.wav", nil, nil, nil, CHAN_WEAPON )
	
	local plybuildings = self:GetTFOwner().TF2Weapons_Buildings
	
	if plybuildings == nil or plybuildings[ self:GetBuildNum() ] == nil then return end
	
	table.RemoveByValue( plybuildings[ self:GetBuildNum() ], self )
	
	self:GetTFOwner().TF2Weapons_Buildings = plybuildings
	
	if SERVER then
		
		net.Start( "tf2weapons_building_remove" )
			
			net.WriteEntity( self:GetTFOwner() )
			net.WriteInt( self:GetBuildNum(), 32 )
			net.WriteEntity( self )
			
		net.Broadcast()
		
	end
	
	if IsValid( self:GetLink() ) == true then
		
		self:GetLink():SetTFUpgrade( 0 )
		self:GetLink():SetTFLevel( 1 )
		
	end
	
end