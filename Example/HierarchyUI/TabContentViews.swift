//
//  TabContentViews.swift
//  HierarchyUI_Example
//
//  Created by Ihor Demchenko on 10.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import SwiftUI

struct TabContentView1: View {
    
    @EnvironmentObject var navigation: HierarchyNavigator
    
    var body: some View {
        Button(action: {
            navigation.push(
                settings: .init(hidesBottomBarWhenPushed: true)
            )
        }, label: {
            Text("1 Push next")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.green)
        Button(action: {
            navigation.pop()
        }, label: {
            Text("pop")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.green)
    }
}

struct TabContentView2: View {
    
    @EnvironmentObject var navigation: HierarchyNavigator
    
    var body: some View {
        Button(action: {
            navigation.push()
        }, label: {
            Text("2 Push Next")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.yellow)
    }
}

struct TabContentView3: View {
    @EnvironmentObject var navigation: HierarchyNavigator
    
    var body: some View {
        Button(action: {
            navigation.push()
        }, label: {
            Text("3 Push next")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.blue)
        Button(action: {
            navigation.pop()
        }, label: {
            Text("pop")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.green)
    }
}

struct TabContentView4: View {
    @EnvironmentObject var navigation: HierarchyNavigator

    var body: some View {
        Button(action: {
            navigation.modal()
        }, label: {
            Text("4 modals")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.red)
        Button(action: {
            navigation.pop()
        }, label: {
            Text("pop")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.green)
    }
}

struct TabContentView5: View {
    @EnvironmentObject var navigation: HierarchyNavigator

    var body: some View {
        Button(action: {
            navigation.push()
        }, label: {
            Text("5 Push next")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.purple)
        Button(action: {
            navigation.pop()
        }, label: {
            Text("pop")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.green)
    }
}

struct TabContentView6: View {
    @EnvironmentObject var navigation: HierarchyNavigator

    var body: some View {
        Button(action: {
            navigation.push(key: "7")
        }, label: {
            Text("6 Push to 7")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.black)
        Button(action: {
            navigation.pop()
        }, label: {
            Text("pop")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.green)
    }
}

struct TabContentView7: View {
    @EnvironmentObject var navigation: HierarchyNavigator

    var body: some View {
        Button(action: {
            navigation.push()
        }, label: {
            Text("7 Push next")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.red)
        Button(action: {
            navigation.pop()
        }, label: {
            Text("pop")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.green)
    }
}

struct TabContentView8: View {
    @EnvironmentObject var navigation: HierarchyNavigator

    var body: some View {
        Button(action: {
            navigation.popToRoot()
        }, label: {
            Text("Pop To Root")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.orange)
        Button(action: {
            navigation.pop()
        }, label: {
            Text("pop")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.green)
    }
}

struct TabContentView12: View {
    @EnvironmentObject var navigation: HierarchyNavigator
    
    var body: some View {
        Button(action: {
            navigation.push()
        }, label: {
            Text("12 Push next")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.green)
        Button(action: {
            navigation.dismiss()
        }, label: {
            Text("Dismiss")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.green)
    }
}

struct TabContentView13: View {
    @EnvironmentObject var navigation: HierarchyNavigator
    
    var body: some View {
        Button(action: {
            navigation.push()
        }, label: {
            Text("13 Push next")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.green)
        Button(action: {
            navigation.pop()
        }, label: {
            Text("Pop")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.green)
        Button(action: {
            navigation.dismiss()
        }, label: {
            Text("Dismiss")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.green)
    }
}

struct TabContentView14: View {
    @EnvironmentObject var navigation: HierarchyNavigator

    var body: some View {
        Button(action: {
            navigation.pop(key: "12")
        }, label: {
            Text("14 Pop to 12")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.green)
        Button(action: {
            navigation.pop()
        }, label: {
            Text("Pop")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.green)
        .background(Color.green)
        Button(action: {
            navigation.dismiss()
        }, label: {
            Text("Dismiss")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.green)
    }
}

struct ViewReplacer: View {
    @EnvironmentObject var navigation: HierarchyNavigator

    var body: some View {
        Text("Replaced")
            .foregroundColor(Color.white)
            .background(Color.green)
    }
}
