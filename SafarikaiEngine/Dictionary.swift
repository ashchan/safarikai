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

        let dictPath = Bundle(for: type(of: self)).path(forResource: "data", ofType: "json")!
        let loading = { [weak self] in
            if let data = try? Data(contentsOf: URL(fileURLWithPath: dictPath), options: .mappedIfSafe) {
                let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                self?.dictData = DictData(json: json)
            }
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
            let path = "/tmp/data.json"
            let data = try JSONEncoder().encode(dictData)
            FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
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
            if let index = dictData.kanji[variant] {
                index.forEach { idx in
                    push(index: Int(idx[0])!, kana: idx[1], kanji: variant, to: &results, matchedWord: variant)
                }
            } else {
                if let index = dictData.hiragana[variant] {
                    index.forEach { idx in
                        push(
                            index: Int(idx[0])!,
                            kana: variant,
                            kanji: idx.count > 1 ? idx[1] : variant,
                            to: &results,
                            matchedWord: variant
                        )
                    }
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
