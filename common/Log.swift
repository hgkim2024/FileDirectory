//
//  Log.swift
//  LogProject
//
//  Created by 김현구 on 3/15/24.
//

import UIKit

// MARK: - Log Tag
public enum Tag: Int {
    // MARK: - 상위 태그
    case APP
    case STORAGE
    case PHOTO
    case DOCUMENT
    case SHARE
    case PICKER
    case MEDIA
    case VIDEO
    case TEXT
    case GIF
    case LIVE
    
    // MARK: - 하위 태그
    case PATH
    case SIZE
    case NAME
    case ID
    case EXT
    case SUCCESS
    case FAIL
    case SEND
    case RECEIVED
    
    // MARK: - NONE 태그
    case NONE
    
    var title: String {
        return String(describing: self)
    }
}


// MARK: - Log Level
enum LogLevel: String {
    case TRACE
    case DEBUG
    case WARNING
    case ERROR
    case FATAL
    case NONE
}

// MARK: - Log
public class Log {
    
    static private var logLevel = LogLevel.TRACE
    static private var logTagMap = NSMutableDictionary() // : [String: [Tag]]()
    
    static func setLogLevel(_ logLevel: LogLevel) {
        self.logLevel = logLevel
    }
    
    static private func getKey(file: String, line: Int, function: String) -> String {
        return "\(file)_\(line)_\(function)"
    }
    
    public static func tag(_ tag: Tag, file: String = #file, line: Int = #line, function: String = #function) -> Log.Type {
        let key = getKey(file: file, line: line, function: function)
        setTags([tag], key: key)
        
        return Log.self
    }
    
    
    public static func tag(_ tags: [Tag], file: String = #file, line: Int = #line, function: String = #function) -> Log.Type {
        let key = getKey(file: file, line: line, function: function)
        setTags(tags, key: key)
        
        return Log.self
    }
    
    static private func setTags(_ tags: [Tag], key: String) {
        if let initValue = logTagMap[key] {
            if var list = initValue as? [Tag] {
                list.append(contentsOf: tags)
                logTagMap[key] = list.filter({$0 != Tag.NONE})
            }
        } else {
            logTagMap[key] = tags.filter({$0 != Tag.NONE})
        }
    }
    
    static private func printLog(_ message: String, logLevel: LogLevel, file: String, line: Int, function: String) {
        let key = getKey(file: file, line: line, function: function)
        
        if isNotPrintLog(logLevel: logLevel) {
            logTagMap[key] = nil
            return
        }

        var tag = ""
        
        if logTagMap[key] == nil {
            logTagMap[key] = [Tag.NONE]
        }
        
        if  let tags = (logTagMap[key] as? [Tag])?.sorted(by: {$0.rawValue < $1.rawValue}) {
            for t in tags {
                tag += "[\(t.title)]"
            }
        }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let content = "[\(logLevel.rawValue)] \(tag) [\(fileName)]:\(line) [\(function)]: - \(message)"
        
        NSLog(content)
//        LinphoneManager.instance().printLog(tag, message: content, level: logLevel.linphoneLogLevel)
        
        logTagMap[key] = nil
    }
    
    // trace
    public static func t(_ format: String, file: String = #file, line: Int = #line, function: String = #function) {
        printLog(format, logLevel: LogLevel.TRACE, file: file, line: line, function: function)
    }
    
    // debug
    public static func d(_ format: String, file: String = #file, line: Int = #line, function: String = #function) {
        printLog(format, logLevel: LogLevel.DEBUG, file: file, line: line, function: function)
    }
    
    // warning
    public static func w(_ format: String, file: String = #file, line: Int = #line, function: String = #function) {
        printLog(format, logLevel: LogLevel.WARNING, file: file, line: line, function: function)
    }
    
    // error
    public static func e(_ format: String, file: String = #file, line: Int = #line, function: String = #function) {
        printLog(format, logLevel: LogLevel.ERROR, file: file, line: line, function: function)
    }
    
    // fatal
    public static func f(_ format: String, file: String = #file, line: Int = #line, function: String = #function) {
        printLog(format, logLevel: LogLevel.FATAL, file: file, line: line, function: function)
    }
    
    static private func isNotPrintLog(logLevel: LogLevel) -> Bool {
        switch self.logLevel {
        case .TRACE:
            return false
            
        case .DEBUG:
            switch logLevel {
            case .TRACE:
                return true
            default:
                return false
            }
            
        case .WARNING:
            switch logLevel {
            case .TRACE, .DEBUG:
                return true
            default:
                return false
            }
            
        case .ERROR:
            switch logLevel {
            case .TRACE, .DEBUG, .WARNING:
                return true
            default:
                return false
            }
            
        case .FATAL:
            switch logLevel {
            case .TRACE, .DEBUG, .WARNING, .ERROR:
                return true
            default:
                return false
            }
            
        case .NONE:
            return true
        }
    }
}
