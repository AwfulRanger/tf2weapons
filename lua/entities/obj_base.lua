AddCSLuaFile()

game.AddParticles( "particles/sparks.pcf" )
game.AddParticles( "particles/explosion.pcf" )

if CLIENT then
	
	net.Receive( "tf2weapons_building_destroy", function()
		
		local building = net.ReadEntity()
		if IsValid( building ) == true then building:OnDestroy() end
		
	end )
	
else
	
	util.AddNetworkString( "tf2weapons_building_destroy" )
	
end

CreateConVar( "tf2weapons_building_teammates", 0, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED }, [[0 to prevent teammates from damaging buildings and enemies from repairing them
1 to allow teammates to damage buildings and enemies to repair them
2 to prevent anyone from damaging buildings and allow anyone to repair them
3 to allow anyone to damage buildings and prevent anyone but owner from repairing them]] )

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Building"
ENT.Category = "Team Fortress 2"
ENT.Author = "AwfulRanger"
ENT.Spawnable = false
ENT.AdminOnly = false

ENT.TF2Weapons_NoAirblast = true
ENT.TF2Weapons_Building = true

ENT.BuildMins = Vector( -20, -20, 0 )
ENT.BuildMaxs = Vector( 20, 20, 66 )

ENT.ExplodeSound = Sound( "weapons/sentry_explode.wav" )

ENT.BuildUpgradeBase = 25
ENT.BuildRepairBase = 105
ENT.BuildConstructionRateBase = 2

ENT.Levels = {
	
	{
		
		Health = 100,
		UpgradeCost = -1,
		Model = Model( "models/buildables/repair_level1.mdl" ),
		BuildModel = Model( "models/buildables/repair_level1.mdl" ),
		BuildAnim = nil,
		BuildTime = 10,
		
		Idle = "ref",
		
		Bodygroups = "000",
		BuildBodygroups = "000",
		
		Gibs = {}
		
	},
	
}

function ENT:TFNetworkVar( vartype, varname, default, slot, extended )
	
	if self[ "GetTF" .. varname ] ~= nil or self[ "SetTF" .. varname ] ~= nil then return end
	
	if self.CreatedNetworkVars == nil then self.CreatedNetworkVars = {} end
	
	if self.CreatedNetworkVars[ vartype ] == nil then
		
		self.CreatedNetworkVars[ vartype ] = 0
		
	end
	
	if slot ~= nil then self.CreatedNetworkVars[ vartype ] = slot end
	slot = self.CreatedNetworkVars[ vartype ]
	
	self:NetworkVar( vartype, slot, "TF" .. varname, extended )
	if SERVER and default ~= nil then self[ "SetTF" .. varname ]( self, default ) end
	
	self.CreatedNetworkVars[ vartype ] = self.CreatedNetworkVars[ vartype ] + 1
	
	return self[ "GetTF" .. varname ]( self )
	
end

function ENT:BaseDataTables()
	
	self:TFNetworkVar( "Bool", "Upgrading", false )
	self:TFNetworkVar( "Bool", "Building", false )
	self:TFNetworkVar( "Bool", "Destroyed", false )
	self:TFNetworkVar( "Bool", "BLU", false )
	
	self:TFNetworkVar( "Float", "UpgradeMult", 1 )
	self:TFNetworkVar( "Float", "LastUpgrade", 0 )
	self:TFNetworkVar( "Float", "UpgradeAmount", 0 )
	
	self:TFNetworkVar( "Int", "Level", 0 )
	self:TFNetworkVar( "Int", "Upgrade", 0 )
	self:TFNetworkVar( "Int", "UpgradeHealth", 0 )
	self:TFNetworkVar( "Int", "UpgradeRemoveHealth", 0 )
	self:TFNetworkVar( "Int", "BuildID", 0 )
	
	self:TFNetworkVar( "Entity", "Owner", nil )
	
end

function ENT:SetupDataTables()
	
	self:BaseDataTables()
	
end

function ENT:GetBuildNum()
	
	return TF2Weapons.Building.NONE
	
end

function ENT:SetBuildAlt( alt )
end

function ENT:SetLevelModel( level, building )
	
	if level == nil then level = self:GetTFLevel() end
	stats = self.Levels[ level ]
	if stats == nil then return end
	
	if building == true then
		
		if stats.BuildModel ~= nil then self:SetModel( stats.BuildModel ) end
		if stats.BuildAnim ~= nil then self:ResetSequence( stats.BuildAnim ) end
		if stats.BuildBodygroups ~= nil then self:SetBodyGroups( stats.BuildBodygroups ) end
		
	else
		
		if stats.Model ~= nil then self:SetModel( stats.Model ) end
		if stats.Bodygroups ~= nil then self:SetBodyGroups( stats.Bodygroups ) end
		
	end
	
	if SERVER then
		
		if self:GetTFBLU() ~= true then
			
			if stats.SkinRED ~= nil then self:SetSkin( stats.SkinRED ) end
			
		else
			
			if stats.SkinBLU ~= nil then self:SetSkin( stats.SkinBLU ) end
			
		end
		
	end
	
	--if SERVER then
		
		self:PhysicsInitBox( self.BuildMins, self.BuildMaxs )
		if IsValid( self:GetPhysicsObject() ) == true then self:GetPhysicsObject():EnableMotion( false ) end
		self:SetMoveType( MOVETYPE_NONE )
		
	--end
	
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
	
end

function ENT:LevelUp()
	
	local level = self:GetTFLevel() + 1
	
	self:SetLevel( level )
	
end

function ENT:LevelDown()
	
	local level = self:GetTFLevel() - 1
	
	self:SetLevel( level )
	
end

function ENT:Upgrade( dmg )
	
	local weapon = dmg:GetInflictor()
	if IsValid( weapon ) ~= true or weapon.TF2Weapons_BuildTool ~= true then return false end
	
	local level = self:GetTFLevel()
	local stats = self.Levels[ level ]
	if stats == nil then return false end
	
	if stats.UpgradeCost < 0 then return false end
	
	local upgrade = self:GetTFUpgrade()
	--local upgrademax = weapon:BuildUpgradeMax()
	local upgrademax = self.BuildUpgradeBase
	if weapon.BuildUpgradeMax ~= nil then upgrademax = weapon:BuildUpgradeMax( self.BuildUpgradeBase ) end
	if upgrademax > weapon:Ammo1() then upgrademax = weapon:Ammo1() end
	
	if upgrademax <= 0 then return false end
	
	local cost = upgrademax
	
	if upgrade + upgrademax >= stats.UpgradeCost then
		
		if upgrade + upgrademax > stats.UpgradeCost then cost = stats.UpgradeCost - upgrade end
		
		if SERVER then self:LevelUp() end
		
	else
		
		if SERVER then self:SetTFUpgrade( upgrade + upgrademax ) end
		
	end
	
	weapon:TakePrimaryAmmo( cost )
	
	return true
	
end

function ENT:HandleLevel()
	
	if self:GetTFLevel() < 1 then
		
		self:SetLevel( 1 )
		self:SetTFBuilding( true )
		
	end
	
end

function ENT:HandleUpgrade()
	
	local stats = self.Levels[ self:GetTFLevel() ]
	if self:GetTFUpgrading() == true and stats ~= nil then
		
		local starttime = self:GetTFLastUpgrade()
		local endtime = stats.BuildTime
		
		local addtime = ( CurTime() - starttime ) * self:DoUpgradeMult()
		local addamount = addtime / endtime
		
		local amount = self:GetTFUpgradeAmount() + addamount
		
		if amount > 1 then
			
			self:SetLevelModel()
			
			self:SetTFUpgrading( false )
			self:SetTFBuilding( false )
			
			amount = 1
			
		else
			
			self:SetCycle( amount )
			
			self:SetTFLastUpgrade( CurTime() )
			
		end
		
		self:SetTFUpgradeAmount( amount )
		
	end
	
end

function ENT:HandleUpgradeHealth()
	
	if self:GetTFUpgradeHealth() < 1 then return end
	
	local stats = self.Levels[ self:GetTFLevel() ]
	
	if stats == nil then return end
	
	local starthealth = self:GetTFUpgradeHealth()
	local endhealth = stats.Health
	local health = endhealth - starthealth
	if self.Levels[ self:GetTFLevel() - 1 ] ~= nil then health = endhealth - self.Levels[ self:GetTFLevel() - 1 ].Health end
	local mult = self:GetTFUpgradeAmount()
	if self:GetTFBuilding() ~= true then mult = 1 end
	
	self:SetHealth( starthealth + ( health * mult ) - self:GetTFUpgradeRemoveHealth() )
	
	if mult >= 1 then self:SetTFUpgradeHealth( 0 ) end
	
	if self:Health() > self:GetMaxHealth() then self:SetHealth( self:GetMaxHealth() ) end
	
end


ENT.CreatedParticles = {}

function ENT:AddParticle( particle, options )
	
	if particle == nil or particle == "" or options == nil then return end
	
	if SERVER then
		
		net.Start( "tf2weapons_addparticle" )
			
			net.WriteEntity( self )
			
			net.WriteString( particle )
			
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
		
		local num = #self.CreatedParticles + 1
		
		local mdls = {}
		
		for i = 1, #options do
			
			local option = options[ i ]
			
			if option.entity == nil then option.entity = self end
			
			if IsValid( option.entity ) == true and isstring( option.attachment ) == true then option.attachment = option.entity:LookupAttachment( option.attachment ) end
			
			if option.attachtype == PATTACH_POINT_FOLLOW and option.attachment ~= nil and IsValid( option.entity ) == true then
				
				local attach = option.entity:GetAttachment( option.attachment )
				local ang = Angle( 0, 0, 0 )
				if attach ~= nil and attach.Ang ~= nil then ang = attach.Ang end
				
				local mdl = ClientsideModel( "models/weapons/w_models/w_drg_ball.mdl" )
				mdl:SetNoDraw( true )
				mdl:SetPos( option.entity:GetPos() )
				mdl:SetAngles( ang )
				mdl:SetParent( option.entity, option.attachment )
				option.entity = mdl
				
				table.insert( mdls, mdl )
				
				option.attachtype = PATTACH_ABSORIGIN
				
			end
			
		end
		
		local newparticle = self:CreateParticleEffect( particle, options )
		
		for i = 1, #mdls do
			
			mdls[ i ].particle = newparticle
			
		end
		
		self.CreatedParticles[ num ] = {
			
			particle = newparticle,
			models = mdls,
			
		}
		
		return newparticle, num
		
	end
	
end

function ENT:GetParticle( id )
	
	return self.CreatedParticles[ id ]
	
end

function ENT:RemoveParticle( particletbl, force )
	
	local remove = {}
	
	local particle = particletbl.particle
	local models = particletbl.models
	
	if IsValid( particle ) == true then
		
		if force == true then
			
			particle:StopEmissionAndDestroyImmediately()
			
		else
			
			particle:StopEmission()
			
		end
		
	end
	
	if force == true then
		
		for i_ = 1, #models do
			
			if IsValid( models[ i_ ] ) == true then models[ i_ ]:Remove() end
			
		end
		
	end
	
end

function ENT:RemoveParticles( force )
	
	for i = 1, #self.CreatedParticles do
		
		self:RemoveParticle( self.CreatedParticles[ i ], force )
		if force == true then self.CreatedParticles[ i ] = nil end
		
	end
	
end

function ENT:HandleParticles()
	
	local remove = {}
	
	for i = 1, #self.CreatedParticles do
		
		local tbl = self.CreatedParticles[ i ]
		if IsValid( tbl.particle ) ~= true then
			
			self:RemoveParticle( tbl, true )
			table.insert( remove, i )
			
		end
		
	end
	
	for i = 1, #remove do
		
		table.remove( self.CreatedParticles, remove[ i ] )
		
	end
	
end

function ENT:Think()
	
	self:HandleLevel()
	
	self:HandleUpgrade()
	
	self:HandleUpgradeHealth()
	
	self:HandleParticles()
	
	local stats = self.Levels[ self:GetTFLevel() ]
	
	if self:GetTFUpgrading() ~= true and stats ~= nil then
		
		if stats.Idle ~= nil then self:SetSequence( stats.Idle ) end
		
	end
	
	self:NextThink( CurTime() + 0.05 )
	return true
	
end

ENT.RepairerList = {}
ENT.RepairerTime = 1
ENT.RepairerMult = 2
ENT.DefaultMult = 1

function ENT:DoUpgradeMult()
	
	local mult = self.DefaultMult
	
	for _, v in pairs( self.RepairerList ) do
		
		if CurTime() > v + self.RepairerTime then
			
			self.RepairerList[ _ ] = nil
			
		else
			
			local addmult = self.RepairerMult
			if _.BuildConstructRate ~= nil then addmult = _:BuildConstructRate( self.RepairerMult ) end
			
			mult = mult * addmult
			
		end
		
	end
	
	if SERVER then self:SetTFUpgradeMult( mult ) end
	
	return self:GetTFUpgradeMult()
	
end

function ENT:Repair( dmg )
	
	local weapon = dmg:GetInflictor()
	if IsValid( weapon ) ~= true or weapon.TF2Weapons_BuildTool ~= true then return false end
	
	local level = self:GetTFLevel()
	local stats = self.Levels[ level ]
	if stats == nil then return false end
	
	if self:Health() >= self:GetMaxHealth() then return false end
	
	local repair = self:Health()
	--local repairmax = weapon:BuildRepairMax()
	local repairmax = self.BuildRepairBase
	if weapon.BuildRepairMax ~= nil then repairmax = weapon:BuildRepairMax( self.BuildRepairBase ) end
	if repair + repairmax > self:GetMaxHealth() then repairmax = self:GetMaxHealth() - repair end
	
	local cost = ( 1 + repairmax ) / 3
	
	if cost > weapon:Ammo1() then
		
		repairmax = ( weapon:Ammo1() - 1 ) * ( 1 / 3 )
		cost = ( 1 + repairmax ) / 3
		
	end
	
	if repairmax <= 0 then return false end
	
	self:SetHealth( repair + repairmax )
	
	weapon:TakePrimaryAmmo( cost )
	
	return true
	
end

function ENT:ToolHit( dmg )
	
	local upgraded = self:Repair( dmg )
	if upgraded ~= true then upgraded = self:Upgrade( dmg ) end
	
	return upgraded
	
end

function ENT:OnHit( dmg )
	
	local friendly = true
	local upgraded = false
	
	if IsValid( dmg:GetAttacker() ) == true then
		
		friendly = TF2Weapons:EntityCanRepair( self, dmg:GetAttacker() )
		
	else
		
		friendly = false
		
	end
	
	if friendly == true then
		
		if self:GetTFBuilding() == true then
			
			self.RepairerList[ dmg:GetInflictor() ] = CurTime()
			upgraded = true
			
		elseif self:GetTFUpgrading() ~= true then
			
			upgraded = self:ToolHit( dmg )
			
		end
		
	elseif dmg:GetAttacker() ~= self then
		
		local health = self:Health()
		local damage = dmg:GetDamage()
		
		if health ~= nil and damage ~= nil then
			
			self:SetHealth( self:Health() - dmg:GetDamage() )
			if self:GetTFBuilding() == true then self:SetTFUpgradeRemoveHealth( self:GetTFUpgradeRemoveHealth() + dmg:GetDamage() ) end
			
			if self:GetTFDestroyed() ~= true and self:Health() <= 0 then
				
				self:SetTFDestroyed( true )
				self:OnDestroy( true )
				
			end
			
		end
		
	end
	
	return friendly, upgraded
	
end

function ENT:OnTakeDamage( dmg )
	
	self:OnHit( dmg )
	
end

function ENT:CreateGibs()
	
	if CLIENT then return end
	
	local stats = self.Levels[ self:GetTFLevel() ]
	if stats ~= nil and stats.Gibs ~= nil then
		
		for i = 1, #stats.Gibs do
			
			local gibstat = stats.Gibs[ i ]
			
			local gib = ents.Create( "tf_obj_gib" )
			gib:SetPos( self:GetPos() )
			gib:SetAngles( self:GetAngles() )
			if gibstat.Model ~= nil then gib:SetModel( gibstat.Model ) end
			if gibstat.Scrap ~= nil then gib:SetTFScrap( gibstat.Scrap ) end
			if self:GetTFBLU() ~= true then
				
				if gibstat.SkinRED ~= nil then gib:SetSkin( gibstat.SkinRED ) end
				
			else
				
				if gibstat.SkinBLU ~= nil then gib:SetSkin( gibstat.SkinBLU ) end
				
			end
			gib:Spawn()
			gib:PhysWake()
			
			if IsValid( gib:GetPhysicsObject() ) == true then
				
				local force = 128
				local dir = Vector( math.random( -force, force ), math.random( -force, force ), force )
				
				gib:GetPhysicsObject():SetVelocity( dir )
				
			end
			
		end
		
	end
	
end

function ENT:OnDestroy( send )
	
	ParticleEffect( "explosioncore_buildings", self:GetPos(), self:GetAngles() )
	
	if CLIENT then return end
	
	if send == true then
		
		net.Start( "tf2weapons_building_destroy" )
			
			net.WriteEntity( self )
			
		net.Broadcast()
		
	end
	
	self:CreateGibs()
	if self.ExplodeSound ~= nil then self:EmitSound( self.ExplodeSound ) end
	self:Remove()
	
end

function ENT:Removed()
	
	local plybuildings = self:GetTFOwner().TF2Weapons_Buildings
	
	if plybuildings == nil or plybuildings[ self:GetBuildNum() ] == nil then return end
	
	local valid = true
	
	local key = table.RemoveByValue( plybuildings[ self:GetBuildNum() ], self )
	
	if key == false then
		
		valid = false
		key = -1
		
	end
	
	self:GetTFOwner().TF2Weapons_Buildings = plybuildings
	
	if SERVER then
		
		net.Start( "tf2weapons_building_remove" )
			
			net.WriteEntity( self:GetTFOwner() )
			net.WriteInt( self:GetBuildNum(), 32 )
			net.WriteBool( valid )
			net.WriteInt( key, 32 )
			net.WriteEntity( self )
			
		net.Broadcast()
		
	end
	
end

function ENT:OnRemove()
	
	self:Removed()
	
end