local icons = require("icons")
local colors = require("appearance").colors

local whitelist = {
  ["Spotify"] = true,
  ["Music"]   = true,
}

local media_cover = sbar.add("item", {
  position = "right",
  background = {
    color         = colors.transparent,
    image         = { scale = 0.85 },
    corner_radius = 6,
  },
  label   = { drawing = false },
  icon    = { drawing = false },
  drawing = false,
  popup = {
    align      = "center",
    horizontal = false,
    background = {
      color         = colors.bg1,
      border_color  = colors.bg2,
      border_width  = 2,
      corner_radius = 12,
    },
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

-- ── Popup items ─────────────────────────────────────────────────────────────

-- Large artwork image at the top of the popup
local popup_artwork = sbar.add("item", {
  position = "popup." .. media_cover.name,
  icon     = { drawing = false },
  label    = { drawing = false },
  background = {
    color         = colors.transparent,
    image         = { scale = 0.5 },
    corner_radius = 10,
    height        = 200,
    drawing       = true,
  },
  padding_left  = 8,
  padding_right = 8,
})

-- Controls row — previous, play/pause, next
local popup_prev = sbar.add("item", {
  position     = "popup." .. media_cover.name,
  icon         = { string = icons.media.back, font = { size = 16 }, color = colors.white },
  label        = { drawing = false },
  padding_left = 12,
  padding_right = 12,
  click_script = "nowplaying-cli previous",
})

local popup_play = sbar.add("item", {
  position      = "popup." .. media_cover.name,
  icon          = { string = icons.media.play_pause, font = { size = 20 }, color = colors.white },
  label         = { drawing = false },
  padding_left  = 12,
  padding_right = 12,
  click_script  = "nowplaying-cli togglePlayPause",
})

local popup_next = sbar.add("item", {
  position      = "popup." .. media_cover.name,
  icon          = { string = icons.media.forward, font = { size = 16 }, color = colors.white },
  label         = { drawing = false },
  padding_left  = 12,
  padding_right = 12,
  click_script  = "nowplaying-cli next",
})

-- Bracket the three controls so they sit on one horizontal line
sbar.add("bracket", "media.controls.bracket",
  { "media.popup.prev", "media.popup.play", "media.popup.next" },
  {
    background = {
      color         = colors.bg2,
      corner_radius = 10,
      height        = 36,
      drawing       = true,
    },
  }
)
-- ── Logic ────────────────────────────────────────────────────────────────────

local interrupt = 0

local function animate_detail(detail)
  if not detail then interrupt = interrupt - 1 end
  if interrupt > 0 and not detail then return end
  sbar.animate("tanh", 30, function()
    media_artist:set({ label = { width = detail and "dynamic" or 0 } })
    media_title:set({ label = { width = detail and "dynamic" or 0 } })
  end)
end

local function update_artwork()
  sbar.exec(
    "nowplaying-cli get artworkData | tr -d '\n' | base64 -d > /tmp/sketchybar_artwork.jpg",
    function()
      media_cover:set({
        background = { image = { string = "/tmp/sketchybar_artwork.jpg", scale = 0.05 } },
      })
      popup_artwork:set({
        background = { image = { string = "/tmp/sketchybar_artwork.jpg", scale = 0.65 } },
      })
    end
  )
end

-- Poll nowplaying-cli every 5 seconds
local poller = sbar.add("item", {
  drawing     = false,
  updates     = true,
  update_freq = 5,
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

        media_cover:set({ drawing = true })
        update_artwork()

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
