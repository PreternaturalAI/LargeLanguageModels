//
// Copyright (c) Vatsal Manot
//

import NaturalLanguage

extension NLLanguage {
    public enum Name: String {
        case undetermined
        case amharic
        case arabic
        case armenian
        case bengali
        case bulgarian
        case burmese
        case catalan
        case cherokee
        case croatian
        case czech
        case danish
        case dutch
        case english
        case finnish
        case french
        case georgian
        case german
        case greek
        case gujarati
        case hebrew
        case hindi
        case hungarian
        case icelandic
        case indonesian
        case italian
        case japanese
        case kannada
        case khmer
        case korean
        case lao
        case malay
        case malayalam
        case marathi
        case mongolian
        case norwegian
        case oriya
        case persian
        case polish
        case portuguese
        case punjabi
        case romanian
        case russian
        case simplifiedChinese
        case sinhalese
        case slovak
        case spanish
        case swedish
        case tamil
        case telugu
        case thai
        case tibetan
        case traditionalChinese
        case turkish
        case ukrainian
        case urdu
        case vietnamese
        case kazakh
        
        public init?(_ language: NLLanguage) throws {
            self.init(rawValue: try language._name().unwrap())
        }
    }
    
    public init?(name: Name) {
        guard let language = NLLanguage._fromName(name.rawValue) else {
            return nil
        }
        
        self = language
    }
    
    private static func _fromName(_ string: String) -> NLLanguage? {
        guard let languageString = Name(rawValue: string) else {
            return nil
        }
        switch languageString {
            case .undetermined: return .undetermined
            case .amharic: return .amharic
            case .arabic: return .arabic
            case .armenian: return .armenian
            case .bengali: return .bengali
            case .bulgarian: return .bulgarian
            case .burmese: return .burmese
            case .catalan: return .catalan
            case .cherokee: return .cherokee
            case .croatian: return .croatian
            case .czech: return .czech
            case .danish: return .danish
            case .dutch: return .dutch
            case .english: return .english
            case .finnish: return .finnish
            case .french: return .french
            case .georgian: return .georgian
            case .german: return .german
            case .greek: return .greek
            case .gujarati: return .gujarati
            case .hebrew: return .hebrew
            case .hindi: return .hindi
            case .hungarian: return .hungarian
            case .icelandic: return .icelandic
            case .indonesian: return .indonesian
            case .italian: return .italian
            case .japanese: return .japanese
            case .kannada: return .kannada
            case .khmer: return .khmer
            case .korean: return .korean
            case .lao: return .lao
            case .malay: return .malay
            case .malayalam: return .malayalam
            case .marathi: return .marathi
            case .mongolian: return .mongolian
            case .norwegian: return .norwegian
            case .oriya: return .oriya
            case .persian: return .persian
            case .polish: return .polish
            case .portuguese: return .portuguese
            case .punjabi: return .punjabi
            case .romanian: return .romanian
            case .russian: return .russian
            case .simplifiedChinese: return .simplifiedChinese
            case .sinhalese: return .sinhalese
            case .slovak: return .slovak
            case .spanish: return .spanish
            case .swedish: return .swedish
            case .tamil: return .tamil
            case .telugu: return .telugu
            case .thai: return .thai
            case .tibetan: return .tibetan
            case .traditionalChinese: return .traditionalChinese
            case .turkish: return .turkish
            case .ukrainian: return .ukrainian
            case .urdu: return .urdu
            case .vietnamese: return .vietnamese
            case .kazakh: return .kazakh
        }
    }
    
    private func _name() -> String? {
        switch self {
            case .undetermined: return Name.undetermined.rawValue
            case .amharic: return Name.amharic.rawValue
            case .arabic: return Name.arabic.rawValue
            case .armenian: return Name.armenian.rawValue
            case .bengali: return Name.bengali.rawValue
            case .bulgarian: return Name.bulgarian.rawValue
            case .burmese: return Name.burmese.rawValue
            case .catalan: return Name.catalan.rawValue
            case .cherokee: return Name.cherokee.rawValue
            case .croatian: return Name.croatian.rawValue
            case .czech: return Name.czech.rawValue
            case .danish: return Name.danish.rawValue
            case .dutch: return Name.dutch.rawValue
            case .english: return Name.english.rawValue
            case .finnish: return Name.finnish.rawValue
            case .french: return Name.french.rawValue
            case .georgian: return Name.georgian.rawValue
            case .german: return Name.german.rawValue
            case .greek: return Name.greek.rawValue
            case .gujarati: return Name.gujarati.rawValue
            case .hebrew: return Name.hebrew.rawValue
            case .hindi: return Name.hindi.rawValue
            case .hungarian: return Name.hungarian.rawValue
            case .icelandic: return Name.icelandic.rawValue
            case .indonesian: return Name.indonesian.rawValue
            case .italian: return Name.italian.rawValue
            case .japanese: return Name.japanese.rawValue
            case .kannada: return Name.kannada.rawValue
            case .khmer: return Name.khmer.rawValue
            case .korean: return Name.korean.rawValue
            case .lao: return Name.lao.rawValue
            case .malay: return Name.malay.rawValue
            case .malayalam: return Name.malayalam.rawValue
            case .marathi: return Name.marathi.rawValue
            case .mongolian: return Name.mongolian.rawValue
            case .norwegian: return Name.norwegian.rawValue
            case .oriya: return Name.oriya.rawValue
            case .persian: return Name.persian.rawValue
            case .polish: return Name.polish.rawValue
            case .portuguese: return Name.portuguese.rawValue
            case .punjabi: return Name.punjabi.rawValue
            case .romanian: return Name.romanian.rawValue
            case .russian: return Name.russian.rawValue
            case .simplifiedChinese: return Name.simplifiedChinese.rawValue
            case .sinhalese: return Name.sinhalese.rawValue
            case .slovak: return Name.slovak.rawValue
            case .spanish: return Name.spanish.rawValue
            case .swedish: return Name.swedish.rawValue
            case .tamil: return Name.tamil.rawValue
            case .telugu: return Name.telugu.rawValue
            case .thai: return Name.thai.rawValue
            case .tibetan: return Name.tibetan.rawValue
            case .traditionalChinese: return Name.traditionalChinese.rawValue
            case .turkish: return Name.turkish.rawValue
            case .ukrainian: return Name.ukrainian.rawValue
            case .urdu: return Name.urdu.rawValue
            case .vietnamese: return Name.vietnamese.rawValue
            case .kazakh: return Name.kazakh.rawValue
            default:
                return nil
        }
    }
}
