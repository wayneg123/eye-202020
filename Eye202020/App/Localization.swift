import Combine
import Foundation

enum AppLanguage: String {
    case english = "en"
    case simplifiedChinese = "zh-Hans"

    var locale: Locale { Locale(identifier: rawValue) }
}

final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    private static let languageKey = "app.language"
    @Published private(set) var language: AppLanguage

    var locale: Locale { language.locale }

    private init(defaults: UserDefaults = .standard) {
        language = defaults.string(forKey: Self.languageKey)
            .flatMap(AppLanguage.init(rawValue:)) ?? .english
    }

    func toggleLanguage() {
        language = language == .english ? .simplifiedChinese : .english
        UserDefaults.standard.set(language.rawValue, forKey: Self.languageKey)
    }
}

enum L10n {
    static func text(_ key: String) -> String {
        NSLocalizedString(key, tableName: nil, bundle: localizedBundle, value: key, comment: "")
    }

    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: text(key), locale: LocalizationManager.shared.locale, arguments: arguments)
    }

    private static var localizedBundle: Bundle {
        guard
            let path = Bundle.main.path(
                forResource: LocalizationManager.shared.language.rawValue,
                ofType: "lproj"
            ),
            let bundle = Bundle(path: path)
        else {
            return .main
        }
        return bundle
    }
}
