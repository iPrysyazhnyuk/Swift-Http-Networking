//
//  ViewController.swift
//  Swift-Http-Networking
//
//  Created by Igor Prysyazhnyuk on 06/19/2017.
//  Copyright (c) 2017 Igor Prysyazhnyuk. All rights reserved.
//

import UIKit
import Swift_Http_Networking
import ObjectMapper

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        getPosts()
        getPost(id: 1)
    }
    
    private func getPosts() {
        HTTPRequest.makeWithDictionaryResponse(route: JSONPlaceholderRouter.posts, onSuccess: { (dict, statusCode) in
            print(dict)
        }) { (error, statusCode) in
            print(error.localizedDescription)
        }
    }
    
    private func getPost(id: Int) {
        HTTPRequest.make(route: JSONPlaceholderRouter.post(id: id), onSuccess: { (post: Post) in
            print(post)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
