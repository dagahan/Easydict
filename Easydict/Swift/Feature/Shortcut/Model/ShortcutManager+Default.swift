//
//  ShortcutManager+Default.swift
//  Easydict
//
//  Created by Sharker on 2024/2/5.
//  Copyright © 2024 izual. All rights reserved.
//

import Defaults
import Magnet

// MARK: - ShortcutManager + Defaults Settings

extension ShortcutManager {
    // Set defalut hotkeys for global and app
    func setDefaultShortcutKeys() {
        setDefaultGlobalShortcutKeys()
        setDefaultAppShortcutKeys()
    }

    private func setDefaultGlobalShortcutKeys() {
        Defaults[.snipShortcut] = KeyCombo(key: .s, cocoaModifiers: .option)
        Defaults[.selectionShortcut] = KeyCombo(key: .d, cocoaModifiers: .option)
    }

    private func setDefaultAppShortcutKeys() {
        Defaults[.clearInputShortcut] = KeyCombo(key: .k, cocoaModifiers: .command)
        Defaults[.clearAllShortcut] = KeyCombo(key: .k, cocoaModifiers: [.command, .shift])
        Defaults[.copyShortcut] = KeyCombo(key: .c, cocoaModifiers: [.command, .shift])
        Defaults[.copyFirstResultShortcut] = KeyCombo(key: .j, cocoaModifiers: [.command, .shift])
        Defaults[.focusShortcut] = KeyCombo(key: .i, cocoaModifiers: .command)
        Defaults[.playShortcut] = KeyCombo(key: .s, cocoaModifiers: .command)
        Defaults[.retryShortcut] = KeyCombo(key: .r, cocoaModifiers: .command)
        Defaults[.toggleShortcut] = KeyCombo(key: .t, cocoaModifiers: .command)
        Defaults[.pinShortcut] = KeyCombo(key: .p, cocoaModifiers: .command)
        Defaults[.hideShortcut] = KeyCombo(key: .y, cocoaModifiers: .command)
        Defaults[.increaseFontSize] = KeyCombo(key: .keypadPlus, cocoaModifiers: .command)
        Defaults[.decreaseFontSize] = KeyCombo(key: .keypadMinus, cocoaModifiers: .command)
        Defaults[.googleShortcut] = KeyCombo(key: .return, cocoaModifiers: .command)
        Defaults[.eudicShortcut] = KeyCombo(key: .return, cocoaModifiers: [.command, .shift])
        Defaults[.appleDictionaryShortcut] = KeyCombo(key: .d, cocoaModifiers: [.command, .shift])
    }
}

// MARK: - ShortcutManager + GlobalShortcut

extension ShortcutManager {
    /// Setup global shortcut actions
    func setupGlobalShortcutActions() {
        for action in ShortcutAction.globalActions {
            if let key = action.defaultsKey {
                let keyCombo = Defaults[key]
                bindingGlobalShortcutAction(keyCombo: keyCombo, action: action)
            }
        }
    }

    /// Bind global shortcut action (registers as system-wide hotkey)
    func bindingGlobalShortcutAction(keyCombo: KeyCombo?, action: ShortcutAction) {
        let identifierSurvivingSecureInput = action.rawValue + ".withControl"
        HotKeyCenter.shared.unregisterHotKey(with: action.rawValue)
        HotKeyCenter.shared.unregisterHotKey(with: identifierSurvivingSecureInput)

        guard let keyCombo, ShortcutAction.actionsRegisteredSystemWide.contains(action) else {
            return
        }

        let keyComboSurvivingSecureInput = KeyCombo(
            key: keyCombo.key,
            cocoaModifiers: keyCombo.keyEquivalentModifierMask.union(.control)
        )
        let identifiedKeyCombos = [(action.rawValue, keyCombo)]
            + (keyComboSurvivingSecureInput.map { [(identifierSurvivingSecureInput, $0)] } ?? [])
        for (identifier, keyCombo) in identifiedKeyCombos {
            HotKey(identifier: identifier, keyCombo: keyCombo) { _ in
                Task { @MainActor in
                    action.executeAction()
                }
            }.register()
        }
    }
}
