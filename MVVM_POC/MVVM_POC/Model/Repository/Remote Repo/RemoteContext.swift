//
//  RemoteContext.swift
//
//  Created by Moayad Al kouz on 9/26/17.
//  Copyright © 2018 Moayad Al kouz. All rights reserved
//
/**
  class helps handling HTTP request to remote server.
 */

import Alamofire
import AlamofireNetworkActivityLogger

enum ContentType: String{
    case propertyList = "application/x-plist"
    case json = "application/json"
    case urlEncoded = "application/x-www-form-urlencoded"
}

protocol RemoteContextProtocol {
    func request(endPoint: EndPointProtocol, parameters:Parameters?, completion: @escaping Handler<Any>)
    func request(endPoint: EndPointProtocol, paramsAny:[Any]?, completion: @escaping Handler<Any>)
    func multipartRequest(endPoint: EndPointProtocol, params:Parameters?, multipartName: String?, uploadFiles: [AttachmentModel]?, completion: @escaping Handler<Any>)
}

final class RemoteContext: RemoteContextProtocol {
    
    
    //MARK: - Properties
    
    
    private var sessionManager: SessionManager!
    
    var baseURL: String!
    //////////////////////////////////
    
    
    //MARK: - Initializers
    
    
    /// Initialize session manager and Alamofire configurations
    init(baseURL: String){
        self.baseURL = baseURL
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        
        configuration.httpAdditionalHeaders?.updateValue("application/json", forKey: "Accept")
        self.sessionManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    
    
    
    /// Creates an HTTP request to a given endpoint address
    ///
    /// - Parameters:
    ///   - endPoint: Endpoint
    ///   - parameters: [String: Any], Optional
    ///   - completion: A callback function invoked when the operation is completed.
    func request(endPoint: EndPointProtocol, parameters:Parameters?, completion: @escaping Handler<Any>){
        let urlRequest = buildURlRequest(endPoint: endPoint, params: parameters)
        sendRequest(reqestUrl: urlRequest) { (result) in
            switch result{
                
            case .success(let response):
                guard let wsResponse = response as? DataResponse<Data> else{
                    completion(.success(Data()))
                    return
                }
                if let wsData = wsResponse.data {
                    do{
                        let data = try JSONEncoder().encode(wsData)
                        completion(.success(data))
                    } catch{
                        completion(.success(wsData))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }//End sendRequest
    }
    
    /// Creates an HTTP request to a given endpoint address
    ///
    /// - Parameters:
    ///   - endPoint: Endpoint
    ///   - parameters: [Any], Optional array of objects
    ///   - completion: A callback function invoked when the operation is completed.
    func request(endPoint: EndPointProtocol, paramsAny:[Any]?, completion: @escaping Handler<Any>){
        let params = paramsAny?.asParameters()
        let urlRequest = buildURlRequestArray(endPoint: endPoint, params: params)
        Alamofire.request(urlRequest).validate().responseData { [weak self] (response) in
            switch response.result {
            case .success:
                if let wsData = response.data {
                    do{
                        let data = try JSONEncoder().encode(wsData)
                        completion(.success(data))
                    } catch{
                        completion(.success(wsData))
                    }
                    return
                }
                completion(.success(Data()))
                
            case .failure(let responseError as NSError):
                let error = self?.buildError(response: response, responseError: responseError)
                completion(.failure(error!))
                
            }
        }//End sessionManager.request
    }
    
    func multipartRequest(endPoint: EndPointProtocol, params:Parameters?, multipartName: String?, uploadFiles: [AttachmentModel]?, completion: @escaping Handler<Any>){
        let relativePath = baseURL + endPoint.address
        let url = URL(string: relativePath)!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endPoint.httpMethod.rawValue
        
        if let headers = endPoint.headers {
            headers.keys.forEach({ (key) in
                urlRequest.setValue(headers[key]!, forHTTPHeaderField: key )
            })
        }
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let params = params{
                for (key,value) in params {
                    multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
                }
            }
            
            if let files = uploadFiles, let name = multipartName{
                for file in files{
                    multipartFormData.append(file.data, withName: name, fileName: file.fileName, mimeType: file.mimeType)
                }
            }
        }, with: urlRequest) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                upload.validate().responseData(completionHandler: { [weak self] (dataResponse) in
                    switch dataResponse.result {
                    case .success:
                        if let wsData = dataResponse.data {
                            do{
                                let data = try JSONEncoder().encode(wsData)
                                completion(.success(data))
                            } catch{
                                completion(.success(wsData))
                            }
                            return
                        }
                        completion(.success(Data()))
                    case .failure(let responseError as NSError):
                        let error = self?.buildError(response: dataResponse, responseError: responseError)
                        completion(.failure(error!))
                    }
                })
            case .failure(let responseError as NSError):
                completion(.failure(responseError))
            }
        }
    }
    
    
    
    /// Helper method to send an Http request to a given Endpoint.
    ///
    /// - Parameters:
    ///   - endPoint: Endpoint object
    ///   - parameters: Http request parameter as [String: Any], optional.
    ///   - completion: A callback function
    private func sendRequest (reqestUrl: URLRequestConvertible, completion: @escaping Handler<Any> ) {
        sessionManager.request(reqestUrl).validate().responseData { [weak self](response) in
            switch response.result {
            case .success:
                completion(.success(response))
            case .failure(let responseError as NSError):
                let error = self?.buildError(response: response, responseError: responseError)
                completion(.failure(error!))
            }
        }//End sessionManager.request
        
    }
    
    
    /// Helper method to build an HTTP request.
    ///
    /// - Parameters:
    ///   - endPoint: Endpoint object.
    ///   - params: Http request parameter as [String: Any], optional.
    /// - Returns: An Http request object of type URLRequestConvertible.
    private func buildURlRequest(endPoint: EndPointProtocol, params: Parameters?) -> URLRequestConvertible{
        let relativePath = baseURL + endPoint.address
        let url = URL(string: relativePath)!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endPoint.httpMethod.rawValue
        
        var encoding: ParameterEncoding!
        
        if let headers = endPoint.headers {
            headers.keys.forEach({ (key) in
                urlRequest.setValue(headers[key]!, forHTTPHeaderField: key )
            })
            
            if let contentType = headers["Content-Type"] {
                switch contentType {
                case ContentType.json.rawValue:
                    encoding = JSONEncoding.default
                case ContentType.propertyList.rawValue:
                    encoding = PropertyListEncoding.default
                case ContentType.urlEncoded.rawValue:
                    encoding = URLEncoding.default
                default:
                    encoding = JSONEncoding.default
                }
            }else{
                encoding = JSONEncoding.default
            }
        }
        if endPoint.httpMethod == .get || endPoint.httpMethod == .delete{
            encoding = URLEncoding.default
        }
        return try! encoding.encode(urlRequest, with: params)
    }
    
    
    /// Helper method to build an HTTP request.
    ///
    /// - Parameters:
    ///   - endPoint: Endpoint object.
    ///   - params: Http request parameter as [Any], optional.
    /// - Returns: An Http request object of type URLRequestConvertible.
    private func buildURlRequestArray(endPoint: EndPointProtocol, params: Parameters?) -> URLRequestConvertible{
        let relativePath = baseURL + endPoint.address
        let url = URL(string: relativePath)!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endPoint.httpMethod.rawValue
        urlRequest.timeoutInterval = 30
        if let headers = endPoint.headers {
            headers.keys.forEach({ (key) in
                urlRequest.setValue(headers[key]!, forHTTPHeaderField: key )
            })
        }
        
        
        let encoding = ArrayEncoding()
        
        return try! encoding.encode(urlRequest, with: params)
    }
    
    private func buildError(response: DataResponse<Data>, responseError: NSError?) -> NSError?{
        let userInfo: [String : Any] = [
            NSLocalizedDescriptionKey :  NSLocalizedString("unknownError", comment: "comment") ,
            NSLocalizedFailureReasonErrorKey : NSLocalizedString("unknownError", comment: "comment")
        ]
        let error = NSError(domain: "RemoteDataSourceDomain", code: 400, userInfo: userInfo)
        
        guard let statusCode = response.response?.statusCode else{
            return responseError
        }
        
        if Array(300..<600).contains(statusCode){
            return error
        }
        
        return responseError
    }
}


private let arrayParametersKey = "arrayParametersKey"

/// Extenstion that allows an array be sent as a request parameters
extension Array {
    /// Convert the receiver array to a `Parameters` object.
    func asParameters() -> Parameters {
        return [arrayParametersKey: self]
    }
}


/// Convert the parameters into a json array, and it is added as the request body.
/// The array should be sent as parameters using its `asParameters` method.
public struct ArrayEncoding: ParameterEncoding {
    
    /// The options for writing the parameters as JSON data.
    public let options: JSONSerialization.WritingOptions
    
    
    /// Creates a new instance of the encoding using the given options
    ///
    /// - parameter options: The options used to encode the json. Default is `[]`
    ///
    /// - returns: The new instance
    public init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        guard let parameters = parameters,
            let array = parameters[arrayParametersKey] else {
                return urlRequest
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: options)
            
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            urlRequest.httpBody = data
            
        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }
        
        return urlRequest
    }
}
