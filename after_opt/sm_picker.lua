local api = require("sm.api")
local fzf = require("fzf-lua")

local function create_memo_previewer(lookup)
  local builtin = require("fzf-lua.previewer.builtin")
  local MemoPreview = builtin.buffer_or_file:extend()

  function MemoPreview:new(o, opts, fzf_win)
    o = o or {}
    o.render_markdown = false
    MemoPreview.super.new(self, o, opts, fzf_win)
    setmetatable(self, MemoPreview)
    return self
  end

  function MemoPreview:parse_entry(entry_str)
    local path = lookup[entry_str]
    if not path then
      return {}
    end
    return { path = path, line = 1, col = 1 }
  end

  return MemoPreview
end

-- List and open memos
vim.keymap.set("n", "<Leader>xl", function()
  local entries = api.get_memos()
  local items = {}
  local lookup = {}
  for _, entry in ipairs(entries) do
    table.insert(items, entry.text)
    lookup[entry.text] = entry.value
  end
  fzf.fzf_exec(items, {
    prompt = "Memos> ",
    previewer = create_memo_previewer(lookup),
    actions = {
      ["default"] = function(selected)
        if selected[1] then
          api.open_memo(lookup[selected[1]])
        end
      end,
    },
  })
end, { desc = "[sm] List memos" })

-- Grep within memos directory
vim.keymap.set("n", "<Leader>xg", function()
  fzf.live_grep({ cwd = api.get_memos_dir() })
end, { desc = "Grep memos" })

-- Browse memos by tag
vim.keymap.set("n", "<Leader>xt", function()
  local entries = api.get_tags()
  local items = {}
  local lookup = {}
  for _, entry in ipairs(entries) do
    table.insert(items, entry.text)
    lookup[entry.text] = entry.value
  end
  fzf.fzf_exec(items, {
    prompt = "Tags> ",
    actions = {
      ["default"] = function(selected)
        if selected[1] then
          local tag = lookup[selected[1]]
          local memo_entries = api.get_memos_by_tag(tag)
          local memo_items = {}
          local memo_lookup = {}
          for _, e in ipairs(memo_entries) do
            table.insert(memo_items, e.text)
            memo_lookup[e.text] = e.value
          end
          fzf.fzf_exec(memo_items, {
            prompt = "Memos [" .. tag .. "]> ",
            previewer = create_memo_previewer(memo_lookup),
            actions = {
              ["default"] = function(sel)
                if sel[1] then
                  api.open_memo(memo_lookup[sel[1]])
                end
              end,
            },
          })
        end
      end,
    },
  })
end, { desc = "[sm] Browse tags" })

-- Insert wiki-style link
vim.keymap.set("n", "<Leader>xi", function()
  local entries = api.get_memos_for_link()
  local items = {}
  local lookup = {}
  for _, entry in ipairs(entries) do
    table.insert(items, entry.text)
    lookup[entry.text] = entry.value
  end
  fzf.fzf_exec(items, {
    prompt = "Insert Link> ",
    actions = {
      ["default"] = function(selected)
        if selected[1] then
          api.insert_link(lookup[selected[1]])
        end
      end,
    },
  })
end, { desc = "[sm] Insert link" })

-- Buffer-local keymaps for memo files
local group = vim.api.nvim_create_augroup("sm_user_keymaps", { clear = true })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = group,
  pattern = require("sm").autocmd_pattern(),
  callback = function(args)
    local buf = args.buf
    vim.keymap.set("n", "<leader>xa", require("sm").buf_add_tag, { buffer = buf, desc = "Add tag" })
    vim.keymap.set("n", "<leader>xf", require("sm").buf_follow_link, { buffer = buf, desc = "Follow link" })
  end,
})
