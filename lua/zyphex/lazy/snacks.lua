return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        -- Draws images via kitty's graphics protocol; under tmux it needs
        -- allow-passthrough (set in ~/.tmux.conf). magick converts non-PNGs.
        image = {
            enabled = true,
            convert = {
                magick = {
                    -- Pre-scale PNGs (pixel art) by the largest whole factor that
                    -- fits 1920x1080: -scale replicates pixels, so edges stay hard
                    -- and kitty's own (bilinear) scaling only nudges the size.
                    png = {
                        "{src}[0]",
                        "-scale", "%[fx:max(1,floor(min(1920/w,1080/h)))*100]%",
                        "-scale", "1920x1080>",
                    },
                },
            },
        },
    },
    config = function(_, opts)
        require("snacks").setup(opts)

        -- snacks shows PNGs as-is, skipping magick, so route them through the
        -- convert step to get the png args above. Its cache is keyed on path
        -- alone; add the mtime so an edited sprite isn't served stale.
        local Convert = getmetatable(require("snacks.image.convert").convert({ src = "x.png" }))
        local resolve = Convert.resolve
        function Convert:resolve()
            local st = self:ft() == "png" and vim.uv.fs_stat(self.src)
            if st then
                self.prefix = self.prefix .. "-" .. st.mtime.sec
                self:_resolve("convert")
            end
            resolve(self)
        end

        -- snacks hides an image buffer's image when it leaves the window but never
        -- un-hides it, so a reopened image stays blank. Wipe image buffers when
        -- hidden instead; reopening then re-reads and redraws them.
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "image",
            callback = function(ev)
                vim.bo[ev.buf].bufhidden = "wipe"
            end,
        })

        -- snacks only ever scales images down, so small images render a few
        -- cells wide. Blow them up by a whole factor to fill the window; whole
        -- factors keep the aspect ratio exact.
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
