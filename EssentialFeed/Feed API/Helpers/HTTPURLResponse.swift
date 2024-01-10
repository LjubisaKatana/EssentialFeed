//
//  HTTPURLResponse.swift
//  EssentialFeed
//
//  Created by Ljubisa Katana on 10.1.24..
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
