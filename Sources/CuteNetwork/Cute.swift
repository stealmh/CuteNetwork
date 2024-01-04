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
            let request = try self.buildRequest(from: route, boundary: nil)
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
//MARK: - Cute + Upload
extension Cute {
    /// - petitUpload(_ root: EndPoint, image: UIImage, fileName: String, imageType: String, petitLogVisible: Bool) async throws -> Data 함수를 래핑
    open func petitUpload<T: Decodable>(_ root: EndPoint,
                                        imageMultiPart: ImageInformation? = nil,
                                        videoMultiPart: VideoInformation? = nil,
                                        petitLogVisible: Bool = true) async throws -> T {
        guard imageMultiPart != nil || videoMultiPart != nil else {
            throw NetworkError.custom(message: "잘못된 접근")
        }
        
        do {
            let result = try await petitUpload(root,
                                               imageMultiPart: imageMultiPart,
                                               videoMultiPart: videoMultiPart,
                                               petitLogVisible: petitLogVisible)
            
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
    /// - petitUpload(_ route: EndPoint, image: UIImage, fileName: String, imageType: String, logAccess: Bool, completion: @escaping NetworkRouterCompletion) 함수를 래핑
    open func petitUpload(_ root: EndPoint,
                          imageMultiPart: ImageInformation? = nil,
                          videoMultiPart: VideoInformation? = nil,
                          petitLogVisible: Bool) async throws -> Data {
        guard imageMultiPart != nil || videoMultiPart != nil else {
            throw NetworkError.custom(message: "잘못된 접근")
        }
        
        
        return try await withCheckedThrowingContinuation({ value in
            petitUpload(root,
                        imageMultiPart: imageMultiPart,
                        videoMultiPart: videoMultiPart,
                        logAccess: petitLogVisible) { data, response, error in
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
    open func petitUpload(_ route: EndPoint,
                          imageMultiPart: ImageInformation? = nil,
                          videoMultiPart: VideoInformation? = nil,
                          logAccess: Bool,
                          completion: @escaping NetworkRouterCompletion) {
        
        guard imageMultiPart != nil || videoMultiPart != nil else {
            completion(nil, nil, NetworkError.custom(message: "잘못된 접근"))
            return
        }
        
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
            let boundary = "Boundary-\(UUID().uuidString)"
            let request = try self.buildRequest(from: route, boundary: boundary)
            let multipartBody: Data?
            if let imageMultiPart {
                multipartBody = createMultipartBody(boundary, imageMultiPart)
            } else {
                print("요기")
                multipartBody = createMultipartBody(boundary, videoMultiPart!)
            }
            if logAccess { NetworkLogger.log(request: request) }
            
            task = session.uploadTask(with: request, from: multipartBody!, completionHandler: { data, response, error in
                print(String(data: data!, encoding: .utf8))
                print(response)
                print(error)
                completion(data, response, error)
            })
            
        } catch {
            completion(nil, nil, error)
        }
        
        self.task?.resume()
    }
    
    // 이미지를 업로드하는 Multipart Form Data 요청 생성
    fileprivate func buildMultipartRequest(_ boundary: String, from route: EndPoint) throws -> URLRequest {
        var request = URLRequest(url: route.baseURL)
        request.httpMethod = route.httpMethod.rawValue
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if let header = route.headers {
            for (key, value) in header {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        return request
    }
    
    fileprivate func createMultipartBody(_ boundary: String, _ imageType: ImageInformation) -> Data {
        let boundaryPrefix = "--\(boundary)\r\n"
        var uploadData = Data()
        if let data = imageType.image.jpegData(compressionQuality: 0.8) {
            uploadData.append(boundaryPrefix.data(using: .utf8)!)
            uploadData.append("Content-Disposition: form-data; name=\"\(imageType.fieldName)\"; filename=\"\(imageType.fileName)\"\r\n".data(using: .utf8)!)
            uploadData.append("Content-Type: \(imageType.mimeType)\r\n\r\n".data(using: .utf8)!)
            uploadData.append(data)
            uploadData.append("\r\n".data(using: .utf8)!)
            uploadData.append("--\(boundary)--".data(using: .utf8)!)
        }
        return uploadData
    }
    
    fileprivate func createMultipartBody(_ boundary: String, _ videoMultiPart: VideoInformation) -> Data {
        print(#function)
        let boundaryPrefix = "--\(boundary)\r\n"
        var uploadData = Data()
        if let data = try? Data(contentsOf: videoMultiPart.videoURL) {
            uploadData.append(boundaryPrefix.data(using: .utf8)!)
            uploadData.append("Content-Disposition: form-data; name=\"\(videoMultiPart.fieldName)\"; filename=\"\(videoMultiPart.fileName)\"\r\n".data(using: .utf8)!)
            uploadData.append("Content-Type: \(videoMultiPart.mimeType)\r\n\r\n".data(using: .utf8)!)
            uploadData.append(data)
            uploadData.append("\r\n".data(using: .utf8)!)
            uploadData.append("--\(boundary)--".data(using: .utf8)!)
        }
        return uploadData
    }
    
}
//MARK: - Cute extension(fileprivate)
/// Only `Cute` Class used.
fileprivate extension Cute {
    func buildRequest(from route: EndPoint, boundary: String?) throws -> URLRequest {
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
            case .upload:
                if let boundary {
                    let request = try buildMultipartRequest(boundary, from: route)
                    return request
                }
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
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
    }
}

