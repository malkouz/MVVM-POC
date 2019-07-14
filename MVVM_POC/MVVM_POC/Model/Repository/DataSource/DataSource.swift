//
//  DataSource.swift
//
//  Created by Moayad Al kouz on 7/8/18.
//  Copyright © 2018 Moayad Al kouz. All rights reserved.
//

import Foundation


typealias Handler<T> = (Result<T?, NSError>) -> Void


protocol DataSourceProtocol {
    func searchRepos(queryString: String, completionHandler: @escaping Handler<SearchReposResults>)
}


final class DataSource: DataSourceProtocol {
    
    //MARK: Shared Instance
    static var shared: DataSourceProtocol = DataSource()
    
    //MARK: - Properties
    
    private lazy var remoteDataSource:DataSourceProtocol = RemoteDataSource()
    private lazy var localDataSource:DataSourceProtocol = LocalDataSource()
    
    //MARK: - Initializers
    
    /// Can't init
    private init() {
        
    }
    
    
    func searchRepos(queryString: String, completionHandler: @escaping Handler<SearchReposResults>) {
        remoteDataSource.searchRepos(queryString: queryString, completionHandler: completionHandler)
        
        
    }
    
    
    //////////////////////////////////
}
