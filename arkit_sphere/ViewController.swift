//
//  ViewController.swift
//  arkit_sphere
//
//  Created by tanabe.nobuyuki on 2020/08/25.
//  Copyright © 2020 tanabe.nobuyuki. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        sceneView.delegate = self
        
        sceneView.scene = SCNScene()
        sceneView.debugOptions = [.showFeaturePoints]
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    // 平面を検出した時に呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // 平面ジオメトリ
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let planeGeometry = ARSCNPlaneGeometry(device: sceneView.device!)!
        planeGeometry.update(from: planeAnchor.geometry)
        
        let planeColor = UIColor.white.withAlphaComponent(0.5)
        planeGeometry.materials.first?.diffuse.contents = planeColor
        let planeNode = SCNNode(geometry: planeGeometry)
        let text = SCNText(string: "Hello world!", extrusionDepth: 0.0)
        text.font = UIFont.boldSystemFont(ofSize: CGFloat(planeAnchor.extent.x / 10.0))
        text.materials.first?.diffuse.contents = UIColor.green
        let textNode = SCNNode(geometry: text)
        let (min, max) =  (textNode.boundingBox)
        textNode.pivot = SCNMatrix4MakeTranslation((max.x - min.x) / 2 + min.x, (max.y - min.y) / 2 + min.y, 0)
        textNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        textNode.position = SCNVector3(planeAnchor.center)
        planeNode.addChildNode(textNode)
        DispatchQueue.main.async {
            node.addChildNode(planeNode)
        }
    }
    
    // ARSCNViewDelegate#renderer
    // Tells the delegate that a SceneKit node's properties have been updated to match the current state of its corresponding anchor.
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else  { return }
        
        DispatchQueue.main.async(execute: {
            for childNode in node.childNodes {
                guard let plainGeometry = childNode.geometry as? ARSCNPlaneGeometry else { break }
                plainGeometry.update(from: planeAnchor.geometry)
                guard let textNode = childNode.childNodes.first,let text = textNode.geometry as? SCNText else { break }
                let size = CGFloat(min(planeAnchor.extent.x, planeAnchor.extent.z) / 10.0)
                text.font = UIFont.boldSystemFont(ofSize: size)
                let (min, max) = (textNode.boundingBox)
                let textBoundsWidth = (max.x - min.x)
                let textBoundsheight = (max.y - min.y)
                textNode.pivot = SCNMatrix4MakeTranslation(textBoundsWidth/2 + min.x, textBoundsheight/2 + min.y, 0)
                textNode.position = SCNVector3(planeAnchor.center)
                break
            }
        })
    }
    
    // ARSCNViewDelegate#renderer
    // Tells the delegate that the SceneKit node corresponding to a removed AR anchor has been removed from the scene.
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        for childNode in node.childNodes {
            if childNode.geometry as? ARSCNPlaneGeometry != nil {
                childNode.removeFromParentNode()
                break
            }
        }
    }
    
}


