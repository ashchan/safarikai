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
    private var dictData: DictData!
    private var cachedIndexes = Set<Int>()

    internal init() {}

    var isLoaded: Bool {
        return dictData != nil
    }

    var isLoading = false

    public func load(async: Bool = true) {
        if isLoading || isLoaded {
            return
        }

        isLoading = true

        let entriesPath = Bundle(for: type(of: self)).path(forResource: "entries", ofType: "json")!
        let indexesPath = Bundle(for: type(of: self)).path(forResource: "indexes", ofType: "json")!
        let loading = { [weak self] in
            let entriesData = try! Data(contentsOf: URL(fileURLWithPath: entriesPath), options: .mappedIfSafe)
            let indexesData = try! Data(contentsOf: URL(fileURLWithPath: indexesPath), options: .mappedIfSafe)
            let entries = try! JSONSerialization.jsonObject(with: entriesData, options: []) as! Entries
            let indexes = try! JSONSerialization.jsonObject(with: indexesData, options: []) as! Indexes
            self?.dictData = DictData(entries: entries, indexes: indexes)
        }

        if async {
            DispatchQueue.global().async {
                loading()
            }
        } else {
            loading()
        }
    }

    static func convertEdict2() {
        guard let data = try? String(contentsOfFile: "/tmp/edict2u") else {
            fatalError("/tmp/edict2u not found!")
        }
        let dictData = DictData(string: data)

        do {
            let entriesPath = "/tmp/entries.json"
            let entriesData = try JSONEncoder().encode(dictData.entries)
            FileManager.default.createFile(atPath: entriesPath, contents: entriesData, attributes: nil)

            let indexesPath = "/tmp/indexes.json"
            let indexesData = try JSONEncoder().encode(dictData.indexes)
            FileManager.default.createFile(atPath: indexesPath, contents: indexesData, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

extension Dict {
    /// Search a word.
    public func search(_ word: String, limit: Int = 5) -> ([Result], match: String?) {
        var results: [Result] = []
        cachedIndexes.removeAll()
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
        guard isLoaded else {
            return []
        }

        var results: [Result] = []

        variants(for: word).forEach { variant in
            if let index = dictData.indexes[variant] {
                index.forEach { idx in
                    let entryIndex = Int(idx[0])!
                    push(
                        index: abs(entryIndex),
                        kana: entryIndex < 0 ? variant : idx[1],
                        kanji: entryIndex < 0 ? idx[1] : variant,
                        to: &results,
                        matchedWord: variant
                    )
                }
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

    func push(index: Int, kana: String, kanji: String, to results: inout [Result], matchedWord: String) {
        if cachedIndexes.contains(index) {
            return
        }

        cachedIndexes.insert(index)

        let pending = Result(kana: kana, kanji: kanji, translation: dictData.entries[index], romaji: Romaji.romaji(from: kana))
        results.append(pending)
    }
}
