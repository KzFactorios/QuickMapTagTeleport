local PREFIX = require("settings/constants").PREFIX

local gui_style = data.raw["gui-style"].default

gui_style[PREFIX .. "frame_action_button"] = {
  type = "button_style",
  parent = "frame_action_button",
  default_font_color = { 1, 1, 1 },
}

gui_style[PREFIX .. "red_confirm_button"] = {
  type = "button_style",
  parent = "red_confirm_button",
  default_font_color = { 0.1, 0.1, 0.1 },
  left_padding = 24,
  right_padding = 24,
}

gui_style[PREFIX .. "add_tag_textfield"] = {
  type = "textbox_style",
  width = 248,
  bottom_margin = 8,
}

gui_style[PREFIX .. "add_tag_table"] = {
  type = "table_style",
  horizontal_spacing = 8
}

gui_style[PREFIX .. "section_divider"] = {
  type = "line_style",
  height = 16,
}
