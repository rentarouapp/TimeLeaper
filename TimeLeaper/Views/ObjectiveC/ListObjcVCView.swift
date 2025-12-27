//
//  ListObjcVCView.swift
//  TimeLeaper
//
//  Created by 上條蓮太朗 on 2025/12/26.
//

import SwiftUI

struct ListObjcVCView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ListObjcViewController {
        ListObjcViewController()
    }

    func updateUIViewController(
        _ uiViewController: ListObjcViewController,
        context: Context
    ) {}
}
