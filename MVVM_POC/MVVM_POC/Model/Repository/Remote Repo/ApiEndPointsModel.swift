//
//  ApiEndPoints.swift
//
//  Created by Moayad Al kouz on 9/28/17.
//  Copyright © 2018 Moayad Al kouz. All rights reserved
//

import Alamofire


//MARK: - OAuth Enums


enum OAuthGrantType: String{
    case phoneNumber
    case refresh_token
}

enum OAuthKeys: String{
    case phoneNumber
    case grant_type
    case code
    case client_id
    case client_secret
    case refresh_token
}
//////////////////////////////////


//MARK: - ApiEndPoints


public enum ApiEndPoints: String{
	///GET
    case search = "search/repositories"
    
}


//////////////////////////////////



//////////////////////////////////

//MARK: - Endpoint
protocol EndPointProtocol {
    var address: String { get set }
    var httpMethod: HTTPMethod { get set }
    var headers: [String:String]? { get set }
}
struct EndPoint: EndPointProtocol {
    
    //MARK: - Properties
    var address: String
    var httpMethod: HTTPMethod
    var headers: [String:String]?
    //MARK: - Initializers
    
    /// Initializes an Endpoint object.
    ///
    /// - Parameters:
    ///   - address: TIAApiEndPoints Enum
    ///   - httpMethod: HTTPMethod
    ///   - headers: [[String: String]], Optional with nil as default value.
    init(address: ApiEndPoints, httpMethod: HTTPMethod, headers: [String:String]? = nil) {
        self.address = address.rawValue
        self.httpMethod = httpMethod
        self.headers = headers
    }
    
    init(address: String, httpMethod: HTTPMethod, headers: [String:String]? = nil) {
        self.address = address
        self.httpMethod = httpMethod
        self.headers = headers
    }
}


//////////////////////////////////


//MARK: - ApiHeaderKey


enum ApiHeaderKey: String {
    case clientId = "client_id"
    case clientSecret = "client_secret"
    case language = "Accept-Language"
    case environment = "x-environment"
    case authorization = "Authorization"
    case apiVersion = "api-version"
    case authorizationType = "bearer"
    case contentType = "Content-Type"
    case accept = "Accept"
    case origin = "Origin"
}




