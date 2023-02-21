//
//  Log.swift
//  AlpacaClient
//
//  Created by Sergey Gernyak on 16.02.2023.
//

import Foundation

class Log {
    enum EventType: String {
        case error = "[‼️]"
        case info = "[ℹ️]"
        case debug = "[💬]"
        case verbose = "[🔬]"
        case warning = "[⚠️]"
        case severe = "[🔥]"
        case api = "[🌎]"
    }
    
    fileprivate static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS" // Use your own
    fileprivate static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    class func error(_ object: Any) {
        print("\(Date.now.toString()) \(EventType.error.rawValue)[\(object)]")
    }

    class func info(_ object: Any) {
        print("\(Date.now.toString()) \(EventType.info.rawValue)[\(object)]")
    }

    class func debug(_ object: Any) {
        debugPrint("\(Date.now.toString()) \(EventType.debug.rawValue)[\(object)]")
    }

    class func verbose(_ object: Any) {
        print("\(Date.now.toString()) \(EventType.verbose.rawValue)[\(object)]")
    }

    class func warning(_ object: Any) {
        print("\(Date.now.toString()) \(EventType.warning.rawValue)[\(object)")
    }

    class func severe(_ object: Any) {
        print("\(Date.now.toString()) \(EventType.severe.rawValue)[\(object)")
    }
    
    class func API(request: URLRequest) {
        var mutableString = "\n"

        if let httpMethod = request.httpMethod {
            mutableString.append("➡️ \(httpMethod) ")
        }
        if let url = request.url {
            mutableString.append("\(url)")
        }
        if let allHTTPHeaderFields = request.allHTTPHeaderFields {
            mutableString.append("\n📜 Header Fields:")
            if allHTTPHeaderFields.count > 0 {
                for (key, value) in allHTTPHeaderFields {
                    mutableString.append("\n\(key): \(value)")
                }
            } else {
                mutableString.append("\n<no-headers-specified>")
            }
        }
        if let httpBody = request.httpBody {
            mutableString.append("\n📦 Body: \(String(decoding: httpBody, as: UTF8.self))")
        } else {
            mutableString.append("\n📦 Body: <no-data>")
        }

        print("\(Date().toString()) \(EventType.api.rawValue) \(mutableString)")
    }
    
    class func API(response: URLResponse, object: Data?) {
        guard let httpUrlResponse = response as? HTTPURLResponse else { return }
        let statusCode = httpUrlResponse.statusCode

        var mutableString = "\n"

        mutableString.append("⬅️ \(statusCode) ")

        if let url = response.url {
            mutableString.append("\(url)")
        }
        mutableString.append("\n📜 Header Fields:")
        if httpUrlResponse.allHeaderFields.count > 0 {
            for (key, value) in httpUrlResponse.allHeaderFields {
                mutableString.append("\n\(key): \(value)")
            }
        } else {
            mutableString.append("\n<no-headers-specified>")
        }
        if let object = object {
            mutableString.append("\n📦 Body: \(String(decoding: object, as: UTF8.self))")
        } else {
            mutableString.append("\n📦 Body: <no-data>")
        }

        print("\(Date().toString()) \(EventType.api.rawValue) \(mutableString)")
    }
}

private extension Date {
    func toString() -> String {
        Log.dateFormatter.string(from: self as Date)
    }
}
