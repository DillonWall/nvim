return {

    {
        "nvimtools/none-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "nvim-lua/plenary.nvim" },
    },

    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/nvim-cmp",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "j-hui/fidget.nvim",
            "nvimtools/none-ls.nvim",
        },

        config = function()
            local cmp = require('cmp')
            local cmp_lsp = require("cmp_nvim_lsp")
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                cmp_lsp.default_capabilities())

            require("fidget").setup({})
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",
                    "gopls",
                    "html",
                    "cssls",
                    "tailwindcss",
                    "emmet_language_server",
                    "eslint",
                    "prettierd",
                    "ts_ls",
                    -- "gopls@v0.14.2",
                },
                handlers = {
                    function(server_name) -- default handler (optional)
                        require("lspconfig")[server_name].setup {
                            capabilities = capabilities
                        }
                    end,

                    zls = function()
                        local lspconfig = require("lspconfig")
                        lspconfig.zls.setup({
                            root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
                            settings = {
                                zls = {
                                    enable_inlay_hints = true,
                                    enable_snippets = true,
                                    warn_style = true,
                                },
                            },
                        })
                        vim.g.zig_fmt_parse_errors = 0
                        vim.g.zig_fmt_autosave = 0
                    end,
                    ["lua_ls"] = function()
                        local lspconfig = require("lspconfig")
                        lspconfig.lua_ls.setup {
                            capabilities = capabilities,
                            settings = {
                                Lua = {
                                    runtime = { version = "Lua 5.1" },
                                    diagnostics = {
                                        globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                                    }
                                }
                            }
                        }
                    end,
                    ['ts_ls'] = function()
                        -- 1. Import Mason Registry
                        -- local mason_registry = require('mason-registry')
                        -- local vue_language_server_path = mason_registry.get_package('vue-language-server'):get_install_path() ..
                        --     '/node_modules/@vue/language-server'

                        -- 2. Import lspconfig
                        local lspconfig = require('lspconfig')

                        -- 3. Configure ts_ls for TypeScript and Vue
                        lspconfig.ts_ls.setup {
                            -- init_options = {
                            --     plugins = {
                            --         {
                            --             name = '@vue/typescript-plugin',
                            --             location = vue_language_server_path,
                            --             languages = { 'vue' },
                            --         },
                            --     },
                            -- },
                            filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
                        }
                    end,
                }
            })

            -- null-ls setup for prettier
            local none_ls = require("null-ls")
            local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })

            none_ls.setup({
                sources = {
                    none_ls.builtins.formatting.prettier,
                },
                on_attach = function(client, bufnr)
                    if client.supports_method("textDocument/formatting") then
                        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            group = augroup,
                            buffer = bufnr,
                            callback = function()
                                vim.lsp.buf.format({ bufnr = bufnr, filter = function(c) return c.name == "null-ls" end })
                            end,
                        })
                    end
                end,
            })

            local cmp_select = { behavior = cmp.SelectBehavior.Select }

            cmp.setup({
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' }, -- For luasnip users.
                }, {
                    { name = 'buffer' },
                })
            })

            vim.diagnostic.config({
                -- update_in_insert = true,
                float = {
                    focusable = false,
                    style = "minimal",
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
            })
        end,
    }
}
