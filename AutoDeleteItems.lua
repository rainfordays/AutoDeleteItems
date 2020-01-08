local _, core = ...

function core:Print(...)
  DEFAULT_CHAT_FRAME:AddMessage(tostringall(...))
end




local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:RegisterEvent("VARIABLES_LOADED");
events:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)


function events:ADDON_LOADED(name)
  if name ~= "AutoDeleteItems" then return end
  if AutoDeleteItems == nil then AutoDeleteItems = {} end
  AutoDeleteItems = AutoDeleteItems
end

function events:VARIABLES_LOADED()

  StaticPopupDialogs["DELETE_ITEM"].button3 = "Always"
  StaticPopupDialogs["DELETE_ITEM"].OnAlt = function(self)
    local infoType, itemID, itemLink = GetCursorInfo()
    AutoDeleteItems[itemLink] = true
    DeleteCursorItem()
  end

end