//
//  GithubRepoModel.swift
//  MVVM_POC
//
//  Created by Moayad Al kouz on 7/10/19.
//  Copyright © 2019 Moayad Al kouz. All rights reserved.
//

import Foundation

struct SearchReposResults: Codable {
    var count: Int?
    var reposItems : [GithubRepoModel]?
    
    private enum CodingKeys : String, CodingKey {
        case count = "total_count"
        case reposItems = "items"
    }
}

struct GithubRepoModel: Codable {
    var id: Int?
    var name: String?
    var stars: Int?
    var watchers: Int?
    
    private enum CodingKeys : String, CodingKey {
        case id = "id"
        case name = "name"
        case stars = "stargazers_count"
        case watchers = "watchers_count"
    }
}
