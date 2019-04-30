//
//  CircleProgressView.swift
//
//  Code generated using QuartzCode 1.66.3 on 2019/4/30.
//  www.quartzcodeapp.com
//

import UIKit

@IBDesignable
class CircleProgressView: UIView, CAAnimationDelegate {
	
	var layers = [String: CALayer]()
	var completionBlocks = [CAAnimation: (Bool) -> Void]()
	var updateLayerValueForCompletedAnimation : Bool = false
	
	
	
	//MARK: - Life Cycle
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupProperties()
		setupLayers()
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		setupProperties()
		setupLayers()
	}
	
	override var frame: CGRect{
		didSet{
			setupLayerFrames()
		}
	}
	
	override var bounds: CGRect{
		didSet{
			setupLayerFrames()
		}
	}
	
	func setupProperties(){
		
	}
	
	func setupLayers(){
		self.backgroundColor = UIColor(red:1.00, green: 1.00, blue:1.00, alpha:1.0)
		
		let progressCircle = CAShapeLayer()
		self.layer.addSublayer(progressCircle)
		layers["progressCircle"] = progressCircle
		
		resetLayerProperties(forLayerIdentifiers: nil)
		setupLayerFrames()
	}
	
	func resetLayerProperties(forLayerIdentifiers layerIds: [String]!){
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		
		if layerIds == nil || layerIds.contains("progressCircle"){
			let progressCircle = layers["progressCircle"] as! CAShapeLayer
			progressCircle.lineCap     = .round
			progressCircle.fillColor   = nil
			progressCircle.strokeColor = UIColor(red:1.00, green: 0.00, blue:0.26, alpha:1.0).cgColor
			progressCircle.lineWidth   = 4
		}
		
		CATransaction.commit()
	}
	
	func setupLayerFrames(){
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		
		if let progressCircle = layers["progressCircle"] as? CAShapeLayer{
			progressCircle.frame = CGRect(x: 0.01515 * progressCircle.superlayer!.bounds.width, y: 0.01515 * progressCircle.superlayer!.bounds.height, width: 0.9697 * progressCircle.superlayer!.bounds.width, height: 0.9697 * progressCircle.superlayer!.bounds.height)
			progressCircle.path  = progressCirclePath(bounds: layers["progressCircle"]!.bounds).cgPath
		}
		
		CATransaction.commit()
	}
	
	//MARK: - Animation Setup
	
	func addProgressAnimation(totalDuration: CFTimeInterval = 1, completionBlock: ((_ finished: Bool) -> Void)? = nil){
		if completionBlock != nil{
			let completionAnim = CABasicAnimation(keyPath:"completionAnim")
			completionAnim.duration = totalDuration
			completionAnim.delegate = self
			completionAnim.setValue("progress", forKey:"animId")
			completionAnim.setValue(false, forKey:"needEndAnim")
			layer.add(completionAnim, forKey:"progress")
			if let anim = layer.animation(forKey: "progress"){
				completionBlocks[anim] = completionBlock
			}
		}
		
		let fillMode : CAMediaTimingFillMode = .forwards
		
		////ProgressCircle animation
		let progressCircleStrokeStartAnim      = CAKeyframeAnimation(keyPath:"strokeStart")
		progressCircleStrokeStartAnim.values   = [1, 0]
		progressCircleStrokeStartAnim.keyTimes = [0, 1]
		progressCircleStrokeStartAnim.duration = totalDuration
		
		let progressCircleProgressAnim : CAAnimationGroup = QCMethod.group(animations: [progressCircleStrokeStartAnim], fillMode:fillMode)
		layers["progressCircle"]?.add(progressCircleProgressAnim, forKey:"progressCircleProgressAnim")
	}
	
	//MARK: - Animation Cleanup
	
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool){
		if let completionBlock = completionBlocks[anim]{
			completionBlocks.removeValue(forKey: anim)
			if (flag && updateLayerValueForCompletedAnimation) || anim.value(forKey: "needEndAnim") as! Bool{
				updateLayerValues(forAnimationId: anim.value(forKey: "animId") as! String)
				removeAnimations(forAnimationId: anim.value(forKey: "animId") as! String)
			}
			completionBlock(flag)
		}
	}
	
	func updateLayerValues(forAnimationId identifier: String){
		if identifier == "progress"{
			QCMethod.updateValueFromPresentationLayer(forAnimation: layers["progressCircle"]!.animation(forKey: "progressCircleProgressAnim"), theLayer:layers["progressCircle"]!)
		}
	}
	
	func removeAnimations(forAnimationId identifier: String){
		if identifier == "progress"{
			layers["progressCircle"]?.removeAnimation(forKey: "progressCircleProgressAnim")
		}
	}
	
	func removeAllAnimations(){
		for layer in layers.values{
			layer.removeAllAnimations()
		}
	}
	
	//MARK: - Bezier Path
	
	func progressCirclePath(bounds: CGRect) -> UIBezierPath{
		let progressCirclePath = UIBezierPath()
		let minX = CGFloat(bounds.minX), minY = bounds.minY, w = bounds.width, h = bounds.height;
		
		progressCirclePath.move(to: CGPoint(x:minX + 0.5 * w, y: minY))
		progressCirclePath.addCurve(to: CGPoint(x:minX, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.22386 * w, y: minY), controlPoint2:CGPoint(x:minX, y: minY + 0.22386 * h))
		progressCirclePath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY + h), controlPoint1:CGPoint(x:minX, y: minY + 0.77614 * h), controlPoint2:CGPoint(x:minX + 0.22386 * w, y: minY + h))
		progressCirclePath.addCurve(to: CGPoint(x:minX + w, y: minY + 0.5 * h), controlPoint1:CGPoint(x:minX + 0.77614 * w, y: minY + h), controlPoint2:CGPoint(x:minX + w, y: minY + 0.77614 * h))
		progressCirclePath.addCurve(to: CGPoint(x:minX + 0.5 * w, y: minY), controlPoint1:CGPoint(x:minX + w, y: minY + 0.22386 * h), controlPoint2:CGPoint(x:minX + 0.77614 * w, y: minY))
		
		return progressCirclePath
	}
	
	
}
