# HierarchyUI

[![CI Status](https://img.shields.io/travis/idemche/HierarchyUI.svg?style=flat)](https://travis-ci.org/idemche/HierarchyUI)
[![Version](https://img.shields.io/cocoapods/v/HierarchyUI.svg?style=flat)](https://cocoapods.org/pods/HierarchyUI)
[![License](https://img.shields.io/cocoapods/l/HierarchyUI.svg?style=flat)](https://cocoapods.org/pods/HierarchyUI)
[![Platform](https://img.shields.io/cocoapods/p/HierarchyUI.svg?style=flat)](https://cocoapods.org/pods/HierarchyUI)

<a href="https://github.com/apple/swift-package-manager" alt="HierarchyUI on Swift Package Manager" title="HierarchyUI on Swift Package Manager"><img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" /></a>
</p>

SwiftUI is a declarative UI layouting framework.
HierarchyUI is a declarative UI navigation construction framework.

As Apple states in its official documentation:
SwiftUI uses a declarative syntax, so you can simply state what your user interface should do.
For example, you can write that you want a list of items consisting of text fields,
then describe alignment, font, and color for each field.
Your code is simpler and easier to read than ever before, saving you time and maintenance.

SwiftUI's implementation implies that Navigation is embedded into UI layout, within NavigationLink.
That creates some limitation in terms of different architectures which tend to separate UI from business
and navigation logic.

HierarchyUI provides a way to create a readable and simple way to create a declarative Navigation structure
separately, without mixing it with UI.


## Usage

Let us consider you have several `View`s:

ContentView1 ContentView2 ContentView3

And you need to organize them into simple push/pop navigation stack.

For that, you need to create a separate `NavigationHierarchy`:

<table>
  <tr>
    <th width="30%">Here's an example</th>
    <th width="30%">Here's the initial rendering result</th>
  </tr>
  <tr>
    <td>Create a `NavigationHierarchy`</td>
    <th rowspan="9"><img src="https://raw.githubusercontent.com/idemche/HierarchyUI/main/docs/images/1.png"></th>
  </tr>
  <tr>
    <td><div class="highlight highlight-source-swift"><pre>
struct MainNavigationHierarchy: NavigationHierarchy {
    func structure() -> NavigationHierarchyRoute {
        View1().route(key: "1").pushes {
            View2().route(key: "2").pushes {
                View3().route(key: "3")
            }
        }
    }
}
</pre></div></td>
  </tr>
  <tr>
    <td> and then render this hierarchy within AppDelegate</td>
  </tr>
  <tr>
    <td width="30%"><div class="highlight highlight-source-swift"><pre>
 @UIApplicationMain
 class AppDelegate: UIResponder, UIApplicationDelegate {

     var window: UIWindow?
     
     lazy var hierarchyRenderer = NavigationHierarchyRouteRenderer()

     func application(
         _ application: UIApplication,
         didFinishLaunchingWithOptions
         launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {

         self.window = UIWindow()

         let mainHierarchy = MainNavigationHierarchy()
         window?.rootViewController = hierarchyRenderer
            .render(hierarchy: mainHierarchy)

         window?.makeKeyAndVisible()

         return true
     }</pre></div></td>
  </tr>
</table>

where `.route(key: AnyHashable)` creates a route in `NavigationHierarchy`, and `.pushes {}` method of
View/NavigationHierarchyRoute determines which `View` is going to be pushed next from destination `View`.





## Requirements

## Installation

HierarchyUI is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'HierarchyUI'
```

## Author

idemche, idemche@gmail.com

## License

HierarchyUI is available under the MIT license. See the LICENSE file for more info.
