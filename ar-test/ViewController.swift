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

class ViewController: UIViewController, ARSCNViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var penButton: UIButton!
    var isTouching: Bool = false
    var isPasted: Bool = false
    var location: CGPoint? = nil
    var mrBlack = UIImage(named: "black-cropped")!
    var mrBlackNode: SCNNode? = nil
    var isCaptureMode = false
    let thumbImageView = UIImageView()
    let motionManager = CMMotionManager()
    var angle: Double? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
//        let sampleImage = UIImage(named: "black-cropped")!
        
        self.mrBlackNode = SCNNode()
        self.mrBlackNode!.geometry = SCNBox(width: mrBlack.size.width * 0.00004, height: mrBlack.size.height * 0.00004, length: 0.0001, chamferRadius: 0)
        
//        let material = SCNMaterial()
//        material.diffuse.contents = mrBlack // 表面の色は、ランダムで指定する
//        self.mrBlackNode!.geometry?.materials = [material] // 表面の情報をノードに適用
        
        if motionManager.isDeviceMotionAvailable {

            motionManager.deviceMotionUpdateInterval = 0.1;

            let queue = OperationQueue()
            motionManager.startDeviceMotionUpdates(to: queue, withHandler: { [weak self] (motion, error) -> Void in

                // Get the attitude of the device
                if let attitude = motion?.attitude {
                    // Get the pitch (in radians) and convert to degrees.
                    // Import Darwin to get M_PI in Swift
                    self?.angle = attitude.roll * Double(180.0/Float.pi)
                }

            })

            print("Device motion started")
        }
    }
    
    @objc func handleSceneViewTap(sender: UITapGestureRecognizer) {
//        let snapshot = sceneView.snapshot()
//        thumbImageView.image = snapshot
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
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
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
        guard let location = location else { return }
        guard isTouching else { return }
        
        if isPasted { return }
        isPasted = true
        let clone = mrBlackNode!.clone()
        
        if let camera = sceneView.pointOfView {
            print("----> test \(camera.position.z - 1)")
//            let worldPosition = SCNVector3(camera.position.x, camera.position.y, camera.position.z - 1)
            let worldPosition = sceneView.unprojectPoint(SCNVector3(location.x, location.y, 0.99))
            clone.position = worldPosition
            if let angle = angle {
                print("---> angle \(angle)")
                clone.rotation = SCNVector4(0,1,0,angle)
            }
            sceneView.scene.rootNode.addChildNode(clone)
        }
        
        
    }
    
    @IBAction func selectPhoto(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        // 画像選択時の処理
        // ↓選んだ画像を取得
        if let selected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.mrBlack = selected
            
            self.mrBlackNode = SCNNode()
            self.mrBlackNode!.geometry = SCNBox(width: mrBlack.size.width * 0.00004, height: mrBlack.size.height * 0.00004, length: 0.0001, chamferRadius: 0)
            
            let material = SCNMaterial()
            material.diffuse.contents = mrBlack // 表面の色は、ランダムで指定する
            self.mrBlackNode!.geometry?.materials = [material] // 表面の情報をノードに適用
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // キャンセルボタンを押下時の処理
        picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func penAction(_ sender: Any) {
        self.mrBlackNode = SCNNode()
        self.mrBlackNode!.geometry = SCNBox(width: mrBlack.size.width * 0.00000004, height: mrBlack.size.height * 0.00000004, length: 0.0000001, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = mrBlack // 表面の色は、ランダムで指定する
        self.mrBlackNode!.geometry?.materials = [material] // 表面の情報をノードに適用
    }
}
