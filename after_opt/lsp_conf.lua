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
                lint = false,
                unstable = true,
            },
        })
    end,
}

local secret = require("secret")
if secret["grammarly"] ~= nil then
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
