//
//  main.swift
//  Gocamping
//
//  Created by 康 on 2023/10/24.
//

import UIKit

autoreleasepool {
    disableTrace() // 放在這邊，就永遠到不了下一個停止點，對反追蹤很有用
                   // 但是放在這邊一定一下就知道，這個部分叫做示威
    let className = NSStringFromClass(AppDelegate.self)
    UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, className)
}
