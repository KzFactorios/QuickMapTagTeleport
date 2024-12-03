local constants = require("settings/constants")

data:extend {
  {
    name = constants.events.OPEN_STOCK_GUI,
    type = "custom-input",
    key_sequence = "mouse-button-1"
  },
  {
    name = constants.events.ADD_TAG_INPUT,
    type = "custom-input",
    key_sequence = "mouse-button-2"
  },
  {
    name = constants.events.CLOSE_WITH_TOGGLE_MAP,
    type = "custom-input",
    key_sequence = "",
    linked_game_control = "toggle-map"
  },
  {
    name = constants.events.FAVE_ORDER_UPDATED,
    type = "custom-input",
    key_sequence = "",
  },
  {
    name = constants.events.SELECTED_FAVE_CHANGED,
    type = "custom-input",
    key_sequence = "",
  },

}
