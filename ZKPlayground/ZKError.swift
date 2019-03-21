//
//  ZKError.swift
//  ZKPlayground
//
//  Created by Ronald "Danger" Mannak on 3/20/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

enum ZKError: Error {
    case fileNotFound(String)
    case directoryNotFound(String)
    case cannotOpenFile(String)
    case cannotSaveFile(String)
    case platformNotFound(String)
    case frameworkNotFound(String)
    case bashScriptFailed(String)
    case initError(String)
    case internalError(String)
}
