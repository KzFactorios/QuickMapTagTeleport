data:extend({
  {
    type = "font",
    name = "custom-tiny-font",
    from = "default",
    size = 8,      -- Adjust this size to be smaller than default-tiny
    border = false -- Set to true if you want better readability with a border
  },
  {
    type = "sprite",
    name = "custom-map-view-tag",
    filename = "__QuickMapTagTeleport__/graphics/tag-in-map-view.png",
    priority = "extra-high",
    size = { 32, 49 },
    flags = { "gui-icon" },
  }
})


require("prototypes/styles")
require("prototypes/custom_input_events")
