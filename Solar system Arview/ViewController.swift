import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        // Create the solar system
        createSolarSystem()
        
        sceneView.autoenablesDefaultLighting = true
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

    private func createSolarSystem() {
        // Sun
        let sun = createPlanet(radius: 0.2, texture: "art.scnassets/8k_sun.jpg", orbitRadius: 0)
        sceneView.scene.rootNode.addChildNode(sun)
        
        // Planets
        let planets = [
            ("mercury", 0.03, "art.scnassets/8k_mercury.jpg", 0.40),
            ("venus", 0.06, "art.scnassets/8k_venus_surface.jpg", 0.60),
            ("earth", 0.06, "art.scnassets/8k_earth_daymap.jpg", 0.80),
            ("mars", 0.04, "art.scnassets/8k_mars.jpg", 1.0),
            ("jupiter", 0.14, "art.scnassets/8k_jupiter.jpg", 1.60),
            ("saturn", 0.12, "art.scnassets/8k_saturn.jpg", 2.00),
            ("uranus", 0.1, "art.scnassets/2k_uranus.jpg", 2.40),
            ("neptune", 0.1, "art.scnassets/2k_neptune.jpg", 2.80)
        ]
        
        for (_, radius, texture, orbitRadius) in planets {
            let planet = createPlanet(radius: CGFloat(radius), texture: texture, orbitRadius: Float(orbitRadius))
            sceneView.scene.rootNode.addChildNode(planet)
            rotateNode(node: planet)
            orbitNode(node: planet, aroundNode: sun, orbitRadius: Float(orbitRadius), duration: Double(orbitRadius) * 10)
        }
        
        // Add the Moon orbiting Earth
        if let earth = sceneView.scene.rootNode.childNode(withName: "earth", recursively: true) {
            let moon = createPlanet(radius: 0.02, texture: "art.scnassets/8k_moon.jpg", orbitRadius: 0.1)
            earth.addChildNode(moon)
            rotateNode(node: moon)
            orbitNode(node: moon, aroundNode: earth, orbitRadius: 0.1, duration: 5)
        }
    }
    

    private func createPlanet(radius: CGFloat, texture: String, orbitRadius: Float) -> SCNNode {
        let sphere = SCNSphere(radius: radius)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: texture)
        sphere.materials = [material]
        
        let node = SCNNode()
        node.geometry = sphere
        node.position = SCNVector3(orbitRadius, 0, -1)
        node.name = texture.components(separatedBy: "/").last?.components(separatedBy: ".").first // Set the name of the node to the texture name without extension
        
        return node
    }
    
    private func rotateNode(node: SCNNode) {
        let rotation = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 10)
        let repeatRotation = SCNAction.repeatForever(rotation)
        node.runAction(repeatRotation)
    }
    
    private func orbitNode(node: SCNNode, aroundNode centralNode: SCNNode, orbitRadius: Float, duration: Double) {
        let orbit = SCNAction.customAction(duration: duration) { (node, elapsedTime) in
            let angle = Float(elapsedTime / CGFloat(duration) * 2 * .pi)
            let x = orbitRadius * cos(angle)
            let z = orbitRadius * sin(angle)
            node.position = SCNVector3(x, node.position.y, z - 1)
        }
        let repeatOrbit = SCNAction.repeatForever(orbit)
        node.runAction(repeatOrbit)
    }
}
