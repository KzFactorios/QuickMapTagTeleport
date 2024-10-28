local PREFIX = require("Constants").PREFIX

local gui_style = data.raw["gui-style"].default

gui_style[PREFIX .. "add_tag_textfield"] = {
  type = "textbox_style",
  width = 248
}

gui_style[PREFIX .. "add_tag_table"] = {
  type = "table_style",
  horizontal_spacing = 8
}
