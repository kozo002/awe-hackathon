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
    var isTouching: Bool = false
    var location: CGPoint? = nil
    var mrBlack = UIImage(named: "black-cropped")!
    var mrBlackNode: SCNNode? = nil
    var isCaptureMode = false
    let thumbImageView = UIImageView()
    
    @IBOutlet weak var photoButton: UIButton!
    let motion = CMMotionManager()
    var timer: Timer? = nil
    var motionX: Double? = nil
    var motionY: Double? = nil
    var motionZ: Double? = nil
    
    func startAccelerometers() {
       // Make sure the accelerometer hardware is available.
       if self.motion.isAccelerometerAvailable {
          self.motion.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
          self.motion.startAccelerometerUpdates()

          // Configure a timer to fetch the data.
          self.timer = Timer(fire: Date(), interval: (1.0/60.0),
                repeats: true, block: { (timer) in
             // Get the accelerometer data.
             if let data = self.motion.accelerometerData {
                self.motionX = data.acceleration.x
                self.motionY = data.acceleration.y
                self.motionZ = data.acceleration.z

                // Use the accelerometer data in your app.
             }
          })

          // Add the timer to the current run loop.
          RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.default)
       }
    }
    
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
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        if isCaptureMode { return }
        guard isTouching else { return }
        guard let location = location else { return }
        let clone = mrBlackNode!.clone()
        if let camera = sceneView.pointOfView {
            let worldPosition = SCNVector3(camera.position.x, camera.position.y, camera.position.z - 1)
            clone.position = worldPosition
            print(clone.position)
            if let motionX = motionX, let motionY = motionY, let motionZ = motionZ {
                clone.rotation = SCNVector4(motionX * 10, motionY * 10, motionZ * 10, 50)
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
            self.mrBlackNode!.geometry = SCNBox(width: mrBlack.size.width * 0.0004, height: mrBlack.size.height * 0.0004, length: 0.0001, chamferRadius: 0)
            
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
}
