//
//  TabBarHierarchy.swift
//  HierarchyUI_Example
//
//  Created by Ihor Demchenko on 09.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import HierarchyUI

struct TabBarHierarchy: NavigationHierarchy {
    func structure() -> NavigationHierarchyRoute {
        TabBarHierarchyBuilder(key: "MainTabBar", initialTabIndex: 0)
            .tab(tabBarSystemItem: .bookmarks) {
                ContentView1().route(key: "1").pushes {
                    ContentView5().route(key: "5").pushes {
                        ContentView6().route(key: "6").pushes {
                            ContentView7().route(key: "7").pushes {
                                ContentView8().route(key: "8")
                            }
                        }
                    }
                }
            }
            .tab(tabBarSystemItem: .contacts) {
                ContentView2().route(key: "2").pushes {
                    ContentView5().route(key: "5").pushes {
                        ContentView6().route(key: "6").pushes {
                            ContentView7().route(key: "7").pushes {
                                ContentView8().route(key: "8")
                            }
                        }
                    }
                }.modals {
                    ContentView12().route(key: "12").pushes {
                        ContentView13().route(key: "13").pushes {
                            ContentView14().route(key: "14")
                        }
                    }
                }
            }
            .tab(tabBarSystemItem: .downloads) {
                ContentView3().route(key: "3").pushes {
                    ContentView5().route(key: "5").pushes {
                        ContentView6().route(key: "6").pushes {
                            ContentView7().route(key: "7").pushes {
                                ContentView8().route(key: "8")
                            }
                        }
                    }
                }
            }
            .tab(tabBarSystemItem: .favorites) {
                ContentView4().route(key: "4").pushes {
                    ContentView5().route(key: "5").pushes {
                        ContentView6().route(key: "6").pushes {
                            ContentView7().route(key: "7").pushes {
                                ContentView8().route(key: "8")
                            }
                        }
                    }
                }
            }
            .build()
    }
}
