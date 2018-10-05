//
//  Dictionary.swift
//  SafarikaiEngine
//
//  Created by Aaron Lee on 2018/09/22.
//  Copyright © 2018 Aaron Lee. All rights reserved.
//

import Foundation
import Regex

public class Dict {
    public static let shared = Dict()
    private var dictData: DictData?
    private var cachedWords = Set<String>()

    private init() {
        let dictPath = Bundle(for: type(of: self)).path(forResource: "data", ofType: "json")!
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: URL(fileURLWithPath: dictPath), options: .mappedIfSafe) {
                self?.dictData = try? JSONDecoder().decode(DictData.self, from: data)
            }
        }
    }
}

struct DictData: Decodable {
    var words: [String: [String]]
    var indexes: [String: [String]]
}

extension Dict {
    /// Search a word.
    public func search(_ word: String, limit: Int = 5) -> ([Result], match: String?) {
        var results: [Result] = []
        cachedWords.removeAll()
        var longest: String?

        if word.isEmpty {
            return (results, nil)
        }

        for len in (1 ... word.count).reversed() {
            let part = word.substring(to: len)
            let records = search(word: part)
            if records.count > 0 && longest == nil {
                longest = part
            }
            results += records

            if results.count >= limit {
                break
            }
        }

        return ([Result](results.prefix(limit)), longest)
    }

    /// Search word with all possible variants.
    func search(word: String) -> [Result] {
        guard let dictData = dictData else {
            return []
        }

        var results: [Result] = []

        let vars = variants(for: word)
        vars.forEach { push(word: $0, to: &results) }
        vars.forEach { variant in
            if let indexes = dictData.indexes[variant] {
                indexes.forEach({ index in
                    push(word: index, to: &results, matchedWord: variant)
                })
            }
        }

        return results
    }

    func variants(for word: String) -> [String] {
        var results: [String]

        if word.count > 1 {
            results = Deinflector.deinflect(word)
        } else {
            results = [word]
        }

        let hiragana = Romaji.hiragana(from: word).joined()
        if hiragana != word && hiragana.count > 0 {
            results.append(hiragana)
        }

        return results
    }

    func push(word: String, to results: inout [Result], matchedWord: String? = nil) {
        if cachedWords.contains(word) {
            return
        }

        cachedWords.insert(word)
        if let records = dictData!.words[word] {
            records.forEach { record in
                let pending = parseResult(kanji: word, result: record)
                if matchedWord == nil || (pending.kana == matchedWord || pending.kanji == matchedWord) {
                    results.append(pending)
                }
            }
        }
    }

    func parseResult(kanji: String, result: String) -> Result {
        var kana, translation: String
        if result.first == "[" {
            let parts = result.split(separator: "]")
            kana = String(parts.first!.dropFirst()) // Remove first "["
            translation = String(parts.last!)
        } else {
            kana = kanji
            translation = result
        }

        translation.replaceAll(matching: Regex("^ \\/\\(\\S+\\) "), with: "")
        translation = translation.replacingOccurrences(of: "/(P)/", with: "")
        translation = translation.split(separator: "/")
            .filter({ !$0.isEmpty })
            .joined(separator: "; ")

        return Result(kana: kana, kanji: kanji, translation: translation, romaji: Romaji.romaji(from: kana))
    }
}
