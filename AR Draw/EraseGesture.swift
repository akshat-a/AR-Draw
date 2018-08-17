//
//  EraseGesture.swift
//  AR Draw
//
//  Created by Akshat Aggarwal on 16/08/18.
//  Copyright © 2018 Akshat Aggarwal. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class EraseGesture: UIGestureRecognizer {
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    if touches.count != 1 {
      state = .failed
    }
    state = .began
    // Stores the location of the tap in the view the recognizer is connected to
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    if state == .failed {
      return
    }
    state = .changed
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
    state = .ended
  }
}
