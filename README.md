# FlowLedger (iOS)

A private personal finance tracker — built purely for my own use.  
It helps record monthly income, expenses, and savings across multiple accounts with clean visual summaries.

---

## 🧱 Tech Stack
- iOS 17+ (Swift 5.10)
- SwiftUI + NavigationStack
- SwiftData (for persistence)
- Clean Architecture (Presentation → Domain → Data)

---

## 📂 Structure
```
FlowLedger/
  Presentation/      # SwiftUI screens & components
  Support/           # Theme, helpers, extensions
  Resources/         # Assets & localized strings
  Tests/             # Unit tests
  UITests/           # UI tests
```

---

## 🚀 Run
1. Open `FlowLedger.xcodeproj` in Xcode 15 or 16  
2. Choose scheme **FlowLedger**  
3. Run on an **iPhone 15 Simulator** (or any iOS 17+ device)

---

## 🗺️ Roadmap
- [ ] Build UI skeleton for all 5 tabs  
- [ ] Add dummy data for charts  
- [ ] Integrate SwiftData persistence  
- [ ] Add iCloud sync  
- [ ] Generate PDF monthly reports
