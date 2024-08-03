--!strict

local TweenService = game:GetService("TweenService")

local Types = require(script.Parent.Types)
local Cycles = require(script.Parent.Functions.Cycles)

local IsRunning = function(state: Enum.PlaybackState): boolean
	return state == Enum.PlaybackState.Paused or state == Enum.PlaybackState.Playing
end

local Animator: Types.AnimatorImpl = {} :: Types.AnimatorImpl
Animator.__index = Animator

function Animator.new(Object: Instance): Types.Animator
	assert(Object and Object:IsA("Instance"), "Invalid object.")

	local self: Types.Animation = {
		Object = Object,
		PlaybackState = Enum.PlaybackState.Begin,

		_Conn = nil,

		_States = {},
		_Current = nil,
		_Tweens = {},

		_FinishBinds = {},
	}

	return setmetatable(self, Animator)
end

function Animator:AddState(value: Types.State): Types.Animator
	local id: Types.Id? = value["Id"]

	assert(type(id) == "string" or type(id) == "number", "Id must be a string or a number.")

	self["_States"][id :: Types.Id] = table.clone(value)

	return self
end

function Animator:_stop(): Types.Animator
	if self["_Conn"] then
		self["_Conn"]:Disconnect()
		self["_Conn"] = nil
	end

	if self["_Current"] then
		self["_Tweens"][self["_Current"] :: Types.Id]:Cancel()
		self["_Current"] = nil
	end

	return self
end

function Animator:_getTween(Id: Types.Id?): Tween
	Id = Id or self["_Current"]
	assert(Id, "Id can't be nil.")

	local tween: Tween? = self["_Tweens"][Id]
	if not tween then
		local state = self["_States"][Id]

		assert(state, "State not found.")

		tween = TweenService:Create(self["Object"], state["Info"] or TweenInfo.new(), state["Goal"])
		self["_Tweens"][Id] = tween
	end
	return tween :: Tween
end

function Animator:Cancel()
	self["PlaybackState"] = Enum.PlaybackState.Cancelled
	return self:_stop()
end

function Animator:Pause(): Types.Animator
	if self["PlaybackState"] ~= Enum.PlaybackState.Playing then
		return self
	end

	self["PlaybackState"] = Enum.PlaybackState.Paused
	self:_getTween():Pause()

	return self
end

function Animator:ForcePlay(Id: Types.Id?, Callback: ((Types.Animator) -> nil)?): Types.Animator
	if self["PlaybackState"] == Enum.PlaybackState.Paused and (Id == nil or self["_Current"] == Id) then
		self:_getTween():Play()
		self["PlaybackState"] = Enum.PlaybackState.Playing

		return self
	end

	assert(type(Id) == "string" or type(Id) == "number", "Id must be a string or a number.")

	if IsRunning(self["PlaybackState"]) then
		self:_stop()
	end

	local tween: Tween = self:_getTween(Id)

	self["_Conn"] = (tween :: Tween).Completed:Once(function()
		for _, params in self["_FinishBinds"] do
			local play: Types.PlayFunction = params["ForcePlay"] and self.ForcePlay or self.Play
			play(params["Other"], params["Id"] or Id, params["Callback"])
		end

		self["PlaybackState"] = Enum.PlaybackState.Completed

		if Callback then
			pcall(Callback, self)
		end
		self:_stop()
	end)

	self["PlaybackState"] = Enum.PlaybackState.Playing
	self["_Current"] = Id
	tween:Play()

	return self
end

function Animator:Play(Id: Types.Id?, Callback: ((Types.Animator) -> nil)?): Types.Animator
	if self["PlaybackState"] == Enum.PlaybackState.Playing then
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

function Animator:BindToFinish(value: Types.BindParams): Types.Animator
	local other = value["Other"]

	assert(other, "Invalid animator to bind.")
	assert(other ~= self, "Cannot bind to itself.")
	assert(getmetatable(other) == Animator, "Invalid type of animator to bind.")

	self["_FinishBinds"][other] = value

	if Cycles(self) then
		warn("Possible binding cycle, tween may cycle forever.")
	end

	return self
end

function Animator:UnBind(Other: Types.Animator): Types.Animator
	self["_FinishBinds"][Other] = nil
	return self
end

return Animator
