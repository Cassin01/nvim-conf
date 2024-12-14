local vim = vim
local lspconfig = require("lspconfig")
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {},
})

local nmap = function(bufnr)
    return function(keys, func, desc)
        if desc then
            desc = "[lsp]" .. desc
        end
        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
    end
end
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
    local nmap_ = nmap(bufnr)
    nmap_("sd", vim.lsp.buf.definition, "definition")
    nmap_("si", vim.lsp.buf.implementation, "implementation")
    nmap_("sy", vim.lsp.buf.type_definition, "type definition")
    nmap_("sK", vim.lsp.buf.hover, "hover")
    nmap_("sD", vim.lsp.buf.declaration, "declaration")
    nmap_("s<C-k>", vim.lsp.buf.signature_help, "signature_help")
    nmap_("sa", vim.lsp.buf.code_action, "code_action")
    nmap_("swl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "list_workspace_folders")
    nmap_("sr", require("telescope.builtin").lsp_references, "references")
    if client.server_capabilities.documentFormattingProvider then
        local format = function()
            vim.lsp.buf.format({ timeout_ms = 2000 })
        end
        nmap_("sf", format, "format")
    end
    nmap_("<Space>td", require("telescope.builtin").lsp_document_symbols, "lsp document symbol")
    nmap_("<Space>tw", require("telescope.builtin").lsp_dynamic_workspace_symbols, "lsp workspace symbols")

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
    ["buf"] = function()
        lspconfig["buf"].setup({
            filetypes = { "proto" },
            on_attach = default_on_attach,
        })
    end,
    ["ts_ls"] = function()
        local vue_typescript_plugin = require("mason-registry").get_package("vue-language-server"):get_install_path()
            .. "/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin"

        lspconfig["ts_ls"].setup({
            on_attach = default_on_attach,
            init_options = {
                plugins = {
                    {
                        name = "@vue/typescript-plugin",
                        location = vue_typescript_plugin,
                        languages = { "javascript", "typescript", "vue" },
                    },
                },
            },
            filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        })
    end,
    ["volar"] = function()
        lspconfig.volar.setup({
            on_attach = default_on_attach,
            root_dir = lspconfig.util.root_pattern({ "package.json" }),
            single_file_support = true,
            init_options = {
                vue = {
                    hybridMode = true,
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
                    },
                },
            },
        })
    end,
    ["protobuf_language_server"] = function()
        gopath = os.getenv("GOPATH")
        lspconfig.protobuf_language_server.setup({
            on_attach = default_on_attach,
            cmd = { gopath .. "/bin/protobuf-language-server" },
            filetypes = { "proto", "cpp" },
            root_dir = util.root_pattern(".git"),
            single_file_support = true,
            settings = {},
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

-- on_attachが実行されるより先にLSPがアタッチされたタイミングで発火する
-- WARN: LspAttachよりも後に実行される可能性がある
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp_attached_", { clear = true }),
    callback = function(ev)
        vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client == nil then
            return
        end
        local format = function()
            vim.lsp.buf.format({ timeout_ms = 2000 })
        end
        nmap(ev.bufnr)("sf", vim.lsp.buf.format, "format")
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd({ "BufWritePre" }, {
                group = vim.api.nvim_create_augroup("lsp_attached_format_", { clear = true }),
                buffer = ev.bufnr,
                callback = function()
                    format()
                end,
            })
        end
    end,
})
