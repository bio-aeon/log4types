# Filtering by Severity

`filterBySeverity` suppresses messages below a threshold.

```idris
import Log4Types

main : IO ()
main = do
  let logger = filterBySeverity Warning severity (cmap show logStringStdout)
  logger <& mkDebug "hidden"    -- suppressed (below Warning)
  logger <& mkWarning "visible" -- printed
  logger <& mkError "visible"   -- printed
```

## General Filtering with cfilter

`cfilter` takes any predicate:

```idris
let positiveOnly = cfilter (> 0) intLogger
positiveOnly <& 5    -- logged
positiveOnly <& (-3) -- suppressed
```

## Monadic Filtering with cfilterM

`cfilterM` allows the predicate to perform effects:

```idris
let filtered = cfilterM (\msg => do
  threshold <- readIORef currentLevel
  pure (severity msg >= threshold)
  ) logger
```

## Transform-and-Filter with cmapMaybe

`cmapMaybe` combines transformation and filtering - log only when the function returns `Just`:

```idris
let safeHead = cmapMaybe Data.List.head' intLogger
safeHead <& [1, 2, 3]  -- logs 1
safeHead <& []          -- suppressed
```
