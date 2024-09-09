local vim = vim
local lspconfig = require("lspconfig")
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { },
})

-- local default_on_attach = function(client)
-- --     -- require("mappings").keys_lsp()
--     client.resolved_capabilities.document_formatting = false
--     client.resolved_capabilities.document_range_formatting = false
-- end
local navic = require("nvim-navic")
local default_on_attach = function(client, bufnr)
    if client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
    end
    local nmap = function(keys, func, desc)
        if desc then
            desc = desc .. " [lsp]"
        end
        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
    end
    nmap('sd', vim.lsp.buf.definition, 'definition')
    nmap('si', vim.lsp.buf.implementation, 'implementation')
    nmap('sy', vim.lsp.buf.type_definition, 'type definition')
    nmap('sK', vim.lsp.buf.hover, 'hover')
    nmap('sD', vim.lsp.buf.declaration, 'declaration')
    nmap('s<C-k>', vim.lsp.buf.signature_help, 'signature_help')
    nmap('sa', vim.lsp.buf.code_action, 'code_action')
    nmap('swl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, 'list_workspace_folders')
    nmap('sr', require('telescope.builtin').lsp_references, 'references')
    nmap('<Space>td', require('telescope.builtin').lsp_document_symbols, 'lsp document symbol')
    nmap('<Space>tw', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'lsp workspace symbols')

    -- ubnzv/virtual-types.nvim
    require("virtualtypes").on_attach()
end
local default_capabilities = require("cmp_nvim_lsp").default_capabilities()
-- default_capabilities.offsetEncoding = { "utf-8", "utf-16" }

lspconfig.util.default_config = vim.tbl_extend("force", lspconfig.util.default_config, {
    -- on_attach = default_on_attach,
    capabilities = default_capabilities,
})

local setup_handlers = {
    function(server_name)
        lspconfig[server_name].setup({})
    end,
    ["lua_ls"] = function()
        lspconfig.lua_ls.setup({
            on_attach = default_on_attach,
            settings = {
                Lua = {
                    runtime = {
                        version = "LuaJIT",
                    },
                    diagnostics = {
                        globals = { "vim", "use", "require" },
                    },
                    workspace = {
                        checkThirdParty = false, -- Stop ask to configure my work environment.
                        library = vim.api.nvim_get_runtime_file("", true),
                    },
                    telemetry = {
                        enable = false,
                    },
                    format = {
                        enable = true,
                        -- Put format options here
                        -- NOTE: the value should be STRING!!
                        defaultConfig = {
                            indent_style = "space",
                            indent_size = "2",
                        },
                    },
                },
            },
        })
    end,
    ["rust_analyzer"] = function()
        lspconfig.rust_analyzer.setup({
            on_attach = default_on_attach,
            settings = {
                ["rust-analyzer"] = {
                    assist = {
                        importGranularity = "module",
                        importPrefix = "by_self",
                    },
                    cargo = {
                        loadOutDirsFromCheck = true,
                    },
                    procMacro = {
                        enable = false,
                    },
                    checkOnSave = {
                        command = "clippy",
                    },
                },
            },
        })
    end,
    ["denols"] = function()
        lspconfig.denols.setup({
            single_file_support = false,
            root_dir = lspconfig.util.root_pattern("denops", "deno.json"),
            init_options = {
                lint = true,
                unstable = true,
            },
        })
    end,
    ["gopls"] = function()
        lspconfig.gopls.setup({
            on_attach = default_on_attach,
            settings = {
                gopls = {
                    analyses = {
                        unusedparams = true,
                    },
                    staticcheck = true,
                    gofumpt = true,
                },
            },
        })
    end,
    ["pylsp"] = function()
        lspconfig.pylsp.setup({
            on_attach = default_on_attach,
            -- https://github.com/python-rope/rope/wiki/Rope-in-Vim-or-Neovim
            cmd = { "pylsp" },
            settings = {
                pylsp = {
                    configurationSources = { "flake8" },
                    plugins = {
                        -- https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
                        jedi_symbols = {
                            enabled = true,
                            all_scopes = true,
                            include_import_symbols = true,
                        },
                        -- jedi_definition.enabled = true,
                        jedi_hover = {
                            enabled = true,
                        },
                        rope_completion = {
                            enabled = true,
                        },
                    }
                }
            }
        })
    end,
    -- ["protols"] = function()
    --     lspconfig.protols.setup({
    --         on_attach = default_on_attach,
    --     })
    -- end
}

local ok, secret = pcall(require, "secret")
if ok and secret["grammarly"] ~= nil then
    setup_handlers["grammarly"] = function()
        lspconfig.grammarly.setup({
            init_options = {
                clientId = secret["grammarly"].clientId,
            },
        })
    end
end

local function setup_default()
    require("mason-lspconfig").setup_handlers(setup_handlers)
end

setup_default()
