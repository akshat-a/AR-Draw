//
//  ViewController.swift
//  AR Draw
//
//  Created by Akshat Aggarwal on 20/07/18.
//  Copyright © 2018 Akshat Aggarwal. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

  @IBOutlet weak var sceneView: ARSCNView!

  let config = ARWorldTrackingConfiguration()

  @IBOutlet weak var drawBtn: UIButton!

  var previousPoint: SCNVector3?

  override func viewDidLoad() {
    super.viewDidLoad()

    sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]

    sceneView.showsStatistics = true
    sceneView.delegate = self

    self.sceneView.session.run(config)

    let v1 = SCNVector3(0.1, 0, 0)
    let v2 = SCNVector3(0.1, 1, 0.1)

    let shape = SCNNode(geometry: getLineSegment(vector: v1, toVector: v2))
    shape.position = SCNVector3(0, 0, 0)
    shape.geometry?.firstMaterial?.diffuse.contents = UIColor.red
    self.sceneView.scene.rootNode.addChildNode(shape)
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
    guard let pointOfView = sceneView.pointOfView else {
      return
    }

    let transform = pointOfView.transform
    // The transform table stores the orientation info in the 3rd column
    // Eg: m31 refers to col 3 row 1
    let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)

    // The transform stores the current location in the 4th column
    let location = SCNVector3(transform.m41, transform.m42, transform.m43 + 0.1)

    // We get the location by combining the orientation and the location
    let currentCameraPosition = orientation + location


    DispatchQueue.main.async {
//      if self.drawBtn.isHighlighted {
//        let sphere = SCNNode(geometry: SCNSphere(radius: 0.01))
//        sphere.position = currentCameraPosition
//        sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.red
//        self.sceneView.scene.rootNode.addChildNode(sphere)
//      } else {
//        let pointer = SCNNode(geometry: SCNSphere(radius: 0.01))
//        pointer.position = currentCameraPosition
//        pointer.name = "pointer"
//        pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.red
//        self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
//          if node.name == "pointer" {
//            node.removeFromParentNode()
//          }
//        })
//        self.sceneView.scene.rootNode.addChildNode(pointer)
//      }

      if self.drawBtn.isHighlighted {
        if let previousPoint = self.previousPoint {
          // We have successfully unwrapped the value
          let line = getLineSegment(vector: previousPoint, toVector: currentCameraPosition)
          let shape = SCNNode(geometry: line)
          shape.geometry?.firstMaterial?.diffuse.contents = UIColor.red
          shape.position = SCNVector3Zero
          self.sceneView.scene.rootNode.addChildNode(shape)
        }
      } else {
        let pointer = SCNNode(geometry: SCNSphere(radius: 0.01))
        pointer.position = currentCameraPosition
        pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
          if node.geometry is SCNSphere {
            node.removeFromParentNode()
          }
        })
        self.sceneView.scene.rootNode.addChildNode(pointer)
      }
      self.previousPoint = currentCameraPosition
      glLineWidth(20)
    }
  }
}

//func getLineSegment(fromPoint: SCNVector3, toPoint: SCNVector3) -> SCNGeometry {
//  let indices: [Int] = [0, 1]
//  let source = SCNGeometrySource(vertices: [fromPoint, toPoint])
//  let element = SCNGeometryElement(indices: indices, primitiveType: .line)
//
//  return SCNGeometry(sources: [source], elements: [element])
//}

func getLineSegment(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {

  let indices: [Int32] = [0, 1]

  let source = SCNGeometrySource(vertices: [vector1, vector2])
  let element = SCNGeometryElement(indices: indices, primitiveType: .line)

  return SCNGeometry(sources: [source], elements: [element])

}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
  return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

