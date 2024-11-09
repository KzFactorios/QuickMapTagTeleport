local Constants = require("settings/constants")

data:extend {
  {
    name = Constants.events.ADD_TAG_INPUT,
    type = "custom-input",
    key_sequence = "mouse-button-2"
  },
  {
    name = Constants.events.CLOSE_WITH_TOGGLE_MAP,
    type = "custom-input",
    key_sequence = "",
    linked_game_control = "toggle-map"
  }
}
