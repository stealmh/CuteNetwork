//
//  Cute.swift
//  
//
//  Created by mino on 2023/11/29.
//

import Foundation

open class Cute<EndPoint: EndPointType>: NSObject, NetworkRouter, URLSessionDelegate {
    /// Properties
    private var task: URLSessionTask?
    /// petit(_ root: EndPoint, petitLogVisible: Bool) async throws -> Data 함수를 통해 받은 Data를 파싱해주는 함수입니다.
    open func petit<T: Decodable>(_ root: EndPoint, petitLogVisible: Bool = true) async throws -> T {
        do {
            let result = try await petit(root, petitLogVisible: petitLogVisible)
            
            let decoder = JSONDecoder()
            let data = try decoder.decode(T.self, from: result)
            
            return data
        } catch {
            /// [1] `result` error handling
            if let networkError = error as? NetworkError { throw networkError }
            /// [2] `Decode fail` error handling
            else { throw NetworkError.parsingError }
        }
    }
    /// petit(_ route: EndPoint, logAccess: Bool, completion: @escaping NetworkRouterCompletion)를 받아
    /// 에러, 데이터를 넘겨주는 함수, 정상일 경우 Data를 반환합니다.
    open func petit(_ root: EndPoint, petitLogVisible: Bool) async throws -> Data {
        return try await withCheckedThrowingContinuation({ value in
            petit(root, logAccess: petitLogVisible) { data, response, error in
                if let error {
                    value.resume(throwing: error as? NetworkError ?? NetworkError.custom(message: error.localizedDescription))
                }
                
                if let response = response as? HTTPURLResponse {
                    let result = ResponseHandler.handleNetworkResponse(response)
                    switch result {
                    case .success:
                        guard let data else {
                            value.resume(throwing: NetworkError.custom(message: "데이터를 받지 못했습니다."))
                            return
                        }
                        value.resume(returning: data)
                    case .failure(let message):
                        guard let _ = data else {
                            value.resume(throwing: NetworkError.custom(message: message))
                            return
                        }
                    }
                }
            }
        })
    }
    /// dataTask를 걸친 데이터 까지 넘겨주는 역할
    open func petit(_ route: EndPoint, logAccess: Bool, completion: @escaping NetworkRouterCompletion) {
        guard Reachability.isConnectedToNetwork() else {
            completion(nil, nil, NetworkError.noConnectionToInternet)
            return
        }
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 60
        if #available(iOS 11, *) {
            configuration.waitsForConnectivity = true
        }
        let session = URLSession(configuration: configuration)
        do {
            let request = try self.buildRequest(from: route)
            if logAccess { NetworkLogger.log(request: request) }
            task = session.dataTask(with: request, completionHandler: { data, response, error in
                completion(data, response, error)
            })
        } catch {
            completion(nil, nil, error)
        }
        self.task?.resume()
    }
    
    open func cancel() {
        self.task?.cancel()
    }
}
//MARK: - Cute extension(fileprivate)
/// Only `Cute` Class used.
fileprivate extension Cute {
    func buildRequest(from route: EndPoint) throws -> URLRequest {
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path))
        request.httpMethod = route.httpMethod.rawValue
        do {
            switch route.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
            case .requestParameters(let bodyParameters,
                                    let bodyEncoding,
                                    let urlParameters):
                
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
                
            case .requestParametersAndHeaders(let bodyParameters,
                                              let bodyEncoding,
                                              let urlParameters,
                                              let additionalHeaders):
                self.addHeaders(route.headers, request: &request)
                self.addHeaders(additionalHeaders, request: &request)
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
            }
            return request
        } catch {
            throw error
        }
    }
    
    func configureParameters(bodyParameters: Parameters?,
                                         bodyEncoding: ParameterEncoding,
                                         urlParameters: Parameters?,
                                         request: inout URLRequest) throws {
        do {
            try bodyEncoding.encode(urlRequest: &request,
                                    bodyParameters: bodyParameters, urlParameters: urlParameters)
        } catch {
            throw error
        }
    }
    
    func addHeaders(_ headers: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = headers else { return }
        headers.forEach { request.setValue($0, forHTTPHeaderField: $1) }
    }
}
