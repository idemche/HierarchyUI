//
//  ContentViews.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 02.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import SwiftUI
import HierarchyUI

struct View1: View {
    
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

struct View2: View {
    
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
        Button(action: {
            navigation.modal()
        }, label: {
            Text("modal")
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

struct View3: View {
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

struct View4: View {
    @EnvironmentObject var navigation: HierarchyNavigator

    var body: some View {
        Button(action: {
            navigation.push(key: "6")
        }, label: {
            Text("4 Push to 6")
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

struct View5: View {
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

struct View6: View {
    @EnvironmentObject var navigation: HierarchyNavigator

    var body: some View {
        Button(action: {
            navigation.push(key: "8")
        }, label: {
            Text("6 Push to 8")
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

struct View7: View {
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

struct View8: View {
    @EnvironmentObject var navigation: HierarchyNavigator

    var body: some View {
        Button(action: {
            navigation.push()
        }, label: {
            Text("8 Push Next")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.blue)
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

struct View9: View {
    @EnvironmentObject var navigation: HierarchyNavigator
    
    var body: some View {
        Button(action: {
            navigation.push(key: "10")
        }, label: {
            Text("9 Push to 10")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.gray)
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

struct View10: View {
    @EnvironmentObject var navigation: HierarchyNavigator
    
    var body: some View {
        Button(action: {
            navigation.push()
        }, label: {
            Text("10")
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


struct View11: View {
    @EnvironmentObject var navigation: HierarchyNavigator
    
    var body: some View {
        Button(action: {
            navigation.pop(key: "1")
        }, label: {
            Text("11 Pops to 1")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.red)
        Button(action: {
            navigation.replace()
        }, label: {
            Text("Replace")
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

struct View12: View {
    @EnvironmentObject var navigation: HierarchyNavigator
    
    var body: some View {
        Button(action: {
            navigation.push()
        }, label: {
            Text("12")
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

struct View13: View {
    @EnvironmentObject var navigation: HierarchyNavigator
    
    var body: some View {
        Button(action: {
            navigation.push()
        }, label: {
            Text("13")
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

struct View14: View {
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
