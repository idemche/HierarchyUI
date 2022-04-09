//
//  MainNavigationHierarchy.swift
//  HierarchyUI
//
//  Created by Ihor Demchenko on 04.04.2022.
//  Copyright © 2022 Ihor Demchenko. All rights reserved.
//

import HierarchyUI

struct MainNavigationHierarchy: NavigationHierarchy {
    func structure() -> NavigationHierarchyRoute {
        ContentView1().route(key: "1").pushes {
            ContentView2().route(key: "2").pushes {
                ContentView3().route(key: "3").pushes {
                    ContentView4().route(key: "4").pushes {
                        [
                            ContentView5().route(key: "5"),
                            ContentView6().route(key: "6").pushes {
                                ContentView8().route(key: "8").pushes {
                                    ContentView9().route(key: "9").pushes {
                                        ContentView10().route(key: "10").pushes {
                                            ContentView11().route(key: "11").replaces {
                                                TabBarHierarchy().structure()
                                            }
                                        }
                                    }
                                }
                            },
                            ContentView7().route(key: "7"),
                        ]
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
    }
}
