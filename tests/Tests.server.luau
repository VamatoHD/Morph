local Morph = require(game.ReplicatedStorage.Morph)

local Part = workspace:WaitForChild("TestPart")

local State1 = {
	Id = 1,
	Info = TweenInfo.new(1),
	Goal = { Position = Vector3.zero },
}

local function playingMorph()
	return Morph.new(Part):AddState(State1):Play(1)
end

local function round_to_ms(n: number): number
	return math.round(n * 1000 * 1000) / 1000
end

local function assert_eq(value, expected, message)
	if value ~= expected then
		error(message .. ": expected " .. tostring(expected) .. " | got " .. tostring(value))
	end
end

local function assert_not_eq(value, expected, message)
	if value == expected then
		error(message .. ": " .. tostring(value) .. " equals the expected.")
	end
end

local function call(func, ...)
	local suc, res = pcall(func, ...)
	return {
		["ShouldPass"] = function(err)
			if not suc then
				error(err or "")
			end
			return res
		end,
		["ShouldFail"] = function(err)
			if suc then
				error(err or "")
			end
			return res
		end,
	}
end

local function Test_New()
	call(Morph.new).ShouldFail("Creating with no arguments didn't fail.")
	local v = call(Morph.new, Part).ShouldPass("Creating with parameter shouldn't fail.")

	assert_eq(getmetatable(v), Morph, "Didn't return proper object")
end

local function Test_AddState()
	local v = Morph.new(Part)

	call(v.AddState, v, { Id = false }).ShouldFail("Invalid Id to create.")
	call(v.AddState, v, { Id = 1 }).ShouldPass("Should create with valid id.")

	assert_not_eq(v["_States"][1], nil, "State not added properly.")
end

local function Test_Stop()
	local v = Morph.new(Part):AddState(State1)

	v:ForcePlay(1):Wait(0.1)

	call(v._stop, v).ShouldPass("How did :_stop fail?")

	assert_eq(v["_Current"], nil, "_Current not reseted.")
	assert_eq(v["_Conn"], nil, "_Conn not reseted.")
end

local function Test_GetTween()
	local v = Morph.new(Part)

	call(v._getTween, v).ShouldFail("Id not passed.")
	call(v._getTween, v, 1).ShouldFail("No state found.")

	v:AddState(State1)

	local t1: Tween = call(v._getTween, v, 1).ShouldPass("Should create tween.")

	assert_not_eq(v["_Tweens"][1], nil, "Tween not created?!")

	local t2: Tween = call(v._getTween, v, 1).ShouldPass("Should return stored tween.")

	assert_eq(t1, t2, "Tweens don't match.")
end

local function Test_Cancel()
	local v = call(function()
		return playingMorph():Cancel()
	end).ShouldPass("How did cancelling fail?")
	assert_eq(v["PlaybackState"], Enum.PlaybackState.Cancelled, "Morph not cancelled")
end

local function Test_Pause()
	local v = call(function()
		return playingMorph():Pause()
	end).ShouldPass("How did cancelling fail?")

	assert_eq(v["PlaybackState"], Enum.PlaybackState.Paused, "Morph not paused")

	return v
end

local function Test_ForcePlay()
	local v = Morph.new(Part):AddState(State1)

	call(v.ForcePlay, v, false).ShouldFail("Invalid state to play.")
	call(v.ForcePlay, v, 2).ShouldFail("State not found.")

	call(v.ForcePlay, v, 1).ShouldPass("Why did it fail??")

	assert_eq(v["_Current"], 1, "Current not updated")
	assert_eq(v["PlaybackState"], Enum.PlaybackState.Playing, "PlaybackState not updated")
	assert_not_eq(v["_Conn"], nil, "Finish connection wasn't connected properly")

	local start = os.clock()

	repeat
		if os.clock() - start > 5 then
			error("Tween didn't finish in time.")
		end
		task.wait()
	until v["PlaybackState"] == Enum.PlaybackState.Completed

	assert_eq(v["_Current"], nil, "_Current not reseted.")
	assert_eq(v["_Conn"], nil, "_Conn not reseted.")
end

local function Test_Wait()
	local v = Morph.new(Part)
	call(v.Wait, v, "aa").ShouldFail("Invalid parameter type.")
	call(v.Wait, v, 0.5).ShouldPass("Valid time number.")
end

local function Test_BindToFinish()
	local v1 = Morph.new(Part)
	local v2 = Morph.new(Part)

	call(v1.BindToFinish, v1, {}).ShouldFail("No value passed.")
	call(v1.BindToFinish, v1, { Other = v1 }).ShouldFail("Bind to itself.")
	call(v1.BindToFinish, v1, { Other = 1 }).ShouldFail("Invalid animator type.")

	call(v1.BindToFinish, v1, { Other = v2 }).ShouldPass("Passed valid params.")

	assert_not_eq(v1["_FinishBinds"][v2], nil, "Didn't store bind properly.")
end

local function Test_Unbind()
	local v1 = Morph.new(Part)
	local v2 = Morph.new(Part)

	call(v1.BindToFinish, v1, { Other = v2 }).ShouldPass("Passed valid params.")
	call(v1.UnBind, v1, v2).ShouldPass("How did it even fail???")

	assert_eq(v1["_FinishBinds"][v2], nil, "Didn't clean properly")
end

local function RunTests()
	local tests = {
		["Morph.new"] = Test_New,
		["Morph:AddState"] = Test_AddState,
		["Morph:_stop"] = Test_Stop,
		["Morph:_getTween"] = Test_GetTween,
		["Morph:Cancel"] = Test_Cancel,
		["Morph:Pause"] = Test_Pause,
		["Morph:ForcePlay"] = Test_ForcePlay,
		["Morph:Wait"] = Test_Wait,
		["Morph:BindToFinish"] = Test_BindToFinish,
		["Morph:UnBind"] = Test_Unbind,
	}

	for key, func in tests do
		print("Testing " .. key)

		local start = os.clock()

		local suc, res = pcall(func)

		if not suc then
			warn("\t Failed:\n" .. res)
		else
			local took = os.clock() - start
			print("\t Passed! Took " .. round_to_ms(took) .. "ms.")
		end
	end

	print("Finished running all tests.")
end

RunTests()
