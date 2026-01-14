---@type vim.lsp.Config
return {
  -- basedpyright settings optimized for hover and inlay hints ONLY
  -- ty handles ALL diagnostics, navigation, completion, etc.
  settings = {
    basedpyright = {
      analysis = {
        -- Completely disable type checking - ty handles all diagnostics
        typeCheckingMode = "off",
        -- Disable all diagnostic rules
        diagnosticSeverityOverrides = {
          -- Disable ALL diagnostic rules to prevent any diagnostics from showing
          reportMissingParameterType = "none",
          reportUnknownParameterType = "none",
          reportUnknownArgumentType = "none",
          reportUnknownLambdaType = "none",
          reportUnknownVariableType = "none",
          reportUnknownMemberType = "none",
          reportMissingTypeArgument = "none",
          reportUnannotatedClassAttribute = "none",
          reportGeneralTypeIssues = "none",
          reportOptionalSubscript = "none",
          reportOptionalMemberAccess = "none",
          reportOptionalCall = "none",
          reportOptionalIterable = "none",
          reportOptionalContextManager = "none",
          reportOptionalOperand = "none",
          reportUntypedFunctionDecorator = "none",
          reportUntypedClassDecorator = "none",
          reportUntypedBaseClass = "none",
          reportInvalidTypeVarUse = "none",
          reportCallInDefaultInitializer = "none",
          reportUnnecessaryIsInstance = "none",
          reportUnnecessaryCast = "none",
          reportUnnecessaryComparison = "none",
          reportUnnecessaryContains = "none",
          reportAssertAlwaysTrue = "none",
          reportSelfClsParameterName = "none",
          reportImplicitStringConcatenation = "none",
          reportUndefinedVariable = "none",
          reportUnboundVariable = "none",
          reportInvalidStubStatement = "none",
          reportIncompleteStub = "none",
          reportUnsupportedDunderAll = "none",
          reportUnusedVariable = "none",
          reportUnusedClass = "none",
          reportUnusedFunction = "none",
          reportUnusedImport = "none",
          reportDuplicateImport = "none",
          reportWildcardImportFromLibrary = "none",
          reportPrivateUsage = "none",
          reportConstantRedefinition = "none",
          reportIncompatibleMethodOverride = "none",
          reportIncompatibleVariableOverride = "none",
          reportInconsistentConstructor = "none",
          reportOverlappingOverload = "none",
          reportMissingSuperCall = "none",
          reportUninitializedInstanceVariable = "none",
          reportInvalidStringEscapeSequence = "none",
          reportMissingTypeStubs = "none",
          reportImportCycles = "none",
          reportUnusedExpression = "none",
          reportMatchNotExhaustive = "none",
          reportShadowedImports = "none",
          reportImplicitOverride = "none",
          reportPropertyTypeMismatch = "none",
          reportAny = "none",
        },
        -- Enable inlay hints for better type information (basedpyright supports these!)
        inlayHints = {
          variableTypes = true,
          functionReturnTypes = true,
          parameterTypes = true,
        },
      },
    },
    python = {
      analysis = {
        -- Enable type stubs for accurate hover information
        useLibraryCodeForTypes = true,
        -- Auto-search paths for better type resolution
        autoSearchPaths = true,
      },
    },
  },
}
