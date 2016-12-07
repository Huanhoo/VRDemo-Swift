//
//  VRGLKView.swift
//  VRDemo
//
//  Created by huhuan on 2016/11/30.
//  Copyright © 2016年 Huanhoo. All rights reserved.
//

import UIKit
import GLKit

protocol VRGLKViewDelegate {
    func dataSource() -> CVPixelBuffer?
}

class VRGLKView: GLKView, GLKViewDelegate {
    
    var vertexShader: GLuint = 0
    var fragmentShader: GLuint = 0
    var numIndices: Int = 0
    var vertexIndicesBufferID: GLuint = 0
    var vertexBufferID: GLuint = 0
    var vertexTexCoordID: GLuint = 0
    var vertexTexCoordAttributeIndex: GLuint = 0
    
    var uniform_model_view_projection_matrix: GLuint = 0
    var uniform_y: GLuint = 0
    var uniform_uv: GLuint = 0
    var uniform_color_conversion_martrix: GLuint = 0
    
    let sphereSliceNum = 200
    let sphereRadius = 1.0
    let sphereScale = 300
    
    var fingerRotationX: Float = 0
    var fingerRotationY: Float = 0
    
    var glkDelegate: VRGLKViewDelegate?
    
    var program: VRProgram?
    var texture: VKGLTexture?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.configureGLKView()
        self.configureTexture()
        self.configureProgram()
        self.configureBuffer()
        self.configureUniform()
        self.configureDisplayLink()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    internal func glkView(_ view: GLKView, drawIn rect: CGRect) {
        
        
        
        
    }
    
    override func draw(_ rect: CGRect) {
        
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT));
        var buffer: CVPixelBuffer? = glkDelegate!.dataSource()
        
        if buffer == nil {
            return
        }
        
        texture?.refreshTextureWithPixelBuffer(pixelBuffer: buffer)
        
        var matrix: GLKMatrix4 = GLKMatrix4Identity
        var success: Bool  = matrixWithSize(size:self.bounds.size, matrix:&matrix)
        if success {
            glViewport(0, 0, GLsizei(rect.width*2), GLsizei(rect.height*2))
            
            glUniformMatrix4fv(GLint(uniform_model_view_projection_matrix), 1, GLboolean(GL_FALSE), matrix.array)
            glDrawElements(GLenum(GL_TRIANGLES), GLsizei(numIndices), GLenum(GL_UNSIGNED_SHORT), nil);
        }
 
    }
    
    func configureGLKView() {
        
        self.drawableDepthFormat = GLKViewDrawableDepthFormat.format24
        self.contentScaleFactor = 2.0
        self.delegate = self
        self.context = EAGLContext.init(api: EAGLRenderingAPI.openGLES2)
        EAGLContext.setCurrent(self.context)
        glClearColor(0, 0, 0, 1)
        
    }

    func configureProgram() {
        
        self.program = VRProgram()
        self.program!.addAttribute(attributeName: "position")
        self.program!.addAttribute(attributeName: "texCoord")
        
        if !self.program!.link() {
            program = nil
            print("failure")
        }
        
        vertexTexCoordAttributeIndex = program!.attributeIndex(attributeName: "texCoord")
        
        uniform_model_view_projection_matrix = program!.uniformIndex(uniformName: "modelViewProjectionMatrix")
        uniform_y = program!.uniformIndex(uniformName: "SamplerY")
        uniform_uv = program!.uniformIndex(uniformName: "SamplerUV")
        uniform_color_conversion_martrix = program!.uniformIndex(uniformName: "colorConversionMatrix")
        program!.use()
        
    }
    
    func configureTexture() {
        texture = VKGLTexture.init(context: self.context)
    }
    
    func configureBuffer() {
        
        var vertices: UnsafeMutablePointer<Float>?
        var textCoord:UnsafeMutablePointer<Float>?
        var indices: UnsafeMutablePointer<Int16>?
        var numVertices: Int32? = 0
        
        
        numIndices = Int(GLuint(esGenSphere(Int32(sphereSliceNum), Float(sphereRadius), &vertices, &textCoord, &indices, &numVertices!)))
        
        // Indices
        var tempVertexIndicesBufferID: GLuint = 0
        glGenBuffers(1, &tempVertexIndicesBufferID)
        vertexIndicesBufferID = tempVertexIndicesBufferID
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vertexIndicesBufferID)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), numIndices*MemoryLayout<GLushort>.size, indices, GLenum(GL_STATIC_DRAW))
        
        // Vertex
        var tempVertexBufferID: GLuint = 0
        glGenBuffers(1, &tempVertexBufferID)
        vertexBufferID = tempVertexBufferID
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBufferID)
        glBufferData(GLenum(GL_ARRAY_BUFFER), Int(numVertices!)*3*MemoryLayout<GLfloat>.size, vertices, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size*3), nil)
        
        // Texture Coordinates
        var tempVertexTexCoordID: GLuint = 0
        glGenBuffers(1, &tempVertexTexCoordID)
        vertexTexCoordID = tempVertexTexCoordID
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexTexCoordID)
        glBufferData(GLenum(GL_ARRAY_BUFFER), Int(numVertices!)*2*MemoryLayout<GLfloat>.size, textCoord, GLenum(GL_DYNAMIC_DRAW))
        
        glEnableVertexAttribArray(vertexTexCoordAttributeIndex);
        glVertexAttribPointer(vertexTexCoordAttributeIndex, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size*2), nil);
        
    }
    
    func configureUniform() {
        
        //var conversion: UnsafePointer<GLfloat>!
        
        var array: [GLfloat] = [1.164, 1.164, 1.164, 0.0, -0.213, 2.112, 1.793, -0.533, 0.0]
        //var arrayPtr = UnsafeMutableBufferPointer<GLfloat>(start: &array, count: array.count)
        // baseAddress 是第一个元素的指针
        //var basePtr = arrayPtr.baseAddress as UnsafePointer<GLfloat>!
        
        glUniform1i(GLint(uniform_y), 0);
        glUniform1i(GLint(uniform_uv), 1);
        glUniformMatrix3fv(GLint(uniform_color_conversion_martrix), 1, GLboolean(GL_FALSE), &array);
        
    }
    
    func configureDisplayLink() {
        let displayLink = CADisplayLink.init(target: self, selector: #selector(displayLinkAction))
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    func matrixWithSize(size: CGSize, matrix: inout GLKMatrix4) -> Bool {
    
        var modelViewMatrix: GLKMatrix4  = GLKMatrix4Identity;
        modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, -(Float)(fingerRotationX));
        modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, Float(fingerRotationY));
        
        var aspect: Float = fabs(Float(size.width) / Float(size.height))
        var mvpMatrix: GLKMatrix4  = GLKMatrix4Identity;
        var projectionMatrix: GLKMatrix4 = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60), aspect, 0.1, 400.0)
        var viewMatrix: GLKMatrix4  = GLKMatrix4MakeLookAt(0, 0, 0.0, 0, 0, -1000, 0, 1, 0);
        mvpMatrix = GLKMatrix4Multiply(projectionMatrix, viewMatrix);
        mvpMatrix = GLKMatrix4Multiply(mvpMatrix, modelViewMatrix);
        
        matrix = mvpMatrix;
        
        return true;
        
    }
    
    func displayLinkAction() {
        self.display()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        let touch: UITouch = touches.first!;
        var distX: Float  = Float(touch.location(in: touch.view).x) - Float(touch.previousLocation(in: touch.view).x)
        var distY: Float = Float(touch.location(in: touch.view).y) - Float(touch.previousLocation(in: touch.view).y)
        distX *= 0.005;
        distY *= 0.005;
        fingerRotationX += distY *  60 / 100;
        fingerRotationY -= distX *  60 / 100;
    
    }

}

extension GLKMatrix4 {
    var array: [Float] {
        return (0..<16).map { i in
            self[i]
        }
    }
}
