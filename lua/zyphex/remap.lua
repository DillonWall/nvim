vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<cr>")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
-- vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>f", '<cmd>lua require("conform").format()<CR>')

vim.keymap.set("n", "<C-m>", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<C-,>", "<cmd>lprev<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>cprev<CR>zz")

vim.keymap.set("n", "<leader>S", [[:%S/<C-r><C-w>/<C-r><C-w>/gc<Left><Left><Left>]])
vim.keymap.set("n", "<leader>s", [[:%S/<C-r><C-w>//gc<Left><Left><Left>]])
-- Visual: substitute the selection file-wide. Plain words go through Abolish's
-- :S (case variants); anything else (/, regex chars, spaces, multi-line) falls
-- back to a literal \V :s, since :S can't escape its separator or \v specials.
local function visual_sub(prefill)
    return function()
        local text = table.concat(vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = vim.fn.mode() }), "\n")
        local cmd
        if text:match("^[%w_%-]+$") then
            cmd = "%S/" .. text .. "/" .. (prefill and text or "") .. "/gc"
        else
            local pat = vim.fn.escape(text, [[\/]]):gsub("\n", [[\n]]):gsub("\t", [[\t]])
            local rep = prefill and vim.fn.escape(text, [[\/&~]]):gsub("\n", [[\r]]):gsub("\t", [[\t]]) or ""
            cmd = [[%s/\V\C]] .. pat .. "/" .. rep .. "/gc"
        end
        -- selection text is typed raw (replace_keycodes = false), so "<Left>" in it stays literal
        return vim.keycode("<Esc>:") .. cmd .. vim.keycode("<Left><Left><Left>")
    end
end
vim.keymap.set("x", "<leader>S", visual_sub(true), { expr = true, replace_keycodes = false })
vim.keymap.set("x", "<leader>s", visual_sub(false), { expr = true, replace_keycodes = false })

-- one-eyed fighting kirby: capture each selected line, cursor in the replacement (\1 = the line)
vim.keymap.set("x", "<leader>k", [[:s/\(.*\)//<Left>]])

-- yank the Nth word of each selected line, one per line; N = count (2<leader>iw) or digit (<leader>2iw)
-- <leader>w: whitespace-separated (foo.bar(x) is one word); <leader>iw: keyword runs, symbols skipped
local function yank_nth_word(pat, fixed_n)
    return function()
        local n = fixed_n or math.max(vim.v.count, 1)
        local s, e = vim.fn.line("v"), vim.fn.line(".")
        if s > e then s, e = e, s end
        local words = {}
        for _, line in ipairs(vim.api.nvim_buf_get_lines(0, s - 1, e, false)) do
            local w = vim.fn.matchstr(line, pat, 0, n)
            if w ~= "" then table.insert(words, w) end
        end
        vim.fn.setreg('"', words, "l")
        vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
        vim.notify(("yanked word %d from %d lines"):format(n, #words))
    end
end
vim.keymap.set("x", "<leader>w", yank_nth_word([[\S\@<!\S\+]]))
vim.keymap.set("x", "<leader>iw", yank_nth_word([[\<\k\+]]))
for i = 1, 9 do
    vim.keymap.set("x", "<leader>" .. i .. "w", yank_nth_word([[\S\@<!\S\+]], i))
    vim.keymap.set("x", "<leader>" .. i .. "iw", yank_nth_word([[\<\k\+]], i))
end

-- reselect the last paste, in the mode it was pasted (char/line/block)
vim.keymap.set("n", "gp", function() return "`[" .. vim.fn.getregtype():sub(1, 1) .. "`]" end, { expr = true })
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set(
    "n",
    "<leader>ee",
    "oif err != nil {<CR>}<Esc>Oreturn err<Esc>"
)

vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>")

vim.keymap.set({ "n", "v" }, "<leader>cc", "<cmd>CopilotChatToggle<CR>")
vim.g.copilot_no_tab_map = true
vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<S-Tab>")', { expr = true, replace_keycodes = false })

-- vim.keymap.set("n", "<leader><leader>", function()
--     vim.cmd("so")
-- end)
