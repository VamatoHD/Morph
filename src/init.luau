--!strict

local Animator = require(script.Animator)
local Types = require(script.Types)

local Morph: Types.Morph = table.freeze({
	new = Animator.new,
})

return Morph
