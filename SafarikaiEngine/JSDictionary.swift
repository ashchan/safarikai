//
//  JSDictionary.swift
//  SafarikaiEngine
//
//  Created by Aaron Lee on 2018/09/22.
//  Copyright © 2018 Aaron Lee. All rights reserved.
//

import Cocoa
import JavaScriptCore

public class JSDictionary {
    public static let shared = JSDictionary()
    private let context: JSContext = JSContext()
    
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
