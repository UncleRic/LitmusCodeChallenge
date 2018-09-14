//  GoogleBooks.swift
//  LitmusCodeChallenge
//
//  Created by Frederick C. Lee on 9/13/18.
//  Copyright © 2018 Amourine Technologies. All rights reserved.
// ----------------------------------------------------------------------------------

import Foundation

// ----------------------------------
// Received Error from Server:
struct ErrorCode: Codable {
    let code: Int
    let type: String
    let info: String
}

struct ErrorStruct: Codable {
    let success: Bool
    let error: ErrorCode
}

struct GoogleState {
    let APIKey = "AIzaSyAvisnGVcTlXChaYWzvZAK4eGR4aee_ie4"
    private let url: URL = URL(string: "apple.com")!
    
    var dataDict: GoogleBooksModel?
    
    enum Message {
        case dataReceived(Data?)
        case reload(String)
    }

    enum Command {
        case loadData(url: URL, message: (Data?) -> Message)
        case errorStatus(desc: ErrorStruct)
    }

    mutating func buildURL(_ searchText: String) -> URL? {
        let base = "https://www.googleapis.com/books/v1/volumes"
        let searchTerm = "?q=\(searchText)"
        let filter = "&langRestrict=English&printType=books"
        let key = "&key=" + APIKey
        return URL(string: base + searchTerm + filter + key)
    }

    // ----------------------------------------------------------------------------------

    mutating func process(_ message: Message) -> Command? {
        switch message {
        case .dataReceived(let data):
            guard let data = data
            else { return nil }
            do {
                dataDict = try JSONDecoder().decode(GoogleBooksModel.self, from: data)
            } catch (let error) {
                print(error)
            }

        case .reload(let searchText):
            if let url = buildURL(searchText.urlVersion) {
                return .loadData(url: url, message: Message.dataReceived)
            }
        }
        return nil
    }
}
