//
//  ViewController.swift
//  FirestoreLargeWriteTest
//
//  Created by Adam Shaw on 2/6/19.
//  Copyright © 2019 Test Org. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var docSizeTextField: UITextField!
    @IBOutlet weak var docCountTextField: UITextField!
    @IBOutlet weak var batchDocCountTextField: UITextField!
    @IBOutlet weak var writeDelayTextField: UITextField!
    @IBOutlet weak var logTextView: UITextView!
    
    let db: Firestore
    
    required init?(coder aDecoder: NSCoder) {
        FirebaseApp.configure()
        db = Firestore.firestore()
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup defaults
        docSizeTextField.text = "100"
        docCountTextField.text = "200"
        batchDocCountTextField.text = "10"
        writeDelayTextField.text = "1.0"
    }


    @IBAction func tappedAddDocs(_ sender: Any) {
        
        // settings
        let docSize = (Int(docSizeTextField.text ?? "0") ?? 0)*1000
        let docCount = Int(docCountTextField.text ?? "0") ?? 0
        let writeDelay = Float(writeDelayTextField.text ?? "0") ?? 0.0
        
        // formatter for total byte count
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        // track total bytes and doc number
        var totalBytes = 0
        var docNum = 1
        
        // function (called recursively to add a single document
        func addDoc(remaining: Int) {
            
            // prepare new document
            let docData = ["data": Data(count: docSize)]
            let docRef = db.collection("testDocuments").document()
            
            // log
            let localDocNum = docNum
            totalBytes += docSize       // total bytes written so far
            let totalBytesString: String = numberFormatter.string(from: NSNumber(value: totalBytes)) ?? ""
            logToTextView(text: "Adding document \(localDocNum) (total bytes = \(totalBytesString))")
            
            // add document
            docRef.setData(docData) { error in
                if let error = error {
                    self.logToTextView(text: "-- ERROR document \(localDocNum) (\(error))")
                }
                else {
                    self.logToTextView(text: "-- Completed document \(localDocNum)")
                }
            }
            
            docNum += 1         // next doc num
            
            // add next doc after delay
            if remaining-1 > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(writeDelay)) {
                    addDoc(remaining: remaining-1)
                }
            }
        }
        
        // start with first doc
        addDoc(remaining: docCount)
    }
    
    @IBAction func tappedAddDocsBatch(_ sender: Any) {
        
        // settings
        let docSize = (Int(docSizeTextField.text ?? "0") ?? 0)*1000
        let docCount = Int(docCountTextField.text ?? "0") ?? 0
        let writeDelay = Float(writeDelayTextField.text ?? "0") ?? 0.0
        let batchSize = Int(batchDocCountTextField.text ?? "1") ?? 1
        
        // formatter for total byte count
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        // track total bytes and batch number
        var totalBytes = 0
        var batchNum = 1
        
        // function (called recursively to add a batch of documents)
        func addBatchDocs(remaining: Int) {
            
            // docs incuded in this batch
            let docsToBatch = min(remaining, batchSize)
            
            // setup batch and add documents to it
            let batch = db.batch()
            for _ in 0..<docsToBatch {
                let docData = ["data": Data(count: docSize)]
                let docRef = db.collection("testDocuments").document()
                batch.setData(docData, forDocument: docRef)
                totalBytes += docSize
            }
            
            // log
            let localBatchNum = batchNum
            let totalBytesString: String = numberFormatter.string(from: NSNumber(value: totalBytes)) ?? ""
            logToTextView(text: "Adding batch \(localBatchNum) (total bytes = \(totalBytesString))")
            
            // add batch documents
            batch.commit { error in
                if let error = error {
                    self.logToTextView(text: "-- ERROR batch \(localBatchNum) (\(error))")
                }
                else {
                    self.logToTextView(text: "-- Completed batch \(localBatchNum)")
                }
            }
            
            batchNum += 1
            
            // add next batch after delay
            if remaining-docsToBatch > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(writeDelay)) {
                    addBatchDocs(remaining: remaining-docsToBatch)
                }
            }
        }
        
        // start with first batch
        addBatchDocs(remaining: docCount)
    }
    
    
    /**
     Log to UI textView
     */
    func logToTextView(text: String) {
        var logText = logTextView.text ?? ""
        logText.append("\n\(text)")
        logTextView.text = logText
        logTextView.setNeedsLayout()
        logTextView.layoutIfNeeded()
        logTextView.setContentOffset(CGPoint(x: 0, y: logTextView.contentSize.height-logTextView.frame.size.height), animated: false)
    }
}

