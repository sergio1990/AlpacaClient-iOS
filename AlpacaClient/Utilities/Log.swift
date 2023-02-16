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
}

private extension Date {
    func toString() -> String {
        Log.dateFormatter.string(from: self as Date)
    }
}
