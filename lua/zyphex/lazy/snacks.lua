return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        -- Draws images via kitty's graphics protocol; under tmux it needs
        -- allow-passthrough (set in ~/.tmux.conf). magick converts non-PNGs.
        image = { enabled = true },
    },
    config = function(_, opts)
        require("snacks").setup(opts)

        -- snacks only ever scales images down, so pixel-art sprites (16x32 etc.)
        -- render a few cells wide. Blow small ones up by a whole factor to fill
        -- the window; whole factors keep the aspect ratio exact.
        local util = require("snacks.image.util")
        local fit = util.fit
        util.fit = function(file, cells, o)
            -- fit divides by the PNG's DPI, so a junk pHYs chunk (x=0,y=1 on some
            -- exported sprites) skews the aspect into a 1-cell sliver. Treat any
            -- non-square DPI as plain 96.
            local dpi = o and o.info and o.info.dpi
            if dpi and dpi.width ~= dpi.height then
                o = vim.tbl_deep_extend("force", o, { info = { dpi = { width = 96, height = 96 } } })
            end
            local size = fit(file, cells, o)
            local k = math.floor(math.min(cells.width / size.width, cells.height / size.height))
            if k > 1 then
                size = { width = size.width * k, height = size.height * k }
            end
            return size
        end
    end,
}
