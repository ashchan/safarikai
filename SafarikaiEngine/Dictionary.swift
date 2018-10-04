//
//  Dictionary.swift
//  Safarikai
//
//  Created by James Chen on 2016/12/05.
//  Copyright © 2016 ashchan.com. All rights reserved.
//

import Cocoa

public class Dictionary {
    private init() {}

    public static let extensionInstance: Dictionary = Dictionary()

    fileprivate var cachedWords = Set<String>()
}

extension Dictionary {

    /// Search a word.
    public func search(word: String, limit: Int = 5) -> ([Result], match: String?) {
        var results: [Result] = []
        cachedWords.removeAll()
        var longest: String?

        for len in (1 ... word.count).reversed() {
            let w = word.substring(to: len)
            let records = search(w)
            if records.count > 0 && longest == nil {
                longest = w
            }
            results += records
        }

        // TODO: limit
        return (results, longest)
    }

    /// Search word with all possible variants.
    func search(_ word: String) -> [Result] {
        /*
        var results: [Result] = []

        var entries: [Int64: [String]] = [:]
        let fields = "gloss.entry, kanji.kanji, reading.kana, reading.romaji, gloss.sense, gloss.gloss"
        let tables = "gloss left join reading on reading.entry = gloss.entry left join kanji on kanji.entry = gloss.entry"
        let likeClause = variants(for: word).map { "'" + $0 + "'" }.joined(separator: ", ")
        //results.append(Result(kana: word, kanji: "漢字", translation: "Gloss \(entry)", romaji: "kana"))

        return results*/
        return []
    }

    func variants(for word: String) -> [String] {
        var v: [String]

        if word.count > 1 {
            v = Deinflector.deinflect(word)
        } else {
            v = [word]
        }

        let hiragana = Romaji.hiragana(from: word).joined()
        if hiragana != word && hiragana.count > 0 {
            v.append(hiragana)
        }

        return v
    }

    func push(word: String, to results: inout [Result], matchedWord: String? = nil) {
        if !cachedWords.contains(word) {
            cachedWords.insert(word)
            //if record = @dict.words[word]
            //parsed = (@parseResult word, item for item in record)
            //results.push pending for pending in parsed when (not matchedWord) or (pending.kana is matchedWord or pending.kanji is matchedWord)
            /*
             words: {
                 "×": [
                     "[ばつ] /(n,uk) x-mark (used to indicate an incorrect answer in a test, etc.)/impossibility/futility/uselessness/",
                     "[ぺけ] /(n,uk) x-mark (used to indicate an incorrect answer in a test, etc.)/impossibility/futility/uselessness/",
                     "[ペケ] /(n,uk) x-mark (used to indicate an incorrect answer in a test, etc.)/impossibility/futility/uselessness/"
                 ]
             }
 */
        }
    }
}
