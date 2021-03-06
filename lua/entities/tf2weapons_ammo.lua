AddCSLuaFile()

local ammotypes = 27 + #game.BuildAmmoTypes()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Ammo"
ENT.Category = "Team Fortress 2"
ENT.Author = "AwfulRanger"
ENT.Spawnable = false
ENT.AdminOnly = false

ENT.Model = "models/items/ammopack_large.mdl"
ENT.Ammo = 1

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
	
	self:TFNetworkVar( "Bool", "Touched", false )
	
end

function ENT:SetupDataTables()
	
	self:BaseDataTables()
	
end

function ENT:Initialize()
	
	self:SetModel( self.Model )
	
	if SERVER then
		
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
		
		self:SetTrigger( true )
		
	end
	
	if IsValid( self:GetPhysicsObject() ) == true then
		
		self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
		
	end
	
	self:PhysWake()
	
end

function ENT:Touch( ent )
	
	if self:GetTFTouched() ~= true and ent:IsPlayer() == true then
		
		local remove = false
		
		for i = 1, ammotypes do
			
			local ammo = ent:GetAmmoCount( i )
			local max = game.GetAmmoMax( i )
			if ammo < max then
				
				remove = true
				ent:SetAmmo( math.min( ammo + ( max * self.Ammo ), max ), i, true )
				
			end
			
		end
		
		if remove == true then
			
			self:Remove()
			self:SetTFTouched( true )
			
		end
		
	end
	
end