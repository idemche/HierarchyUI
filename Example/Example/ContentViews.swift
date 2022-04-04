//
//  ContentViews.swift
//  NavigationUI
//
//  Created by Ihor Demchenko on 02.04.2022.
//

import SwiftUI

struct ContentView1: View {
    
    @EnvironmentObject var navigation: Navigator
    
    var body: some View {
        Button(action: {
            navigation.push()
        }, label: {
            Text("1")
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

struct ContentView2: View {
    
    @EnvironmentObject var navigation: Navigator
    
    var body: some View {
        Button(action: {
            navigation.push()
        }, label: {
            Text("2")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.green)
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

struct ContentView3: View {
    @EnvironmentObject var navigation: Navigator
    
    var body: some View {
        Button(action: {
            navigation.push()
        }, label: {
            Text("3")
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

struct ContentView4: View {
    @EnvironmentObject var navigation: Navigator

    var body: some View {
        Button(action: {
            navigation.push(key: "6")
        }, label: {
            Text("4")
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

struct ContentView5: View {
    @EnvironmentObject var navigation: Navigator

    var body: some View {
        Button(action: {
            navigation.push()
        }, label: {
            Text("5")
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

struct ContentView6: View {
    @EnvironmentObject var navigation: Navigator

    var body: some View {
        Button(action: {
            navigation.push(key: "8")
        }, label: {
            Text("6")
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

struct ContentView7: View {
    @EnvironmentObject var navigation: Navigator

    var body: some View {
        Button(action: {
            navigation.push()
        }, label: {
            Text("7")
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

struct ContentView8: View {
    @EnvironmentObject var navigation: Navigator

    var body: some View {
        Button(action: {
            navigation.push(key: "9")
        }, label: {
            Text("8")
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

struct ContentView9: View {
    @EnvironmentObject var navigation: Navigator
    
    var body: some View {
        Button(action: {
            navigation.push(key: "10")
        }, label: {
            Text("9")
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

struct ContentView10: View {
    @EnvironmentObject var navigation: Navigator
    
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


struct ContentView11: View {
    @EnvironmentObject var navigation: Navigator
    
    var body: some View {
        Button(action: {
            navigation.pop(key: "1")
        }, label: {
            Text("11 Pops to 1")
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.white)
        })
        .background(Color.green)
        Button(action: {
            navigation.replace()
        }, label: {
            Text("Replace")
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

struct ContentView12: View {
    @EnvironmentObject var navigation: Navigator
    
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

struct ContentView13: View {
    @EnvironmentObject var navigation: Navigator
    
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

struct ContentView14: View {
    @EnvironmentObject var navigation: Navigator

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

struct ContentViewReplacer: View {
    @EnvironmentObject var navigation: Navigator

    var body: some View {
        Text("Replaced")
            .foregroundColor(Color.white)
            .background(Color.green)
    }
}
