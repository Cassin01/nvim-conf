local lspconfig = require("lspconfig")
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {"gopls"},
})

-- local default_on_attach = function(client)
-- --     -- require("mappings").keys_lsp()
--     client.resolved_capabilities.document_formatting = false
--     client.resolved_capabilities.document_range_formatting = false
-- end
local navic = require("nvim-navic")
local nmap = function(bufnr)
    return function(keys, func, desc)
        if desc then
            desc = "[lsp]" .. desc
        end
        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
    end
end
local default_on_attach = function(client, bufnr)
    print("LSP attached: " .. client.name)
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
    nmap_("sr", vim.lsp.buf.references, "references")
    nmap_("sR", require("telescope.builtin").lsp_references, "references")
    nmap_("sq", vim.diagnostic.setqflist, "set_qflist")
    nmap_("swl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "list_workspace_folders")
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
        -- if client.supports_method("textDocument/formatting") then
        --     vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        --         group = vim.api.nvim_create_augroup("lsp_attached_format_", { clear = true }),
        --         buffer = ev.bufnr,
        --         callback = function()
        --             format()
        --         end,
        --     })
        -- end
    end,
})

vim.lsp.config('lua_ls', {
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

vim.lsp.config('gopls', {
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

vim.lsp.config('rust_analyzer', {
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
            diagnostics = {
                disabled = { "unresolved-proc-macro", "macro-error" },
            },
        },
    },
})

vim.lsp.config('ts_ls', {
    on_attach = default_on_attach,
    init_options = {
        plugins = {
            {
                name = "@vue/typescript-plugin",
                location = require("mason-registry").get_package("vue-language-server"):get_install_path()
                    .. "/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin",
                languages = { "javascript", "typescript", "vue" },
            },
        },
    },
    filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
})

vim.lsp.config('volar', {
    on_attach = default_on_attach,
    root_dir = lspconfig.util.root_pattern({ "package.json" }),
    single_file_support = true,
    init_options = {
        vue = {
            hybridMode = true,
        },
    },
})

vim.lsp.config('denols', {
    single_file_support = false,
    root_dir = lspconfig.util.root_pattern("denops", "deno.json"),
    init_options = {
        lint = true,
        unstable = true,
    },
})

vim.lsp.config('pylsp', {
    on_attach = default_on_attach,
    cmd = { "pylsp" },
    settings = {
        pylsp = {
            configurationSources = { "flake8" },
            plugins = {
                jedi_symbols = {
                    enabled = true,
                    all_scopes = true,
                    include_import_symbols = true,
                },
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

vim.lsp.config('sqls', {
    on_attach = function(client, bufnr)
        require("sqls").on_attach(client, bufnr)
        default_on_attach(client, bufnr)
    end,
})

local ok, secret = pcall(require, "secret")
if ok and secret["grammarly"] ~= nil then
    vim.lsp.config('grammarly', {
        init_options = {
            clientId = secret["grammarly"].clientId,
        },
    })
end

vim.lsp.enable({
    "gopls",
    "lua_ls",
    "rust_analyzer",
    "ts_ls",
    "volar",
    "denols",
    "pylsp",
    "sqls"
})
