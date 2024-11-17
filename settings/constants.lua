local constants = {}

constants.PREFIX = "quick-map-tag_"

constants.events = {
  ADD_TAG_INPUT = constants.PREFIX .. "add-tag-input",
  TELEPORT_INPUT = constants.PREFIX .. "teleport-input",
  CLOSE_WITH_TOGGLE_MAP = constants.PREFIX .. "close-with-toggle-map"
}

return constants
