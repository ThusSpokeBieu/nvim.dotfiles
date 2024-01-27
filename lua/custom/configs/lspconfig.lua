local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities
local lspconfig = require("lspconfig")
local util = require "lspconfig/util"

-- rust 
lspconfig.rust_analyzer.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"rust"},
  root_dir = util.root_pattern("Cargo.toml"),
  settings = {
    ['rust-analyzer'] = {
      cargo = { 
        allFeatures = true,
      }
    }
  }
})


-- go
lspconfig.gopls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {"gopls"},
  filetypes = { "go", "gomod", "gowork", "gotmpl"},
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unused = true,
      }
    }
  }
}

-- java
local home = os.getenv('HOME')
local jdtls = require('jdtls')

local root_markers = { 'gradlew', 'mvnw', '.git' }
local root_dir = require('jdtls.setup').find_root(root_markers)

local workspace_folder = home .. "/.workspace/java/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

local bundles = {
  vim.fn.glob(
    home ..
    '/.local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-0.50.0.jar'
    )
}

vim.list_extend(bundles,
  vim.split(vim.fn.glob(home .. "/.local/share/nvim/mason/share/java-test/*jar", 1), '\n'))

local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

lspconfig.jdtls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    flags = {
      allow_incremental_sync = true,
    },
    init_options = {
    },
    java = {
                  saveActions = {
                      organizeImports = true,
                  },
      format = {
        settings = {
          url = home .. "/.config/nvim/resources/eclipse-java-google-style.xml",
          profile = "GoogleStyle",
        },
      },
      configuration = {
        runtimes = {
          {
            name = "JavaSE-21",
            path = "/home/mess/.sdkman/candidates/java/21.0.2-graal"
          },
        },
        updateBuildConfiguration = "interactive",
      },
      signatureHelp = { enabled = true },
      contentProvider = { preferred = 'fernflower' },
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      inlayHints = {
        parameterNames = {
          enabled = "all", -- literals, all, none
        },
      },
      completion = {
        favoriteStaticMembers = {
          -- "org.hamcrest.MatcherAssert.assertThat",
          -- "org.hamcrest.Matchers.*",
          -- "org.hamcrest.CoreMatchers.*",
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.mockito.Mockito.*",
          "java.util.stream.Collectors.*",
          "java.util.Map.entry",
          "org.assertj.core.api.Assertions.*"
        },
        filteredTypes = {
          "com.sun.*",
          "io.micrometer.shaded.*",
          "java.awt.*",
          "jdk.*", "sun.*",
        },
      },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
        },
        hashCodeEquals = {
          useJava7Objects = true,
        },
        useBlocks = true,
      },
      extendedClientCapabilities = extendedClientCapabilities
    },
  },
  cmd = {
    "java",
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx4g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    "-javaagent:" .. home .. "/.local/share/nvim/mason/packages/jdtls/lombok.jar",
    '-jar',
    vim.fn.glob(home ..
      "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
    "-configuration", home .. "/.local/share/nvim/mason/packages/jdtls/config_linux/",
    '-data', workspace_folder,
  },
  init_options = {
    bundles = bundles,
  },
}
