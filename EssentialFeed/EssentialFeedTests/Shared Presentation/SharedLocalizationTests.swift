//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Ljubisa Katana on 31.1.24..
//

import XCTest
import EssentialFeed

final class SharedLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)

        assertLocalizedKeyAndValuesExist(in: bundle, table)

    }

    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }

}
