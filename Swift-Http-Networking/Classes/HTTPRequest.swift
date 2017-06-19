//
//  HTTPRequest.swift
//  Pods
//
//  Created by Igor Prysyazhnyuk on 6/16/17.
//
//

import Alamofire
import ObjectMapper

public class HTTPRequest {
    
    enum Key: String {
        case array = "array"
        case string = "string"
    }
    
    private static func handleAlamofireResponse(dataResponse: DataResponse<Any>,
                                                onSuccess: ((_ dictionary: [String: Any], _ statusCode: Int) -> ())? = nil,
                                                onError: ((Error, _ statusCode: Int?) -> ())? = nil) {
        let result = dataResponse.result
        if let error = result.error {
            onError?(error, nil)
            return
        }
        
        guard let response = dataResponse.response else {
            callNoReponseError(onError: onError)
            return
        }
        
        var responseValue: [String: Any] = [:]
        if let objectValue = result.value as? [String: Any] {
            responseValue = objectValue
        } else if let arrayValue = result.value as? [Any] { // If we got array made dictionary from it for object mapper
            responseValue = [Key.array.rawValue: arrayValue as Any]
        } else if let string = result.value as? String {
            responseValue = [Key.string.rawValue: string as Any]
        }
        
        let minSuccessStatusCode = 300
        let statusCode = response.statusCode
        if statusCode < minSuccessStatusCode { onSuccess?(responseValue, statusCode) }
        else { onError?(ResponseError(value: responseValue), statusCode) }
    }
    
    private static func callNoReponseError(onError: ((Error, _ statusCode: Int?) -> ())?) {
        ResponseError(message: "No response".localized)
    }
    
    private static func makeWithDictionaryResponseMultipart(url: String,
                                                                   method: HTTPMethod,
                                                                   params: Parameters? = nil,
                                                                   headers: [String: String]? = nil,
                                                                   onSuccess: ((_ dictionary: [String: Any], _ statusCode: Int) -> ())? = nil,
                                                                   onError: ((Error, _ statusCode: Int?) -> ())? = nil) {
        let url = try! URLRequest(url: url,
                                  method: method,
                                  headers: headers)
        guard let params = params else {
            onError?(RequestError(message: "No multipart params".localized), nil)
            return
        }
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                var images = [String: UIImage]()
                for (key, value) in params {
                    if let image = value as? UIImage { images[key] = image }
                    else {
                        let stringValue = String(describing: value)
                        multipartFormData.append(stringValue.data(using: String.Encoding.utf8)!, withName: key)
                    }
                }
                for (key, value) in images {
                    if let imageData = UIImagePNGRepresentation(value) {
                        multipartFormData.append(imageData, withName: key, fileName: "\(key).png", mimeType: "image/png")
                    }
                }
        },
            with: url,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        handleAlamofireResponse(dataResponse: response, onSuccess: { (dictionary, statusCode) in
                            onSuccess?(dictionary, statusCode)
                        }, onError: onError)
                    }
                case .failure(let encodingError):
                    onError?(RequestError(message: encodingError.localizedDescription), nil)
                }
            }
        )
    }
    
    /// Make request with Mappable object response
    ///
    /// - Parameters:
    ///   - url: Full url
    ///   - method: HTTP method
    ///   - params: Parameters
    ///   - encoding: Parameters encoding, if not specified use URLEncoding
    ///   - headers: HTTP headers
    ///   - onSuccess: Closure for success response
    ///   - onError: Closure for error response
    public static func make<T: Mappable>(url: String,
                                    method: HTTPMethod,
                                    params: Parameters? = nil,
                                    encoding: ParameterEncoding? = nil,
                                    headers: [String: String]? = nil,
                                    onSuccess: @escaping (T, _ statusCode: Int) -> (),
                                    onError: ((Error, _ statusCode: Int?) -> ())? = nil) {
        makeWithDictionaryResponse(url: url, method: method, params: params, encoding: encoding, headers: headers, onSuccess: { (dictionary, statusCode) in
            DispatchQueue.global().async {
                let object = T(JSON: dictionary)
                DispatchQueue.main.async {
                    if let object = object { onSuccess(object, statusCode) }
                    else { callNoReponseError(onError: onError) }
                }
            }
        }, onError: onError)
    }
    
    /// Make request with Dictionary response
    ///
    /// - Parameters:
    ///   - url: Full url
    ///   - method: HTTP method
    ///   - params: Parameters
    ///   - encoding: Parameters encoding, if not specified use URLEncoding
    ///   - headers: HTTP headers
    ///   - onSuccess: Closure for success response
    ///   - onError: Closure for error response
    public static func makeWithDictionaryResponse(url: String,
                                                  method: HTTPMethod,
                                                  params: Parameters? = nil,
                                                  encoding: ParameterEncoding? = nil,
                                                  headers: [String: String]? = nil,
                                                  onSuccess: ((_ dictionary: [String: Any], _ statusCode: Int) -> ())? = nil,
                                                  onError: ((Error, _ statusCode: Int?) -> ())? = nil) {
        // If we have image make multipart request
        let hasImage = params?.contains(where: { $0.value is UIImage }) ?? false
        if hasImage {
            makeWithDictionaryResponseMultipart(url: url,
                                                method: method,
                                                params: params,
                                                headers: headers,
                                                onSuccess: onSuccess,
                                                onError: onError)
        } else {
            Alamofire.request(url,
                              method: method,
                              parameters: params,
                              encoding: encoding ?? URLEncoding.default,
                              headers: headers).responseJSON { (dataResponse) in
                                handleAlamofireResponse(dataResponse: dataResponse, onSuccess: { (dictionary, statusCode) in
                                    onSuccess?(dictionary, statusCode)
                                }, onError: onError)
            }
        }
    }
    
    /// Make request with Dictionary response
    ///
    /// - Parameters:
    ///   - route: HTTP route
    ///   - onSuccess: Closure for success response
    ///   - onError: Closure for error response
    public static func makeWithDictionaryResponse(route: HTTPRouter,
                                                  onSuccess: ((_ dictionary: [String: Any], _ statusCode: Int) -> ())? = nil,
                                                  onError: ((Error, _ statusCode: Int?) -> ())? = nil) {
        makeWithDictionaryResponse(url: route.url, method: route.method, params: route.params, encoding: route.encoding, headers: route.headers, onSuccess: onSuccess, onError: onError)
    }
    
    /// Make request with Mappable object response and HTTPRouter input
    ///
    /// - Parameters:
    ///   - route: HTTP route
    ///   - onSuccess: Closure for success response
    ///   - onError: Closure for error response
    public static func make<T: Mappable>(route: HTTPRouter,
                            onSuccess: @escaping (T, _ statusCode: Int) -> (),
                            onError: ((Error, _ statusCode: Int?) -> ())? = nil) {
        make(url: route.url, method: route.method, params: route.params, encoding: route.encoding, headers: route.headers, onSuccess: onSuccess, onError: onError)
    }
    
    /// Maker request with ArrayPager response
    ///
    /// - Parameters:
    ///   - nextPage: Full url of nextPage, nil by default
    ///   - route: HTTP route
    ///   - onSuccess: Closure for success response
    ///   - onError: Closure for error response
    public static func makeArrayPagerRequest<T: Mappable>(nextPage: String? = nil,
                                      route: HTTPRouter,
                                      onSuccess: @escaping (_ array: [T], _ count: Int, _ nextPage: String?, _ statusCode: Int) -> (),
                                      onError: @escaping (Error, _ statusCode: Int?) -> ()) {
        let successHandler: (ArrayPagerResponse<T>, Int) -> () = {
            (arrayPagerResponse: ArrayPagerResponse<T>, statusCode: Int) -> () in
            onSuccess(arrayPagerResponse.results, arrayPagerResponse.count, arrayPagerResponse.nextPage, statusCode)
        }
        if let nextPage = nextPage {
            make(url: nextPage, method: route.method, encoding: route.encoding, headers: route.headers, onSuccess: successHandler, onError: onError)
        } else { make(route: route, onSuccess: successHandler, onError: onError) }
    }
}
