//
//  Books.swift
//  LitmusCodeChallenge
//
//  Created by Frederick C. Lee on 9/13/18.
//  Copyright © 2018 Amourine Technologies. All rights reserved.
//

struct ImageLinks: Codable {
    let smallThumbnail: String
    let thumbnail: String
}

// Note: Filtering out unneeded attributes from data stream
// (some data elements were deleted.  The following were commented out):

struct VolumeInfo: Codable {
    let title: String
    let authors: [String]
//    let publisher: String
//    let publishedDate: String
//    let description: String
    let imageLinks: ImageLinks
}

struct SaleInfo: Codable {
    let country: String
    let isEbook: Bool
}

struct Epub: Codable {
    let isAvailable: Bool
}

struct Pdf: Codable {
    let isAvailable: Bool
}

struct AccessInfo: Codable {
    let country: String
    let viewability: String
    let epub: Epub
    let pdf: Pdf
    let webReaderLink: String
    let accessViewStatus: String
    let quoteSharingAllowed: Bool
}

struct Item: Codable {
    let selfLink: String
    let volumeInfo: VolumeInfo
    let saleInfo: SaleInfo
}

struct GoogleBooksModel: Codable {
    let items: [Item]
}
