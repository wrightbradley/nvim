return {
  -- Tailwind colorizer for blink.cmp
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = {
      { "roobert/tailwindcss-colorizer-cmp.nvim", opts = {} },
    },
    opts = function(_, opts)
      -- Get the tailwind formatter
      local tailwind_formatter = require("tailwindcss-colorizer-cmp").formatter

      -- If transform_item exists, wrap it
      local transform_items = opts.sources.providers.lsp and opts.sources.providers.lsp.transform_items
      if transform_items then
        opts.sources.providers.lsp.transform_items = function(ctx, items)
          items = transform_items(ctx, items)
          for _, item in ipairs(items) do
            item = tailwind_formatter(nil, item) or item
          end
          return items
        end
      else
        -- Create transform_items if it doesn't exist
        opts.sources.providers.lsp = opts.sources.providers.lsp or {}
        opts.sources.providers.lsp.transform_items = function(_, items)
          for _, item in ipairs(items) do
            item = tailwind_formatter(nil, item) or item
          end
          return items
        end
      end
    end,
  },
}
