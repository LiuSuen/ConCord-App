//
//  MapAnnotationView.swift
//  EngEn
//
//  Created by dc on 3/23/23.
//

import SwiftUI
import MapKit

struct MapAnnotationView: View{
    
    var friend: Friend
    

    var body: some View {
        if friend.highlight{
            VStack {
                Image(systemName: "mappin.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)

                Image(systemName: "arrowtriangle.down.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                        .offset(x: 0, y: -5)
            }
            .animation(.easeInOut(duration: 0.5), value: friend.highlight)
        }
        else{
            VStack {
                Image(systemName: "mappin.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)

                Image(systemName: "arrowtriangle.down.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .offset(x: 0, y: -5)
            }
            .animation(.easeInOut(duration: 0.5), value: friend.highlight)
        }
    }
}
