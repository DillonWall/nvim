return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        -- Draws images via kitty's graphics protocol; under tmux it needs
        -- allow-passthrough (set in ~/.tmux.conf). magick converts non-PNGs.
        image = { enabled = true },
    },
}
