//
//  Mortar
//
//  Copyright (c) 2016-Present Jason Fieldman - https://github.com/jmfieldman/Mortar
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#if os(iOS) || os(tvOS)
import UIKit
#else
import AppKit
#endif


public typealias MortarGroup = [MortarConstraint]

public extension Array where Element: MortarConstraint {

    public func activate() -> MortarGroup {
        NSLayoutConstraint.activateConstraints(self.layoutConstraints)
        return self
    }
    
    public func deactivate() -> MortarGroup {
        NSLayoutConstraint.deactivateConstraints(self.layoutConstraints)
        return self
    }
    
    public var layoutConstraints: [NSLayoutConstraint] {
        var response: [NSLayoutConstraint] = []
        self.forEach {
            response += $0.layoutConstraints
        }
        return response
    }
    
    public func replaceWith(newConstraints: MortarGroup) -> MortarGroup {
        self.deactivate()
        newConstraints.activate()
        return newConstraints
    }
    
    public func changePriority(newPriority: UILayoutPriority) -> MortarGroup {
        for constraint in self {
            constraint.changePriority(newPriority)
        }
        return self
    }
    
    public func changePriority(newPriority: MortarLayoutPriority) -> MortarGroup {
        for constraint in self {
            constraint.changePriority(newPriority)
        }
        return self
    }
}