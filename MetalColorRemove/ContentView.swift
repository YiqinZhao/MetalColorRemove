//
//  ContentView.swift
//  MetalColorRemove
//
//  Created by Yiqin Zhao on 10/4/20.
//

import SwiftUI
import Metal
import MetalKit
import Foundation

let device = MTLCreateSystemDefaultDevice()!
let textureLoader = MTKTextureLoader(device: device)
let colorRemove = ColorRemoveModule()


struct ContentView: View {
    static let imageWidth: Int = 400
    static let imageHeight: Int = 300
    static let emptyPlaceholder = NSImage(size: NSSize(width: imageWidth, height: imageHeight))
    
    @State var originalImage: NSImage? = nil
    @State var convertedImage: NSImage? = nil
    
    var body: some View {
        VStack {
            HStack {
                Image(nsImage: self.originalImage ?? Self.emptyPlaceholder)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: CGFloat(Self.imageWidth), height: CGFloat(Self.imageHeight), alignment: .center)
                    .padding()
                Image(nsImage: self.convertedImage ?? Self.emptyPlaceholder)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: CGFloat(Self.imageWidth), height: CGFloat(Self.imageHeight), alignment: .center)
                    .padding()
            }.padding()
            
            HStack {
                Button(action: self.onSelectFileButtonClick, label: {
                    Text("Select File")
                })
                
                Button(action: self.onConvertButtonClick, label: {
                    Text("Convert")
                })
            }.padding()
        }
    }
    
    func onSelectFileButtonClick() {
        let dialog = NSOpenPanel()
        dialog.title = "Choose a picture file"
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowedFileTypes = ["png"]
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url
            
            if (result != nil) {
                let path = result!.path
                
                self.originalImage = NSImage(contentsOfFile: path)
            }
        } else {
            print("Failed")
        }
    }
    
    func onConvertButtonClick() {
        let width: Int = Int(self.originalImage!.size.width)
        let height: Int = Int(self.originalImage!.size.height)
        
        let inTexDes: MTLTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)
        inTexDes.usage = .shaderRead
        
        let imageData = NSData(data: self.originalImage!.tiffRepresentation!)
        let inTexture = device.makeTexture(descriptor: inTexDes)!
        
        inTexture.replace(region: MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0), size: MTLSize(width: inTexture.width, height: inTexture.height, depth: 1)), mipmapLevel: 0, withBytes: imageData.bytes, bytesPerRow: 4 * inTexDes.width)
        
        let outTexDes = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)
        outTexDes.usage = [.shaderRead, .shaderWrite]
        
        let outTexture = device.makeTexture(descriptor: outTexDes)!
        
        let thredGroupSize = 32
        
        colorRemove[
            [
                (inTexture.width + thredGroupSize - 1) / thredGroupSize,
                (inTexture.height + thredGroupSize - 1) / thredGroupSize
            ],
            [thredGroupSize, thredGroupSize]
        ](inTexture: inTexture, outTexture: outTexture)
        

        let cgImage = getCGImage(from: outTexture, width: width, height: height)!
        self.convertedImage = NSImage(cgImage: cgImage, size: NSSize(width: width, height: height))
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
