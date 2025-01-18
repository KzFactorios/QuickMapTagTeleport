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

gui_style["row_container"] = {
  type = "frame_style",
  --parent = "inside_shallow_frame_with_padding",
  bottom_padding = 8,
}

gui_style["header_frame"] = {
  type = "frame_style"
}

gui_style["child_flow"] = {
  type = "flow_style"
}

gui_style["fave_text_label"] = {
  type = "label_style",
  width = 250,
  maximal_height = 80,
}

gui_style["fav_bar_gui"] = {
  type = "frame_style",
  parent = "invisible_frame",

  height = 40,
  padding = 0,
  top_padding = 0,
  bottom_padding = 0,
  horizontal_spacing = 0,
  vertical_spacing = 0,
}

--[[gui_style["fav_bar_label"] = {
  type = "label_style",
  parent = "label",
  bottom_margin = 12,
}]]

gui_style["fav_bar_slot_button_in_shallow_frame"] = {
  type = "button_style",
  parent = "slot_button",
  top_margin = 12,
  width = 72,
  height = 72,
}

gui_style["fav_bar_row"] = {
  type = "frame_style",
  parent = "invisible_frame",
  padding = 0,
  vertical_spacing = 0,
}

gui_style[PREFIX .. "toggle_favorite_mode_button"] = {
  type = "button_style",
  parent = "slot_button",
  width = 36,
  height = 36,
  top_margin = 2,
  background_color = { 1, 0, 0 },
  default_graphical_set = {
    base = {
      position = { 64, 0 },
      width = 32,
      height = 32,
      scale = 1.0,
      filename = "__base__/graphics/icons/signal/signal-heart.png",

    },
  },
  hovered_graphical_set = {
    base = {
      position = { 64, 0 },
      width = 32,
      height = 32,
      scale = 1.0,
      filename = "__base__/graphics/icons/signal/signal-heart.png",
    },
  },
  clicked_graphical_set = {
    base = {
      position = { 64, 0 },
      width = 32,
      height = 32,
      scale = 1.0,
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
    base = { position = { 0, 0 }, width = 32, height = 32, corner_size = 8, }
  },
  hovered_graphical_set = {
    base = {
      position = { 0, 0 },
      width = 32,
      height = 32,
      corner_size = 8,
      default_font_color = { .5, .5, 1 }
    },
  },
  clicked_graphical_set = {
    base = {
      position = { 0, 0 },
      width = 32,
      height = 32,
      corner_size = 8,
      default_font_color = { 1, 0, 0 },
      invert_colors = true
    },
  },
}

gui_style[PREFIX .. "edit-fave-gui-info-image"] = {
  type = "image_style",
  width = 8,
  height = 20,
  padding = 0,
  margin = 0,
  bottom_margin = 8,
  stretch_image_to_widget_size = true,
}
