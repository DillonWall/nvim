return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup()

        -- `main` has no `ensure_installed`/`auto_install`; parsers must be listed.
        require("nvim-treesitter").install({
            "bash", "c", "diff", "gitcommit", "gitignore", "javascript",
            "jsdoc", "json", "liquid", "lua", "markdown",
            "markdown_inline", "nginx", "pem", "python", "rust", "sql",
            "ssh_config", "toml", "tsx", "typescript", "vim",
            "vimdoc", "yaml", "zig",
        })

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("zyphex_treesitter", { clear = true }),
            desc = "Enable Treesitter highlighting and indentation",
            callback = function(args)
                if not pcall(vim.treesitter.start, args.buf) then
                    return
                end

                vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

                if args.match == "markdown" then
                    vim.bo[args.buf].syntax = "on"
                end
            end,
        })

        -- -- Only needed if using templ (HTML + Go)
        -- vim.api.nvim_create_autocmd("User", { pattern = "TSUpdate", callback = function()
        --     require("nvim-treesitter.parsers").templ = {
        --         install_info = {
        --             url = "https://github.com/vrischmann/tree-sitter-templ.git",
        --             branch = "master",
        --         },
        --     }
        -- end })
        --
        -- vim.treesitter.language.register("templ", "templ")
    end
}
