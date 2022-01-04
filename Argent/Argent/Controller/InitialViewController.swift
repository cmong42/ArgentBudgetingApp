//
//  InitialViewController.swift
//  Argent
//
//  Created by Christine Ong on 1/2/22.
//

import Foundation
import UIKit


class InitialViewController: UIViewController{
    @IBOutlet weak var iconViewer: UIImageView!
    
    override func viewDidLoad() {
        let imageData = try? Data(contentsOf: Bundle.main.url(forResource: "play", withExtension: "gif")!)
           let advTimeGif = UIImage.gifImageWithData(imageData!)
           iconViewer.image = advTimeGif
    }
}
