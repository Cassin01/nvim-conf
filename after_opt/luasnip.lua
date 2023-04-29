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
local dl = require("luasnip.extras").dynamic_lambda

local get_filename = function()
    local name = vim.fn.expand("%:r")
    if name == "" then
        return "programming"
    end
    return name
end


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
rec_arg = function(div)
    local lambda = function()
        return sn(
            nil,
            c(1, {
                -- Order is important, sn(...) first would cause infinite loop of expansion.
                t(""),
                sn(nil, { t({ div .. " " }), i(1), d(2, rec_arg(div), {}) }),
            })
        )
    end
    return lambda
end

local arg_t = function(n)
    return sn(n, fmt("{}: {}", { i(1), i(2) }))
end

local ret_t = function(n)
    return c(n, { t(""), sn(nil, fmt("-> {} ", { i(1, "Type") })) })
end

local rec_arg_rs
rec_arg_rs = function()
    return sn(
        nil,
        c(1, {
            t(""),
            sn(nil, { t({ ", " }), arg_t(1), d(2, rec_arg_rs, {}) }),
        })
    )
end
local function reused_func(args, snip)
end

local snippet = {
    all = {
        s("ternary", {
            i(1, "cond"),
            t(" ? "),
            i(2, "then"),
            t(" : "),
            i(3, "else"),
        }),
    },
    sh = {
        s("#!",
        fmt([[
        #!/usr/bin/env {}
            ]],
        {c(1, {t("zsh"), t("bash"), t("nu")})}))
    },
    asciidoctor = {
        s("header",
            fmt([[
:doctype: book
:toc:
:toc-title: 目次
:sectnums:
:chapter-label:
:source-highlighter: highlight.js
:highlightjs-theme: github
:highlightjs-languages: haskell
:icons: font
:author: Cassin01
:tag: {1}
:stem: latexmath
                ]], {i(1, "tag")})),
        },
    rust = {
        s(
            "fn",
            fmt(
                [[
        fn {1}({2}{3}) {4}{{
            {5}
        }}
        ]]       ,
                {
                    i(1, "name"),
                    -- i(2, ""),
                    arg_t(2),
                    d(3, rec_arg_rs, {}),
                    ret_t(4),
                    i(5, "body"),
                }
            )
        ),
        s(
            "num2char",
            fmt([[std::char::from_digit({} as u32, 10)]], {
                i(1, "num"),
            })
        ),
        s("char2num", fmt([[{} as u8 - '0' as u8]], { i(1, "char") })),
    },
    org = {
        s(
            "header", fmt([[
#+title: {}
#+filetags: :{}:
                ]],
                {
                    i(1, "title"),
                    i(2, "programming")
                }
            ))

    },
    markdown = {
        s(
            "header",
            fmt(
                [[
        ```yaml
        title: {}
        date: {}
        categories: [{}{}]
        tags: [{}{}]
        ```
        ]]       ,
                {
                    -- i(1, "title"),
                    i(1, get_filename()),
                    f(function()
                        return os.date("%Y-%m-%d")
                    end),
                    i(2, "programming"),
                    d(3, rec_arg(","), {}),
                    i(4, "rust"),
                    d(5, rec_arg(","), {}),
                }
            )
        ),
        s(
            ",",
            fmt([[, {}{}]], {
                i(1),
                d(2, rec_arg(","), {}),
            })
        ),
    },

    lua = {
        s(
            "fn",
            fmt(
                [[
        function {}({}{})
            {}
        end
        ]]       ,
                {
                    i(1, "name"),
                    i(2, ""),
                    d(3, rec_arg(","), {}),
                    i(4, "return nil"),
                }
            )
        ),
        s(
            "req",
            fmt('local {} = require("{}")', {
                dl(2, l._1:match("%.([%w_]+)$"), { 1 }),
                i(1),
            })
        ),
        s("for", {
            t("for "),
            c(1, {
                sn(nil, {
                    i(1, "k"),
                    t(", "),
                    i(2, "v"),
                    t(" in "),
                    c(3, { t("pairs"), t("ipairs"), i(nil) }),
                    t("("),
                    i(4),
                    t(")"),
                }),
                sn(nil, { i(1, "i"), t(" = "), i(2), t(", "), i(3) }),
            }),
            t({ " do", "\t" }),
            i(0),
            t({ "", "end" }),
        }),
    },
    tex = {
        s("ls", {
            t({ "\\begin{itemize}", "\t\\item " }),
            i(1),
            d(2, rec_ls, {}),
            t({ "", "\\end{itemize}" }),
        }),
    },
    fennel = {
        s(
            "lambda",
            fmt(
                [[
        (λ [{}{}]
            {})]],
                {
                    i(1, ""),
                    d(2, rec_arg(""), {}),
                    i(3, ""),
                }
            )
        ),
        s("event", t({ [[:event ["User plug-lazy-load"]] })),
    },
}

--info
-- https://github.com/L3MON4D3/Dotfiles/blob/master/.config/nvim/lua/plugins/luasnip/init.lua

for k, v in pairs(snippet) do
    ls.add_snippets(k, v)
end
