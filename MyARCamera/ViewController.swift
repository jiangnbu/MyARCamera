//
//  ViewController.swift
//  MyARCamera
//
//  Created by jiangzhenfeng on 2017/9/29.
//  Copyright © 2017年 jiangzhenfeng. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var mutDataArray:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
    /// 增加照片相框
    ///
    /// - Parameter image: <#image description#>
    /// - Returns: <#return value description#>
    func imageAddBorder(image:UIImage) -> UIImage! {
        let screenRect = UIScreen.main.bounds
        let imageView = UIImageView.init(frame: CGRect.init(x: screenRect.origin.x, y: screenRect.origin.y, width: image.size.width, height: image.size.height))
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 30
        imageView.image = image
        
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, imageView.isOpaque, 1.0);
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return img;
    }
    
    // MARK:  初始化
    func setupScene()
    {
        // 初始化视觉场景
        sceneView.delegate = self
        sceneView.showsStatistics = false
        
        //        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene.init()
        sceneView.scene = scene
    }
    
    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        print(node)
        return node
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("\n",error, "\n")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        print("\nsessionWasInterrupted!!!\n")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        print("\nsessionInterruptionEnded!!!\n")
    }
    
    // MARK: 点击行为交互
    @IBAction func handleCleanButton(_ sender: UIButton) {
        setupScene()
    }
    
    @IBAction func handleCameraButton(_ sender: UIButton) {
        handleCamera(button: sender)
    }

    @IBAction func handleFinishButton(_ sender: UIButton) {
        if (mutDataArray.count > 0)
        {
            let imageDict = mutDataArray.lastObject as! NSDictionary
            let image = imageDict.object(forKey: "image") as! UIImage
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
            let alertVC =  UIAlertController.init(title: "保存成功", message: "请打开相册查看", preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction.init(title: "我知道了", style: UIAlertActionStyle.default, handler: nil)
            alertVC.addAction(alertAction)
            self.present(alertVC, animated: true, completion: nil)
        }
        
    }
    
    
    // MARK: 拍照视觉场景处理
    @objc
    
    func handleCamera(button:UIButton) {
        
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        let imagePlane:SCNPlane
        imagePlane = SCNPlane.init(width: sceneView.bounds.width/4000, height: sceneView.bounds.height/4000)
        let tmpImage = imageAddBorder(image: sceneView.snapshot())
        let tmpDict = NSDictionary(object: tmpImage!, forKey: "image" as NSCopying)
        mutDataArray.add(tmpDict)
        imagePlane.firstMaterial?.diffuse.contents = tmpImage
        imagePlane.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
        
        let planeNode = SCNNode.init(geometry: imagePlane)
        sceneView.scene.rootNode.addChildNode(planeNode)
        
        // 创建转化矩阵，将截图放置在相机前 20 cm 处
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.2
        planeNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
    }
    
}
