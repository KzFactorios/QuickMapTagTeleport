local constants = require("settings/constants")
local PREFIX = constants.PREFIX

data:extend {

  {
    name = constants.events.ADD_TAG_INPUT,
    type = "custom-input",
    key_sequence = "mouse-button-2",
    order = "aa"
  },
  {
    name = constants.events.CLOSE_WITH_TOGGLE_MAP,
    type = "custom-input",
    key_sequence = "",
    linked_game_control = "toggle-map"
  },
  {
    type = "custom-input",
    name = PREFIX .. "teleport-to-fave-1",
    key_sequence = "CONTROL + 1",
    consuming = "game-only",
    order = "ca"
  },
  {
    type = "custom-input",
    name = PREFIX .. "teleport-to-fave-2",
    key_sequence = "CONTROL + 2",
    consuming = "game-only",
    order = "cb"
  },
  {
    type = "custom-input",
    name = PREFIX .. "teleport-to-fave-3",
    key_sequence = "CONTROL + 3",
    consuming = "game-only",
    order = "cc"
  },
  {
    type = "custom-input",
    name = PREFIX .. "teleport-to-fave-4",
    key_sequence = "CONTROL + 4",
    consuming = "game-only",
    order = "cd"
  },
  {
    type = "custom-input",
    name = PREFIX .. "teleport-to-fave-5",
    key_sequence = "CONTROL + 5",
    consuming = "game-only",
    order = "ce"
  },
  {
    type = "custom-input",
    name = PREFIX .. "teleport-to-fave-6",
    key_sequence = "CONTROL + 6",
    consuming = "game-only",
    order = "cf"
  },
  {
    type = "custom-input",
    name = PREFIX .. "teleport-to-fave-7",
    key_sequence = "CONTROL + 7",
    consuming = "game-only",
    order = "cg"
  },
  {
    type = "custom-input",
    name = PREFIX .. "teleport-to-fave-8",
    key_sequence = "CONTROL + 8",
    consuming = "game-only",
    order = "ch"
  },
  {
    type = "custom-input",
    name = PREFIX .. "teleport-to-fave-9",
    key_sequence = "CONTROL + 9",
    consuming = "game-only",
    order = "ci"
  },
  {
    type = "custom-input",
    name = PREFIX .. "teleport-to-fave-10",
    key_sequence = "CONTROL + 0",
    consuming = "game-only",
    order = "cj"
  },
}