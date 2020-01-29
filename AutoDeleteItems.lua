local _, A = ...

function A:Print(...)
  DEFAULT_CHAT_FRAME:AddMessage(tostringall(...))
end


A.slashPrefix = "|cff42adf5/ad|r "
A.addonName = "|cff42adf5AutoDeleteItems|r "


--[[
    ---- EVENT FRAME ----
]]
local E = CreateFrame("Frame")
E:RegisterEvent("ADDON_LOADED")
E:RegisterEvent("VARIABLES_LOADED")
E:RegisterEvent("PLAYER_ENTERING_WORLD")
E:RegisterEvent("BAG_UPDATE")
E:RegisterEvent("START_LOOT_ROLL")
E:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)


--[[
    -- ADDON LOADED --
]]
function E:ADDON_LOADED(name)
  if name ~= "AutoDeleteItems" then return end
  if AutoDelete == nil then AutoDelete = {} end

  for itemLink, _ in pairs(AutoDelete) do
    if string.find(itemLink, "Hitem") then
      local itemName, _ = GetItemInfo(itemLink)
      AutoDelete[itemLink] = nil
      AutoDelete[itemName] = {itemLink = itemLink}
    end
  end

  for itemLink, _ in pairs(AutoDelete) do
    if string.find(itemLink, "Hitem") then
      AutoDelete[itemLink] = nil
    end
  end

  SLASH_AUTODELETEITEMS1= "/ad";
  SlashCmdList.AUTODELETEITEMS = function(msg)
    A:SlashCommand(msg)
  end
end



--[[
    -- VARIABLES LOADED --
]]
function E:VARIABLES_LOADED()

  StaticPopupDialogs["DELETE_ITEM"].button3 = "Auto-delete" -- Add third button to the delete item popup
  StaticPopupDialogs["DELETE_ITEM"].OnAlt = function(self) -- Add function for third button
    local infoType, itemID, itemLink = GetCursorInfo() -- Get cursor item info
    local itemName = GetItemInfo(itemLink)
    AutoDelete[itemName] = {itemLink = itemLink} -- Add item to autodelete
    DeleteCursorItem() -- Delete cursor item
  end
end


--[[
    -- PLAYER ENTERING WORLD --
]]
function E:PLAYER_ENTERING_WORLD(login, reloadUI)
  if login or reloadUI then
    A:Print(A.addonName .. "loaded. /ad for more information.")
  end
end


--[[
    -- START LOOT ROLL --
]]
function E:START_LOOT_ROLL(rollID, rollTimer)
  _, rollItemName = GetLootRollItemInfo(rollID)
  for ADitemName, table in pairs(AutoDelete) do
    if rollitemName == ADitemName then
      RollOnLoot(rollID, nil)
    end
  end
end



--[[
    -- BAG UPDATE DELAYED --
    (WE WANT THE DELAYED ONE BECAUSE IT FIRES LAST)
]]
function E:BAG_UPDATE(B)
  for S = 1, GetContainerNumSlots(B) do
    local itemLink = GetContainerItemLink(B, S)
    if itemLink then
      local itemName = GetItemInfo(itemLink)
      if AutoDelete[itemName] then
        PickupContainerItem(B, S)
        DeleteCursorItem()
      end
    end
  end
end



--[[
    ---- SLASH COMMANDS ----
]]
function A:SlashCommand(args)
  local command, rest = strsplit(" ", args, 2) -- Split args to a command and itemlink
  command = command:lower() -- command to lowercase for easier detection

  if command == "save" then
    local itemName, itemLink = GetItemInfo(rest) -- Make sure the subcommand is an actual itemlink
    if itemName then
      for itemNameSaved, data in pairs(AutoDelete) do -- Loop through autodelete items
        if itemName == itemNameSaved then -- if match is found
          AutoDelete[itemName] = nil -- delete table entry, (making the addon NOT delete that item)
          A:Print(A.addonName .. "no longer deleting " .. itemLink)
          return
        end
      end
    end

  elseif command == "delete" then
    local itemName, itemLink = GetItemInfo(rest) -- Make sure the subcommand is an actual itemlink
    if itemName then
      AutoDelete[itemName] = {itemLink = itemLink} -- Add item to autodelete
      A:Print(A.addonName .. " auto-deleting " .. itemLink)
    end

  elseif command == "list" then
    if A:Count(AutoDelete) > 0 then
      A:Print(A.addonName .. "- Deleting these items.")
      for itemName, data in pairs(AutoDelete) do
        A:Print(data.itemLink)
      end
    else
      A:Print(A.addonName .. "- No items being auto-deleted.")
    end

  else
    A:Print(A.addonName .. ": when you try deleting an item there will be a new button which will add that item to the auto-delete list. Other commands are listed below.")
    A:Print("Available commands")
    A:Print(A.slashPrefix.."delete [item link]: delete the linked item")
    A:Print(A.slashPrefix.."save [item link]: do NOT delete the linked item")
    A:Print(A.slashPrefix.."list: list items being auto-deleted")
  end
end


function A:Count(T)
  local i = 0
  for _,_ in pairs(T) do
    i = i+1
  end
  return i
end
