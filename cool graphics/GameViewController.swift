//
//  GameViewController.swift
//  cool graphics
//
//  Created by Sima Nerush on 12/7/22.
//

import UIKit
import MetalKit

class GameViewController: UIViewController {
  // a reference to the GPU
  var device: MTLDevice!
  
  // grahics layer
  var metalLayer: CAMetalLayer!
  
  // vertices of the triangle
  let vertexData: [Float] = [
    0.0,  1.0, 0.0,
    -1.0, -1.0, 0.0,
    1.0, -1.0, 0.0
  ]
  
  var vertexBuffer: MTLBuffer!
  
  // render pipeline reference
  var pipelineState: MTLRenderPipelineState!
  
  var commandQueue: MTLCommandQueue!
  
  var timer: CADisplayLink!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    device = MTLCreateSystemDefaultDevice()
    
    // setting up the metal layer
    metalLayer = CAMetalLayer()
    metalLayer.device = device
    metalLayer.pixelFormat = .bgra8Unorm
    metalLayer.framebufferOnly = true
    metalLayer.frame = view.layer.frame
    view.layer.addSublayer(metalLayer)
    
    
    let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
    // make buffer from the CPU to GPU2
    vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
    
    // get precompiled shaders
    let defaultLibrary = device.makeDefaultLibrary()!
    let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
    let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
    
    // configure the pipeline
    let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
    pipelineStateDescriptor.vertexFunction = vertexProgram
    pipelineStateDescriptor.fragmentFunction = fragmentProgram
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    
    // make the pipeline
    pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    
    // make the command queue
    commandQueue = device.makeCommandQueue()
    
    timer = CADisplayLink(target: self, selector: #selector(gameloop))
    timer.add(to: RunLoop.main, forMode: .default)
  }
  
  func render() {
    guard let drawable = metalLayer?.nextDrawable() else { return }
    let renderPassDescriptor = MTLRenderPassDescriptor()
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture
    renderPassDescriptor.colorAttachments[0].loadAction = .clear
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
      red: 0.0,
      green: 104.0/255.0,
      blue: 55.0/255.0,
      alpha: 1.0)
    
    let commandBuffer = commandQueue.makeCommandBuffer()!
    let renderEncoder = commandBuffer
      .makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    renderEncoder
      .drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
    renderEncoder.endEncoding()
    
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
  
  @objc func gameloop() {
    autoreleasepool {
      self.render()
    }
  }
}
