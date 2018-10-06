//
//  DictData.swift
//  SafarikaiEngine
//
//  Created by James Chen on 2018/10/06.
//  Copyright © 2018 ashchan.com. All rights reserved.
//

import Foundation

struct DictData: Decodable {
    var words: [String: [String]]
    var indexes: [String: [String]]

    enum CodingKeys: String, CodingKey {
        case words
        case indexes
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        words = (try? values.decode([String: [String]].self, forKey: .words)) ?? [:]
        indexes = (try? values.decode([String: [String]].self, forKey: .indexes)) ?? [:]
    }

    init(json: [String: Any]) {
        guard let words = json["words"] as? [String: [String]], let indexes = json["indexes"] as? [String: [String]] else {
            fatalError("Parse json fail")
        }

        self.words = words
        self.indexes = indexes
    }
}
