# voxPOS

A point-of-sale till for a quick-service counter whose customers order in languages
the staff do not share. The customer speaks, the staff read the order in English,
check it, and take the money.

Built for **iOS 26.5** with SwiftUI and Swift 6.

---

## ⚠️ Speech to text is a mock-up

**The microphone is not connected.** `FakeSpeechTranscriber` waits like a real
recogniser would, then returns one of four canned sentences at random:

| Sentence | Language | What it exercises |
|---|---|---|
| `Cho tôi hai burger gà, một cái không phô mai` | Vietnamese | translation, and an option the kitchen cannot make |
| `One coke with no ice and a large fries please` | English | no translation needed — the pass-through path |
| `Dos hamburguesas con queso y un helado de vainilla` | Spanish | translation from a third language |
| `Cho tôi một ly trà sữa trân châu` | Vietnamese | nothing on the menu — the warning path |

Speaking into the device does nothing. Tapping **Start listening** plays the
animation for about a second and then hands back the next sample.

**Translation is a mock-up too.** `FakeTranslator` is a phrase table covering exactly
those four sentences; anything else comes back unchanged.

Replacing either means writing one type that conforms to `SpeechTranscribing` or
`TextTranslating`. Nothing above it changes — not the use case, not the view model,
not the views. That is the point of the ports.

## What is real

| Part | Status |
|---|---|
| Language detection | **Real** — `NLLanguageRecognizer` on device |
| Turning text into an order | **Real** — Apple Foundation Models, on device |
| Menu, prices, options | **Real** — `Resources/SampleProducts.json` |
| Customer-facing notices | **Real** — 25 languages in `Resources/CustomerNotices.json` |
| Speech to text | Mock-up |
| Translation | Mock-up |
| Card terminal | `SimulatedPaymentTerminal` — approves everything |

Nothing leaves the device. There is no network layer in this app because it has none.

## Running it

```bash
open voxPOS.xcodeproj      # then ⌘R
```

Sign in with any name and shift code, then **Voice Order** or **Manual Order**.

**Apple Intelligence must be switched on** for the order interpreter, and it is not
available inside the iOS Simulator — on a Mac the simulator inherits the host's
setting, so check System Settings → Apple Intelligence & Siri. Without it the app
does not crash: it shows *"Apple Intelligence is turned off. Turn it on in Settings
to take voice orders."* **Manual Order** works either way; it runs no model at all.

## Tests

```bash
xcodebuild -project voxPOS.xcodeproj -scheme voxPOS \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

24 unit tests over the three use cases that touch money. They run against stubs — no
microphone, no card reader, no Apple Intelligence — so a failure means a business
rule is wrong, never that a device was busy.

## Architecture

```
Views  →  ViewModels  →  Use Cases  →  Domain Models + Ports  →  Data
```

Dependencies point down only; a use case never knows a view exists.

**Six use cases**, each carrying rules rather than moving data:

| Use case | What it protects |
|---|---|
| `StaffLoginUseCase` | a shift that survives a relaunch, so takings stay attributable |
| `TranscribeSpokenOrderUseCase` | refuses a language it is not sure of, rather than translating from the wrong one |
| `ConvertTextToOrderUseCase` | the model names products; **the menu sets every price** |
| `StartManualOrderUseCase` | will not spend an order number on a ticket nothing can be sold on |
| `ReviseOrderUseCase` | merges identical lines, floors a line at one, refuses to edit a paid order |
| `TakePaymentUseCase` | no double charge; every attempt recorded, declines included |

Ports live at the bottom of the use case layer — `SpeechTranscribing`,
`LanguageDetecting`, `TextTranslating`, `OrderInterpreting`, `PaymentAuthorizing` —
which is why the two mock-ups above can be swapped for real adapters without
touching a rule.

## Known gaps

- **Orders and payments are not persisted.** `.modelContainer` is commented out in
  `voxPOSApp.swift`; quit the app mid-shift and the takings are gone. This is the
  first thing to fix.
- The interpreter can still miscount `"two burgers, one without mayonnaise"` as three
  burgers. Measured 68% correct with one model pass, 86% with two.
- `NLLanguageRecognizer` conflates Malay with Indonesian, Nepali with Hindi, and
  Filipino with Indonesian, so those three notice languages are never reached by
  automatic detection.
- The customer-facing translations in `CustomerNotices.json` have not been checked by
  native speakers.

## Layout

```
voxPOS/
  Models/           Staff · Product · Order · OrderItem · Payment · OrderNumbering
  UseCases/         the six above, each with its own typed error enum
  Services/         ports, and the adapters behind them
  Repositories/     product, staff and payment stores
  ViewModels/       screen state only
  Views/            SwiftUI screens
  Resources/        menu, model instructions, customer notices
voxPOSTests/        24 unit tests plus shared test doubles
```
