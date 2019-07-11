//
//  ReposListViewModel.swift
//  MVVM_POC
//
//  Created by Moayad Al kouz on 7/10/19.
//  Copyright © 2019 Moayad Al kouz. All rights reserved.
//
import Foundation

protocol ReposListViewModelProtocol {
    func serachRepos(queryString: String, success: (() -> Void)?, failed: ((NSError?) -> Void)?)
    func getRepoData(at index: Int) -> (name: String, stars: String)
    var reposCount: Int { get }
}

class ReposListViewModel: ReposListViewModelProtocol {
    private var searchRepos: SearchReposResults?
    
    func serachRepos(queryString: String, success: (() -> Void)?, failed: ((NSError?) -> Void)?){
        if queryString.count < 3{
            let error = NSError(domain: "Error101", code: 101, userInfo:
                [
                    NSLocalizedDescriptionKey :  "Query string should be at least 3 chars" ,
                    NSLocalizedFailureReasonErrorKey : "Query string should be at least 3 chars"
                ]
            )
            failed?(error)
            return
        }
        
        DataSource.shared.searchRepos(queryString: queryString) { [weak self] (results) in
            switch results{
            case .success(let model):
                self?.searchRepos = model
                success?()
            case .failure(let error):
                failed?(error)
            }
        }
    }
    
    
    var reposCount: Int{
        return searchRepos?.reposItems?.count ?? 0
    }
    
    func getRepoData(at index: Int) -> (name: String, stars: String){
        guard let items = searchRepos?.reposItems, index >= 0, index < items.count else{
            return ("", "")
        }
        
        let item = items[index]
        
        return( item.name ?? "", String(format: "%d", item.stars ?? 0))
    }
}
