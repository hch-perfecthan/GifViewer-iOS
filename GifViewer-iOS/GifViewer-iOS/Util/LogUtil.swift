//
//  LogUtil.swift
//  GifViewer
//
//  Created by Chang-Hoon Han on 2020/08/03.
//  Copyright © 2020 Chang-Hoon Han. All rights reserved.
//

import Foundation

/**
 * 로그 설정 클래스
 */
class LogUtil {
    
    private static let TAG: String = NSStringFromClass(LogUtil.self);
    
    public static let IS_ENABLED = true;
    
    static func print(_ log: Any) {
        print(TAG, log);
    }
    
    static func print(_ tag: String, _ log: Any) {
        if (LogUtil.IS_ENABLED) {
            Swift.print(tag, log);
        }
    }
}
