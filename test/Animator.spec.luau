return function()
	local Morph = require(game.ReplicatedStorage.Morph)

	local part = Instance.new("Part")
	part.Anchored = true

	local state1 = {
		Id = 1,
		Goal = {
			Position = Vector3.zero,
		},
		Info = TweenInfo.new(10),
	}

	describe("Created animator", function()
		it("Created animator", function()
			local new = Morph.new(part)
			expect(new).to.be.ok()
		end)

		it("Invalid object for creating", function()
			expect(Morph.new).to.throw("Invalid object.")
		end)
	end)

	describe("Adding States", function()
		it("Add valid state", function()
			expect(function()
				return Morph.new(part):AddState(state1)
			end).never.to.throw()
		end)

		it("Add invalid state id", function()
			expect(function()
				local state2 = table.clone(state1)
				state2["Id"] = false
				return Morph.new(part):AddState(state2)
			end).to.throw("Id must be a string or a number.")
		end)
	end)

	describe("Play", function()
		it("Can play", function()
			local new = Morph.new(part):AddState(state1)
			expect(function()
				new:Play(1)
			end).never.to.throw()
		end)

		it("Can pause", function()
			local new = Morph.new(part):AddState(state1)
			expect(function()
				return new:Play(1):Pause()["_isPaused"]
			end).never.to.equal(true)
		end)
	end)

    it("Clean on stop",function()
        local new = Morph.new(part):AddState(state1):Stop()
        expect(new["_isPaused"]).to.equal(false)
        expect(new["_isRunning"]).to.equal(false)
        expect(new["_Tween"]).never.to.be.ok()
        expect(new["_Conn"]).never.to.be.ok()
    end)

	part:Destroy()
end
