# Masking

Wrap a sensitive field in `Masked` to log it as `***`, or in `Hidden` to leave it out of the output. Code still reads the real value with `.reveal`.

```idris
import Log4Types
import Log4Types.JSON

record User where
  constructor MkUser
  name     : String
  email    : Masked String
  password : Hidden String

Loggable User where
  logFields renderer u acc =
    addLoggableField renderer "password" u.password $
    addLoggableField renderer "email" u.email $
    addLoggableField renderer "name" u.name acc
  logShow u = u.name

main : IO ()
main = do
  let alice = MkUser "alice" (MkMasked "alice@example.com") (MkHidden "hunter2")
  jsonLogStdout <& alice
  -- Output: {"name":"alice","email":"***"}
  cmap show logStringStdout <& MkMsg Info "signed up" (logFields fieldsRenderer alice [])
  -- Output: [INFO] signed up name="alice" email="***"
```

`addLoggableField` writes a scalar, `Masked` or `Hidden` value under the given name.

## Policies

To log part of a value, apply a policy with `addMaskedField`:

```idris
record Payment where
  constructor MkPayment
  amount : Double
  card   : Masked String

Loggable Payment where
  logFields renderer p acc =
    addMaskedField renderer "card" (lastN 4) p.card.reveal $
    addLoggableField renderer "amount" p.amount acc
  logShow p = "payment of " ++ show p.amount
```

```idris
jsonLogStdout <& MkPayment 12.5 (MkMasked "4111111111111111")
-- Output: {"amount":12.5,"card":"************1111"}
```

| Policy | Input | Logged as |
|--------|-------|-----------|
| `defaultMask` | `hunter2` | `***` |
| `lastN 4` | `4111111111111111` | `************1111` |
| `emailDomainOnly` | `alice@example.com` | `*****@example.com` |

A value no longer than `n` under `lastN n`, or one without an `@` under `emailDomainOnly`, is logged as `***`. A custom policy is `MkMaskPolicy f` for any `f : a -> String`.

## Limits

A value read with `.reveal` and put into `logShow`, a message's text or a hand-built `Msg` field is logged unmasked.
