//
//  StateManager.swift
//  mocacong
//
//  Created by Suji Lee on 2023/07/01.
//

import SwiftUI
import Combine

class StateManager: ObservableObject {
    
    static let shared = StateManager()
    
    @Published private var _isLoggedIn: Bool = false
    @Published private var _isAgreed: Bool = false
    @Published private var _tokenExpired: Bool = false
    @Published private var _serverDown: Bool = false
    @Published private var _userReportCount: Int = 0
        
    var isLoggedIn: Bool {
        get {
            return self._isLoggedIn
        }
        set {
            self._isLoggedIn = newValue
        }
    }
    var isAgreed: Bool {
        get {
            return self._isAgreed
        }
        set {
            self._isAgreed = newValue
        }
    }
    var tokenExpired: Bool {
        get {
            return self._tokenExpired
        }
        set {
            self._tokenExpired = newValue
        }
    }
    var serverDown: Bool {
        get {
            return self._serverDown
        }
        set {
            self._serverDown = newValue
        }
    }
    var userReportCount: Int {
        get {
            return self._userReportCount
        }
        set {
            self._userReportCount = newValue
        }
    }
    
    init() {}
    
}
