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
E:RegisterEvent("BAG_UPDATE_DELAYED")
E:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)


--[[
    -- ADDON LOADED --
]]
function E:ADDON_LOADED(name)
  if name ~= "AutoDeleteItems" then return end
  if AutoDelete == nil then AutoDelete = {} end


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
    AutoDelete[itemLink] = true -- Add item to autodelete
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
    -- BAG UPDATE DELAYED --
    (WE WANT THE DELAYED ONE BECAUSE IT FIRES LAST)
]]
function E:BAG_UPDATE_DELAYED()
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
function A:SlashCommand(args)
  local command, rest = strsplit(" ", args, 2) -- Split args to a command and itemlink
  command = command:lower() -- command to lowercase for easier detection

  if command == "save" then
    local itemName = GetItemInfo(rest) -- Make sure the subcommand is an actual itemlink
    if itemName then
      for itemLink, _ in pairs(AutoDelete) do -- Loop through autodelete items
        if itemLink == rest then -- if match is found
          AutoDelete[itemLink] = nil -- delete table entry, (making the addon NOT delete that item)
          return
        end
      end
    end

  elseif command == "delete" then
    local itemName = GetItemInfo(rest) -- Make sure the subcommand is an actual itemlink
    if itemName then
      AutoDelete[rest] = true -- Add item to autodelete
    end

  elseif command == "list" then
    if A:Count(AutoDelete) > 0 then
      A:Print(A.addonName .. "- Deleting these items.")
      for i, _ in pairs(AutoDelete) do
        A:Print(i)
      end
    else
      A:Print(A.addonName .. "- No items being auto-deleted.")
    end

  else
    A:Print(A.addonName .. ": when you try deleting an item there will be a new button which will add that item to the auto-delete list. Other commands are listed below.")
    A:Print("Available commands")
    A:Print(A.slashPrefix.."delete [item link]: delete the linked item")
    A:Print(A.slashPrefix.."save [item link]: do NOT delete the linked item")
  end
end


function A:Count(T)
  local i = 0
  for _,_ in pairs(T) do
    i = i+1
  end
  return i
end
