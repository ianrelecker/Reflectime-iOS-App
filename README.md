# Reflectime

A private journaling app for iPhone, iPad, and Mac (Designed for iPhone). Write a reflection, optionally remember where you were, and look back when you have a few saved.

This started as Ian Relecker’s undergraduate Computer Science senior project. It is written in Swift and SwiftUI. Reflections are stored with Core Data and synced with CloudKit.

## iOS 27

Version 3.0 targets **iOS 26** and is built with the **iOS 27 SDK**.

- Liquid Glass system chrome (`NavigationStack`, `TabView`, glass buttons)
- Search tab and a sidebar-adaptable tab bar on iPad
- On-device Apple Intelligence summaries, tags, and follow-up prompts (never sent off-device)
- App Intents / Shortcuts: “Log a reflection”, “Open today’s journal”
- Daily reminder notifications, optional location, iCloud sync
- Insights: writing streak, this week, category chart, day/category look-back
- Privacy manifest and no third-party analytics

Existing iCloud reflections keep the same Core Data model. Category `Intrests` from earlier versions still displays as Interests.

## Requirements

- Xcode 27 / iOS 27 SDK
- Deployment target: iOS 26.0
- Apple ID with iCloud for sync
- Apple Intelligence hardware for on-device insights (the rest of the app works without it)

## Privacy

Location is only stored when you include it on a reflection. On-device insights run through Foundation Models on the device. There is no analytics SDK and no RevenueCat/IAP in this open-source tree.

## Support

- [Privacy Policy](https://www.ianrelecker.com/reflectime-app/privacy-policy)
- [Contact](https://www.ianrelecker.com/contact)
