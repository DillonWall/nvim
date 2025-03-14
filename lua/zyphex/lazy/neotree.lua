return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
        -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function()
        require("neo-tree").setup({
            window = {
                width = 30
            },
            filesystem = {
                filtered_items = {
                    visible = true,
                    hide_dotfiles = false,
                    hide_gitignored = true,
                },
                hijack_netrw_behavior = "open_current"
            },
            event_handlers = { {
                event = "neo_tree_buffer_enter",
                handler = function(_)
                    vim.cmd [[
              setlocal relativenumber
            ]]
                end,
            } },
        })
    end,
    vim.keymap.set('n', '<leader>pv', ':Neotree filesystem reveal current toggle<CR>', {})
}
