local _, core = ...

function core:Print(...)
  DEFAULT_CHAT_FRAME:AddMessage(tostringall(...))
end




local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:RegisterEvent("VARIABLES_LOADED");
events:RegisterEvent("BAG_UPDATE_DELAYED");
events:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)


function events:ADDON_LOADED(name)
  if name ~= "AutoDeleteItems" then return end
  if AutoDeleteItems == nil then AutoDeleteItems = {} end
  AutoDeleteItems = AutoDeleteItems


  SLASH_AUTODELETEITEMS1= "/ad";
  SlashCmdList.AUTODELETEITEMS = function(msg)
    core:SlashCommand(msg)
  end
end

function events:VARIABLES_LOADED()

  StaticPopupDialogs["DELETE_ITEM"].button3 = "Auto-delete"
  StaticPopupDialogs["DELETE_ITEM"].OnAlt = function(self)
    local infoType, itemID, itemLink = GetCursorInfo()
    AutoDeleteItems[itemLink] = true
    DeleteCursorItem()
  end

end


function events:BAG_UPDATE_DELAYED()

  for bag = 0, NUM_BAG_SLOTS do
    for slot = 1, GetNumBagSlots(bag) do
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





function core:SlashCommand(args)
  local command, itemLinkChat, rest = strsplit(" ", args, 3)
  command = command:lower()

  if command == "save" then
    local itemName = GetItemInfo(itemLinkChat)
    if itemName then
      for itemLink, _ in pairs(AutoDelete) do
        if itemLink == itemLinkChat then
          AutoDelete[itemLink] = nil
          return
        end
      end
    end
  elseif command == "delete" then
    local itemName = GetItemInfo(itemLinkChat)
    if itemName then
      AutoDelete[itemLinkChat] = true
    end
  else
    core:Print("Available commands")
    core:Print("  delete [item link]: delete the linked item")
    core:Print("  save [item link]: do not delete the linked item")
  end
end
