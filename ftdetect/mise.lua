vim.filetype.add({
  filename = {
    ["mise.toml"] = "mise",
    [".mise.toml"] = "mise",
    ["mise.local.toml"] = "mise",
    [".mise.local.toml"] = "mise",
  },
  pattern = {
    -- mise.<env>.toml and .mise.<env>.toml variants
    [".*mise%.%a+%.toml"] = "mise",
    [".*%.mise%.%a+%.toml"] = "mise",
    -- config/mise/config.toml style paths
    [".*/mise/config%.toml"] = "mise",
  },
})
