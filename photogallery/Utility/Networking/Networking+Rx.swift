//
//  Networking+Rx.swift
//  photoGallery
//
//  Created by Arup Saha on 06/10/17.
//  Copyright © 2017 Arup Saha. All rights reserved.
//

import RxSwift
import Moya
import SwiftyJSON
import Alamofire

protocol JSONMappable {
    init(json: JSON)
}

extension JSONMappable {
    static func fromJSONArray(_ json: [Any]) -> [Self] {
        let jsonData = json.map {
            JSON($0)
            }.map {
                Self(json: $0)
        }
        return jsonData
    }
    
    static func fromJSONArray(_ json: [JSON]) -> [Self] {
        return json.map { Self(json: $0) }
    }
}

enum PGError: Error {
    case ParsingError
    case UploadError
    case NetworkError
    
    static func isNetworkError(_ code: Int) -> Bool {
        return code == NSURLErrorTimedOut ||
            code == NSURLErrorNetworkConnectionLost ||
            code == NSURLErrorNotConnectedToInternet ||
            code == NSURLErrorCannotConnectToHost ||
            code == NSURLErrorCannotFindHost
    }
}

extension ObservableType where E == Response {
    func mapToModels<T: JSONMappable>(_: T.Type, arrayRootPath: [String]) -> Observable<Result<[T]>> {
        return observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { result -> Result<[T]> in
                if PGError.isNetworkError(result.statusCode) {
                    return Result.failure(PGError.NetworkError)
                } else {
                    var json = JSON(result.data)
                    arrayRootPath.forEach({
                        json = json[$0]
                    })
                    if let array = json.array {
                        return Result.success(T.fromJSONArray(array))
                    } else {
                        return Result.success([])
                    }
                }
        }
    }
    
    func mapToModel<T: JSONMappable>(_: T.Type) -> Observable<Result<T>> {
        return observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { result -> Result<T> in
                if PGError.isNetworkError(result.statusCode) {
                    return Result.failure(PGError.NetworkError)
                } else {
                    return Result.success(T(json: JSON(result.data)))
                }
        }
    }
}

extension MoyaProvider {
    /// Designated request-making method which won't return error.
    public func requestWithoutError(_ token: Target) -> Observable<Response> {
        // Creates an observable that starts a request each time it's subscribed to.
        return Observable.create { [weak self] observer in
            let cancellableToken = self?.request(token) { result in
                switch result {
                case let .success(response):
                    observer.onNext(response)
                    observer.onCompleted()
                    break
                case .failure(let failureRes):
                    switch failureRes {
                    case .underlying(let response):
                        observer.onNext(Response(statusCode: response.0._code,
                                                 data: Data(),
                                                 response: nil))
                        observer.onCompleted()
                        break
                    default:
                        observer.onNext(Response(statusCode: NSURLErrorCannotParseResponse,
                                                 data: Data(),
                                                 response: nil))
                        observer.onCompleted()
                        break
                    }
                }
            }
            return Disposables.create {
                cancellableToken?.cancel()
            }
        }
    }
}
