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



gui_style["fav_bar_gui"] = {
  type = "frame_style",
  parent = "invisible_frame",
  padding = 0,
  --padding_right = 0,
  horizontal_spacing = 0,
}

gui_style["fav_bar_row"] = {
  type = "frame_style",
  parent = "invisible_frame",
  height = 40,
  padding = 0,
  vertical_spacing = 0,
}

gui_style[PREFIX .. "toggle_favorite_mode_button"] = {
  type = "button_style",
  parent = "mod_gui_button",
  width = 40,
  height = 40,
  background_color = {1,0,0},
  default_graphical_set = {
    base = {
      position = { 64, 0 },
      width = 32,
      height = 32,
      scale = 1.0,
      border = 1,
      filename = "__base__/graphics/icons/signal/signal-heart.png",
      
    },
  },
  hovered_graphical_set = {
    base = {
      position = { 64, 0 },
      width = 32,
      height = 32,
      scale = 1.0,
      border = 1,
      filename = "__base__/graphics/icons/signal/signal-heart.png",
    },
  },
  clicked_graphical_set = {
    base = {
      position = { 64, 0 },
      width = 32,
      height = 32,
      scale = 1.0,
      border = 1,
      filename = "__base__/graphics/icons/signal/signal-heart.png",
    },
  }
}

gui_style["light_blue_button_style"] = {
  type = "button_style",
  parent = "slot_button",
  --top_margin = 8,
  default_font_color = { 1, 1, 1 },
  font = "custom-tiny-font",

  default_background = { 1, 0, 0 },
  width = 40,
  height = 40,
  default_graphical_set = {
    base = { position = { 0, 0 }, width = 32, height = 32, corner_size = 8,}
  },
  hovered_graphical_set = {
    base = { position = { 0, 0 }, width = 32, height = 32, corner_size = 8,
      default_font_color = { .5,.5,1} },
  },
  clicked_graphical_set = {
    base = { position = { 0, 0 }, width = 32, height = 32, corner_size = 8,
      default_font_color = { 1, 0, 0 }, invert_colors = true },
  },
}

gui_style[PREFIX .. "edit-fave-gui-info-image"] = {
  type = "image_style",
  width = 20,
  height = 50,
  stretch_image_to_widget_size = true,
}
