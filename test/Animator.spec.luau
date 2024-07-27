return function()
	local Morph = require(game.ReplicatedStorage.Morph)

	local part = Instance.new("Part")
	part.Anchored = true

	local state1 = {
		Id = 1,
		Goal = { Position = Vector3.zero },
		TweenInfo.new(10),
	}

	it("Valid requiring", function()
		expect(Morph).to.be.ok()
	end)

	describe("Creating animator", function()
		it("Valid argument", function()
			expect(function()
				return Morph.new(part)
			end).never.to.throw()
		end)

		it("Invalid argument", function()
			expect(function()
				Morph.new()
			end).to.throw()
		end)
	end)

	describe("Adding states", function()
		it("Invalid id", function()
			expect(function()
				Morph.new(part):AddState({
					Id = false,
				})
			end).to.throw()
		end)

		it("Valid string id", function()
			local new = Morph.new(part):AddState({
				Id = "Ola",
			})

			expect(new).to.be.ok()
			expect(new["_States"]["Ola"]).to.be.ok()
		end)

		it("Valid number id", function()
			local new = Morph.new(part):AddState({
				Id = 1,
			})

			expect(new).to.be.ok()
			expect(new["_States"][1]).to.be.ok()
		end)

		it("Multiple states", function()
			local new = Morph.new(part):AddState({ Id = 1 }):AddState({ Id = 2 })

			expect(new).to.be.ok()
			expect(#new["_States"]).to.equal(2)
			expect(new["_States"][1]).to.be.ok()
			expect(new["_States"][2]).to.be.ok()
		end)
	end)

	describe("Stopping", function()
		local new = Morph.new(part):AddState(state1)
		it("Playing", function()
			new:Play(1):Stop()

			expect(new["_isRunning"]).to.equal(false)
			expect(new["_isPaused"]).to.equal(false)
			expect(new["_Tween"]).never.to.be.ok()
			expect(new["_Conn"]).never.to.be.ok()
		end)

		it("Pausing", function()
			new:Play(1):Pause():Stop()

			expect(new["_isRunning"]).to.equal(false)
			expect(new["_isPaused"]).to.equal(false)
			expect(new["_Tween"]).never.to.be.ok()
			expect(new["_Conn"]).never.to.be.ok()
		end)
	end)

	describe("Waiting", function()
		it("Invalid type", function()
			expect(function()
				Morph.new(part):Wait("a")
			end).to.throw()
		end)
	end)

	describe("Pausing", function()
		it("Not playing", function()
			local new = Morph.new(part):Pause()

			expect(new["_isPaused"]).to.equal(false)
		end)

		it("Pause execution", function()
			local new = Morph.new(part):AddState(state1):Play(1):Pause()
			expect(new["_isPaused"]).to.equal(true)
		end)
	end)

	describe("Playing", function()
		it("Invalid Id", function()
			expect(function()
				Morph.new(part):Play(false)
			end).to.throw()
		end)

		it("Invalid state", function()
			expect(function()
				Morph.new(part):Play(1)
			end).to.throw()
		end)

		it("Valid variables", function()
			local new = Morph.new(part):AddState(state1):Play(1)

			expect(new["_Current"]).to.equal(1)
			expect(new["_isPaused"]).to.equal(false)
			expect(new["_isRunning"]).to.equal(true)
			expect(new["_Tween"]).to.be.ok()
			expect(new["_Conn"]).to.be.ok()
		end)
	end)

	part:Destroy()
end
