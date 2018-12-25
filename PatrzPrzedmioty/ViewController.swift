//
//  ViewController.swift
//  PatrzJedzenie
//
//  Created by Piotr_Brus on 23/12/2018.
//  Copyright © 2018 Piotr_Brus. All rights reserved.
//

import UIKit
import Vision
import CoreML
import ChameleonFramework

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var cameraView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            cameraView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Nie można skonwertować na CIImage")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Failed to load CoreML")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Błąd żądania")
            }
            if let firstResult = results.first {
                if firstResult.identifier.contains("pen") {
                    self.navigationItem.title = "Długopis!"
                    self.navigationController?.navigationBar.barTintColor = FlatGreen()
                    self.navigationItem.rightBarButtonItem?.tintColor = ContrastColorOf(FlatGreen(), returnFlat: true)
                } else {
                    self.navigationItem.title = "To nie jest długopis :("
                    self.navigationController?.navigationBar.barTintColor = FlatRed()
                    self.navigationItem.rightBarButtonItem?.tintColor = ContrastColorOf(FlatRed(), returnFlat: true)
                }
            }
            print(results)
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
        try handler.perform([request])
        } catch {
            print(error)
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
}

