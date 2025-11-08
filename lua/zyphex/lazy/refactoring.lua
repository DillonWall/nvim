return {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    lazy = false,
    opts = {},
    config = function()
        require('refactoring').setup({
            prompt_func_return_type = {
                go = false,
                java = false,

                cpp = false,
                c = false,
                h = false,
                hpp = false,
                cxx = false,
            },
            prompt_func_param_type = {
                go = false,
                java = false,

                cpp = false,
                c = false,
                h = false,
                hpp = false,
                cxx = false,
            },
            printf_statements = {},
            print_var_statements = {},
            show_success_message = true, -- shows a message with information about the refactor on success
            -- i.e. [Refactor] Inlined 3 variable occurrences
        })
    end,
    vim.keymap.set({ "n", "x" }, "<leader>re", function() return require('refactoring').refactor('Extract Function') end,
        { expr = true }),
    vim.keymap.set({ "n", "x" }, "<leader>rf",
        function() return require('refactoring').refactor('Extract Function To File') end, { expr = true }),
    vim.keymap.set({ "n", "x" }, "<leader>rv", function() return require('refactoring').refactor('Extract Variable') end,
        { expr = true }),
    vim.keymap.set({ "n", "x" }, "<leader>rI", function() return require('refactoring').refactor('Inline Function') end,
        { expr = true }),
    vim.keymap.set({ "n", "x" }, "<leader>ri", function() return require('refactoring').refactor('Inline Variable') end,
        { expr = true }),

    vim.keymap.set({ "n", "x" }, "<leader>rbb", function() return require('refactoring').refactor('Extract Block') end,
        { expr = true }),
    vim.keymap.set({ "n", "x" }, "<leader>rbf",
        function() return require('refactoring').refactor('Extract Block To File') end, { expr = true }),
}
