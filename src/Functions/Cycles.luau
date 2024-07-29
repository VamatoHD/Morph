--!strict

local Types = require(script.Parent.Parent.Types)

return function(Animator: Types.Animator): boolean
	local visited: { [Types.Animator]: boolean } = {}
	local queue: { Types.Animator } = { Animator }

	repeat
		local cur = table.remove(queue, 1) :: Types.Animator

		if visited[cur] then
			return true
		end
		visited[cur] = true

		for anim: Types.Animator, _ in cur["_FinishBinds"] do
			table.insert(queue, anim)
		end

	until #queue == 0

	return false
end
