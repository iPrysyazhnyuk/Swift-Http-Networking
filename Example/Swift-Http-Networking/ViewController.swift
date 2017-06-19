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
        HTTPRequest.make(route: JSONPlaceholderRouter.posts, onSuccess: { (arrayResponse: ArrayResponse<Post>) in
            print(arrayResponse.array)
        }) { (error) in
            print(error)
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
