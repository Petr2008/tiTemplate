//
//  AnimateController.swift
//  tiTemplate
//
//  Created by Petr Gusakov on 19.10.2020.
//

import UIKit

class AnimateController: UIViewController {

    @IBOutlet var animateView: UIView!
    
    var imageList: [UIImage]!
    var layerList = [CALayer]()
    
    var widthScreen: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let size = CGSize(width: widthScreen, height: widthScreen / 3 * 4)
        
        for image in imageList {
            let layer = CALayer()
            layer.anchorPoint = .zero
            layer.position = .zero
            layer.bounds = CGRect(origin: .zero, size: size)
            layer.contents = image.cgImage
            
            layerList.append(layer)
        }
    }
    
    
    @IBAction func animationAction(_ sender: Any) {
        //animMove(layer: layerList.last!)
        anim0()
        anim1()
    }
    
    func anim0() {
        let width = self.view.bounds.width
        let layer = self.layerList.first!
        
        //let height = self.view.bounds.height
        
        var animations = [CABasicAnimation]()

        let positionAnimationFaza0 = CABasicAnimation(keyPath: "position")   // поставили
        positionAnimationFaza0.fromValue = CGPoint(x: width, y: 0)
        positionAnimationFaza0.toValue = CGPoint(x: width, y: 0)
        positionAnimationFaza0.duration = 0.0
        animations.append(positionAnimationFaza0)
        // 0.0
        // 0.0
        let positionAnimationFaza1 = CABasicAnimation(keyPath: "position")  // показываем 1 сек ( не виден )
        positionAnimationFaza1.fromValue = CGPoint(x: width, y: 0)
        positionAnimationFaza1.toValue = CGPoint(x: width, y: 0)
        positionAnimationFaza1.beginTime = 0.0
        positionAnimationFaza1.duration = 1.0
        animations.append(positionAnimationFaza1)
        // 1.0
        let positionAnimationFaza2 = CABasicAnimation(keyPath: "position")  // показываем 1 сек
        positionAnimationFaza2.fromValue = CGPoint(x: width, y: 0)
        positionAnimationFaza2.toValue = CGPoint.zero
        positionAnimationFaza2.beginTime = 1.0
        positionAnimationFaza2.duration = 0.0
        animations.append(positionAnimationFaza2)
        // 1.0

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.0
        animationGroup.animations = animations
        
        layer.add(animationGroup, forKey: nil)
        
        layer.position = CGPoint.zero
        self.animateView.layer.addSublayer(layer)

    }

    func anim1() {
        let width = self.view.bounds.width
        let layer = self.layerList.last!
        
        //let height = self.view.bounds.height
        
        var animations = [CABasicAnimation]()
        // стоим запрос1 нет анимации время 0,4
        //запрос0 позиция(x: view.width, y: 0) - нет анимации не виден
        let positionAnimationFaza0 = CABasicAnimation(keyPath: "position")   // поставили
        positionAnimationFaza0.fromValue = CGPoint.zero
        positionAnimationFaza0.toValue = CGPoint.zero
        positionAnimationFaza0.duration = 0.0
        animations.append(positionAnimationFaza0)
        // 0.0
        let positionAnimationFaza1 = CABasicAnimation(keyPath: "position")  // показываем 1 сек
        positionAnimationFaza1.fromValue = CGPoint.zero
        positionAnimationFaza1.toValue = CGPoint.zero
        positionAnimationFaza1.beginTime = 0.0
        positionAnimationFaza1.duration = 1.0
        animations.append(positionAnimationFaza1)
        // 1.0
        let positionAnimationFaza2 = CABasicAnimation(keyPath: "position")  // убираем вправо за пределы экрана
        positionAnimationFaza2.fromValue = CGPoint.zero
        positionAnimationFaza2.toValue = CGPoint(x: width, y: 0)
        positionAnimationFaza2.beginTime = 1.0
        positionAnimationFaza2.duration = 0.0
        animations.append(positionAnimationFaza2)
        // 1.0
        let positionAnimationFaza3 = CABasicAnimation(keyPath: "position")  // показываем 1 сек ( не виден )
        positionAnimationFaza3.fromValue = CGPoint(x: width, y: 0)
        positionAnimationFaza3.toValue = CGPoint(x: width, y: 0)
        positionAnimationFaza3.beginTime = 1.0
        positionAnimationFaza3.duration = 1.0
        animations.append(positionAnimationFaza3)
        // 2.0
        let positionAnimationFaza4 = CABasicAnimation(keyPath: "position")  // двигаем на середину
        positionAnimationFaza4.fromValue = CGPoint(x: width, y: 0)
        positionAnimationFaza4.toValue = CGPoint(x: width / 2, y: 0)
        positionAnimationFaza4.beginTime = 2.0
        positionAnimationFaza4.duration = 0.5
        animations.append(positionAnimationFaza4)
        // 2.5
        let positionAnimationFaza5 = CABasicAnimation(keyPath: "position")  // показываем 0,5 сек
        positionAnimationFaza5.fromValue = CGPoint(x: width / 2, y: 0)
        positionAnimationFaza5.toValue = CGPoint(x: width / 2, y: 0)
        positionAnimationFaza5.beginTime = 2.5
        positionAnimationFaza5.duration = 0.5
        animations.append(positionAnimationFaza5)
        // 3.0
        let positionAnimationFaza6 = CABasicAnimation(keyPath: "position")  // двигаем вправо до 1/10 экрана
        positionAnimationFaza6.fromValue = CGPoint(x: width / 2, y: 0)
        positionAnimationFaza6.toValue = CGPoint(x: width - width / 10.0, y: 0)
        positionAnimationFaza6.beginTime = 3.0
        positionAnimationFaza6.duration = 0.5
        animations.append(positionAnimationFaza6)
        // 3.5
        let positionAnimationFaza7 = CABasicAnimation(keyPath: "position")  // показываем 0,5 сек
        positionAnimationFaza7.fromValue = CGPoint(x: width - width / 10.0, y: 0)
        positionAnimationFaza7.toValue = CGPoint(x: width - width / 10.0, y: 0)
        positionAnimationFaza7.beginTime = 3.5
        positionAnimationFaza7.duration = 0.5
        animations.append(positionAnimationFaza7)
        // 4.0
        let positionAnimationFaza8 = CABasicAnimation(keyPath: "position")  // двигаем влево до начала экрана
        positionAnimationFaza8.fromValue = CGPoint(x: width - width / 10.0, y: 0)
        positionAnimationFaza8.toValue = CGPoint.zero
        positionAnimationFaza8.beginTime = 4.0
        positionAnimationFaza8.duration = 1.0
        animations.append(positionAnimationFaza8)
        // 5.0
//        let positionAnimationFaza1 = CABasicAnimation(keyPath: "position")
//        positionAnimationFaza1.fromValue = CGPoint.zero
//        positionAnimationFaza1.toValue = CGPoint(x: width / 2.0, y: 0)
//        positionAnimationFaza1.beginTime = 1.0
//        positionAnimationFaza1.duration = 0.5
//        animations.append(positionAnimationFaza1)
//
//        let positionAnimationFaza2 = CABasicAnimation(keyPath: "position")
//        positionAnimationFaza2.fromValue = CGPoint(x: width / 2.0, y: 0)
//        positionAnimationFaza2.toValue = CGPoint(x: width / 2.0, y: 0)
//        positionAnimationFaza2.beginTime = 1.5
//        positionAnimationFaza2.duration = 0.5
//        animations.append(positionAnimationFaza2)
//
//        let positionAnimationFaza3 = CABasicAnimation(keyPath: "position")
//        positionAnimationFaza3.fromValue = CGPoint(x: width / 2.0, y: 0)
//        positionAnimationFaza3.toValue = CGPoint(x: width - width / 10.0, y: 0)
//        positionAnimationFaza3.beginTime = 2.0
//        positionAnimationFaza3.duration = 0.5
//        animations.append(positionAnimationFaza3)
//
//        let positionAnimationFaza4 = CABasicAnimation(keyPath: "position")
//        positionAnimationFaza4.fromValue = CGPoint(x: width - width / 10.0, y: 0)
//        positionAnimationFaza4.toValue = CGPoint(x: width - width / 10.0, y: 0)
//        positionAnimationFaza4.beginTime = 2.5
//        positionAnimationFaza4.duration = 0.5
//        animations.append(positionAnimationFaza4)
//
//        let positionAnimationFaza5 = CABasicAnimation(keyPath: "position")
//        positionAnimationFaza5.fromValue = CGPoint(x: width - width / 10.0, y: 0)
//        positionAnimationFaza5.toValue = CGPoint.zero
//        positionAnimationFaza5.beginTime = 3.0
//        positionAnimationFaza5.duration = 1.0
//        animations.append(positionAnimationFaza5)

        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 5.0
        animationGroup.animations = animations
        
        layer.add(animationGroup, forKey: nil)
        
        layer.position = CGPoint.zero
        self.animateView.layer.addSublayer(layer)

    }

    
    func animMove(layer: CALayer) {
        
        let width = self.view.bounds.width
        let height = self.view.bounds.height

        
        var animations = [CABasicAnimation]()
        // стоим запрос1 нет анимации время 0,4
        //запрос0 позиция(x: view.width, y: 0) - нет анимации не виден
        let positionAnimationFaza0 = CABasicAnimation(keyPath: "position")
        positionAnimationFaza0.fromValue = CGPoint(x: width, y: 0)
        positionAnimationFaza0.toValue = CGPoint.zero
        positionAnimationFaza0.duration = 1.0
        animations.append(positionAnimationFaza0)
        
        let positionAnimationFaza1 = CABasicAnimation(keyPath: "position")
        positionAnimationFaza1.fromValue = CGPoint.zero
        positionAnimationFaza1.toValue = CGPoint(x: width / 2.0, y: 0)
        positionAnimationFaza1.beginTime = 1.0
        positionAnimationFaza1.duration = 0.5
        animations.append(positionAnimationFaza1)

        let positionAnimationFaza2 = CABasicAnimation(keyPath: "position")
        positionAnimationFaza2.fromValue = CGPoint(x: width / 2.0, y: 0)
        positionAnimationFaza2.toValue = CGPoint(x: width / 2.0, y: 0)
        positionAnimationFaza2.beginTime = 1.5
        positionAnimationFaza2.duration = 0.5
        animations.append(positionAnimationFaza2)

        let positionAnimationFaza3 = CABasicAnimation(keyPath: "position")
        positionAnimationFaza3.fromValue = CGPoint(x: width / 2.0, y: 0)
        positionAnimationFaza3.toValue = CGPoint(x: width - width / 10.0, y: 0)
        positionAnimationFaza3.beginTime = 2.0
        positionAnimationFaza3.duration = 0.5
        animations.append(positionAnimationFaza3)

        let positionAnimationFaza4 = CABasicAnimation(keyPath: "position")
        positionAnimationFaza4.fromValue = CGPoint(x: width - width / 10.0, y: 0)
        positionAnimationFaza4.toValue = CGPoint(x: width - width / 10.0, y: 0)
        positionAnimationFaza4.beginTime = 2.5
        positionAnimationFaza4.duration = 0.5
        animations.append(positionAnimationFaza4)

        let positionAnimationFaza5 = CABasicAnimation(keyPath: "position")
        positionAnimationFaza5.fromValue = CGPoint(x: width - width / 10.0, y: 0)
        positionAnimationFaza5.toValue = CGPoint.zero
        positionAnimationFaza5.beginTime = 3.0
        positionAnimationFaza5.duration = 1.0
        animations.append(positionAnimationFaza5)

        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 4.0
        animationGroup.animations = animations
        
        layer.add(animationGroup, forKey: nil)
        
        layer.position = CGPoint.zero
        self.animateView.layer.addSublayer(layer)
        
        
        //        let animationPos = CABasicAnimation(keyPath: "frame");
        //        animationPos.fromValue = plane.posStart
        //        animationPos.toValue = plane.posEnd
        //        animationPos.duration = CFTimeInterval(plane.timeEnd! - plane.timeStart)
        //        animationPos.autoreverses = false //true - возвращает в исходное значение либо плавно, либо нет
        //        plane.add(animationPos, forKey: "animatePosition");

        //        let theAnimation = CABasicAnimation(keyPath: "frame");
        //        theAnimation.fromValue = plane.posStart
        //        theAnimation.toValue = plane.posEnd!
        //        theAnimation.duration = 3.0;
        //        //theAnimation.autoreverses = false //true - возвращает в исходное значение либо плавно, либо нет
        //        theAnimation.repeatCount = 1
        //        plane.add(theAnimation, forKey: "animatePosition");
                
        
        

        //        let oldBounds = bounds
        //        var newBounds = oldBounds
        //        newBounds.size = frame.size

//                let boundsAnimation = CABasicAnimation(keyPath: "bounds")
//                boundsAnimation.fromValue = NSValue(nonretainedObject: plane.posStart)
//                boundsAnimation.toValue = NSValue(nonretainedObject: plane.posEnd)
//
//                let groupAnimation = CAAnimationGroup()
//                groupAnimation.animations = [positionAnimation, boundsAnimation]
//                groupAnimation.fillMode = .forwards
//                groupAnimation.duration = duration
//                groupAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//                plane.frame = plane.posEnd!
//
//                plane.add(groupAnimation, forKey: "frame")
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        self.animateView.layer.addSublayer(layerList.first!)
//    }
//    override func viewWillDisappear(_ animated: Bool) {
//        print(self.heightLayoutConstraint.constant)
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
