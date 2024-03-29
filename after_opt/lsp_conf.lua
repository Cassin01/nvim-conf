local vim = vim
local lspconfig = require("lspconfig")
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "sumneko_lua" },
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
    nmap('sr', require('telescope.builtin').lsp_references, 'references')
    nmap('si', vim.lsp.buf.implementation, 'implementation')
    nmap('sy', vim.lsp.buf.type_definition, 'type definition')
    nmap('<Space>td', require('telescope.builtin').lsp_document_symbols, 'lsp document symbol')
    nmap('<Space>tw', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'lsp workspace symbols')

    -- ubnzv/virtual-types.nvim
    require("virtualtypes").on_attach()
end
local default_capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.util.default_config = vim.tbl_extend("force", lspconfig.util.default_config, {
    -- on_attach = default_on_attach,
    capabilities = default_capabilities,
})

local setup_handlers = {
    function(server_name)
        lspconfig[server_name].setup({})
    end,
    ["sumneko_lua"] = function()
        lspconfig.sumneko_lua.setup({
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
