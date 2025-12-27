//
//  ListObjcVCView.swift
//  TimeLeaper
//
//  Created by 上條蓮太朗 on 2025/12/26.
//

import SwiftUI
import UIKit

struct ListObjcVCView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let listObjcVC = ListObjcViewController()
        let navigationController = UINavigationController(rootViewController: listObjcVC)
        // Optional: prefer large titles
        navigationController.navigationBar.prefersLargeTitles = false
        return navigationController
    }
    
    func updateUIViewController(
        _ uiViewController: UINavigationController,
        context: Context
    ) {}
}
