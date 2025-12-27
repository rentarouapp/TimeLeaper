//
//  BaseView.swift
//  TimeLeaper
//
//  Created by 上條蓮太朗 on 2025/12/26.
//

import SwiftUI

struct BaseView: View {
    var body: some View {
        TabView {
            ObjcBaseView()
                .tabItem {
                    Label("Objc-C", systemImage: "fossil.shell")
                }
            
            Text("Swift")
                .tabItem {
                    Label("Swift", systemImage: "swift")
                }
            
            Text("SwiftUI")
                .tabItem {
                    Label("SwiftUI", systemImage: "square.3.layers.3d.top.filled")
                }
        }
    }
}

#Preview {
    BaseView()
}
