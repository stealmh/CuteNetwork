# CuteNetwork 1.1.1
CuteNetwork is networking code built on top of urlSession. <br>
If you've ever used Moya, which wraps Alamofire, we were inspired by that library. Try out the cute little request 🐣. <br>

### Swift Package Manager
```
.package(url: "https://github.com/stealmh/CuteNetwork", .upToNextMajor(from: "1.1.1"))
```
## Usage
First, we need to create an enumeration:
```swift
enum WhatIsEndPoint: EndPointType {
    var baseURL: URL
    
    var path: String
    
    var httpMethod: HTTPMethod
    
    var task: HTTPTask
    
    var headers: HTTPHeaders?
}
```

</br>If you populate the enumeration with details, it will look like this: 
```swift
enum WhatIsEndPoint: EndPointType {
    case getPosts
    case getSinglePost(Int)
    
    var baseURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com")!
    }
    
    var path: String {
        switch self {
        case .getPosts:
            return "/posts"
        case .getSinglePost(let id):
            return "posts/\(id)"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        // There are three requests:

        // request is used to just get a value (GET)
        return .request

        // requestParameters is the request containing the parameters.
        // Depending on the value of bodyEncoding, values other than those that apply can be ignored by putting nil.
        return .requestParameters(bodyParameters: Parameters?,
                                  bodyEncoding: ParameterEncoding,
                                  urlParameters: Parameters?)

        // In additionHeaders, you can add header values.
        // Similarly, if you want to set it in `var headers: HTTPHeaders?`,
        // you can set the value of `additionHeaders` to nil.
        return .requestParametersAndHeaders(bodyParameters: Parameters?,
                                            bodyEncoding: ParameterEncoding,
                                            urlParameters: Parameters?,
                                            additionHeaders: HTTPHeaders?)
    }
    
    var headers: HTTPHeaders? {
        return ["Content-Type": "application/json"]
    }
}
```
</br>It's simple to use. Like this! </br>
```swift
// Just put in the enumeration you created earlier and set the type to be decoded and you're done.
let cute = Cute<MyEndPoint>()

do {
    let result: PlaceholderDTO = try await cute.petit(.getSinglePost(3))
    print("result is \(result)")
} catch {
    switch error as? NetworkError {
    case .parsingError:
        print("parsing-Fail")
    default:
        print("default")
    }
 }
// Error handling can also be received as any enumeration so that it can be handled by the usage. <br>
// If it's a clearly expected error, you can simply default the rest. that's it!
// A description of this package.
```
