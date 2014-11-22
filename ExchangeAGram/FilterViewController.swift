//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Andreas Seeger @MBPR on 17.11.14.
//  Copyright (c) 2014 ASSeeger. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var thisFeedItem: FeedItem!
    
    var collectionView: UICollectionView!
    
    let kIntensity: Double = 0.7
    
    var context: CIContext = CIContext(options: nil)
    
    var filters: [CIFilter] = []
    
    let placeholderImage = UIImage(named: "Placeholder")
    
    let tmp = NSTemporaryDirectory()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "MyCell")
        
        
        self.view.addSubview(collectionView)
        
        filters = photoFilter()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    // UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: FilterCell = collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as FilterCell
        
        if cell.imageView.image == nil {
            cell.imageView.image = placeholderImage
            
            let filterQueue: dispatch_queue_t = dispatch_queue_create("filter queue", nil)
            
            dispatch_async(filterQueue, { () -> Void in
                let filterImage = self.filteredImageFromImage(self.thisFeedItem.thumbnail, filter: self.filters[indexPath.row])
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.imageView.image = filterImage
                })
            })
            
        }
        
        
        
        return cell
    }
    
    // Helper function
    
    func photoFilter() ->[CIFilter] {

        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        let colorControl = CIFilter(name: "CIColorControls")
        colorControl.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControl, sepia, colorClamp, composite, vignette]
    }
    
    func filteredImageFromImage (imageData: NSData, filter:CIFilter) -> UIImage{
        
        let unfilteredImage = CIImage(data: imageData)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        let filteredImage: CIImage = filter.outputImage
        
        let extend = filteredImage.extent()
        let cgImage: CGImageRef = context.createCGImage(filteredImage, fromRect: extend)
        
        let finalImage = UIImage(CGImage: cgImage)
        
        return finalImage!
    }
    
    // Caching function
    
    func cacheImage(imageNumber: Int) {
        
        let filename = "\(imageNumber)"
        let uniquePath = tmp.stringByAppendingPathComponent(filename)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(uniquePath){
            
            let data = self.thisFeedItem.thumbnail
            let filter = self.filters[imageNumber]
            let image = filteredImageFromImage(data, filter: filter)
            
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true)
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
