//
//  LocalDataSource.swift
//
//  Created by Moayad Al kouz on 7/8/18.
//  Copyright © 2018 Moayad Al kouz. All rights reserved.
//

import Foundation


class LocalDataSource: DataSourceProtocol{
    //MARK: - Properties
    lazy var localContext = LocalContext()
    
    func searchRepos(queryString: String, completionHandler: @escaping Handler<SearchReposResults>) {
        fatalError("Search online only")
    }
}

