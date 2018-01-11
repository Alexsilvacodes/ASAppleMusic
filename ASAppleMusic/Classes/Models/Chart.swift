//
//  Chart.swift
//  ASAppleMusic
//
//  Copyright © 2018 Alex Silva. All rights reserved.
//

import Foundation

// API doc: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Chart.html

class Chart: Resource {

    // MARK: Resource attributes
    var id: String
    var href: URL
    var meta: [String : Any]?

    // MARK: Chart attributes
    var name: String
    var chart: String
    var chartHref: String
    var data: [Resource]
    var next: String

    init(id: String, href: URL, name: String, chart: String, chartHref: String, data: [Resource], next: String) {
        self.id = id
        self.href = href
        self.name = name
        self.chart = chart
        self.chartHref = chartHref
        self.data = data
        self.next = next
    }
}
