local constants = {}

constants.PREFIX = "quick-map-tag_"

local PRE = constants.PREFIX

constants.events = {
  ADD_TAG_INPUT = PRE .. "add-tag-input",
  TELEPORT_INPUT = PRE .. "teleport-input",
  CLOSE_WITH_TOGGLE_MAP = PRE .. "close-with-toggle-map",
  OPEN_STOCK_GUI = PRE .. "open-stock-gui",
}

return constants
