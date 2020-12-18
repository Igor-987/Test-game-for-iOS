//
//  GameViewController.swift
//  FG
//
//  Created by Игорь Ков on 16.12.2020.
//

//  import UIKit
//  import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
//    Аутлет - для вывода score на экран
    let scoreLabel = UILabel()
    
    let restartButton = UIButton()

    //    MARK: - Хранимые свойства
    var duration:TimeInterval = 5
    
//  действие при game over
    var hit = true
    
//  подсчет очков
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
    }
    }
    
    var scene: SCNScene!
    
    //    MARK: - My methods
    
    func addShip() {
        
//      получу самолет
        let ship = getShip()
        
//      задам координаты самолета
        let x = Int.random(in: -25 ... 25)
        let y = Int.random(in: -25 ... 25)
        let z = -100
        ship.position = SCNVector3(x,y,z)
        
//      чтобы самолет не летел боком, а летел на нас
        ship.look(at: SCNVector3(2 * x, 2 * y, 2 * z))
                
        
//      добавим анимацию полета (летит в точку 0,0,0 за 10 секунд)
        ship.runAction(.move(to: SCNVector3(), duration: duration)) {
            self.removeShip()
            self.newGame()
        }
//  completionHandler: { print(#line, #function) - действие при окончании анимации, мы заменили его на нашу функцию "удалить самолет". print(#line, #function - вставляем в код для отслеживания в консоли выполнения этого участка кода
        
//      самолет не сбит
        hit = false
        
//      добавлю самолет на сцену
        scene.rootNode.addChildNode(ship)
    }
    
//    размещение счета на экране
    func configureLayout() {
        let scnView = view as! SCNView
        
//        кнопка перезапуск
        let w1: CGFloat = 200
        let h1 = CGFloat(100)
        let x = scnView.frame.midX - w1 / 2
        let y = scnView.frame.midX + h1 * 1.6
        restartButton.backgroundColor = .green
        restartButton.frame = CGRect(x: x, y: y, width: w1, height: h1)
        restartButton.isHidden = true
        restartButton.layer.cornerRadius = 15
        restartButton.setTitle("New Game", for: .normal)
        restartButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        restartButton.titleLabel?.textColor = .black
        
        
        scnView.addSubview(restartButton)
        
//        отображение счета
        scoreLabel.font = UIFont.systemFont(ofSize: 30)
        scoreLabel.frame = CGRect(x: 0, y: 0, width: scnView.frame.width, height: 100)
        scoreLabel.textAlignment = .center
        scoreLabel.textColor = .white
        
        scnView.addSubview(scoreLabel)
        
        score = 0
        
        
//      добавляю действие для кнопки New Game
        restartButton.addTarget(self, action: #selector(restartButtonTap), for: .touchUpInside)
        
    }
    
    
    func getShip() -> SCNNode {
//        получаем сцену
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
//        получаем самолет
        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
//        возвращаем результат функции - корабль
        return ship
    }
    func newGame() {
//      добавляем самолет из функции addShip, но проверяем, сбит или не сбит самолет
        guard hit else {
            DispatchQueue.main.async {
                self.restartButton.isHidden = false
            }
            return
        }
        
        addShip()
//  увеличим сложность (повысим скорость самолета с каждым новым запуском)
        duration *= 0.85
    }
    func removeShip() {
        var ship: SCNNode?
        
        repeat {
            ship = scene.rootNode.childNode(withName: "ship", recursively: true)
            ship?.removeFromParentNode()
        } while ship != nil
//  ? стоит потому, что при вызове функции самолета может уже не быть на сцене, и тогда это выдаст ошибку
    }
    
    //    MARK: - Other methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
//        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        // animate the 3d object
//        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
//      удаляем самолет (он на сцене еще один)
        removeShip()
        
//      На начало
        newGame()
        
//      выводим счет на экран
        configureLayout()

        
    }
//  обработка нажатия на самолет
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        // check what nodes are tapped, в переменную р записываются координаты нажатия
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
//          самолет сбит
            hit = true
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.1
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                self.removeShip()
                self.newGame()
                self.score += 1
            }
            
            material.emission.contents = UIColor.green
            
            SCNTransaction.commit()
        }
    }
   
//    нажатие на кнопку New Game
    @objc func restartButtonTap() {
        duration = 5
        restartButton.isHidden = true
        hit = true
        score = 0
        
        newGame()
    }
    
    
    
//    MARK: - Other
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
