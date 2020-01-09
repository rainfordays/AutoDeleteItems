local _, core = ...

function core:Print(...)
  DEFAULT_CHAT_FRAME:AddMessage(tostringall(...))
end


core.prefix = "|cff42adf5/ad|r "
core.addonName = "|cff42adf5AutoDeleteItems|r "


--[[
    ---- EVENT FRAME ----
]]
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("VARIABLES_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("BAG_UPDATE_DELAYED")
events:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)


--[[
    -- ADDON LOADED --
]]
function events:ADDON_LOADED(name)
  if name ~= "AutoDeleteItems" then return end
  if AutoDelete == nil then AutoDelete = {} end


  SLASH_AUTODELETEITEMS1= "/ad";
  SlashCmdList.AUTODELETEITEMS = function(msg)
    core:SlashCommand(msg)
  end
end



--[[
    -- VARIABLES LOADED --
]]
function events:VARIABLES_LOADED()

  StaticPopupDialogs["DELETE_ITEM"].button3 = "Auto-delete" -- Add third button to the delete item popup
  StaticPopupDialogs["DELETE_ITEM"].OnAlt = function(self) -- Add function for third button
    local infoType, itemID, itemLink = GetCursorInfo() -- Get cursor item info
    AutoDelete[itemLink] = true -- Add item to autodelete
    DeleteCursorItem() -- Delete cursor item
  end
end


--[[
    -- PLAYER ENTERING WORLD --
]]
function events:PLAYER_ENTERING_WORLD(login, reloadUI)
  if login or reloadUI then
    core:Print(core.addonName .. "loaded. /ad for more information.")
  end
end



--[[
    -- BAG UPDATE DELAYED --
    (WE WANT THE DELAYED ONE BECAUSE IT FIRES LAST)
]]
function events:BAG_UPDATE_DELAYED()
  for bag = 0, NUM_BAG_SLOTS do
    for slot = 1, GetContainerNumSlots(bag) do
      local itemLink = GetContainerItemLink(bag, slot)
      if itemLink then
        if AutoDelete[itemLink] then
          PickupContainerItem(bag, slot)
          DeleteCursorItem()
        end
      end
    end
  end

end



--[[
    ---- SLASH COMMANDS ----
]]
function core:SlashCommand(args)
  local command, itemLinkChat, rest = strsplit(" ", args, 3) -- Split args to a command and itemlink
  command = command:lower() -- command to lowercase for easier detection

  if command == "save" then
    local itemName = GetItemInfo(itemLinkChat) -- Make sure the subcommand is an actual itemlink
    if itemName then
      for itemLink, _ in pairs(AutoDelete) do -- Loop through autodelete items
        if itemLink == itemLinkChat then -- if match is found
          AutoDelete[itemLink] = nil -- delete table entry, (making the addon NOT delete that item)
          return
        end
      end
    end
  elseif command == "delete" then
    local itemName = GetItemInfo(itemLinkChat) -- Make sure the subcommand is an actual itemlink
    if itemName then
      AutoDelete[itemLinkChat] = true -- Add item to autodelete
    end
  else
    core:Print(core.addonName .. ": when you try deleting an item there will be a new button which will add that item to the auto-delete list. Other commands are listed below.")
    core:Print("Available commands")
    core:Print(core.prefix.."delete [item link]: delete the linked item")
    core:Print(core.prefix.."save [item link]: do NOT delete the linked item")
  end
end
