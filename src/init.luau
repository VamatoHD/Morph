local TweenService = game:GetService("TweenService")

local module = {}
module.__index = module

function module.NewMorph(Obj)
	local new = {
		["Object"] = Obj,
		["Tween"] = nil,

		["EndConn"] = nil,
		["Running"] = false,

		["States"] = {},
		["Current"] = nil
	}

	setmetatable(new,module)
	return new
end

function module:CopyState(tween,id:string)
	if tween["States"][id] == nil then
		return warn("State not found, ignoring.")
	end

	self["States"][id] = tween["States"][id]

	if self["Current"] == nil then
		self["Current"] = id
	end
	return self
end

function module:AddState(id:string,Info:TweenInfo,Goal)
	assert(id ~= true,"State id cannot be true.")
	assert(id ~= false,"State id cannot be false.")
	assert(id ~= nil,"State id cannot be nil.")

	self["States"][id] = {
		["Info"] = Info,
		["Goal"] = Goal,
	}

	if self["Current"] == nil then
		self["Current"] = id
	end
	return self
end

function module:SetState(id:string)
	self["Current"] = id
	return self
end

function module:Stop()
	if self["Tween"] then
		self["Tween"]:Cancel()
		self["Tween"] = nil
	end
	if self["EndConn"] then
		self["EndConn"]:Disconnect()
		self["EndConn"] = nil
	end

	self["Running"] = false
	return self
end

--WARNING : Untested function / May cause unexpected behaviour
function module:Yield()
	if self["Running"] == false then return end
	if not self["Tween"] then return end
	self["Tween"].Completed:Wait()

	return self
end

function module:ForcePlay(Callback)
	local cur = self["Current"]
	local state = self["States"][cur]

	assert(cur,"Invalid state for twenning.")
	assert(state,"State for tweening not found.")

	if self["Running"] ~= false then
		self:Stop()
	end

	self["Tween"] = TweenService:Create(self["Object"],state["Info"],state["Goal"])

	self["EndConn"] = self["Tween"].Completed:Once(function()
		if Callback then
			pcall(Callback,self,self["Object"])
		end
		self:Stop()
	end)

	self["Running"] = cur
	self["Tween"]:Play()

	return self
end

function module:Play(CallBack)
	if self["Running"] == false or self["Current"] ~= self["Running"] then
		self:ForcePlay(CallBack)
	end

	return self
end

return module
