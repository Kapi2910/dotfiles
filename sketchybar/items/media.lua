local icons = require("icons")
local colors = require("colors")

local media_cover = sbar.add("item", {
  position = "right",
  background = {
    color        = colors.transparent,
    image        = { scale = 0.85 },
    corner_radius = 6,
  },
  label   = { drawing = false },
  icon    = { drawing = false },
  drawing = false,
  popup = {
    align      = "center",
    horizontal = true,
  }
})

local media_artist = sbar.add("item", {
  position      = "right",
  drawing       = false,
  padding_left  = 3,
  padding_right = 0,
  width         = 0,
  icon          = { drawing = false },
  label = {
    width     = 0,
    font      = { size = 9 },
    color     = colors.with_alpha(colors.white, 0.6),
    max_chars = 18,
    y_offset  = 6,
  },
})

local media_title = sbar.add("item", {
  position      = "right",
  drawing       = false,
  padding_left  = 3,
  padding_right = 0,
  icon          = { drawing = false },
  label = {
    font      = { size = 11 },
    width     = 0,
    max_chars = 16,
    y_offset  = -5,
  },
})

sbar.add("item", {
  position     = "popup." .. media_cover.name,
  icon         = { string = icons.media.back },
  label        = { drawing = false },
  click_script = "nowplaying-cli previous",
})

sbar.add("item", {
  position     = "popup." .. media_cover.name,
  icon         = { string = icons.media.play_pause },
  label        = { drawing = false },
  click_script = "nowplaying-cli togglePlayPause",
})

sbar.add("item", {
  position     = "popup." .. media_cover.name,
  icon         = { string = icons.media.forward },
  label        = { drawing = false },
  click_script = "nowplaying-cli next",
})

local interrupt = 0
local function animate_detail(detail)
  if not detail then interrupt = interrupt - 1 end
  if interrupt > 0 and not detail then return end
  sbar.animate("tanh", 30, function()
    media_artist:set({ label = { width = detail and "dynamic" or 0 } })
    media_title:set({ label = { width = detail and "dynamic" or 0 } })
  end)
end

-- Poll nowplaying-cli every 5 seconds
local poller = sbar.add("item", {
  drawing     = false,
  updates     = true,
  update_freq = 3,
})

poller:subscribe("routine", function()
  sbar.exec("nowplaying-cli get playbackRate", function(rate)
    local playing = rate and rate:match("^%s*(.-)%s*$") == "1"

    if not playing then
      media_cover:set({ drawing = false, popup = { drawing = false } })
      media_artist:set({ drawing = false })
      media_title:set({ drawing = false })
      return
    end

    sbar.exec("nowplaying-cli get artist", function(artist)
      sbar.exec("nowplaying-cli get title", function(title)
        artist = artist and artist:match("^%s*(.-)%s*$") or ""
        title  = title  and title:match("^%s*(.-)%s*$") or ""

        media_artist:set({ drawing = true, label = { string = artist } })
        media_title:set({ drawing = true, label = { string = title } })

        sbar.exec(
          "nowplaying-cli get artworkData | tr -d '\n' | base64 -d > /tmp/sketchybar_artwork.jpg",
          function()
            media_cover:set({
              drawing = true,
              background = {
                image = { string = "/tmp/sketchybar_artwork.jpg", scale = 0.05 },
              },
            })
          end
        )

        animate_detail(true)
        interrupt = interrupt + 1
        sbar.delay(5, animate_detail)
      end)
    end)
  end)
end)

media_cover:subscribe("mouse.entered", function()
  interrupt = interrupt + 1
  animate_detail(true)
end)

media_cover:subscribe("mouse.exited", function()
  animate_detail(false)
end)

media_cover:subscribe("mouse.clicked", function()
  media_cover:set({ popup = { drawing = "toggle" } })
end)

media_title:subscribe("mouse.exited.global", function()
  media_cover:set({ popup = { drawing = false } })
end)
