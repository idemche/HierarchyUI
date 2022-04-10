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


## Create Navigation Structure

Let us consider you have several `View`s:

View1 View2 View3

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
     }
}</pre></div></td>
  </tr>
</table>

where `.route(key: AnyHashable)` creates a route in `NavigationHierarchy`, and `.pushes {}` method of
View/NavigationHierarchyRoute determines which `View` is going to be pushed next from destination `View`.

## Control Navigation

To control Navigation, you need to declare Navigation EnvironmentObject inside your `View`.

<table>
  <tr>
    <th width="30%">Navigation Example</th>
    <th width="30%">How it looks</th>
  </tr>
  <tr>
    <td>Create a `View` with EnvironmentObject</td>
    <th rowspan="9"><img src="https://github.com/idemche/HierarchyUI/blob/main/docs/images/2.gif?raw=true"></th>
  </tr>
  <tr>
    <td><div class="higghlight highlight-source-swift"><pre>
struct View1: View {    
    @EnvironmentObject
    var navigation: HierarchyNavigator
    
    var body: some View {
        Button(
        action: {},
        label: {
            Text("1")
                .frame(
                    width: 100,
                    height: 100,
                    alignment: .center
                )
                .foregroundColor(.white)
        })
        .background(Color.green)
    }
}
</pre></div></td>
  </tr>
  <tr>
    <td> And then invoke push method</td>
  </tr>
  <tr>
    <td width="30%"><div class="highlight highlight-source-swift"><pre>
 struct View1: View {
    @EnvironmentObject
    var navigation: HierarchyNavigator
    
    var body: some View {
        Button(action: {
            navigation.push()
        }, label: {
            Text("1")
                .frame(
                    width: 100,
                    height: 100,
                    alignment: .center
                )
                .foregroundColor(.white)
        })
        .background(Color.green)
    }
}</pre></div></td>
  </tr>
</table> 


## Example

```swift

/// Startup
struct AppStartupNavigationHierarchy: NavigationHierarchy {
    func structure() -> NavigationHierarchyRoute {
        SplashLoadingView().route(key: "Splash").pushes {
            [
                MainScreenNavigationHierarchy().structure()
                AuthorizationFlowNavigationHierarchy().structure(),
            ]
        }
    }
}

/// Authorization Flow
struct AuthorizationFlowNavigationHierarchy: NavigationHierarchy {
    func structure() -> NavigationHierarchyRoute {
        LandingView().route(key: "Landing").pushes {
            LoginView().route(key: "Login").pushes {
                PasswordView().route(key: "Password").replaces {
                    MainScreenNavigationHierarchy().structure()
                }
            }
        }
    }
}

/// Main Screen
struct MainScreenNavigationHierarchy: NavigationHierarchy {
     func structure() -> NavigationHierarchyRoute {
        TabBarHierarchy(key: "MainTabBar", initialTabIndex: 0)
            .tab(tabBarSystemItem: .bookmarks) {
                BookmarksView().route("Bookmarks").pushes {
                    BookmarksDetailsView().route("BookmarksDetails")
                }
                .modals {
                    BookmarksTutorialView().route("Bookmarks Tutorial View")
                }
            }
            .tab(tabBarSystemItem: .contacts) {
                 ContactsView().route("Contacts").pushes {
                    ContactsDetailsView().route("ContactsDetails")
                }
                .modals {
                    ContactsTutorialView().route("Contacts Tutorial View")
                }
            }
            .tab(tabBarSystemItem: .downloads) {
                 DownloadsView().route("Downloads").pushes {
                    DownloadsDetailsView().route("DownloadsDetails")
                }
                .modals {
                    DownloadsTutorialView().route("Downloads Tutorial View")
                }
            }
            .tab(tabBarSystemItem: .favorites) {
                FavoritesView().route("Favorites").pushes {
                    FavoritesDetailsView().route("FavoritesDetails")
                }
                .modals {
                    FavoritesTutorialView().route("Favorites Tutorial View")
                }
            }
            .build()
    }
}
```

## Requirements

Swift 5.x
iOS 13.0+

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
