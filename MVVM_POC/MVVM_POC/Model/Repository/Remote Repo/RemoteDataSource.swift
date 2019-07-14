//
//  TIARemoteDataSource.swift
//
//  Created by Moayad Al kouz on 1/27/19.
//  Copyright © 2019 Moayad Al kouz. All rights reserved.
//

import Foundation

typealias Handler<T> = (Result<T?, NSError>) -> Void


class RemoteDataSource: DataSourceProtocol{
   


    private var remoteContext: RemoteContextProtocol!
    
    init() {
        //load url from xconfig file

        if let urlProtocol =  Bundle.main.object(forInfoDictionaryKey: "Protocol") as? String, let baseUrl =  Bundle.main.object(forInfoDictionaryKey: "Base URL") as? String{
            remoteContext = RemoteContext(baseURL: urlProtocol + "://" + baseUrl)
        }else{
            remoteContext = RemoteContext(baseURL: "https://api.github.com/")

        }
        
    }
    
    func requestData<T: Codable>(endPoint: EndPoint ,parameters: [String: Any]? , model: T.Type ,completionHandler: @escaping Handler<T>){
        remoteContext.request(endPoint: endPoint, parameters: parameters) { (result) in
            switch result{
            case .success(let data):
                let decoder = JSONDecoder()
                do{
                    let model = try decoder.decode(model.self, from: data as! Data)
                    print(model)
                    completionHandler(.success(model))
                }catch let err{
                    completionHandler(.failure(err as NSError))
                }
            case .failure(let error):
                print("Error. In \(#function). \(error.localizedDescription)")
                completionHandler(.failure(error))
            }
        }
    }
    
    func searchRepos(queryString: String, completionHandler: @escaping Handler<SearchReposResults>) {
        let endPoint = EndPoint(address: ApiEndPoints.search, httpMethod: .get)
        
        let params = [ "q" : queryString ]
        requestData(endPoint: endPoint, parameters: params, model: SearchReposResults.self, completionHandler: completionHandler)
    }
}
