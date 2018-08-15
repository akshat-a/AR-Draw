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
import OpenGLES
import GLKit

class ViewController: UIViewController, ARSCNViewDelegate {

  @IBOutlet weak var sceneView: ARSCNView!

  let config = ARWorldTrackingConfiguration()

  @IBOutlet weak var drawBtn: UIButton!

  var previousPoint: SCNVector3?
  var previousLocation: SCNVector3?

  override func viewDidLoad() {
    super.viewDidLoad()

    sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]

    sceneView.showsStatistics = true
    sceneView.delegate = self

    self.sceneView.session.run(config)

//    let v1 = SCNVector3(0.1, 0, 0)
//    let v2 = SCNVector3(0.1, 1, 0.1)
//
//    let shape = SCNNode(geometry: getLineSegment(vector: v1, toVector: v2))
//    shape.position = SCNVector3(0, 0, 0)
//    shape.geometry?.firstMaterial?.diffuse.contents = UIColor.red
//    self.sceneView.scene.rootNode.addChildNode(shape)
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  

  func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
    glLineWidth(10)
    guard let pointOfView = sceneView.pointOfView else {
      return
    }

    let transform = pointOfView.transform
    // The transform table stores the orientation info in the 3rd column
    // Eg: m31 refers to col 3 row 1
    let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)

    // The transform stores the current location in the 4th column
    let currentLocation = SCNVector3(transform.m41, transform.m42, transform.m43 + 0.1)

    // We get the location by combining the orientation and the location
    let currentCameraPosition = orientation + currentLocation


    DispatchQueue.main.async {

      if self.drawBtn.isHighlighted {
        if let previousPoint = self.previousPoint {
          // We have successfully unwrapped the value
//          let line = getLineSegment(from: previousPoint, to: currentCameraPosition)
//          let shape = SCNNode(geometry: line)
//          shape.geometry?.firstMaterial?.diffuse.contents = UIColor.red
//          shape.position = SCNVector3Zero
//          self.sceneView.scene.rootNode.addChildNode(shape)
          let line = SCNNode()
          let shape = line.drawLineBetweenTwoLines(from: previousPoint, to: currentCameraPosition, radius: 0.01, color: UIColor.red)
          self.sceneView.scene.rootNode.addChildNode(shape)

        }
      }

      let pointer = SCNNode(geometry: SCNSphere(radius: 0.01 / 2))
      pointer.position = currentCameraPosition
      pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.red
      self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
        if node.geometry is SCNSphere {
          node.removeFromParentNode()
        }
      })

      self.sceneView.scene.rootNode.addChildNode(pointer)

      self.previousPoint = currentCameraPosition
      self.previousLocation = currentLocation
    }
  }

  @IBAction func resetBtn(_ sender: Any) {
    self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
      node.removeFromParentNode()
    }
  }

}

func getLineSegment(from startPoint: SCNVector3, to endPoint: SCNVector3) -> SCNGeometry {

  glLineWidth(10)
  let indices: [Int32] = [0, 1]

  let source = SCNGeometrySource(vertices: [startPoint, endPoint])
  let element = SCNGeometryElement(indices: indices, primitiveType: .line)

  return SCNGeometry(sources: [source], elements: [element])

}

// Extension Credit: Windchill @ https://stackoverflow.com/questions/35002232/draw-scenekit-object-between-two-points
extension SCNNode {
  func drawLineBetweenTwoLines(from startPoint: SCNVector3, to endPoint: SCNVector3, radius: CGFloat, color: UIColor) -> SCNNode {
    let w = SCNVector3(x: endPoint.x-startPoint.x,
                       y: endPoint.y-startPoint.y,
                       z: endPoint.z-startPoint.z)
    let l = CGFloat(sqrt(w.x * w.x + w.y * w.y + w.z * w.z))

    if l == 0.0 {
      // two points together.
      let sphere = SCNSphere(radius: radius)
      sphere.firstMaterial?.diffuse.contents = color
      self.geometry = sphere
      self.position = startPoint
      return self

    }

    print(l)
    let cyl = SCNCylinder(radius: radius, height: l)
    cyl.firstMaterial?.diffuse.contents = color

    self.geometry = cyl

    //original vector of cylinder above 0,0,0
    let ov = SCNVector3(0, l/2.0,0)
    //target vector, in new coordination
    let nv = SCNVector3((endPoint.x - startPoint.x)/2.0, (endPoint.y - startPoint.y)/2.0,
                        (endPoint.z-startPoint.z)/2.0)

    // axis between two vector
    let av = SCNVector3( (ov.x + nv.x)/2.0, (ov.y+nv.y)/2.0, (ov.z+nv.z)/2.0)

    //normalized axis vector
    let av_normalized = normalizeVector(av)
    let q0 = Float(0.0) //cos(angel/2), angle is always 180 or M_PI
    let q1 = Float(av_normalized.x) // x' * sin(angle/2)
    let q2 = Float(av_normalized.y) // y' * sin(angle/2)
    let q3 = Float(av_normalized.z) // z' * sin(angle/2)

    let r_m11 = q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
    let r_m12 = 2 * q1 * q2 + 2 * q0 * q3
    let r_m13 = 2 * q1 * q3 - 2 * q0 * q2
    let r_m21 = 2 * q1 * q2 - 2 * q0 * q3
    let r_m22 = q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3
    let r_m23 = 2 * q2 * q3 + 2 * q0 * q1
    let r_m31 = 2 * q1 * q3 + 2 * q0 * q2
    let r_m32 = 2 * q2 * q3 - 2 * q0 * q1
    let r_m33 = q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3

    self.transform.m11 = r_m11
    self.transform.m12 = r_m12
    self.transform.m13 = r_m13
    self.transform.m14 = 0.0

    self.transform.m21 = r_m21
    self.transform.m22 = r_m22
    self.transform.m23 = r_m23
    self.transform.m24 = 0.0

    self.transform.m31 = r_m31
    self.transform.m32 = r_m32
    self.transform.m33 = r_m33
    self.transform.m34 = 0.0

    self.transform.m41 = (startPoint.x + endPoint.x) / 2.0
    self.transform.m42 = (startPoint.y + endPoint.y) / 2.0
    self.transform.m43 = (startPoint.z + endPoint.z) / 2.0
    self.transform.m44 = 1.0
    return self
  }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
  return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func normalizeVector(_ iv: SCNVector3) -> SCNVector3 {
  let length = sqrt(iv.x * iv.x + iv.y * iv.y + iv.z * iv.z)
  if length == 0 {
    return SCNVector3(0.0, 0.0, 0.0)
  }

  return SCNVector3( iv.x / length, iv.y / length, iv.z / length)
}



