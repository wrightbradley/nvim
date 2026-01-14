---@type vim.lsp.Config
return {
  -- Pyright settings optimized for hover/type information only
  -- ty and ruff handle diagnostics
  settings = {
    python = {
      analysis = {
        -- Type checking mode - we want full type information but ty handles errors
        typeCheckingMode = "basic",
        -- Enable all type stubs
        useLibraryCodeForTypes = true,
        -- Auto-import completions
        autoImportCompletions = true,
        -- Auto-search paths
        autoSearchPaths = true,
        -- Diagnostic mode - we disable diagnostics since ty handles them
        diagnosticMode = "openFilesOnly",
        -- Disable specific diagnostic rules since ty/ruff handle them
        diagnosticSeverityOverrides = {
          -- Suppress all diagnostics - ty handles them
          reportGeneralTypeIssues = "none",
          reportOptionalSubscript = "none",
          reportOptionalMemberAccess = "none",
          reportOptionalCall = "none",
          reportOptionalIterable = "none",
          reportOptionalContextManager = "none",
          reportOptionalOperand = "none",
          reportTypedDictNotRequiredAccess = "none",
          reportUntypedFunctionDecorator = "none",
          reportUntypedClassDecorator = "none",
          reportUntypedBaseClass = "none",
          reportUnknownParameterType = "none",
          reportUnknownArgumentType = "none",
          reportUnknownLambdaType = "none",
          reportUnknownVariableType = "none",
          reportUnknownMemberType = "none",
          reportMissingParameterType = "none",
          reportMissingTypeArgument = "none",
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
          reportUnknownParameterType = "none",
          reportMissingTypeStubs = "none",
          reportImportCycles = "none",
          reportUnusedExpression = "none",
          reportMatchNotExhaustive = "none",
          reportShadowedImports = "none",
        },
      },
    },
  },
}
