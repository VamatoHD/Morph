--!strict

local TweenService = game:GetService("TweenService")

local Types = require(script.Parent.Types)

local Animator: Types.AnimatorImpl = {} :: Types.AnimatorImpl
Animator.__index = Animator

function Animator.new(Object: Instance): Types.Animator
	assert(Object and Object:IsA("Instance"),"Invalid object.")

	local self: Types.Animation = {
		Object = Object,

		_isRunning = false,
		_isPaused = false,
		_Conn = nil,

		_States = {},
		_Current = nil,

		_Tween = nil,
	}

	return setmetatable(self, Animator)
end

function Animator:AddState(value: Types.State): Types.Animator
	local id: Types.Id? = value["Id"]

	assert(type(id) == "string" or type(id) == "number", "Id must be a string or a number.")

	self._States[id :: Types.Id] = table.clone(value)

	return self
end

function Animator:Stop(): Types.Animator
	if self["_Conn"] then
		self["_Conn"]:Disconnect()
		self["_Conn"] = nil
	end

	if self["_Tween"] then
		self["_Tween"]:Cancel()
		self["_Tween"] = nil
	end

	self["_Current"] = nil
	self["_isRunning"] = false
	self["_isPaused"] = false

	return self
end

function Animator:Pause(): Types.Animator
	if not self["_isRunning"] or not self["_Tween"] then
		return self
	end

	self["_Tween"]:Pause()
	self["_isPaused"] = true

	return self
end

function Animator:ForcePlay(Id: Types.Id?, Callback: ((Instance) -> nil)?): Types.Animator
	if self["_isRunning"] and self["_isPaused"] and (Id == nil or self["_Current"] == Id) then
		(self["_Tween"] :: Tween):Play()
		self["_isPaused"] = false

		return self
	end

	assert(type(Id) == "string" or type(Id) == "number", "Id must be a string or a number.")

	local state: Types.State? = self["_States"][Id :: Types.Id]

	assert(state ~= nil, "State not found.")

	if self["_isRunning"] then
		self:Stop()
	end

	self["_Tween"] = TweenService:Create(self["Object"], state["Info"] or TweenInfo.new(), state["Goal"])

	self["_Conn"] = (self["_Tween"] :: Tween).Completed:Once(function()
		if Callback then
			pcall(Callback, self["Object"])
		end
		self:Stop()
	end)

	self["_Current"] = Id
	self["_isRunning"] = true;
	(self["_Tween"] :: Tween):Play()

	return self
end

function Animator:Play(Id: Types.Id?, Callback: ((Instance) -> nil)?): Types.Animator
	if self["_isRunning"] and not self["_isPaused"] then
		return self
	end

	return self:ForcePlay(Id :: Types.Id, Callback)
end

--For code readability
function Animator:Wait(Time: number): Types.Animator
	assert(type(Time) == "number", "Invalid number to wait.")
	task.wait(Time)
	return self
end

return Animator
