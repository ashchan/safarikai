//
//  DictData.swift
//  SafarikaiEngine
//
//  Created by James Chen on 2018/10/06.
//  Copyright © 2018 ashchan.com. All rights reserved.
//

import Foundation

typealias Entries = [String] // Plain gloss
typealias Indexes = [String: [[String]]] // Key: kanji (or hiragana, if entry index is negative), value: [String(entry index), kana]

struct DictData: Codable {
    var entries: Entries
    var indexes: Indexes

    enum CodingKeys: String, CodingKey {
        case entries, indexes
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        entries = (try? values.decode(Entries.self, forKey: .entries)) ?? []
        indexes = (try? values.decode(Indexes.self, forKey: .indexes)) ?? [:]
    }

    init(json: [String: Any]) {
        guard let entries = json["entries"] as? Entries, let indexes = json["indexes"] as? Indexes else {
            fatalError("Parse JSON fail")
        }

        self.entries = entries
        self.indexes = indexes
    }

    init(entries: Entries, indexes: Indexes) {
        self.entries = entries
        self.indexes = indexes
    }
}

extension DictData {
    // Load from edict2 format, the first line of which is description.
    init(string: String) {
        entries = []
        indexes = [:]

        for (index, line) in string.components(separatedBy: "\n").dropFirst().enumerated() {
            let (kanaItems, kanjiItems, gloss) = parse(line: line)
            entries.append(gloss)
            kanjiItems.forEach { kj in
                let kanjiMapping = [String(index), kanaItems[0]]
                if let kanjiItem = indexes[kj] {
                    indexes[kj] = kanjiItem + [kanjiMapping]
                } else {
                    indexes[kj] = [kanjiMapping]
                }
            }
            let kanjiItem = kanjiItems.first
            kanaItems.forEach { kn in
                let kanaMapping = [String(-index)] + [kanjiItem ?? kn]
                if let kanaItem = indexes[kn] {
                    indexes[kn] = kanaItem + [kanaMapping]
                } else {
                    indexes[kn] = [kanaMapping]
                }
            }
        }
    }

    // Parse line and return ([kana], [kanji], gloss).
    // Line format:
    //   KANJI-1;KANJI-2 [KANA-1;KANA-2] /(general information) (see xxxx) gloss/gloss/.../
    //   The sample entry (linked above) appears as follows in the EDICT2 format:
    //   収集(P);蒐集;拾集;収輯 [しゅうしゅう] /(n,vs) gathering up/collection/accumulation/(P)/
    //   In addition, the EDICT2 has as its last field the sequence number of the entry.
    //   This matches the "ent_seq" entity value in the XML edition. The field has the format: EntLnnnnnnnnX.
    //   The EntL is a unique string to help identify the field. The "X", if present, indicates that
    //   an audio clip of the entry reading is available from the JapanesePod101.com site.
    //
    // More examples:
    //   うつ病(P);鬱病(P);ウツ病;欝病 [うつびょう(うつ病,鬱病,欝病)(P);ウツびょう(ウツ病)] /(n) {med} depression/(P)/EntL1568440X/
    //   うっかり(P);ウッカリ /(adv,adv-to,vs) (on-mim) carelessly/thoughtlessly/inadvertently/(P)/EntL1001010X/
    func parse(line: String) -> ([String], [String], String) {
        let parts = line.components(separatedBy: " /")
        let (kana, kanji) = parse(words: parts.first!)
        let gloss = parts.last!.split(separator: "/").dropLast().filter({ $0 != "(P)" }).joined(separator: "; ")
        return (kana, kanji, gloss)
    }

    // Parse words. Return kana and kanji.
    func parse(words: String) -> ([String], [String]) {
        let kana: [String]
        let kanji: [String]
        let parts = words.components(separatedBy: " [").map { $0.components(separatedBy: "(")[0] }
        if parts.count == 1 {
            kana = parts[0].components(separatedBy: ";")
            kanji = []
        } else {
            kana = parts[1].replacingOccurrences(of: "]", with: "").components(separatedBy: ";").map { $0.components(separatedBy: "(")[0] }
            kanji = parts[0].components(separatedBy: ";").map { $0.components(separatedBy: "(")[0] }
        }
        return (
            kana.map { $0.replacingOccurrences(of: "(P)", with: "") },
            kanji.map { $0.replacingOccurrences(of: "(P)", with: "") }
        )
    }
}
