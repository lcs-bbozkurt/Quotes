//
//  Quote.swift
//  Quotes
//
//  Created by Berk Bozkurt on 2022-02-23.
//

import Foundation

struct Quote: Decodable, Hashable, Encodable {
    let quoteText: String
    let quoteAuthor: String
}

