local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local fmt = require("luasnip.extras.fmt").fmt
local extras = require("luasnip.extras")
local m = extras.m
local l = extras.l
local rep = extras.rep
local postfix = require("luasnip.extras.postfix").postfix

ls.cleanup() -- remove all snippets

local rec_ls
rec_ls = function()
	return sn(
		nil,
		c(1, {
			-- Order is important, sn(...) first would cause infinite loop of expansion.
			t(""),
			sn(nil, { t({ "", "\t\\item " }), i(1), d(2, rec_ls, {}) }),
		})
	)
end

local rec_arg
rec_arg = function()
        return sn(
        nil,
        c(1, {
            -- Order is important, sn(...) first would cause infinite loop of expansion.
            t(""),
            sn(nil, { t({ ", " }), i(1), d(2, rec_arg, {}) }),
        })
        )
end


local snippet = {
    all = {
        s("ternary", {
            i(1, "cond"), t(" ? "), i(2, "then"), t(" : "), i(3, "else")
        })
    },
    markdown = {
        s("header",
        fmt([[
        ```yaml
        layout: post
        title: {}
        ]] ..
        [[date: ]] .. os.date("%Y-%m-%d")
        .. [[

        categories: [{}{}]
        tags: [{}{}]
        ```
        ]],
        {
            i(1, "title"),
            i(2, "programming"),
            d(3, rec_arg, {}),
            i(4, "rust"),
            d(5, rec_arg, {})
        })
        ),
        s(",",
        fmt([[{}{}]],
        {
            i(1),
            d(2, rec_arg, {}),
        })
        ),
    },
    tex = {
        -- rec_ls is self-referencing. That makes this snippet 'infinite' eg. have as many
        -- \item as necessary by utilizing a choiceNode.
        s("ls", {
            t({ "\\begin{itemize}", "\t\\item " }),
            i(1),
            d(2, rec_ls, {}),
            t({ "", "\\end{itemize}" }),
        }),
    }
}

for k, v in pairs(snippet) do
    ls.add_snippets(k, v)
end
