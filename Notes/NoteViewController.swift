//
//  NoteViewController.swift
//  Notes
//
//  Created by Apple User on 17.01.2020.
//  Copyright © 2020 Alena Khoroshilova. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController{
    // variable for segue
    var note: Note!
    
    @IBOutlet var textView: UITextView!
    
    // let's bind that text that we received from the note to our textView
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = note.contents
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        note.contents = textView.text
        NoteManager.main.save(note: note)
    }
}
