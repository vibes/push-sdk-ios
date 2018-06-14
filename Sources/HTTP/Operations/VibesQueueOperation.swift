//
//  VibesQueueOperation.swift
//  VibesPush-iOS
//
//  Created by Jean-Michel Barbieri on 2/21/18.
//  Copyright © 2018 Vibes. All rights reserved.
//
import Foundation

internal class VibesQueueOperation: Operation {
    fileprivate var _isReady: Bool
    fileprivate var _isExecuting: Bool
    fileprivate var _isFinished: Bool 
    fileprivate var _isCancelled: Bool
    
    public override var isReady: Bool {
        get { return _isReady }
        set { update({ self._isReady = newValue }, key: "isReady") }
    }
    
    public override var isExecuting: Bool {
        get { return _isExecuting }
        set { update({ self._isExecuting = newValue }, key: "isExecuting") }
    }
    
    public override var isFinished: Bool {
        get { return _isFinished }
        set { update({ self._isFinished = newValue }, key: "isFinished") }
    }
    
    public override var isCancelled: Bool {
        get { return _isCancelled }
        set { update({ self._isCancelled = newValue }, key: "isCancelled") }
    }
    
    override var isAsynchronous: Bool {
        get { return true }
    }
    
    override init() {
        _isReady = true
        _isExecuting = false
        _isFinished = false
        _isCancelled = false
        super.init()
    }
    
    public override func start() {
        if self.isExecuting == false {
            self.isReady = false
            self.isFinished = false
            self.isCancelled = false
            self.isExecuting = true
        }
    }
    
    private func update(_ change: () -> Void, key: String) {
        willChangeValue(forKey: key)
        change()
        didChangeValue(forKey: key)
    }
    
    func finish() {
        self.isReady = false
        self.isExecuting = false
        self.isCancelled = false
        self.isFinished = true
    }
    
    public override func cancel() {
        self.isReady = false
        self.isFinished = false
        self.isExecuting = false
        self.isCancelled = true
    }
}
