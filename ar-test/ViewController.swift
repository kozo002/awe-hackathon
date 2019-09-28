//
//  ViewController.swift
//  ar-test
//
//  Created by STEPHANUS IVAN on 2019/09/28.
//  Copyright © 2019 STEPHANUS IVAN. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreMotion

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var isTouching: Bool = false
    var isPasted: Bool = false
    var location: CGPoint? = nil
    let mrBlack = UIImage(named: "black-cropped")!
    var mrBlackNode: SCNNode? = nil
    var isCaptureMode = false
    let thumbImageView = UIImageView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
//        let sampleImage = UIImage(named: "black-cropped")!
        
        self.mrBlackNode = SCNNode()
        self.mrBlackNode!.geometry = SCNBox(width: mrBlack.size.width * 0.0004, height: mrBlack.size.height * 0.0004, length: 0.0001, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = mrBlack // 表面の色は、ランダムで指定する
        self.mrBlackNode!.geometry?.materials = [material] // 表面の情報をノードに適用
        
//        self.mrBlackNode.position = SCNVector3(0, 0, -0.5) // ノードの位置は、原点から左右：0m 上下：0m　奥に50cmとする
//        node.rotation = SCNVector4(x: 0, y: -30, z: -5, w: 20)
//        sceneView.scene.rootNode.addChildNode(node)
        
        
        if isCaptureMode {
            let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSceneViewTap))
            sceneView.addGestureRecognizer(singleTapRecognizer)
            thumbImageView.frame = CGRect(x: 16, y: 40, width: self.view.frame.size.width / 4, height: self.view.frame.size.height / 4)
            self.view.addSubview(thumbImageView)
        }
        
        
    }
    
    @objc func handleSceneViewTap(sender: UITapGestureRecognizer) {
        let snapshot = sceneView.snapshot()
        thumbImageView.image = snapshot
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.frameSemantics = .personSegmentationWithDepth

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func randomColor() -> UIColor {
        let red = CGFloat(arc4random() % 10) * 0.1
        let green = CGFloat(arc4random() % 10) * 0.1
        let blue = CGFloat(arc4random() % 10) * 0.1
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
        
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = true
        guard let location = touches.first?.location(in: nil) else { return }
        self.location = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: nil) else { return }
        self.location = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false
        isPasted = false
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        if isCaptureMode { return }
        guard isTouching else { return }
        guard let location = location else { return }
        if isPasted { return }
        isPasted = true
        let clone = mrBlackNode!.clone()
        let worldPosition = sceneView.unprojectPoint(SCNVector3(location.x, location.y, 0.995))
        clone.position = worldPosition

        sceneView.scene.rootNode.addChildNode(clone)
    }
}
