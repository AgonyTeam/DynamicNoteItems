local DNI = RegisterMod("Dynamic Note Items", 1)

--PauseMenu
DNI.Appeared = false
DNI.PauseMenu = false
DNI.MenuItems = {
	OPTIONS = 1,
	RESUME = 2,
	EXIT = 3
}
DNI.MenuItem = DNI.MenuItems.RESUME
DNI.POS_ITEMS_PAUSE = Vector(255, 117) --position of first item
DNI.POS_MY_LIST = Vector(290,135) --item list position
--DeathCard

--Renderqueue
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
	table.insert(toRender, sprite)
end

function DNI:calcPauseItemPosition(index)
	return Vector(DNI.POS_ITEMS_PAUSE.X + math.floor((index-1)/4)*16 + math.floor((index-1)/4), DNI.POS_ITEMS_PAUSE.Y + ((index-1)%4)*16 + ((index-1)%4))
end

function DNI:renderPause() --renders the pause menu list
	if Game():IsPaused() then
		if DNI.PauseMenu then --if in main pause menu
			if Input.IsActionTriggered(ButtonAction.ACTION_MENUUP, 0) then --track cursor movement
				if DNI.MenuItem > DNI.MenuItems.OPTIONS then
					DNI.MenuItem = DNI.MenuItem - 1
				else
					DNI.MenuItem = DNI.MenuItems.EXIT
				end
			elseif Input.IsActionTriggered(ButtonAction.ACTION_MENUDOWN, 0) then
				if DNI.MenuItem < DNI.MenuItems.EXIT then
					DNI.MenuItem = DNI.MenuItem + 1
				else
					DNI.MenuItem = DNI.MenuItems.OPTIONS
				end
			elseif Input.IsActionTriggered(ButtonAction.ACTION_MENUCONFIRM, 0) then --track enter press, if selected menu is options, make hud invisible
				if DNI.MenuItem == DNI.MenuItems.RESUME then
					toRender.HUD:Play("Dissapear")
				elseif DNI.MenuItem == DNI.MenuItems.OPTIONS then
					toRender.HUD.Color = Color(1,1,1,0,0,0,0)
					DNI.PauseMenu = false
				end
			elseif Input.IsActionTriggered(ButtonAction.ACTION_MENUBACK, 0) or Input.IsActionTriggered(ButtonAction.ACTION_PAUSE, 0) then --if game is resumed not by pressing enter, make the hud disappear
				toRender.HUD:Play("Dissapear")
			end
		elseif not DNI.PauseMenu and DNI.MenuItem == DNI.MenuItems.RESUME then --reset PauseMenu bool
			DNI.PauseMenu = true
		else --if not in pausemenu
			if Input.IsActionTriggered(ButtonAction.ACTION_MENUBACK, 0) then --when reentering pausemenu, make it visible
				DNI.PauseMenu = true
				toRender.HUD.Color = Color(1,1,1,1,0,0,0)
			end
		end
		if not DNI.Appeared and not toRender.HUD:IsPlaying("Dissapear") then
			for _,item in pairs(DNI:getCurrentItems()) do
				DNI:addNote(item) --add all notesprites to the toRender table
			end
			toRender.HUD:Play("Appear")
			DNI.Appeared = true
		elseif toRender.HUD:IsFinished("Appear") and not toRender.HUD:IsPlaying("Dissapear") then
			toRender.HUD:Play("Idle")
		end
		toRender.HUD:Render(DNI.POS_MY_LIST, Vector(0,0), Vector(0,0))
		toRender.HUD:Update()
		for index, sprite in pairs(toRender) do --render note sprites
			if index ~= "HUD" then
				--play the same anims and color as hud
				if toRender.HUD:IsPlaying("Appear") and not sprite:IsPlaying("Appear") then
					sprite:Play("Appear")
				elseif toRender.HUD:IsPlaying("Idle") and not sprite:IsPlaying("Idle") then
					sprite:Play("Idle")
				elseif toRender.HUD:IsPlaying("Dissapear") and not sprite:IsPlaying("Disappear") then
					sprite:Play("Disappear")
				end
				sprite.Color = toRender.HUD.Color
				sprite:RenderLayer(0, DNI:calcPauseItemPosition(index))
				sprite:Update()
			end
		end
	else --reset vars and clear table
		DNI.MenuItem = DNI.MenuItems.RESUME
		DNI.Appeared = false 
		DNI.PauseMenu = false
		local tmpHUD = toRender.HUD
		toRender = {HUD = tmpHUD}
	end
end

function DNI:test()
	--Isaac.DebugString(DNI:getFilename(520))
	--if Game():GetFrameCount() <= 1 then
	--	DNI:addNote(CollectibleType.AGONY_C_PLACEHOLDER)
	--end
	debug_tbl1 = toRender
	--debug_text = tostring(Game():IsPaused())
end

DNI:AddCallback(ModCallbacks.MC_POST_UPDATE, DNI.test)
DNI:AddCallback(ModCallbacks.MC_POST_RENDER, DNI.renderPause)