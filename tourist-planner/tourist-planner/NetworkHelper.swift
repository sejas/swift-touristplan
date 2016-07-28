//
//  NetworkHelper.swift
//  baumap
//
//  Created by Antonio Sejas on 6/6/16.
//  Copyright © 2016 Antonio Sejas. All rights reserved.
//

import UIKit

class NetworkHelper: NSObject {
    // MARK: Shared Instance Singleton
    static let sharedInstance = NetworkHelper()
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    //MARK: Errors struct list
    struct anErrorStruct {
        var text: String
        var code: Int
    }
    struct errorsStruct {
        let unauthorized = anErrorStruct(text: "unauthorized", code: 403)
        let internalServer = anErrorStruct(text: "internal server", code: 500)
        let generalError = anErrorStruct(text: "Your request returned a status code other than 2xx!", code: -200)
    }
    let errors = errorsStruct()
    
    // MARK: GET JSON
    func getRequest(urlString: String, headers: [String:String]?, completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        guard let url = NSURL(string: urlString) else {
            let userInfo = [NSLocalizedDescriptionKey : "Error parsin URL \(urlString)"]
            completionHandlerForGET(result: nil, error: NSError(domain: "NetworkHelper", code: 1, userInfo: userInfo))
            return NSURLSessionDataTask()
        }
        
        let request = requestFromHeaders(url, headers: headers)
        return requestHelper(request, completionHandler: completionHandlerForGET)
    }
    
    // MARK: GET DATA
    func getRequestReturnData(urlString: String, completionHandlerForGETData: (data: NSData, error: NSError?) -> Void) -> NSURLSessionDataTask {
        guard let url = NSURL(string: urlString) else {
            let userInfo = [NSLocalizedDescriptionKey : "Error parsin URL \(urlString)"]
            completionHandlerForGETData(data: NSData(), error: NSError(domain: "NetworkHelper", code: 1, userInfo: userInfo))
            return NSURLSessionDataTask()
        }
        
        let request = requestFromHeaders(url, headers: nil)
        return requestHelperReturnData(request, completionHandler: completionHandlerForGETData)
    }
    func getImage(urlString: String, completionHandlerForGETData: (image: UIImage, data:NSData, error: NSError?) -> Void) -> NSURLSessionDataTask {
        return getRequestReturnData(urlString, completionHandlerForGETData: { (data, error) in
            guard error == nil else {
                completionHandlerForGETData(image: UIImage(), data:NSData(), error: error)
                return
            }
            if let image = UIImage(data: data) {
                completionHandlerForGETData(image: image, data:data, error: nil)
            }else{
                let userInfo = [NSLocalizedDescriptionKey : "Error converting Image \(urlString)"]
                completionHandlerForGETData(image: UIImage(), data:NSData(), error: NSError(domain: "NetworkHelper", code: 2, userInfo: userInfo))
            }
        })
    }
    
    // MARK: POST JSON get json
    func postRequestJSON(urlString: String, headers: [String:String]?, jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        guard let url = NSURL(string: urlString) else {
            let userInfo = [NSLocalizedDescriptionKey : "Error parsin URL \(urlString)"]
            completionHandlerForPOST(result: nil, error: NSError(domain: "NetworkHelper", code: 1, userInfo: userInfo))
            return NSURLSessionDataTask()
        }
        
        let request = requestFromHeaders(url, headers: headers)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        return requestHelper(request, completionHandler: completionHandlerForPOST)
    }
    
    // MARK: POST parameters get json
    func postRequest(urlString: String, headers: [String:String]?, parameters: [String:String], completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        guard let url = NSURL(string: urlString) else {
            let userInfo = [NSLocalizedDescriptionKey : "Error parsin URL \(urlString)"]
            completionHandlerForPOST(result: nil, error: NSError(domain: "NetworkHelper", code: 1, userInfo: userInfo))
            return NSURLSessionDataTask()
        }
        
        let request = requestFromHeaders(url, headers: headers)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = self.helperQueryItems(parameters).dataUsingEncoding(NSUTF8StringEncoding)
        print("HTTPBody", self.helperQueryItems(parameters))
        return requestHelper(request, completionHandler: completionHandlerForPOST)
    }
    
    private func helperQueryItems(components: [String: String]) -> String {
        return components.reduce("") { (t, s1) -> String in
            return "\(t)\(s1.0)=\(s1.1.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)&"
        }
    }
    
    
    private func requestHelperReturnData(request: NSURLRequest, completionHandler: (data: NSData, error: NSError?) -> Void) -> NSURLSessionDataTask {
        print("NetworkHelper requestHelper request:",request)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            func sendError(anError: anErrorStruct) {
                print(anError)
                let userInfo = [NSLocalizedDescriptionKey : anError.text]
                completionHandler(data: NSData(), error: NSError(domain: "NetworkHelper", code: anError.code, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError(anErrorStruct(text: "There was an error with your request: \(error)", code: 1))
                return
            }
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                let statusCode = (response as? NSHTTPURLResponse)?.statusCode
                if 403 == statusCode {
                    sendError(self.errors.unauthorized)
                }else if 500 == statusCode {
                    sendError(self.errors.internalServer)
                }else {
                    sendError(self.errors.generalError)
                }
                return
            }
            guard let data = data else {
                sendError(anErrorStruct(text: "No data was returned by the request!", code: 9))
                return
            }
            completionHandler(data: data, error: nil)
            
        }
        task.resume()
        
        return task
    }
    
    // MARK: Request helper for JSON data
    private func requestHelper(request: NSURLRequest, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        return requestHelperReturnData(request, completionHandler: { (data, error) in
            guard (error == nil) else {
                completionHandler(result: nil, error: error)
                return
            }
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandler)
        })

    }
    //MARK: Helpers
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "NetworkHelper", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    // add headers to mutable request
    private func requestFromHeaders(url: NSURL, headers: [String:String]?) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL:url)
        guard let headers = headers else {
            return request
        }
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        return request
    }
    
    // Open url in safari
    func openURLSafari(urlString: String, completionErrorHandler:() -> Void)  {
        var errorUrl = false
        if let urlToOpen = NSURL(string: urlString) {
            if !UIApplication.sharedApplication().openURL(urlToOpen)  {
                errorUrl = true
            }
        }else{
            errorUrl = true
        }
        if errorUrl {
            completionErrorHandler()
        }
    }
    
}
