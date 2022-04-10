//
//  ExampleTabBarHierarchy.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 09.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import HierarchyUI

struct ExampleTabBarHierarchy: NavigationHierarchy {
    func structure() -> NavigationHierarchyRoute {
        TabBarHierarchy(key: "MainTabBar", initialTabIndex: 1)
            .tab(tabBarSystemItem: .bookmarks) {
                TabContentView1().route(key: "1").pushes {
                    TabContentView5().route(key: "5").pushes {
                        TabContentView6().route(key: "6").pushes {
                            TabContentView7().route(key: "7").pushes {
                                TabContentView8().route(key: "8")
                            }
                        }
                    }
                }
            }
            .tab(tabBarSystemItem: .contacts) {
                TabContentView2().route(key: "2").pushes {
                    TabContentView3().route(key: "3").pushes {
                        TabContentView4().route(key: "4").modals {
                            TabContentView12().route(key: "12").pushes {
                                TabContentView13().route(key: "13").pushes {
                                    TabContentView14().route(key: "14")
                                }
                            }
                        }
                    }
                }
            }
            .tab(tabBarSystemItem: .downloads) {
                TabContentView9().route(key: "9").pushes {
                    TabContentView10().route(key: "10").pushes {
                        TabContentView11().route(key: "11")
                    }
                }
            }
            .tab(tabBarSystemItem: .favorites) {
                TabContentView15().route(key: "15").pushes {
                    TabContentView16().route(key: "16").pushes {
                        TabContentView17().route(key: "17")
                    }
                }
            }
            .build()
    }
}
