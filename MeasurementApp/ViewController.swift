//
//  ViewController.swift
//  MeasurementApp
//
//  Created by Abdulfatah Mohamed on 28/11/2022.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var spheres = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView = ARSCNView(frame: self.view.frame)
        self.view.addSubview(self.sceneView)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        addCrossSign()
        registerGestureRecognizers()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    private func registerGestureRecognizers() {
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapRecognizer)
        
    }
    
    @objc func tapped(recognizer: UIGestureRecognizer) {
        
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = self.sceneView.center
        
        guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneInfinite, alignment: .any)
        else {
            return
        }
        
        let hitTestResults = sceneView.session.raycast(query)
        
        if !hitTestResults.isEmpty {
            
            guard let hitResult = hitTestResults.first else {
                return
            }
            
            let sphere = SCNSphere(radius: 0.005)
            
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.red
            
            sphere.firstMaterial = material
            
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                             hitResult.worldTransform.columns.3.y,
                                             hitResult.worldTransform.columns.3.z)
            
            self.sceneView.scene.rootNode.addChildNode(sphereNode)
            
            self.spheres.append(sphereNode)
            
            if self.spheres.count == 2 {
                
                // calculate distance
                let firstPoint = self.spheres.first!
                let secondPoint = self.spheres.last!
                
                let position = SCNVector3Make(secondPoint.position.x - firstPoint.position.x,
                                              secondPoint.position.y - firstPoint.position.y,
                                              secondPoint.position.z - firstPoint.position.z)
                
                let result = sqrt(position.x * position.x + position.y * position.y + position.z * position.z)
                
                print(result)
                
                // remove spheres
                
            }
            
        }
        
    }
    
    private func addCrossSign() {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 33))
        label.text = "+"
        label.textAlignment = .center
        label.center = self.sceneView.center
        
        self.sceneView.addSubview(label)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}
