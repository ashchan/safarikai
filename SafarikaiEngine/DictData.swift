//
//  DictData.swift
//  SafarikaiEngine
//
//  Created by James Chen on 2018/10/06.
//  Copyright © 2018 ashchan.com. All rights reserved.
//

import Foundation

struct DictData: Codable {
    var items: [[String]] // kana, gloss
    var indexes: [String: [Int]] // word: [index in words]

    enum CodingKeys: String, CodingKey {
        case items
        case indexes
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        items = (try? values.decode([[String]].self, forKey: .items)) ?? []
        indexes = (try? values.decode([String: [Int]].self, forKey: .indexes)) ?? [:]
    }

    init(json: [String: Any]) {
        guard let items = json["items"] as? [[String]], let indexes = json["indexes"] as? [String: [Int]] else {
            fatalError("Parse json fail")
        }

        self.items = items
        self.indexes = indexes
    }
}

extension DictData {
    // Load from edict2 format, the first line of which is description.
    init(string: String) {
        items = []
        indexes = [:]

        for (index, line) in string.components(separatedBy: "\n").dropFirst().enumerated() {
            let (words, gloss) = parse(line: line)
            items.append([words[0], gloss])
            words.forEach { word in
                if let existing = indexes[word] {
                    indexes[word] = existing + [index]
                } else {
                    indexes[word] = [index]
                }
            }
        }
    }

    // Parse line and return ([word], gloss), first of [word] is kana.
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
    func parse(line: String) -> ([String], String) {
        let parts = line.components(separatedBy: " /")
        let words = parse(words: parts.first!)
        let gloss = parts.last!.split(separator: "/").dropLast(2).filter({ $0 != "(P)" }).joined(separator: "; ")
        return (words, gloss)
    }

    // Parse words. The first word is always kana.
    func parse(words: String) -> [String] {
        let results: [String]
        let parts = words.components(separatedBy: " [")
        if parts.count == 1 {
            results = parts[0].components(separatedBy: ";")
        } else {
            results = parts[1].replacingOccurrences(of: "]", with: "").components(separatedBy: ";") + parts[0].components(separatedBy: ";")
        }
        return results.map { $0.replacingOccurrences(of: "(P)", with: "") }
    }
}
