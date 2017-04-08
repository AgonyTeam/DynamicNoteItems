local DNI = RegisterMod("Dynamic Note Items", 1)

DNI.Appeared = false
DNI.EscToPause = false
DNI.POS_ITEMS_PAUSE = Vector(64, 150) --position of first item (currently wrong)
DNI.POS_MY_LIST = Vector(290,135) --item list position

local toRender = { 
	HUD = Sprite()
}
toRender.HUD:Load("gfx/ui/pausescreen_mystuff.anm2", true) --init hud sprite

function DNI:getCurrentItems() --returns the items the player has
	local currList = {}
	local player = Isaac.GetPlayer(0)
	for name, id in pairs(CollectibleType) do
		if name ~= "NUM_COLLECTIBLES" and player:HasCollectible(id) then
			table.insert(currList, id)
		end
	end
	return currList
end

function DNI:getFilename(id) --returns gfx filename without path
	local origGfx = Isaac.GetItemConfig():GetCollectible(id).GfxFileName
	return origGfx:match(".*/(.-).png") .. ".png"
end

function DNI:addNote(id) --adds a note for an item
	local sprite = Sprite()
	sprite:Load("gfx/ui/dynamicnotes.anm2", false)
	sprite:ReplaceSpritesheet(0, "gfx/ui/deathnotes/" .. DNI:getFilename(id))
	sprite:LoadGraphics()
	sprite:Play("Item")
	toRender[#toRender+1] = sprite
end

function DNI:renderPause() --renders the pause menu list
	if Game():IsPaused() then
		if not DNI.Appeared then
			for _,item in pairs(DNI:getCurrentItems()) do
				DNI:addNote(item) --add all notesprites to the toRender table
			end
			toRender.HUD:Play("Appear")
			DNI.Appeared = true
		elseif toRender.HUD:IsFinished("Appear") and not toRender.HUD:IsPlaying("Dissapear") then
			toRender.HUD:Play("Idle")
		end
		if not toRender.HUD:IsPlaying("Appear") and (Input.IsActionTriggered(ButtonAction.ACTION_MENUBACK, 0) or Input.IsActionTriggered(ButtonAction.ACTION_PAUSE, 0)) then --play disappear anim when pressing esc or P
			toRender.HUD:Play("Dissapear")
		end
		toRender.HUD:Render(DNI.POS_MY_LIST, Vector(0,0), Vector(0,0))
		toRender.HUD:Update()
		for index, sprite in pairs(toRender) do --render note sprites
			if index ~= "HUD" then
				local renderPos = Vector(DNI.POS_ITEMS_PAUSE.X + (index-1)*16, DNI.POS_ITEMS_PAUSE.Y)
				sprite:RenderLayer(0, renderPos)
				sprite:Update()
			end
		end
	else --reset vars and clear table
		DNI.Appeared = false 
		toRender = {}
	end
end

function DNI:test()
	--Isaac.DebugString(DNI:getFilename(520))
	--if Game():GetFrameCount() <= 1 then
	--	DNI:addNote(CollectibleType.AGONY_C_PLACEHOLDER)
	--end
end

--DNI:AddCallback(ModCallbacks.MC_POST_UPDATE, DNI.test)
DNI:AddCallback(ModCallbacks.MC_POST_RENDER, DNI.renderPause)