//
//  Dictionary.swift
//  SafarikaiEngine
//
//  Created by Aaron Lee on 2018/09/22.
//  Copyright © 2018 Aaron Lee. All rights reserved.
//

import Cocoa
import JavaScriptCore

public class Dictionary {
    public static let shared = Dictionary()
    private let context: JSContext = JSContext()
    private var cachedWords = Set<String>()

    init() {
        // load japanese-kit
        let romajiPath = Bundle.main.path(forResource: "romaji", ofType: "js")
        let romajiSource = try! String.init(contentsOfFile: romajiPath!)
        context.evaluateScript("\(romajiSource)")
        let deinflectPath = Bundle.main.path(forResource: "deinflect", ofType: "js")
        let deinflectSource = try! String.init(contentsOfFile: deinflectPath!)
        context.evaluateScript("this.Deinflect=\(deinflectSource)")

        let dicPath = Bundle.main.path(forResource: "dictionary", ofType: "js")
        let dicSource = try! String.init(contentsOfFile: dicPath!)
        context.evaluateScript(dicSource)

        // prepareDictionary
        context.evaluateScript("this.dict = new Dictionary")

        let edictPath = Bundle.main.path(forResource: "data", ofType: "js")
        let edictSource = try! String.init(contentsOfFile: edictPath!)
        context.evaluateScript("this.dict.load( (function() {\(edictSource); return loadedDict;})() )")
    }

    public func search(_ word: String, limit: Int) -> ([AnyObject], match: String?) {
        guard let lookup = context.evaluateScript("this.dict.find( '\(word)', \(limit) )")!.toDictionary(),
            let results = lookup["results"] as? [AnyObject],
            let match = lookup["match"] as? String else {
            return ([], nil)
        }

        return (results, match)
    }
}

// Left for future use
extension Dictionary {
    /// Search a word.
    public func search(word: String, limit: Int = 5) -> ([Result], match: String?) {
        var results: [Result] = []
        cachedWords.removeAll()
        var longest: String?

        for len in (1 ... word.count).reversed() {
            let part = word.substring(to: len)
            let records = search(part)
            if records.count > 0 && longest == nil {
                longest = part
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
