//
//  ViewController.swift
//  AR Draw
//
//  Created by Akshat Aggarwal on 20/07/18.
//  Copyright © 2018 Akshat Aggarwal. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate, ColorPickerDelegate {



  @IBOutlet weak var colorPicker: ColorPickerView!

  @IBOutlet weak var sceneView: ARSCNView!

  @IBOutlet weak var drawBtn: UIButton!
  @IBOutlet weak var eraseBtn: UIButton!
  
  @IBOutlet weak var colorPickBtn: UIButton!

  var previousPoint: SCNVector3?

  var eraseRecognizer: EraseGesture!

  var drawModel: DrawModel!

  var pointerNode: SCNNode!

  var currentColor: UIColor!

  let config = ARWorldTrackingConfiguration()

  let closeImage = UIImage(named: "close.png")?.withRenderingMode(.alwaysOriginal)

  override func viewDidLoad() {
    super.viewDidLoad()

    drawModel = DrawModel()
    pointerNode = SCNNode()
    currentColor = UIColor.red

    self.colorPicker.delegate = self
    self.colorPicker.isHidden = true

    drawBtn.layer.cornerRadius = drawBtn.frame.width / 2

    colorPickBtn.layer.cornerRadius = colorPickBtn.frame.width / 2
    colorPickBtn.layer.borderWidth = 2.0
    colorPickBtn.layer.borderColor = UIColor.white.cgColor
    colorPickBtn.backgroundColor = currentColor

    sceneView.delegate = self

    self.sceneView.session.run(config)

    eraseRecognizer = EraseGesture(target: self, action: #selector(erase(sender:)))
    self.sceneView.addGestureRecognizer(eraseRecognizer)

  }

  func colorDidChange(color: UIColor) {
    self.currentColor = color
    colorPickBtn.backgroundColor = color
  }


  func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
    guard let pointOfView = sceneView.pointOfView else {
      return
    }
    let transform = pointOfView.transform
    // The transform table stores the orientation info in the 3rd column
    let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)

    // The transform stores the current location in the 4th column
    let currentLocation = SCNVector3(transform.m41, transform.m42, transform.m43 + 0.1)

    // We get the location by combining the orientation and the location
    let currentCameraPosition = orientation + currentLocation

    DispatchQueue.main.async {

      if self.drawBtn.isHighlighted {
        if let previousPoint = self.previousPoint {
          let shape = self.drawModel.drawLineBetweenTwoPoints(from: previousPoint, to: currentCameraPosition, radius: 0.01, color: self.currentColor)
          self.sceneView.scene.rootNode.addChildNode(shape)
        }
      }

      // Remove the previous pointer
      self.pointerNode.removeFromParentNode()

      // Now, add the current Pointer
      self.pointerNode = self.drawModel.getPointer(at: currentCameraPosition, ofColor: self.currentColor)
      self.sceneView.scene.rootNode.addChildNode(self.pointerNode)

      self.previousPoint = currentCameraPosition
    }
  }

  @IBAction func resetBtn(_ sender: Any) {
    self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
      node.removeFromParentNode()
    }
  }

  @IBAction func eraseBtnPressed(_ sender: Any) {
    eraseBtn.isSelected = !eraseBtn.isSelected
  }

  @objc func erase(sender: EraseGesture) {
    if eraseBtn.isSelected {
      if sender.state == .began || sender.state == .changed {
        let scene = sender.view as! SCNView
        let location = sender.location(in: scene)
        let hitTest = scene.hitTest(location)

        if !hitTest.isEmpty {
          let result = hitTest.first
          let node = result?.node
          node?.removeFromParentNode()
        }
      }
    }
  }

  @IBAction func colorPickBtnPressed(_ sender: Any) {
    self.colorPicker.isHidden = !self.colorPicker.isHidden
    if !self.colorPicker.isHidden {
      drawBtn.isEnabled = false
      colorPickBtn.setImage(closeImage, for: .normal)
    } else {
      drawBtn.isEnabled = true
      colorPickBtn.setImage(nil, for: .normal)
    }

  }
  

}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
  return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}


