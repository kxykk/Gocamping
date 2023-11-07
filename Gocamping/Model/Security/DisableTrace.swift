//
//  DisableTrace.swift
//  Gocamping
//
//  Created by 康 on 2023/10/24.
//

import Foundation

@inline(__always)
func disableTrace() {
    #if !DEBUG // Preprocess Macro.
    let disableAttach: CInt = 31
    let handle = dlopen("/usr/lib/libc.dylib", RTLD_NOW)
    let sym = dlsym(handle, "ptrace")
    typealias PtraceType = @convention(c)(CInt, pid_t, CInt, CInt) -> CInt
    let ptrace = unsafeBitCast(sym, to: PtraceType.self)
    _ = ptrace(disableAttach, 0, 0, 0)
    dlclose(handle)
    #endif
}
