local constants = {}

constants.PREFIX = "quick-map-tag_"
local PRE = constants.PREFIX

constants.events = {
  ADD_TAG_INPUT = PRE .. "add-tag-input",
  TELEPORT_INPUT = PRE .. "teleport-input",
  CLOSE_WITH_TOGGLE_MAP = PRE .. "close-with-toggle-map",
  OPEN_STOCK_GUI = PRE .. "open-stock-gui",
  FAVE_ORDER_UPDATED = "fave-order-updated",
  SELECTED_FAVE_CHANGED = "selected-fave-changed",
}

return constants
