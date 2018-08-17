//
//  DrawModel.swift
//  AR Draw
//
//  Created by Akshat Aggarwal on 16/08/18.
//  Copyright © 2018 Akshat Aggarwal. All rights reserved.
//
// Credit for drawLineBetweenTwoPoints: Windchill @ https://stackoverflow.com/questions/35002232/draw-scenekit-object-between-two-points/42941966


import Foundation
import UIKit
import ARKit

class DrawModel {

  func drawLineBetweenTwoPoints(from startPoint: SCNVector3, to endPoint: SCNVector3, radius: CGFloat, color: UIColor) -> SCNNode {
    let w = SCNVector3(x: endPoint.x-startPoint.x,
                       y: endPoint.y-startPoint.y,
                       z: endPoint.z-startPoint.z)
    let l = CGFloat(sqrt(w.x * w.x + w.y * w.y + w.z * w.z))

    let resultNode = SCNNode()
    if l == 0.0 {
      // two points together.
      let sphere = SCNSphere(radius: radius)
      sphere.firstMaterial?.diffuse.contents = color
      resultNode.geometry = sphere
      resultNode.position = startPoint
      return resultNode
    }

    let cyl = SCNCylinder(radius: radius, height: l)
    cyl.firstMaterial?.diffuse.contents = color

    resultNode.geometry = cyl

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

    resultNode.transform.m11 = r_m11
    resultNode.transform.m12 = r_m12
    resultNode.transform.m13 = r_m13
    resultNode.transform.m14 = 0.0

    resultNode.transform.m21 = r_m21
    resultNode.transform.m22 = r_m22
    resultNode.transform.m23 = r_m23
    resultNode.transform.m24 = 0.0

    resultNode.transform.m31 = r_m31
    resultNode.transform.m32 = r_m32
    resultNode.transform.m33 = r_m33
    resultNode.transform.m34 = 0.0

    resultNode.transform.m41 = (startPoint.x + endPoint.x) / 2.0
    resultNode.transform.m42 = (startPoint.y + endPoint.y) / 2.0
    resultNode.transform.m43 = (startPoint.z + endPoint.z) / 2.0
    resultNode.transform.m44 = 1.0
    return resultNode
  }

  func normalizeVector(_ iv: SCNVector3) -> SCNVector3 {
    let length = sqrt(iv.x * iv.x + iv.y * iv.y + iv.z * iv.z)
    if length == 0 {
      return SCNVector3(0.0, 0.0, 0.0)
    }

    return SCNVector3( iv.x / length, iv.y / length, iv.z / length)
  }

  func getPointer(at currentCameraPosition: SCNVector3, ofColor color: UIColor) -> SCNNode{
    let pointer = SCNNode(geometry: SCNSphere(radius: 0.01 / 2))
    pointer.position = currentCameraPosition
    pointer.geometry?.firstMaterial?.diffuse.contents = color
    return pointer
  }
}
