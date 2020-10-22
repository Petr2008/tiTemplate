//
//  AnimateController.swift
//  tiTemplate
//
//  Created by Petr Gusakov on 19.10.2020.
//

import UIKit
import AVFoundation
import Photos

class AnimateController: UIViewController {

    @IBOutlet var animateView: UIView!
    
    var inputMObjectList: [UIImage]!
    var imageList: [CGImage]!

    var layerList = [CALayer]()
    var animeList = [[String]]()
    
    var frameContentList = [Int: [MInfo]]()
    
    var widthScreen: CGFloat!
    
    var videoUrl: URL!
    var audioUrl: URL!
    var sizeVideo = CGSize(width: 600, height: 600)
    var videoFPS: Int32 = 30

    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        videoUrl = documentsDirectory.appendingPathComponent("tmp.mp4")
        audioUrl = Bundle.main.url(forResource: "bensound-summer", withExtension: "mp3")

        
        let size = CGSize(width: widthScreen, height: widthScreen / 3 * 4)
        
        for image in inputMObjectList {
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
    
    @IBAction func makeMovienAction(_ sender: Any) {
        frameContentList = [Int: [MInfo]]()
        let fps = self.videoFPS
        let width = CGFloat(1080)
        let widthStr = String(format: "%.0f", width)
        
        self.imageList = Array()
//        for index in 0..<inputMObjectList.count {
//
//        }
        
        var image = (inputMObjectList.last?.cgImage)!
        //let index = 0
        
        let animeStrArr = [//"0;0.0;0.0;0.0;0.0;0.0;0.0", // поставили
                           "0;0.0;0.0;0.0;0.0;0.0;1.0", // показываем 1 сек
                           //"0;0.0;0.0;w;0.0;1.0;0.0",   // убираем вправо за пределы экрана
                           "0;w;0.0;w;0.0;1.0;1.0",   // показываем 1 сек ( не виден )
                           "0;w;0.0;w / 2;0.0;2.0;0.5",   // двигаем на середину
                           "0;w / 2;0.0;w / 2;0.0;2.5;0.5",   // показываем 0,5 сек
                           "0;w / 2;0.0;w - w / 10.0;0.0;3.0;0.5",   // двигаем вправо до 1/10 экрана
                           "0;w - w / 10.0;0.0;w - w / 10.0;0.0;3.5;0.5",   // показываем 0,5 сек
                           "0;w - w / 10.0;0.0;0.0;0.0;4.0;1.0",   // двигаем влево до начала экрана
                          ]
        
        // установки размера кадра 1080 х 1920 пикселей
        let scale = CGFloat(image.width) / width
        let height = CGFloat(image.height) / scale
        self.sizeVideo = CGSize(width: width, height: height)
        
        guard let colorSpace = image.colorSpace else { return  }
        guard let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: image.bitsPerComponent, bytesPerRow: image.bytesPerRow, space: colorSpace, bitmapInfo: image.alphaInfo.rawValue) else { return }

        // draw image to context (resizing it)
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        // extract resulting image from context
        image = context.makeImage()!
        imageList.append(image)

        // декодируем
        let heightStr = String(format: "%.0f", height)
        
        for string in animeStrArr {
            var context = string.replacingOccurrences(of: "w", with: widthStr)
            context = context.replacingOccurrences(of: "h", with: heightStr)
            let valueList = context.components(separatedBy: ";")

            // from
            let fromX = NSExpression(format: valueList[1]).expressionValue(with: nil, context: nil) as! CGFloat
            let fromY = NSExpression(format: valueList[2]).expressionValue(with: nil, context: nil) as! CGFloat
            let toX = NSExpression(format: valueList[3]).expressionValue(with: nil, context: nil) as! CGFloat
            let toY = NSExpression(format: valueList[4]).expressionValue(with: nil, context: nil) as! CGFloat
            let startCadr = Int(Float(valueList[5])! * Float(fps))
            let allCadr = Int(Float(valueList[6])! * Float(fps))
            
            if allCadr == 0 { continue }
            
            // определяем crop rect для каждого кадра
            // смещение
            let deltaX = (toX - fromX) / CGFloat(allCadr)
            let deltaY = (toY - fromY) / CGFloat(allCadr)

            for index in 0...allCadr {
                let currentCadr = startCadr + index
                let origin = CGPoint(x: fromX + deltaX * CGFloat(index), y: fromY + deltaY * CGFloat(index))
                let size = CGSize(width: CGFloat(width) - origin.x, height: CGFloat(height) - origin.y)
                //let size = CGSize(width: CGFloat(width), height: CGFloat(height))

                let rect = CGRect(origin: origin, size: size)
                print(currentCadr, rect)
                let mInfo = MInfo(rect: rect, opacity: 1.0)
                if var mInfoList = frameContentList[currentCadr] {
                    mInfoList.append(mInfo)
                    frameContentList[currentCadr] = mInfoList
                } else {
                    frameContentList[currentCadr] = [mInfo]
                }
            }
        }
        
        // собственно видео
        let queue = DispatchQueue.init(label: "queue_t")
        createMovie(queue: queue) { (succses) in
            self.mergeVideoWithAudio(videoUrl: self.videoUrl, audioUrl: self.audioUrl!, success: { (URL) in
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL)
                }) { saved, error in
                    print("Video was successfully saved", Date())
//                    DispatchQueue.main.async {
//                        let message = Message(view: self.view, sizeView: sizeView, message: NSLocalizedString("Video successfully saved", comment: ""))
//                        message.removeLong()
//                    }

                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                }
            }) { (error) in
                print(error as Any)
            }
        }

        
    }
    
    func calcFrames() {
    }
    
    func anim0() {
//        let width = self.view.bounds.width
        let layer = self.layerList.first!
        
        let animeStrArr = [//"0;w;0.0;w;0.0;0.0;0.0", // поставили с права ( не виден )
                           "0;w;0.0;w;0.0;0.0;1.0", // показываем 1 сек ( не виден )
                           "0;w;0.0;w;0.0;1.0;0.0",   // двигаем влево до начала экрана без анимации
                          ]

        var animations = [CABasicAnimation]()

        for animeStr in animeStrArr {
            let animation = animationFromStrng(string: animeStr)
            animations.append(animation)
        }
        
        /*
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
        let positionAnimationFaza2 = CABasicAnimation(keyPath: "position")  // двигаем влево до начала экрана без анимации
        positionAnimationFaza2.fromValue = CGPoint(x: width, y: 0)
        positionAnimationFaza2.toValue = CGPoint.zero
        positionAnimationFaza2.beginTime = 1.0
        positionAnimationFaza2.duration = 0.0
        animations.append(positionAnimationFaza2)
        // 1.0
        */
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.0
        animationGroup.animations = animations
        
        layer.add(animationGroup, forKey: nil)
        
        layer.position = CGPoint.zero
        self.animateView.layer.addSublayer(layer)

    }

    func anim1() {
        //let width = self.view.bounds.width
        let layer = self.layerList.last!
        
        //let height = self.view.bounds.height
        //"0;0.0;0.0;0.0;0.0;0.0;0.0"
        let animeStrArr = [//"0;0.0;0.0;0.0;0.0;0.0;0.0", // поставили
                           "0;0.0;0.0;0.0;0.0;0.0;1.0", // показываем 1 сек
                           //"0;0.0;0.0;w;0.0;1.0;0.0",   // убираем вправо за пределы экрана
                           "0;w;0.0;w;0.0;1.0;1.0",   // показываем 1 сек ( не виден )
                           "0;w;0.0;w / 2;0.0;2.0;0.5",   // двигаем на середину
                           "0;w / 2;0.0;w / 2;0.0;2.5;0.5",   // показываем 0,5 сек
                           "0;w / 2;0.0;w - w / 10.0;0.0;3.0;0.5",   // двигаем вправо до 1/10 экрана
                           "0;w - w / 10.0;0.0;w - w / 10.0;0.0;3.5;0.5",   // показываем 0,5 сек
                           "0;w - w / 10.0;0.0;0.0;0.0;4.0;1.0",   // двигаем влево до начала экрана
                          ]
        
        var animations = [CABasicAnimation]()
        
        for animeStr in animeStrArr {
            let animation = animationFromStrng(string: animeStr)
            animations.append(animation)
        }
        /*
        // стоим запрос1 нет анимации время 0,4
        //запрос0 позиция(x: view.width, y: 0) - нет анимации не виден
        let positionAnimationFaza0 = CABasicAnimation(keyPath: "position")   // поставили
        positionAnimationFaza0.fromValue = CGPoint.zero
        positionAnimationFaza0.toValue = CGPoint.zero
        positionAnimationFaza0.beginTime = 0.0
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

        */
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 5.0
        animationGroup.animations = animations
        
        layer.add(animationGroup, forKey: nil)
        
        layer.position = CGPoint.zero
        self.animateView.layer.addSublayer(layer)

    }

    func animationFromStrng(string: String) -> CABasicAnimation {
        var animation = CABasicAnimation()
        // тип анимации;начальная позиция;конечная позиция;время анимации; стар анимации
        // w - ширина вьюхи; h - высота вьюхи
        let widthStr = String(format: "%.0f", self.view.bounds.width)
        let heightStr = String(format: "%.0f", self.view.bounds.height)

        var context = string.replacingOccurrences(of: "w", with: widthStr)
        context = context.replacingOccurrences(of: "h", with: heightStr)
        let valueList = context.components(separatedBy: ";")
        print(valueList)

        // тип анимации пока только 0 - позиция
        animation = CABasicAnimation(keyPath: "position")
        // from
        let fromX = NSExpression(format: valueList[1]).expressionValue(with: nil, context: nil) as! CGFloat
        let fromY = NSExpression(format: valueList[2]).expressionValue(with: nil, context: nil) as! CGFloat
        let toX = NSExpression(format: valueList[3]).expressionValue(with: nil, context: nil) as! CGFloat
        let toY = NSExpression(format: valueList[4]).expressionValue(with: nil, context: nil) as! CGFloat

        animation.fromValue = CGPoint(x: fromX, y: fromY)
        animation.toValue = CGPoint(x: toX, y: toY)
        animation.beginTime = Double(valueList[5])!
        animation.duration = Double(valueList[6])!

        return animation
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
    
    // MARK: - createMovie
    func createMovie(queue: DispatchQueue, _ completionBlock: ((Bool)->Void)?) { print("createMovie")
        FileManager.default.removeItemIfExist(at: videoUrl)

        let allFrames = frameContentList.count

        guard
            let writer = try? AVAssetWriter.init(url: videoUrl, fileType: .mp4)
        else {
            assert(false)
            completionBlock?(false)
            return
        }
        let writerSettings: [String:Any] = [
            AVVideoCodecKey : AVVideoCodecType.h264,
            AVVideoWidthKey : sizeVideo.width,
            AVVideoHeightKey: sizeVideo.height,
        ]
        let writerInput = AVAssetWriterInput.init(mediaType: .video, outputSettings: writerSettings)
        writer.canAdd(writerInput)
        
        let sourceBufferAttributes = [
        (kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32ARGB),
        (kCVPixelBufferWidthKey as String): Float(sizeVideo.width),
        (kCVPixelBufferHeightKey as String): Float(sizeVideo.height)] as [String : Any]
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor.init(assetWriterInput: writerInput, sourcePixelBufferAttributes: sourceBufferAttributes)
        
        let group = DispatchGroup.init()
        group.enter()
        
        writer.add(writerInput)
        writer.startWriting()
        writer.startSession(atSourceTime: CMTime.zero)

        writerInput.requestMediaDataWhenReady(on: queue) {
//            var imageOut: UIImage?
//            var imageScene: UIImage?
//            var frame: Frame!

            // кадры
            for frameIndex in 0..<allFrames {
//                imageOut = nil

                let timeFrame = CMTime(seconds: Double(CGFloat(frameIndex) / CGFloat(self.videoFPS)), preferredTimescale: 600)
                    if self.appendPixelBuffer(frame: frameIndex, presentationTime: timeFrame, pixelBufferAdaptor: pixelBufferAdaptor) {
                            //print(frameIndex)
                        DispatchQueue.main.async {
                            let info = String(format: "%i %@ %i", frameIndex + 1, "out of", allFrames)
                            self.title = info
                        }
                    } else {
                        print("VideoWriter: warning, could not append imageBuffer ", frameIndex)
                    }
                    
                // задержка
                while !writerInput.isReadyForMoreMediaData { //print("isReadyForMoreMediaData")
                    Thread.sleep(forTimeInterval: 0.1)
                }
            }

            writerInput.markAsFinished()
            group.leave()
            // end work
            group.notify(queue: queue) {
                writer.finishWriting {
                    if writer.status != .completed {
                                print("VideoWriter reverseVideo: error - \(String(describing: writer.error))")
                                completionBlock?(false)
                    } else {
                        completionBlock?(true)
                    }
                }
            }
        }
    }
    
    func appendPixelBuffer(frame: Int, presentationTime: CMTime, pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor) -> Bool {
        var appendSucceeded = false
        autoreleasepool {
            if  let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool {
                let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity:1)
                let status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, pixelBufferPointer)
                
                if let pixelBuffer = pixelBufferPointer.pointee , status == 0 {
                    //fillPixelBufferFromImage(image, pixelBuffer: pixelBuffer)
                    //fillPixelBufferFromRect(rect: rect, opacity: opacity, pixelBuffer: pixelBuffer)
                    fillPixelBuffer(frame: frame, pixelBuffer: pixelBuffer)
                    appendSucceeded = pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)

                    pixelBufferPointer.deinitialize(count: 1)
                } else {
                    NSLog("Error: Failed to allocate pixel buffer from pool")
                }
                pixelBufferPointer.deallocate()
            }
        }
        return appendSucceeded
    }
    
    func fillPixelBuffer(frame: Int, pixelBuffer: CVPixelBuffer) {
        print(frame)
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: pixelData,
            width: Int(sizeVideo.width),
            height: Int(sizeVideo.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )
        // пробег по объектам
        var imageOut: UIImage?
        // в зависимости от типа м объекта
        // выбираем тип обработки. пока фото
        let mInfoList = self.frameContentList[frame]!

        //for index in 0..<mInfoList.count {
        let index = 1
            
            let mInfo = mInfoList[0]  // !!!!!!!!!!! поправить на index
            let rect = mInfo.rect
        let recrCrop = CGRect(origin: .zero, size: rect.size)
            let opacity = mInfo.opacity
            var imageScene: UIImage!

        if frame == 65 {
            print("stop")
        }

             // !!!!!!!!!!! поправить на index
        let fillRect = CGRect(origin: .zero, size: self.sizeVideo)
        if let imageRef = self.imageList[0].cropping(to: recrCrop) {
            imageScene = UIImage(cgImage: imageRef)
        } else {
            let fillRect = CGRect(origin: .zero, size: self.sizeVideo)
            UIGraphicsBeginImageContextWithOptions(fillRect.size, false, 0)
            UIColor.green.setFill()
            UIRectFill(fillRect)
            imageScene = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
//        imageScene = UIImage(cgImage: imageRef!)
        
            if opacity != 1  {
                UIGraphicsBeginImageContextWithOptions(self.sizeVideo, true, 1.0)
                if imageOut != nil {
                    imageOut!.draw(at: .zero)
                }
                imageScene.draw(at: .zero, blendMode: .normal, alpha: opacity)
                imageOut = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
            } else {
                UIGraphicsBeginImageContextWithOptions(self.sizeVideo, true, 1.0)
                UIColor.green.setFill()
                UIRectFill(fillRect)
                imageScene.draw(at: rect.origin)
                imageOut = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
//                imageOut = imageScene
            }

        //}
        
//
//        for iFrame in vFrameList {
//            var imageScene: UIImage!
//            if let rect = iFrame.framePosition(frame: frame) {
//                imageScene = iFrame.image.crop(rect: rect)
//                let opacity = iFrame.frameOpacity(frame: frame)
//                if opacity != 1  {
//                    UIGraphicsBeginImageContextWithOptions(self.sizeVideo, true, 1.0)
//                    if imageOut != nil {
//                        imageOut!.draw(at: .zero)
//                    }
//                    imageScene.draw(at: .zero, blendMode: .normal, alpha: opacity)
//                    imageOut = UIGraphicsGetImageFromCurrentImageContext()!
//                    UIGraphicsEndImageContext()
//                } else {
//                    imageOut = imageScene
//                }
//            }
//        }
        
        context?.draw(imageOut!.cgImage!, in: CGRect(x: 0, y: 0, width: sizeVideo.width, height: sizeVideo.height))

        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    }
    
    // MARK: - merge Video and Audio
    func mergeVideoWithAudio(videoUrl: URL, audioUrl: URL, success: @escaping ((URL) -> Void), failure: @escaping ((Error?) -> Void)) {
        let mixComposition: AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack: [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack: [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()

        let aVideoAsset: AVAsset = AVAsset(url: videoUrl)
        let aAudioAsset: AVAsset = AVAsset(url: audioUrl)

        if let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid), let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
            mutableCompositionVideoTrack.append(videoTrack)
            mutableCompositionAudioTrack.append(audioTrack)
            //mutableCompositionAudioTrack.append(addAudioTrack!)


            if let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: .video).first, let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: .audio).first {
                do {
                    try mutableCompositionVideoTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: CMTime.zero)

                    try mutableCompositionAudioTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: CMTime.zero)
                    
                    videoTrack.preferredTransform = aVideoAssetTrack.preferredTransform

                } catch{
                    print(error)
                }
                
                totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration)
            }
        }

        let mutableVideoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mutableVideoComposition.renderSize = CGSize(width: 600, height: 600)

        if let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let outputURL = URL(fileURLWithPath: documentsPath).appendingPathComponent("\("videoPiks").m4v")

            do {
                if FileManager.default.fileExists(atPath: outputURL.path) {
                    try FileManager.default.removeItem(at: outputURL)
                }
            } catch { }

            if let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
                exportSession.outputURL = outputURL
                exportSession.outputFileType = AVFileType.mp4
                exportSession.shouldOptimizeForNetworkUse = true

                /// try to export the file and handle the status cases
                exportSession.exportAsynchronously(completionHandler: {
                    switch exportSession.status {
                    case .failed:
                        if let _error = exportSession.error {
                            failure(_error)
                        }

                    case .cancelled:
                        if let _error = exportSession.error {
                            failure(_error)
                        }

                    default:
                        print("finished")
                        success(outputURL)
                    }
                })
            } else {
                failure(nil)
            }
        }
    }

}

struct MFrame {
    var from: CGPoint
    var to: CGPoint
    var startCadr: Int
    var endCadr: Int
}

struct MInfo {
    var rect: CGRect
    var opacity: CGFloat
}

enum mType {
    case text
    case plane
    case photo
    case video
}
